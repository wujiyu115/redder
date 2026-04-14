import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/feed.dart';
import '../../data/models/feed_item.dart';
import '../../data/models/filter_helpers.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/services/feed_refresh_service.dart';
import '../../data/services/sync/sync_bridge.dart';
import '../../shared/providers/account_provider.dart';
import '../../shared/providers/sync_provider.dart';
import '../source_list/source_list_controller.dart';

/// Provider family for article list controllers, keyed by timeline ID.
final articleListControllerProvider = StateNotifierProvider.family<
    ArticleListController, AsyncValue<ArticleListState>, String>(
  (ref, timelineId) => ArticleListController(ref, timelineId),
);

/// Controller for the article list page.
///
/// Manages article data loading, pagination, and refresh
/// for a specific timeline.
class ArticleListController
    extends StateNotifier<AsyncValue<ArticleListState>> {
  static const _log = AppLogger('ArticleList');

  final Ref _ref;
  final String timelineId;

  late final ArticleRepository _articleRepo;
  late final FeedRepository _feedRepo;
  late final TagRepository _tagRepo;
  late final FeedRefreshService _refreshService;
  late final SyncBridge _syncBridge;

  static const int _pageSize = 30;
  int _currentOffset = 0;
  bool _isLoadingMore = false;

  ArticleListController(this._ref, this.timelineId)
      : super(const AsyncValue.loading()) {
    _articleRepo = ArticleRepository();
    _feedRepo = _ref.read(feedRepositoryProvider);
    _tagRepo = _ref.read(tagRepositoryProvider);
    _refreshService = _ref.read(feedRefreshServiceProvider);
    _syncBridge = _ref.read(syncBridgeProvider);
    _loadInitial();
  }

  /// Gets the current active account ID.
  int? get _activeAccountId => _ref.read(accountSwitchProvider);

  /// Loads the initial page of articles.
  Future<void> _loadInitial() async {
    _log.info('_loadInitial: timelineId=$timelineId');
    try {
      _currentOffset = 0;
      final items = await _loadItems(offset: 0, limit: _pageSize);
      final feedMeta = await _loadFeedMetadata(items);

      state = AsyncValue.data(ArticleListState(
        items: items,
        feedTitles: feedMeta.titles,
        feedIcons: feedMeta.icons,
        hasMore: items.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Loads more articles (infinite scroll).
  Future<void> loadMore() async {
    _log.info('loadMore: offset=$_currentOffset');
    if (_isLoadingMore) return;
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore) return;

    _isLoadingMore = true;
    _currentOffset += _pageSize;

    try {
      final newItems = await _loadItems(
        offset: _currentOffset,
        limit: _pageSize,
      );
      final feedMeta = await _loadFeedMetadata(newItems);

      state = AsyncValue.data(ArticleListState(
        items: [...currentState.items, ...newItems],
        feedTitles: {...currentState.feedTitles, ...feedMeta.titles},
        feedIcons: {...currentState.feedIcons, ...feedMeta.icons},
        hasMore: newItems.length >= _pageSize,
      ));
    } catch (e) {
      // Don't replace state on load-more error, just stop loading
      _currentOffset -= _pageSize;
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refreshes the timeline (pull-to-refresh).
  ///
  /// If an active sync account exists, triggers an incremental sync
  /// to fetch new articles from the remote service.
  Future<void> refresh() async {
    _log.info('refresh: timelineId=$timelineId, activeAccountId=$_activeAccountId');
    // If there's an active sync account, trigger incremental sync
    if (_activeAccountId != null) {
      try {
        await _syncBridge.triggerIncrementalSync();
      } catch (_) {
        // Fall back to local refresh on sync failure
      }
    }
    // Refresh feeds locally
    await _refreshService.refreshAll();
    // Then reload the list
    await _loadInitial();
  }

  /// Marks all articles in the current timeline as read (with remote sync).
  Future<void> markAllAsRead() async {
    _log.info('markAllAsRead: timelineId=$timelineId');
    final accountId = _activeAccountId;
    try {
      if (timelineId == 'all') {
        await _articleRepo.markAllAsRead(accountId: accountId);
      } else if (timelineId.startsWith('feed_')) {
        final feedId = int.tryParse(timelineId.substring(5));
        if (feedId != null) {
          await _syncBridge.markFeedAsReadWithSync(feedId, accountId: accountId);
        }
      } else if (timelineId.startsWith('folder_')) {
        final folderId = int.tryParse(timelineId.substring(7));
        if (folderId != null) {
          final feeds = await _feedRepo.getFeedsByFolder(folderId, accountId: accountId);
          for (final feed in feeds) {
            await _syncBridge.markFeedAsReadWithSync(feed.id, accountId: accountId);
          }
        }
      } else {
        // For category timelines, mark all as read
        await _articleRepo.markAllAsRead(accountId: accountId);
      }
      // Reload the list to reflect changes
      await _loadInitial();
    } catch (e) {
      // Silently fail on mark-all-read errors
    }
  }

  /// Loads items based on the timeline type, filtered by active account.
  Future<List<FeedItem>> _loadItems({
    required int offset,
    required int limit,
  }) async {
    final accountId = _activeAccountId;

    if (timelineId == 'all') {
      return _articleRepo.getArticles(limit: limit, offset: offset, accountId: accountId);
    }

    if (timelineId == 'articles') {
      return _articleRepo.getArticlesByContentType(
        ContentType.article,
        limit: limit,
        offset: offset,
        accountId: accountId,
      );
    }

    if (timelineId == 'podcasts') {
      return _articleRepo.getArticlesByContentType(
        ContentType.audio,
        limit: limit,
        offset: offset,
        accountId: accountId,
      );
    }

    if (timelineId == 'videos') {
      return _articleRepo.getArticlesByContentType(
        ContentType.video,
        limit: limit,
        offset: offset,
        accountId: accountId,
      );
    }

    if (timelineId.startsWith('feed_')) {
      final feedId = int.tryParse(timelineId.substring(5));
      if (feedId != null) {
        return _articleRepo.getArticlesByFeed(
          feedId,
          limit: limit,
          offset: offset,
          accountId: accountId,
        );
      }
    }

    if (timelineId.startsWith('folder_')) {
      final folderId = int.tryParse(timelineId.substring(7));
      if (folderId != null) {
        final feeds = await _feedRepo.getFeedsByFolder(folderId, accountId: accountId);
        final feedIds = feeds.map((f) => f.id).toList();
        return _articleRepo.getArticlesByFeeds(
          feedIds,
          limit: limit,
          offset: offset,
          accountId: accountId,
        );
      }
    }

    if (timelineId.startsWith('tag_')) {
      final tagId = int.tryParse(timelineId.substring(4));
      if (tagId != null) {
        final itemIds = await _tagRepo.getItemIdsByTag(tagId, accountId: accountId);
        final items = <FeedItem>[];
        for (final id in itemIds) {
          final item = await _articleRepo.getArticleById(id, accountId: accountId);
          if (item != null) items.add(item);
        }
        items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return items.skip(offset).take(limit).toList();
      }
    }

    if (timelineId.startsWith('filter_')) {
      final filterId = int.tryParse(timelineId.substring(7));
      if (filterId != null) {
        final db = AppDatabase.instance;
        final filter = await (db.select(db.filters)
              ..where((t) => t.id.equals(filterId)))
            .getSingleOrNull();
        if (filter != null) {
          // Load a larger batch and filter in memory
          final batchSize = (offset + limit) * 3;
          final allItems = await _articleRepo.getArticles(
            limit: batchSize,
            offset: 0,
            accountId: accountId,
          );

          // Build feed type map
          final feeds = await _feedRepo.getAllFeeds(accountId: accountId);
          final feedTypeMap = <int, FeedType>{};
          for (final feed in feeds) {
            feedTypeMap[feed.id] = feed.type;
          }

          // Apply filter
          final matched = allItems.where((item) {
            final feedType = feedTypeMap[item.feedId] ?? FeedType.blog;
            return filter.matches(item, feedType);
          }).toList();

          if (offset >= matched.length) return [];
          final end = (offset + limit).clamp(0, matched.length);
          return matched.sublist(offset, end);
        }
      }
    }

    return _articleRepo.getArticles(limit: limit, offset: offset, accountId: accountId);
  }

  /// Loads feed titles and icons for the given items.
  Future<_FeedMetadata> _loadFeedMetadata(List<FeedItem> items) async {
    final titles = <int, String>{};
    final icons = <int, String?>{};
    final feedIds = items.map((i) => i.feedId).toSet();

    for (final feedId in feedIds) {
      if (!titles.containsKey(feedId)) {
        final feed = await _feedRepo.getFeedById(feedId);
        if (feed != null) {
          titles[feedId] = feed.title;
          icons[feedId] = feed.iconUrl;
        }
      }
    }

    return _FeedMetadata(titles: titles, icons: icons);
  }
}

/// State for the article list page.
class ArticleListState {
  final List<FeedItem> items;
  final Map<int, String> feedTitles;
  final Map<int, String?> feedIcons;
  final bool hasMore;

  const ArticleListState({
    required this.items,
    required this.feedTitles,
    required this.feedIcons,
    required this.hasMore,
  });
}

class _FeedMetadata {
  final Map<int, String> titles;
  final Map<int, String?> icons;

  const _FeedMetadata({required this.titles, required this.icons});
}
