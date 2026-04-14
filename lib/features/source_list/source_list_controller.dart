import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/opml_parser.dart';
import '../../data/models/feed.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/services/feed_refresh_service.dart';
import '../../data/services/sync/sync_bridge.dart';
import '../../data/services/sync/sync_models.dart';
import '../../shared/providers/account_provider.dart';
import '../../shared/providers/sync_provider.dart';

/// Provider for the source list controller.
final sourceListControllerProvider =
    StateNotifierProvider<SourceListController, AsyncValue<SourceListState>>(
  (ref) => SourceListController(ref),
);

/// Provider for the feed repository.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Provider for the article repository.
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository();
});

/// Provider for the tag repository.
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

/// Provider for the feed refresh service.
final feedRefreshServiceProvider = Provider<FeedRefreshService>((ref) {
  return FeedRefreshService();
});

/// Controller for the source list page.
///
/// Manages the state of feeds, folders, tags, and their counts.
/// Handles feed refresh, subscription management, folder operations,
/// OPML import/export, and auto-grouping.
/// All operations go through [SyncBridge] for local+remote dual sync.
class SourceListController
    extends StateNotifier<AsyncValue<SourceListState>> {
  static const _log = AppLogger('SourceList');

  final Ref _ref;
  late final FeedRepository _feedRepo;
  late final ArticleRepository _articleRepo;
  late final TagRepository _tagRepo;
  late final FeedRefreshService _refreshService;
  late final SyncBridge _syncBridge;

  SourceListController(this._ref) : super(const AsyncValue.loading()) {
    _feedRepo = _ref.read(feedRepositoryProvider);
    _articleRepo = _ref.read(articleRepositoryProvider);
    _tagRepo = _ref.read(tagRepositoryProvider);
    _refreshService = _ref.read(feedRefreshServiceProvider);
    _syncBridge = _ref.read(syncBridgeProvider);
    _init();
  }

  AppDatabase get _db => AppDatabase.instance;

  /// Gets the current active account ID.
  int? get _activeAccountId => _ref.read(accountSwitchProvider);

  Future<void> _init() async {
    try {
      // Initialize built-in tags for the current account
      await _tagRepo.initializeBuiltInTags(accountId: _activeAccountId);
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Loads all data for the source list, filtered by the active account.
  Future<void> _loadData() async {
    try {
      final accountId = _activeAccountId;
      final feeds = await _feedRepo.getAllFeeds(accountId: accountId);
      final tags = await _tagRepo.getAllTags(accountId: accountId);

      // Load folders from Drift, filtered by accountId
      final folderQuery = _db.select(_db.folders)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
      if (accountId != null) {
        folderQuery.where((t) => t.accountId.equals(accountId));
      }
      final folders = await folderQuery.get();

      // Load filters from Drift, filtered by accountId
      final filterQuery = _db.select(_db.filters)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
      if (accountId != null) {
        filterQuery.where((t) => t.accountId.equals(accountId));
      }
      final filters = await filterQuery.get();

      // Group feeds by folder
      final feedsByFolder = <int, List<Feed>>{};
      final rootFeeds = <Feed>[];

      for (final feed in feeds) {
        if (feed.folderId != null) {
          feedsByFolder.putIfAbsent(feed.folderId!, () => []).add(feed);
        } else {
          rootFeeds.add(feed);
        }
      }

      // Group feeds by type (for auto-grouping display)
      final feedsByType = <FeedType, List<Feed>>{};
      for (final feed in feeds) {
        feedsByType.putIfAbsent(feed.type, () => []).add(feed);
      }

      // Calculate total unread count
      final totalUnread = feeds.fold<int>(0, (sum, f) => sum + f.unreadCount);

      state = AsyncValue.data(SourceListState(
        feeds: feeds,
        folders: folders,
        tags: tags,
        filters: filters,
        rootFeeds: rootFeeds,
        feedsByFolder: feedsByFolder,
        feedsByType: feedsByType,
        totalUnreadCount: totalUnread,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reloads all data from the local database.
  ///
  /// Called when external changes (e.g. sync account login) modify the
  /// database and the UI needs to reflect the new state.
  Future<void> reloadData() => _loadData();

  // ─── Feed Operations ──────────────────────────────────────

  /// Refreshes all feeds.
  Future<RefreshResult> refreshAll() async {
    _log.info('refreshAll: starting');
    final result = await _refreshService.refreshAll();
    await _loadData();
    return result;
  }

  /// Refreshes a single feed.
  Future<RefreshResult> refreshFeed(int feedId) async {
    _log.info('refreshFeed: feedId=$feedId');
    final result = await _refreshService.refreshFeed(feedId);
    await _loadData();
    return result;
  }

  /// Adds a new feed subscription (with remote sync).
  Future<Feed> addFeed(String feedUrl) async {
    _log.info('addFeed: feedUrl=$feedUrl');
    final feed = await _syncBridge.addFeedWithSync(feedUrl, accountId: _activeAccountId);
    await _loadData();
    return feed;
  }

  /// Deletes a feed subscription and all its articles (with remote sync).
  Future<void> deleteFeed(int feedId) async {
    _log.info('deleteFeed: feedId=$feedId');
    // Delete all articles for this feed first
    await _articleRepo.deleteArticlesByFeed(feedId);
    // Remove feed (with remote sync)
    await _syncBridge.removeFeedWithSync(feedId, accountId: _activeAccountId);
    await _loadData();
  }

  /// Renames a feed (with remote sync).
  Future<void> renameFeed(int feedId, String newTitle) async {
    await _syncBridge.renameFeedWithSync(feedId, newTitle, accountId: _activeAccountId);
    await _loadData();
  }

  /// Moves a feed to a folder (or root if folderId is null) (with remote sync).
  Future<void> moveFeedToFolder(int feedId, int? folderId) async {
    await _syncBridge.moveFeedWithSync(feedId, folderId, accountId: _activeAccountId);
    await _loadData();
  }

  /// Updates the default viewer for a feed.
  Future<void> setFeedDefaultViewer(int feedId, ViewerType viewer) async {
    await _feedRepo.setDefaultViewer(feedId, viewer);
    await _loadData();
  }

  /// Toggles auto Reader View for a feed.
  Future<void> toggleFeedAutoReaderView(int feedId) async {
    await _feedRepo.toggleAutoReaderView(feedId);
    await _loadData();
  }

  // ─── Folder Operations ────────────────────────────────────

  /// Creates a new folder (with remote sync).
  Future<Folder> createFolder(String name, {String? iconName}) async {
    final folder = await _syncBridge.createFolderWithSync(name, accountId: _activeAccountId);
    await _loadData();
    return folder;
  }

  /// Renames a folder (with remote sync).
  Future<void> renameFolder(int folderId, String newName) async {
    await _syncBridge.renameFolderWithSync(folderId, newName, accountId: _activeAccountId);
    await _loadData();
  }

  /// Deletes a folder and moves its feeds to root (with remote sync).
  Future<void> deleteFolder(int folderId) async {
    // Move all feeds in this folder to root
    final feedsInFolder = await _feedRepo.getFeedsByFolder(folderId, accountId: _activeAccountId);
    for (final feed in feedsInFolder) {
      await _syncBridge.moveFeedWithSync(feed.id, null, accountId: _activeAccountId);
    }

    // Delete the folder (with remote sync)
    await _syncBridge.deleteFolderWithSync(folderId, accountId: _activeAccountId);
    await _loadData();
  }

  /// Toggles folder expanded/collapsed state.
  Future<void> toggleFolderExpanded(int folderId) async {
    final folder = await (_db.select(_db.folders)
          ..where((t) => t.id.equals(folderId)))
        .getSingleOrNull();
    if (folder != null) {
      await (_db.update(_db.folders)..where((t) => t.id.equals(folderId)))
          .write(FoldersCompanion(isExpanded: Value(!folder.isExpanded)));
    }
    await _loadData();
  }

  /// Reorders folders by updating their sortOrder.
  ///
  /// [folderIds] is the new ordered list of folder IDs.
  Future<void> reorderFolders(List<int> folderIds) async {
    await _db.batch((batch) {
      for (int i = 0; i < folderIds.length; i++) {
        batch.update(
          _db.folders,
          FoldersCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
          where: ($FoldersTable t) => t.id.equals(folderIds[i]),
        );
      }
    });
    await _loadData();
  }

  /// Reorders feeds within a folder (or root) by updating their sortOrder.
  ///
  /// [feedIds] is the new ordered list of feed IDs.
  Future<void> reorderFeeds(List<int> feedIds) async {
    for (int i = 0; i < feedIds.length; i++) {
      await _feedRepo.updateFeedSortOrder(feedIds[i], i);
    }
    await _loadData();
  }

  // ─── Auto-Grouping ───────────────────────────────────────

  /// Auto-groups ungrouped feeds by their FeedType into folders.
  ///
  /// Creates folders named "Blogs", "Podcasts", "Videos" etc.
  /// and moves feeds of matching type into them.
  Future<void> autoGroupFeeds() async {
    final feeds = await _feedRepo.getAllFeeds();
    final ungroupedFeeds = feeds.where((f) => f.folderId == null).toList();

    if (ungroupedFeeds.isEmpty) return;

    // Group by type
    final byType = <FeedType, List<Feed>>{};
    for (final feed in ungroupedFeeds) {
      byType.putIfAbsent(feed.type, () => []).add(feed);
    }

    // Create folders and move feeds
    for (final entry in byType.entries) {
      if (entry.value.length < 2) continue; // Skip if only 1 feed of this type

      final folderName = _feedTypeFolderName(entry.key);

      // Check if folder already exists
      final existingFolder = await (_db.select(_db.folders)
            ..where((t) => t.name.equals(folderName)))
          .getSingleOrNull();

      int folderId;
      if (existingFolder != null) {
        folderId = existingFolder.id;
      } else {
        final folder = await createFolder(folderName);
        folderId = folder.id;
      }

      // Move feeds to folder
      for (final feed in entry.value) {
        await _feedRepo.moveFeedToFolder(feed.id, folderId);
      }
    }

    await _loadData();
  }

  String _feedTypeFolderName(FeedType type) {
    switch (type) {
      case FeedType.blog:
        return 'Blogs';
      case FeedType.podcast:
        return 'Podcasts';
      case FeedType.video:
        return 'Videos';
      case FeedType.mixed:
        return 'Mixed';
    }
  }

  // ─── OPML Import/Export ───────────────────────────────────

  /// Imports feeds from an OPML string.
  ///
  /// Returns the number of feeds successfully imported.
  Future<int> importOpml(String opmlContent) async {
    final outlines = OpmlParser.parse(opmlContent);
    final flatFeeds = OpmlParser.flatten(outlines);

    int imported = 0;

    // Create folders for OPML folders
    final folderMap = <String, int>{}; // folder name → folder ID

    for (final flatFeed in flatFeeds) {
      if (flatFeed.folderName != null &&
          !folderMap.containsKey(flatFeed.folderName)) {
        // Check if folder already exists
        final existing = await (_db.select(_db.folders)
              ..where((t) => t.name.equals(flatFeed.folderName!)))
            .getSingleOrNull();

        if (existing != null) {
          folderMap[flatFeed.folderName!] = existing.id;
        } else {
          final folder = await createFolder(flatFeed.folderName!);
          folderMap[flatFeed.folderName!] = folder.id;
        }
      }
    }

    // Import feeds
    for (final flatFeed in flatFeeds) {
      try {
        // Skip if already subscribed
        if (await _feedRepo.isSubscribed(flatFeed.feedUrl)) continue;

        final feed = await _feedRepo.addFeed(flatFeed.feedUrl);

        // Move to folder if applicable
        if (flatFeed.folderName != null &&
            folderMap.containsKey(flatFeed.folderName)) {
          await _feedRepo.moveFeedToFolder(
            feed.id,
            folderMap[flatFeed.folderName],
          );
        }

        imported++;
      } catch (_) {
        // Skip feeds that fail to import
        continue;
      }
    }

    await _loadData();
    return imported;
  }

  /// Exports all feeds as an OPML 2.0 string.
  Future<String> exportOpml() async {
    final feeds = await _feedRepo.getAllFeeds();
    final folders = await (_db.select(_db.folders)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    final outlines = <OpmlOutline>[];

    // Add folder outlines with their feeds
    for (final folder in folders) {
      final folderFeeds = feeds.where((f) => f.folderId == folder.id).toList();
      if (folderFeeds.isEmpty) continue;

      outlines.add(OpmlOutline(
        title: folder.name,
        isFolder: true,
        children: folderFeeds
            .map((f) => OpmlOutline(
                  title: f.title,
                  feedUrl: f.feedUrl,
                  siteUrl: f.siteUrl,
                  type: 'rss',
                ))
            .toList(),
      ));
    }

    // Add root feeds (not in any folder)
    final rootFeeds = feeds.where((f) => f.folderId == null);
    for (final feed in rootFeeds) {
      outlines.add(OpmlOutline(
        title: feed.title,
        feedUrl: feed.feedUrl,
        siteUrl: feed.siteUrl,
        type: 'rss',
      ));
    }

    return OpmlParser.generate(outlines: outlines);
  }

  // ─── Tag Operations ────────────────────────────────────

  /// Creates a new custom tag.
  Future<void> createTag(String name, {String? iconName}) async {
    await _tagRepo.createTag(name: name, iconName: iconName);
    await _loadData();
  }

  /// Renames a custom tag.
  Future<void> renameTag(int tagId, String newName) async {
    final tag = await _tagRepo.getTagById(tagId);
    if (tag != null && !tag.isBuiltIn) {
      // Use Drift update with companion since Tag is immutable
      await (_db.update(_db.tags)..where((t) => t.id.equals(tagId))).write(
        TagsCompanion(name: Value(newName)),
      );
      await _loadData();
    }
  }

  /// Deletes a custom tag and all its associations.
  Future<void> deleteTag(int tagId) async {
    await _tagRepo.deleteTag(tagId);
    await _loadData();
  }

  /// Triggers a manual sync with the remote service.
  ///
  /// Performs an incremental sync if the account has synced before,
  /// otherwise performs a full sync. Reloads data after sync completes.
  Future<SyncResult> triggerSync() async {
    _log.info('triggerSync: starting full sync');
    final result = await _syncBridge.triggerFullSync();
    _log.info('triggerSync: completed — newFeeds=${result.newFeeds}, newArticles=${result.newArticles}');
    await _loadData();
    return result;
  }

  /// Reloads the source list data.
  Future<void> reload() => _loadData();
}

/// State for the source list page.
class SourceListState {
  final List<Feed> feeds;
  final List<Folder> folders;
  final List<Tag> tags;
  final List<Filter> filters;
  final List<Feed> rootFeeds;
  final Map<int, List<Feed>> feedsByFolder;
  final Map<FeedType, List<Feed>> feedsByType;
  final int totalUnreadCount;

  const SourceListState({
    required this.feeds,
    required this.folders,
    required this.tags,
    required this.filters,
    required this.rootFeeds,
    required this.feedsByFolder,
    required this.feedsByType,
    required this.totalUnreadCount,
  });
}
