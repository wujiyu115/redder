import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../models/feed.dart';

/// Local data source for Feed operations using Drift.
///
/// Provides CRUD operations and queries for the Feeds table.
class FeedLocalDataSource {
  AppDatabase get _db => AppDatabase.instance;

  /// Inserts or updates a feed.
  Future<int> upsert(FeedsCompanion feed) async {
    final companion = feed.copyWith(updatedAt: Value(DateTime.now()));
    return _db.into(_db.feeds).insertOnConflictUpdate(companion);
  }

  /// Inserts or updates multiple feeds.
  Future<void> upsertAll(List<FeedsCompanion> feeds) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final feed in feeds) {
        batch.insert(
          _db.feeds,
          feed.copyWith(updatedAt: Value(now)),
          onConflict: DoUpdate((_) => feed.copyWith(updatedAt: Value(now))),
        );
      }
    });
  }

  /// Gets a feed by its ID.
  Future<Feed?> getById(int id) async {
    final query = _db.select(_db.feeds)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Gets a feed by its feed URL.
  Future<Feed?> getByUrl(String feedUrl) async {
    final query = _db.select(_db.feeds)
      ..where((t) => t.feedUrl.equals(feedUrl));
    return query.getSingleOrNull();
  }

  /// Gets all feeds.
  Future<List<Feed>> getAll() {
    return _db.select(_db.feeds).get();
  }

  /// Gets all feeds of a specific type.
  Future<List<Feed>> getByType(FeedType type) {
    final query = _db.select(_db.feeds)
      ..where((t) => t.type.equalsValue(type));
    return query.get();
  }

  /// Gets all feeds in a specific folder.
  Future<List<Feed>> getByFolderId(int folderId) {
    final query = _db.select(_db.feeds)
      ..where((t) => t.folderId.equals(folderId));
    return query.get();
  }

  /// Gets all feeds without a folder (root level).
  Future<List<Feed>> getRootFeeds() {
    final query = _db.select(_db.feeds)
      ..where((t) => t.folderId.isNull());
    return query.get();
  }

  /// Gets the total number of feeds.
  Future<int> count() async {
    final countExp = _db.feeds.id.count();
    final query = _db.selectOnly(_db.feeds)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Deletes a feed by its ID.
  Future<bool> delete(int id) async {
    final rows = await (_db.delete(_db.feeds)
          ..where((t) => t.id.equals(id)))
        .go();
    return rows > 0;
  }

  /// Deletes multiple feeds by their IDs.
  Future<int> deleteAll(List<int> ids) {
    return (_db.delete(_db.feeds)
          ..where((t) => t.id.isIn(ids)))
        .go();
  }

  /// Updates the last fetched timestamp for a feed.
  Future<void> updateLastFetched(int id, {int? durationMs}) async {
    await (_db.update(_db.feeds)..where((t) => t.id.equals(id))).write(
      FeedsCompanion(
        lastFetched: Value(DateTime.now()),
        fetchDurationMs: Value(durationMs),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Updates the unread count for a feed.
  Future<void> updateUnreadCount(int id, int count) async {
    await (_db.update(_db.feeds)..where((t) => t.id.equals(id))).write(
      FeedsCompanion(unreadCount: Value(count)),
    );
  }

  /// Watches all feeds for changes (returns a stream).
  Stream<List<Feed>> watchAll() {
    return _db.select(_db.feeds).watch();
  }

  /// Checks if a feed URL already exists.
  Future<bool> exists(String feedUrl) async {
    final feed = await getByUrl(feedUrl);
    return feed != null;
  }
}
