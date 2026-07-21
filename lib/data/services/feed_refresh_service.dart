import 'dart:async';
import 'dart:convert';

import '../../core/database/app_database.dart';
import '../../core/utils/app_logger.dart';
import '../datasources/local/feed_local_ds.dart';
import '../datasources/local/article_local_ds.dart';
import '../datasources/remote/rss_remote_ds.dart';
import '../../core/utils/html_parser.dart';
import '../repositories/settings_repository.dart';
import 'notification_service.dart';

/// Service for refreshing feed subscriptions.
///
/// Handles concurrent feed fetching with rate limiting,
/// incremental updates, deduplication, and error handling.
///
/// Uses [ParsedFeedItem] DTOs from [RssRemoteDataSource] and converts
/// them to [FeedItemsCompanion] for database storage.
class FeedRefreshService {
  static const _log = AppLogger('FeedRefresh');

  final FeedLocalDataSource _feedDs;
  final ArticleLocalDataSource _articleDs;
  final RssRemoteDataSource _remoteDs;

  /// Maximum number of concurrent feed fetches.
  static const int _maxConcurrent = 10;

  FeedRefreshService({
    FeedLocalDataSource? feedDs,
    ArticleLocalDataSource? articleDs,
    RssRemoteDataSource? remoteDs,
  })  : _feedDs = feedDs ?? FeedLocalDataSource(),
        _articleDs = articleDs ?? ArticleLocalDataSource(),
        _remoteDs = remoteDs ?? RssRemoteDataSource();

  /// Refreshes all feeds.
  ///
  /// Returns a [RefreshResult] with counts of new/updated/failed items.
  /// Uses a semaphore pattern to limit concurrent requests.
  Future<RefreshResult> refreshAll() async {
    _log.info('refreshAll: starting');
    final feeds = await _feedDs.getAll();
    final result = await _refreshFeeds(feeds);
    _log.info('refreshAll: completed — ${result.totalFeeds} feeds, ${result.newItems} new items, ${result.failedFeeds} failed');
    return result;
  }

  /// Refreshes a single feed by ID.
  Future<RefreshResult> refreshFeed(int feedId) async {
    _log.info('refreshFeed: feedId=$feedId');
    final feed = await _feedDs.getById(feedId);
    if (feed == null) {
      _log.warning('refreshFeed: feed $feedId not found');
      return RefreshResult.empty();
    }
    return _refreshFeeds([feed]);
  }

  /// Refreshes multiple feeds by IDs.
  Future<RefreshResult> refreshFeeds(List<int> feedIds) async {
    _log.info('refreshFeeds: ${feedIds.length} feed IDs');
    final feeds = await _feedDs.getByIds(feedIds);
    return _refreshFeeds(feeds);
  }

  /// Internal method to refresh a list of feeds with concurrency control.
  Future<RefreshResult> _refreshFeeds(List<Feed> feeds) async {
    _log.info('_refreshFeeds: processing ${feeds.length} feeds');
    int newItems = 0;
    int updatedFeeds = 0;
    int failedFeeds = 0;
    final errors = <String, String>{};

    // Read the app-level notifications master toggle once per batch so each
    // feed can decide whether to fire without re-querying settings per feed.
    bool appNotificationsEnabled = false;
    try {
      appNotificationsEnabled =
          (await SettingsRepository().getSettings()).notificationsEnabled;
    } catch (e) {
      _log.warning('_refreshFeeds: could not read notifications setting');
    }

    // Process feeds with concurrency limit
    final semaphore = _Semaphore(_maxConcurrent);

    final futures = feeds.map((feed) async {
      await semaphore.acquire();
      try {
        final result = await _refreshSingleFeed(feed, appNotificationsEnabled);
        newItems += result.newItemCount;
        if (result.newItemCount > 0) updatedFeeds++;
      } catch (e) {
        failedFeeds++;
        errors[feed.title] = e.toString();
      } finally {
        semaphore.release();
      }
    });

    await Future.wait(futures);

    return RefreshResult(
      totalFeeds: feeds.length,
      updatedFeeds: updatedFeeds,
      failedFeeds: failedFeeds,
      newItems: newItems,
      errors: errors,
    );
  }

  /// Refreshes a single feed: fetch, deduplicate, save new items.
  Future<_SingleFeedResult> _refreshSingleFeed(
    Feed feed,
    bool appNotificationsEnabled,
  ) async {
    _log.info('_refreshSingleFeed: fetching ${feed.title} (${feed.feedUrl})');
    final stopwatch = Stopwatch()..start();

    // Validate feedUrl before attempting to fetch
    if (!feed.feedUrl.startsWith('http://') && !feed.feedUrl.startsWith('https://')) {
      _log.error('_refreshSingleFeed: invalid feedUrl "${feed.feedUrl}" for "${feed.title}", skipping');
      stopwatch.stop();
      return _SingleFeedResult(newItemCount: 0);
    }

    try {
      final result = await _remoteDs.fetchFeed(feed.feedUrl);
      int newItemCount = 0;
      final newTitles = <String>[];

      // Deduplicate by URL against the database in a single batch query
      // (avoids an N+1 SELECT-per-item pattern).
      final candidateUrls =
          result.items.map((i) => i.url).where((u) => u.isNotEmpty).toList();
      final existing = await _articleDs.existingUrls(
        candidateUrls,
        accountId: feed.accountId,
      );

      // Process each parsed item (mutable DTO)
      final newItems = <FeedItemsCompanion>[];
      final seenUrls = <String>{};
      for (final item in result.items) {
        // Skip items with empty URL
        if (item.url.isEmpty) continue;

        // Skip duplicates within the same batch
        if (!seenUrls.add(item.url)) continue;

        // Skip if already exists in database (deduplication by URL)
        if (existing.contains(item.url)) {
          continue;
        }

        // Set feed ID
        item.feedId = feed.id;

        // Extract image if not already set
        if (item.imageUrl == null && item.content != null) {
          item.imageUrl = HtmlParser.extractFirstImageUrl(item.content!);
        }

        // Extract image URLs from content
        if (item.content != null) {
          item.imageUrls = jsonEncode(HtmlParser.extractImageUrls(item.content!));
        }

        // Calculate reading time
        if (item.content != null) {
          final words = HtmlParser.wordCount(item.content!);
          item.wordCount = words;
          item.readingTimeMinutes = (words / 200).ceil();
        }

        // Generate summary if not provided
        if (item.summary == null && item.content != null) {
          item.summary = HtmlParser.extractSummary(item.content!);
        }

        newItems.add(item.toCompanion());
        newTitles.add(item.title);
        newItemCount++;
      }

      // Batch save new items (scoped to the feed's account for isolation)
      if (newItems.isNotEmpty) {
        await _articleDs.upsertAll(newItems, accountId: feed.accountId);
      }

      // Update feed metadata
      stopwatch.stop();
      await _feedDs.updateLastFetched(
        feed.id,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      // Update unread count
      final unreadCount =
          await _articleDs.unreadCountForFeed(feed.id, accountId: feed.accountId);
      await _feedDs.updateUnreadCount(feed.id, unreadCount);

      // Fire local notifications for the new articles. The app-level master
      // toggle and the per-feed flag must both be on; the service just shows.
      if (newItemCount > 0 && appNotificationsEnabled && feed.notificationsEnabled) {
        await _notifyNewArticles(feed: feed, titles: newTitles);
      }

      _log.info('_refreshSingleFeed: ${feed.title} — $newItemCount new items in ${stopwatch.elapsedMilliseconds}ms');
      return _SingleFeedResult(newItemCount: newItemCount);
    } catch (e) {
      _log.error('_refreshSingleFeed: ${feed.title} ${feed.feedUrl} failed', error: e);
      stopwatch.stop();
      rethrow;
    }
  }

  /// Fires local notifications for newly fetched articles.
  ///
  /// ≤3 new items → one notification per article. >3 → a single summary
  /// notification ("N new articles in <feed>") to avoid spamming the user.
  Future<void> _notifyNewArticles({
    required Feed feed,
    required List<String> titles,
  }) async {
    try {
      if (titles.length <= 3) {
        for (final title in titles) {
          await NotificationService.instance.showArticleNotification(
            title: title,
            body: feed.title,
            payload: feed.id.toString(),
          );
        }
      } else {
        await NotificationService.instance.showArticleNotification(
          title: feed.title,
          body: '${titles.length} new articles',
          payload: feed.id.toString(),
        );
      }
    } catch (e) {
      _log.error('_notifyNewArticles: ${feed.title} failed', error: e);
    }
  }
}

/// Result of a feed refresh operation.
class RefreshResult {
  final int totalFeeds;
  final int updatedFeeds;
  final int failedFeeds;
  final int newItems;
  final Map<String, String> errors;

  const RefreshResult({
    required this.totalFeeds,
    required this.updatedFeeds,
    required this.failedFeeds,
    required this.newItems,
    this.errors = const {},
  });

  factory RefreshResult.empty() => const RefreshResult(
        totalFeeds: 0,
        updatedFeeds: 0,
        failedFeeds: 0,
        newItems: 0,
      );

  bool get hasErrors => failedFeeds > 0;
  bool get hasNewItems => newItems > 0;
}

class _SingleFeedResult {
  final int newItemCount;
  const _SingleFeedResult({required this.newItemCount});
}

/// Simple semaphore for concurrency control.
class _Semaphore {
  final int maxCount;
  int _currentCount = 0;
  final _waitQueue = <Completer<void>>[];

  _Semaphore(this.maxCount);

  Future<void> acquire() async {
    if (_currentCount < maxCount) {
      _currentCount++;
      return;
    }
    final completer = Completer<void>();
    _waitQueue.add(completer);
    await completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeAt(0);
      completer.complete();
    } else {
      _currentCount--;
    }
  }
}
