import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../models/feed.dart';

/// Local data source for Feed operations using Drift.
///
/// Provides CRUD operations and queries for the Feeds table.
/// All query methods support optional [accountId] parameter for multi-account data isolation.
class FeedLocalDataSource {
  final AppDatabase? _dbOverride;

  FeedLocalDataSource({AppDatabase? db}) : _dbOverride = db;

  AppDatabase get _db => _dbOverride ?? AppDatabase.instance;

  /// Inserts or updates a feed.
  Future<int> upsert(FeedsCompanion feed, {int? accountId}) async {
    var companion = feed.copyWith(updatedAt: Value(DateTime.now()));
    if (accountId != null) {
      companion = companion.copyWith(accountId: Value(accountId));
    }
    return _db.into(_db.feeds).insertOnConflictUpdate(companion);
  }

  /// Inserts or updates multiple feeds.
  Future<void> upsertAll(List<FeedsCompanion> feeds, {int? accountId}) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final feed in feeds) {
        var companion = feed.copyWith(updatedAt: Value(now));
        if (accountId != null) {
          companion = companion.copyWith(accountId: Value(accountId));
        }
        batch.insert(
          _db.feeds,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  /// Gets a feed by its ID.
  Future<Feed?> getById(int id, {int? accountId}) async {
    final query = _db.select(_db.feeds)..where((t) => t.id.equals(id));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.getSingleOrNull();
  }

  /// Gets a feed by its feed URL.
  /// When [accountId] is provided, filters by account (different accounts can subscribe to the same URL).
  Future<Feed?> getByUrl(String feedUrl, {int? accountId}) async {
    final query = _db.select(_db.feeds)
      ..where((t) => t.feedUrl.equals(feedUrl));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.getSingleOrNull();
  }

  /// Gets all feeds, optionally filtered by [accountId].
  Future<List<Feed>> getAll({int? accountId}) {
    final query = _db.select(_db.feeds);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets all feeds of a specific type, optionally filtered by [accountId].
  Future<List<Feed>> getByType(FeedType type, {int? accountId}) {
    final query = _db.select(_db.feeds)
      ..where((t) => t.type.equalsValue(type));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets all feeds in a specific folder, optionally filtered by [accountId].
  Future<List<Feed>> getByFolderId(int folderId, {int? accountId}) {
    final query = _db.select(_db.feeds)
      ..where((t) => t.folderId.equals(folderId));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets all feeds without a folder (root level), optionally filtered by [accountId].
  Future<List<Feed>> getRootFeeds({int? accountId}) {
    final query = _db.select(_db.feeds)
      ..where((t) => t.folderId.isNull());
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets the total number of feeds, optionally filtered by [accountId].
  Future<int> count({int? accountId}) async {
    final countExp = _db.feeds.id.count();
    final query = _db.selectOnly(_db.feeds)..addColumns([countExp]);
    if (accountId != null) {
      query.where(_db.feeds.accountId.equals(accountId));
    }
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

  /// Deletes all feeds for a specific account.
  Future<int> deleteByAccountId(int accountId) {
    return (_db.delete(_db.feeds)
          ..where((t) => t.accountId.equals(accountId)))
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

  /// Watches all feeds for changes, optionally filtered by [accountId].
  Stream<List<Feed>> watchAll({int? accountId}) {
    final query = _db.select(_db.feeds);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.watch();
  }

  /// Checks if a feed URL already exists, optionally scoped to [accountId].
  Future<bool> exists(String feedUrl, {int? accountId}) async {
    final feed = await getByUrl(feedUrl, accountId: accountId);
    return feed != null;
  }
}
