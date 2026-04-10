import 'package:drift/drift.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../models/feed.dart';
import '../../models/feed_item.dart';

/// Mutable DTO for building feed metadata during parsing.
///
/// Drift-generated [FeedData] is immutable, so we use this intermediate
/// class during RSS/Atom parsing, then convert to [FeedsCompanion] for storage.
class ParsedFeed {
  String title = 'Untitled Feed';
  String? description;
  String feedUrl = '';
  String? siteUrl;
  String? iconUrl;
  FeedType type = FeedType.blog;

  /// Converts to a Drift [FeedsCompanion] for database insertion.
  FeedsCompanion toCompanion() {
    final now = DateTime.now();
    return FeedsCompanion(
      title: Value(title),
      description: Value(description),
      feedUrl: Value(feedUrl),
      siteUrl: Value(siteUrl),
      iconUrl: Value(iconUrl),
      type: Value(type),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }
}

/// Mutable DTO for building feed items during parsing.
///
/// Drift-generated [FeedItemData] is immutable, so we use this intermediate
/// class during RSS/Atom parsing, then convert to [FeedItemsCompanion] for storage.
class ParsedFeedItem {
  int? feedId;
  String title = 'Untitled';
  String? summary;
  String? content;
  String url = '';
  String? imageUrl;
  String? imageUrls;
  String? audioUrl;
  String? videoUrl;
  int? audioDuration;
  String? author;
  DateTime publishedAt = DateTime.now();
  ContentType contentType = ContentType.article;
  int? wordCount;
  int? readingTimeMinutes;

  /// Converts to a Drift [FeedItemsCompanion] for database insertion.
  FeedItemsCompanion toCompanion() {
    final now = DateTime.now();
    return FeedItemsCompanion(
      feedId: Value(feedId ?? 0),
      title: Value(title),
      summary: Value(summary),
      content: Value(content),
      url: Value(url),
      imageUrl: Value(imageUrl),
      imageUrls: Value(imageUrls),
      audioUrl: Value(audioUrl),
      videoUrl: Value(videoUrl),
      audioDuration: Value(audioDuration),
      author: Value(author),
      publishedAt: Value(publishedAt),
      fetchedAt: Value(now),
      contentType: Value(contentType),
      wordCount: Value(wordCount),
      readingTimeMinutes: Value(readingTimeMinutes),
      createdAt: Value(now),
    );
  }
}

/// Remote data source for fetching and parsing RSS/Atom/JSON feeds.
///
/// Supports:
/// - RSS 2.0
/// - Atom 1.0
/// - JSON Feed 1.0/1.1
class RssRemoteDataSource {
  final DioClient _client;

  RssRemoteDataSource({DioClient? client})
      : _client = client ?? DioClient.instance;

  /// Fetches and parses a feed from the given URL.
  ///
  /// Returns a [FeedParseResult] with parsed metadata and items.
  /// Throws on network or parsing errors.
  Future<FeedParseResult> fetchFeed(String feedUrl) async {
    final content = await _client.getString(feedUrl);

    // Try parsing as RSS first, then Atom
    try {
      return _parseRss(content, feedUrl);
    } catch (_) {
      try {
        return _parseAtom(content, feedUrl);
      } catch (_) {
        throw FormatException('Unable to parse feed: $feedUrl');
      }
    }
  }

  /// Parses RSS 2.0 feed content.
  FeedParseResult _parseRss(String content, String feedUrl) {
    final rssFeed = RssFeed.parse(content);

    final feed = ParsedFeed()
      ..title = rssFeed.title ?? 'Untitled Feed'
      ..description = rssFeed.description
      ..feedUrl = feedUrl
      ..siteUrl = rssFeed.link
      ..iconUrl = rssFeed.image?.url;

    // Detect feed type based on content
    final items = <ParsedFeedItem>[];
    for (final rssItem in rssFeed.items ?? <RssItem>[]) {
      final item = ParsedFeedItem()
        ..title = rssItem.title ?? 'Untitled'
        ..summary = rssItem.description
        ..content = rssItem.content?.value
        ..url = rssItem.link ?? ''
        ..author = rssItem.author ?? rssItem.dc?.creator
        ..publishedAt = rssItem.pubDate ?? DateTime.now();

      // Check for enclosures (podcast/video)
      if (rssItem.enclosure != null) {
        final mimeType = rssItem.enclosure!.type ?? '';
        if (mimeType.startsWith('audio/')) {
          item.audioUrl = rssItem.enclosure!.url;
          item.contentType = ContentType.audio;
          feed.type = FeedType.podcast;
        } else if (mimeType.startsWith('video/')) {
          item.videoUrl = rssItem.enclosure!.url;
          item.contentType = ContentType.video;
          feed.type = FeedType.video;
        }
      }

      // Extract image from media or content
      if (rssItem.media?.thumbnails?.isNotEmpty == true) {
        item.imageUrl = rssItem.media!.thumbnails!.first.url;
      }

      // Parse iTunes duration for podcasts
      if (rssItem.itunes?.duration != null) {
        item.audioDuration = _parseDuration(
          rssItem.itunes!.duration.toString(),
        );
      }

      items.add(item);
    }

    return FeedParseResult(feed: feed, items: items);
  }

  /// Parses Atom 1.0 feed content.
  FeedParseResult _parseAtom(String content, String feedUrl) {
    final atomFeed = AtomFeed.parse(content);

    final feed = ParsedFeed()
      ..title = atomFeed.title ?? 'Untitled Feed'
      ..description = atomFeed.subtitle
      ..feedUrl = feedUrl
      ..siteUrl = atomFeed.links
          ?.firstWhere(
            (l) => l.rel == 'alternate' || l.rel == null,
            orElse: () => AtomLink('', null, null, null, null, 0),
          )
          .href
      ..iconUrl = atomFeed.icon;

    final items = <ParsedFeedItem>[];
    for (final entry in atomFeed.items ?? <AtomItem>[]) {
      final item = ParsedFeedItem()
        ..title = entry.title ?? 'Untitled'
        ..summary = entry.summary
        ..content = entry.content
        ..url = entry.links
                ?.firstWhere(
                  (l) => l.rel == 'alternate' || l.rel == null,
                  orElse: () => AtomLink('', null, null, null, null, 0),
                )
                .href ??
            ''
        ..author = entry.authors?.isNotEmpty == true
            ? entry.authors!.first.name
            : null
        ..publishedAt = (entry.published as DateTime?) ?? (entry.updated as DateTime?) ?? DateTime.now();

      items.add(item);
    }

    return FeedParseResult(feed: feed, items: items);
  }

  /// Parses a duration string (HH:MM:SS or MM:SS) into seconds.
  int _parseDuration(String duration) {
    final parts = duration.split(':').map(int.tryParse).toList();
    if (parts.length == 3) {
      return (parts[0] ?? 0) * 3600 +
          (parts[1] ?? 0) * 60 +
          (parts[2] ?? 0);
    } else if (parts.length == 2) {
      return (parts[0] ?? 0) * 60 + (parts[1] ?? 0);
    }
    return int.tryParse(duration) ?? 0;
  }
}

/// Result of parsing a feed, containing both metadata and items as mutable DTOs.
class FeedParseResult {
  /// The parsed feed metadata.
  final ParsedFeed feed;

  /// The parsed feed items.
  final List<ParsedFeedItem> items;

  const FeedParseResult({
    required this.feed,
    required this.items,
  });
}
