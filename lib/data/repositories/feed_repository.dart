import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../datasources/local/feed_local_ds.dart';
import '../datasources/remote/rss_remote_ds.dart';
import '../models/feed.dart';

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

  FeedRepository({
    FeedLocalDataSource? localDs,
    RssRemoteDataSource? remoteDs,
  })  : _localDs = localDs ?? FeedLocalDataSource(),
        _remoteDs = remoteDs ?? RssRemoteDataSource();

  /// Adds a new feed subscription by URL.
  ///
  /// Fetches the feed, saves metadata and items locally.
  /// Returns the saved [Feed] with its assigned ID.
  /// Throws if the feed URL already exists.
  Future<Feed> addFeed(String feedUrl) async {
    // Check if already subscribed
    if (await _localDs.exists(feedUrl)) {
      throw Exception('Already subscribed to this feed');
    }

    // Fetch and parse the feed
    final result = await _remoteDs.fetchFeed(feedUrl);

    // Convert ParsedFeed DTO to FeedsCompanion and save
    final companion = result.feed.toCompanion();
    final feedId = await _localDs.upsert(companion);

    // Return the saved feed data
    final saved = await _localDs.getById(feedId);
    return saved!;
  }

  /// Gets all feeds.
  Future<List<Feed>> getAllFeeds() {
    return _localDs.getAll();
  }

  /// Gets a feed by its ID.
  Future<Feed?> getFeedById(int id) {
    return _localDs.getById(id);
  }

  /// Gets a feed by its URL.
  Future<Feed?> getFeedByUrl(String feedUrl) {
    return _localDs.getByUrl(feedUrl);
  }

  /// Gets all feeds of a specific type.
  Future<List<Feed>> getFeedsByType(FeedType type) {
    return _localDs.getByType(type);
  }

  /// Gets all feeds in a specific folder.
  Future<List<Feed>> getFeedsByFolder(int folderId) {
    return _localDs.getByFolderId(folderId);
  }

  /// Gets all feeds without a folder (root level).
  Future<List<Feed>> getRootFeeds() {
    return _localDs.getRootFeeds();
  }

  /// Gets the total number of feeds.
  Future<int> getFeedCount() {
    return _localDs.count();
  }

  /// Updates a feed's metadata using a [FeedsCompanion].
  Future<void> updateFeed(FeedsCompanion feed) async {
    await _localDs.upsert(feed);
  }

  /// Moves a feed to a folder.
  Future<void> moveFeedToFolder(int feedId, int? folderId) async {
    final feed = await _localDs.getById(feedId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        folderId: Value(folderId),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ));
    }
  }

  /// Updates the default viewer for a feed.
  Future<void> setDefaultViewer(int feedId, ViewerType viewer) async {
    final feed = await _localDs.getById(feedId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        defaultViewer: Value(viewer),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ));
    }
  }

  /// Toggles auto Reader View for a feed.
  Future<void> toggleAutoReaderView(int feedId) async {
    final feed = await _localDs.getById(feedId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        autoReaderView: Value(!feed.autoReaderView),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ));
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

  /// Watches all feeds for changes.
  Stream<List<Feed>> watchAllFeeds() {
    return _localDs.watchAll();
  }

  /// Checks if a feed URL is already subscribed.
  Future<bool> isSubscribed(String feedUrl) {
    return _localDs.exists(feedUrl);
  }

  /// Updates the sort order for a feed.
  Future<void> updateFeedSortOrder(int feedId, int sortOrder) async {
    final feed = await _localDs.getById(feedId);
    if (feed != null) {
      await _localDs.upsert(FeedsCompanion(
        id: Value(feed.id),
        title: Value(feed.title),
        feedUrl: Value(feed.feedUrl),
        sortOrder: Value(sortOrder),
        updatedAt: Value(DateTime.now()),
        createdAt: Value(feed.createdAt),
      ));
    }
  }

  /// Gets feeds grouped by type.
  Future<Map<FeedType, List<Feed>>> getFeedsGroupedByType() async {
    final feeds = await _localDs.getAll();
    final grouped = <FeedType, List<Feed>>{};
    for (final feed in feeds) {
      grouped.putIfAbsent(feed.type, () => []).add(feed);
    }
    return grouped;
  }
}
