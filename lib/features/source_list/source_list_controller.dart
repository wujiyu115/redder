import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/opml_parser.dart';
import '../../data/models/feed.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/services/feed_refresh_service.dart';

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
class SourceListController
    extends StateNotifier<AsyncValue<SourceListState>> {
  final Ref _ref;
  late final FeedRepository _feedRepo;
  late final ArticleRepository _articleRepo;
  late final TagRepository _tagRepo;
  late final FeedRefreshService _refreshService;

  SourceListController(this._ref) : super(const AsyncValue.loading()) {
    _feedRepo = _ref.read(feedRepositoryProvider);
    _articleRepo = _ref.read(articleRepositoryProvider);
    _tagRepo = _ref.read(tagRepositoryProvider);
    _refreshService = _ref.read(feedRefreshServiceProvider);
    _init();
  }

  AppDatabase get _db => AppDatabase.instance;

  Future<void> _init() async {
    try {
      // Initialize built-in tags
      await _tagRepo.initializeBuiltInTags();
      await _loadData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Loads all data for the source list.
  Future<void> _loadData() async {
    try {
      final feeds = await _feedRepo.getAllFeeds();
      final tags = await _tagRepo.getAllTags();

      // Load folders from Drift
      final folders = await (_db.select(_db.folders)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

      // Load filters from Drift
      final filters = await (_db.select(_db.filters)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

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

  // ─── Feed Operations ──────────────────────────────────────

  /// Refreshes all feeds.
  Future<RefreshResult> refreshAll() async {
    final result = await _refreshService.refreshAll();
    await _loadData();
    return result;
  }

  /// Refreshes a single feed.
  Future<RefreshResult> refreshFeed(int feedId) async {
    final result = await _refreshService.refreshFeed(feedId);
    await _loadData();
    return result;
  }

  /// Adds a new feed subscription.
  Future<Feed> addFeed(String feedUrl) async {
    final feed = await _feedRepo.addFeed(feedUrl);
    await _loadData();
    return feed;
  }

  /// Deletes a feed subscription and all its articles.
  Future<void> deleteFeed(int feedId) async {
    // Delete all articles for this feed first
    await _articleRepo.deleteArticlesByFeed(feedId);
    // Remove all tag associations for articles of this feed
    await _feedRepo.deleteFeed(feedId);
    await _loadData();
  }

  /// Moves a feed to a folder (or root if folderId is null).
  Future<void> moveFeedToFolder(int feedId, int? folderId) async {
    await _feedRepo.moveFeedToFolder(feedId, folderId);
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

  /// Creates a new folder.
  Future<Folder> createFolder(String name, {String? iconName}) async {
    final allFolders = await _db.select(_db.folders).get();
    final maxOrder = allFolders.isEmpty
        ? 0
        : allFolders.map((f) => f.sortOrder).reduce((a, b) => a > b ? a : b);

    final now = DateTime.now();
    final id = await _db.into(_db.folders).insert(
      FoldersCompanion.insert(
        name: name,
        iconName: Value(iconName),
        sortOrder: Value(maxOrder + 1),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final folder = await (_db.select(_db.folders)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    await _loadData();
    return folder;
  }

  /// Renames a folder.
  Future<void> renameFolder(int folderId, String newName) async {
    await (_db.update(_db.folders)..where((t) => t.id.equals(folderId))).write(
      FoldersCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _loadData();
  }

  /// Deletes a folder and moves its feeds to root.
  Future<void> deleteFolder(int folderId) async {
    // Move all feeds in this folder to root
    final feedsInFolder = await _feedRepo.getFeedsByFolder(folderId);
    for (final feed in feedsInFolder) {
      await _feedRepo.moveFeedToFolder(feed.id, null);
    }

    // Delete the folder
    await (_db.delete(_db.folders)..where((t) => t.id.equals(folderId))).go();
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
