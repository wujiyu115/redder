import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../datasources/local/feed_local_ds.dart';
import '../datasources/remote/rss_remote_ds.dart';
import '../models/feed.dart';
import '../services/sync/sync_engine.dart';
import '../services/sync/sync_models.dart';

/// Repository for Feed operations.
///
/// Provides a clean API for the presentation layer to interact with
/// feed data. Coordinates between local and remote data sources.
///
/// Uses Drift-generated [Feed] (immutable) for reads and
/// [FeedsCompanion] for writes.
class FeedRepository {
  final FeedLocalDataSource _localDs;
  final RssRemoteDataSource _remoteDs;
  SyncEngine? _syncEngine;

  FeedRepository({
    FeedLocalDataSource? localDs,
    RssRemoteDataSource? remoteDs,
    SyncEngine? syncEngine,
  })  : _localDs = localDs ?? FeedLocalDataSource(),
        _remoteDs = remoteDs ?? RssRemoteDataSource(),
        _syncEngine = syncEngine;

  /// Adds a new feed subscription by URL.
  ///
  /// Fetches the feed, saves metadata and items locally.
  /// Returns the saved [Feed] with its assigned ID.
  /// Throws if the feed URL already exists for the given account.
  Future<Feed> addFeed(String feedUrl, {int? accountId}) async {
    // Check if already subscribed (scoped to account)
    if (await _localDs.exists(feedUrl, accountId: accountId)) {
      throw Exception('Already subscribed to this feed');
    }

    // Fetch and parse the feed
    final result = await _remoteDs.fetchFeed(feedUrl);

    // Convert ParsedFeed DTO to FeedsCompanion and save
    final companion = result.feed.toCompanion();
    final feedId = await _localDs.upsert(companion, accountId: accountId);

    // Return the saved feed data
    final saved = await _localDs.getById(feedId);
    return saved!;
  }

  /// Gets all feeds, optionally filtered by [accountId].
  Future<List<Feed>> getAllFeeds({int? accountId}) {
    return _localDs.getAll(accountId: accountId);
  }

  /// Gets a feed by its ID.
  Future<Feed?> getFeedById(int id, {int? accountId}) {
    return _localDs.getById(id, accountId: accountId);
  }

  /// Gets a feed by its URL, optionally scoped to [accountId].
  Future<Feed?> getFeedByUrl(String feedUrl, {int? accountId}) {
    return _localDs.getByUrl(feedUrl, accountId: accountId);
  }

  /// Gets all feeds of a specific type, optionally filtered by [accountId].
  Future<List<Feed>> getFeedsByType(FeedType type, {int? accountId}) {
    return _localDs.getByType(type, accountId: accountId);
  }

  /// Gets all feeds in a specific folder, optionally filtered by [accountId].
  Future<List<Feed>> getFeedsByFolder(int folderId, {int? accountId}) {
    return _localDs.getByFolderId(folderId, accountId: accountId);
  }

  /// Gets all feeds without a folder (root level), optionally filtered by [accountId].
  Future<List<Feed>> getRootFeeds({int? accountId}) {
    return _localDs.getRootFeeds(accountId: accountId);
  }

  /// Gets the total number of feeds, optionally filtered by [accountId].
  Future<int> getFeedCount({int? accountId}) {
    return _localDs.count(accountId: accountId);
  }

  /// Updates a feed's metadata using a [FeedsCompanion].
  Future<void> updateFeed(FeedsCompanion feed, {int? accountId}) async {
    await _localDs.upsert(feed, accountId: accountId);
  }

  /// Renames a feed.
  Future<void> renameFeed(int feedId, String newTitle, {int? accountId}) async {
    final feed = await _localDs.getById(feedId, accountId: accountId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(newTitle),
        feedUrl: Value(feed.feedUrl),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ), accountId: accountId);
    }
  }

  /// Moves a feed to a folder.
  Future<void> moveFeedToFolder(int feedId, int? folderId, {int? accountId}) async {
    final feed = await _localDs.getById(feedId, accountId: accountId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        folderId: Value(folderId),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ), accountId: accountId);
    }
  }

  /// Updates the default viewer for a feed.
  Future<void> setDefaultViewer(int feedId, ViewerType viewer, {int? accountId}) async {
    final feed = await _localDs.getById(feedId, accountId: accountId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        defaultViewer: Value(viewer),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ), accountId: accountId);
    }
  }

  /// Toggles auto Reader View for a feed.
  Future<void> toggleAutoReaderView(int feedId, {int? accountId}) async {
    final feed = await _localDs.getById(feedId, accountId: accountId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        autoReaderView: Value(!feed.autoReaderView),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ), accountId: accountId);
    }
  }

  /// Deletes a feed and all its items.
  Future<void> deleteFeed(int feedId) async {
    await _localDs.delete(feedId);
  }

  /// Deletes multiple feeds.
  Future<void> deleteFeeds(List<int> feedIds) async {
    await _localDs.deleteAll(feedIds);
  }

  /// Updates the unread count for a feed.
  Future<void> updateUnreadCount(int feedId, int count) {
    return _localDs.updateUnreadCount(feedId, count);
  }

  /// Watches all feeds for changes, optionally filtered by [accountId].
  Stream<List<Feed>> watchAllFeeds({int? accountId}) {
    return _localDs.watchAll(accountId: accountId);
  }

  /// Checks if a feed URL is already subscribed, optionally scoped to [accountId].
  Future<bool> isSubscribed(String feedUrl, {int? accountId}) {
    return _localDs.exists(feedUrl, accountId: accountId);
  }

  /// Updates the sort order for a feed.
  Future<void> updateFeedSortOrder(int feedId, int sortOrder, {int? accountId}) async {
    final feed = await _localDs.getById(feedId, accountId: accountId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        sortOrder: Value(sortOrder),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ), accountId: accountId);
    }
  }

  /// Gets feeds grouped by type, optionally filtered by [accountId].
  Future<Map<FeedType, List<Feed>>> getFeedsGroupedByType({int? accountId}) async {
    final feeds = await _localDs.getAll(accountId: accountId);
    final grouped = <FeedType, List<Feed>>{};
    for (final feed in feeds) {
      grouped.putIfAbsent(feed.type, () => []).add(feed);
    }
    return grouped;
  }

  /// Sets the sync engine for this repository.
  ///
  /// Allows the feed repository to delegate sync operations to the sync engine.
  void setSyncEngine(SyncEngine engine) {
    _syncEngine = engine;
  }

  /// Syncs all feeds using the sync engine.
  ///
  /// If a sync engine is configured, initiates a full sync operation.
  /// Returns the sync result, or null if no sync engine is available.
  Future<SyncResult?> syncFeeds() async {
    if (_syncEngine == null) {
      return null;
    }
    return await _syncEngine!.sync();
  }

  /// Syncs a single feed using the sync engine.
  ///
  /// If a sync engine is configured, initiates a sync operation for the specified feed.
  /// Returns the sync result, or null if no sync engine is available.
  Future<SyncResult?> syncSingleFeed(int feedId) async {
    if (_syncEngine == null) {
      return null;
    }
    return await _syncEngine!.syncFeed(feedId);
  }
}