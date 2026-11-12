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

  /// Inserts or updates a feed, keyed by `(account, feed URL)`.
  ///
  /// Feed URLs are unique per account — two accounts may subscribe to the same
  /// feed — so this cannot be a plain `insertOnConflictUpdate`: drift targets a
  /// single constraint, and local-mode rows carry a NULL account (NULLs never
  /// conflict in SQLite). Look the existing row up first instead.
  Future<int> upsert(FeedsCompanion feed, {int? accountId}) async {
    var companion = feed.copyWith(updatedAt: Value(DateTime.now()));
    if (accountId != null) {
      companion = companion.copyWith(accountId: Value(accountId));
    }

    final existing = await _findByUrl(companion.feedUrl.value, accountId);
    if (existing == null) {
      return _db.into(_db.feeds).insert(companion);
    }

    await (_db.update(_db.feeds)..where((t) => t.id.equals(existing.id)))
        .write(companion);
    return existing.id;
  }

  /// Inserts or updates multiple feeds. See [upsert] for the conflict rules.
  Future<void> upsertAll(List<FeedsCompanion> feeds, {int? accountId}) async {
    if (feeds.isEmpty) return;
    final now = DateTime.now();
    final byUrl = <String, FeedsCompanion>{};
    for (final feed in feeds) {
      var companion = feed.copyWith(updatedAt: Value(now));
      if (accountId != null) {
        companion = companion.copyWith(accountId: Value(accountId));
      }
      byUrl[companion.feedUrl.value] = companion;
    }

    final existingIds = <String, int>{};
    final query = _db.selectOnly(_db.feeds)
      ..addColumns([_db.feeds.id, _db.feeds.feedUrl])
      ..where(_db.feeds.feedUrl.isIn(byUrl.keys.toList()));
    query.where(accountId == null
        ? _db.feeds.accountId.isNull()
        : _db.feeds.accountId.equals(accountId));
    for (final row in await query.get()) {
      existingIds[row.read(_db.feeds.feedUrl)!] = row.read(_db.feeds.id)!;
    }

    await _db.batch((batch) {
      for (final entry in byUrl.entries) {
        final id = existingIds[entry.key];
        if (id == null) {
          batch.insert(_db.feeds, entry.value);
        } else {
          batch.update(_db.feeds, entry.value, where: (t) => t.id.equals(id));
        }
      }
    });
  }

  /// Feeds with [feedUrl] for exactly [accountId] (`null` = local-only rows).
  Future<Feed?> _findByUrl(String feedUrl, int? accountId) {
    final query = _db.select(_db.feeds)
      ..where((t) => t.feedUrl.equals(feedUrl))
      ..where((t) => accountId == null
          ? t.accountId.isNull()
          : t.accountId.equals(accountId))
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Gets a feed by its ID.
  Future<Feed?> getById(int id, {int? accountId}) async {
    final query = _db.select(_db.feeds)..where((t) => t.id.equals(id));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.getSingleOrNull();
  }

  /// Gets multiple feeds by their IDs in a single query.
  ///
  /// Avoids the N+1 pattern of calling [getById] in a loop.
  Future<List<Feed>> getByIds(List<int> ids, {int? accountId}) {
    if (ids.isEmpty) return Future.value(<Feed>[]);
    final query = _db.select(_db.feeds)..where((t) => t.id.isIn(ids));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
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
    final query = _db.select(_db.feeds)..where((t) => t.type.equalsValue(type));
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
    final query = _db.select(_db.feeds)..where((t) => t.folderId.isNull());
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
    final rows =
        await (_db.delete(_db.feeds)..where((t) => t.id.equals(id))).go();
    return rows > 0;
  }

  /// Deletes multiple feeds by their IDs.
  Future<int> deleteAll(List<int> ids) {
    return (_db.delete(_db.feeds)..where((t) => t.id.isIn(ids))).go();
  }

  /// Deletes all feeds for a specific account.
  Future<int> deleteByAccountId(int accountId) {
    return (_db.delete(_db.feeds)..where((t) => t.accountId.equals(accountId)))
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
