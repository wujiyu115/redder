import '../datasources/remote/rss_remote_ds.dart';
import '../models/feed.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/html_parser.dart';

/// Service for discovering RSS/Atom/JSON feeds from a URL.
///
/// Given a URL, attempts to:
/// 1. Parse it directly as a feed
/// 2. Fetch the HTML page and look for feed link tags
/// 3. Try common feed URL patterns
class FeedDiscoveryService {
  final DioClient _client;
  final RssRemoteDataSource _remoteDs;

  FeedDiscoveryService({
    DioClient? client,
    RssRemoteDataSource? remoteDs,
  })  : _client = client ?? DioClient.instance,
        _remoteDs = remoteDs ?? RssRemoteDataSource();

  /// Discovers feeds from a given URL.
  ///
  /// Returns a list of [DiscoveredFeedInfo] with feed metadata.
  /// The list may contain multiple feeds if the page links to several.
  Future<List<DiscoveredFeedInfo>> discover(String url) async {
    final normalizedUrl = _normalizeUrl(url);
    final results = <DiscoveredFeedInfo>[];

    // Strategy 1: Try parsing the URL directly as a feed
    try {
      final result = await _remoteDs.fetchFeed(normalizedUrl);
      results.add(DiscoveredFeedInfo(
        feedUrl: normalizedUrl,
        title: result.feed.title,
        description: result.feed.description,
        type: result.feed.type,
        itemCount: result.items.length,
      ));
      return results; // Direct feed URL, no need to search further
    } catch (_) {
      // Not a direct feed URL, continue with discovery
    }

    // Strategy 2: Fetch HTML and look for feed link tags
    try {
      final html = await _client.getString(normalizedUrl);
      final discoveredFeeds = HtmlParser.discoverFeeds(html);

      for (final discovered in discoveredFeeds) {
        final feedUrl = _resolveUrl(discovered.url, normalizedUrl);
        try {
          final result = await _remoteDs.fetchFeed(feedUrl);
          results.add(DiscoveredFeedInfo(
            feedUrl: feedUrl,
            title: discovered.title.isNotEmpty
                ? discovered.title
                : result.feed.title,
            description: result.feed.description,
            type: result.feed.type,
            itemCount: result.items.length,
          ));
        } catch (_) {
          // Feed URL found but couldn't be parsed, skip
        }
      }
    } catch (_) {
      // Couldn't fetch the page
    }

    // Strategy 3: Try common feed URL patterns
    if (results.isEmpty) {
      final commonPaths = [
        '/feed',
        '/feed/',
        '/rss',
        '/rss/',
        '/atom.xml',
        '/feed.xml',
        '/rss.xml',
        '/index.xml',
        '/feed/atom',
        '/feed/rss',
        '/.rss',
      ];

      final baseUri = Uri.tryParse(normalizedUrl);
      if (baseUri != null) {
        for (final path in commonPaths) {
          final feedUrl = '${baseUri.scheme}://${baseUri.host}$path';
          try {
            final result = await _remoteDs.fetchFeed(feedUrl);
            results.add(DiscoveredFeedInfo(
              feedUrl: feedUrl,
              title: result.feed.title,
              description: result.feed.description,
              type: result.feed.type,
              itemCount: result.items.length,
            ));
            break; // Found one, stop trying
          } catch (_) {
            continue;
          }
        }
      }
    }

    return results;
  }

  /// Normalizes a URL by adding scheme if missing.
  String _normalizeUrl(String url) {
    var normalized = url.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    return normalized;
  }

  /// Resolves a potentially relative URL against a base URL.
  String _resolveUrl(String url, String baseUrl) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final base = Uri.tryParse(baseUrl);
    if (base == null) return url;
    return base.resolve(url).toString();
  }
}

/// Information about a discovered feed.
class DiscoveredFeedInfo {
  /// The feed URL.
  final String feedUrl;

  /// The feed title.
  final String title;

  /// The feed description.
  final String? description;

  /// The detected feed type.
  final FeedType type;

  /// Number of items found in the feed.
  final int itemCount;

  const DiscoveredFeedInfo({
    required this.feedUrl,
    required this.title,
    this.description,
    this.type = FeedType.blog,
    this.itemCount = 0,
  });
}
