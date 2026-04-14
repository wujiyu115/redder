import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../models/feed_item.dart';

/// Local data source for FeedItem (article) operations using Drift.
///
/// Provides CRUD operations, queries, full-text search,
/// and pagination for the FeedItems table.
/// All query methods support optional [accountId] parameter for multi-account data isolation.
class ArticleLocalDataSource {
  final AppDatabase? _dbOverride;

  ArticleLocalDataSource({AppDatabase? db}) : _dbOverride = db;

  AppDatabase get _db => _dbOverride ?? AppDatabase.instance;

  /// Inserts or updates a feed item.
  Future<int> upsert(FeedItemsCompanion item, {int? accountId}) {
    var companion = item;
    if (accountId != null) {
      companion = companion.copyWith(accountId: Value(accountId));
    }
    return _db.into(_db.feedItems).insertOnConflictUpdate(companion);
  }

  /// Inserts or updates multiple feed items.
  ///
  /// Uses `url` as the conflict target since it has a UNIQUE constraint.
  Future<void> upsertAll(List<FeedItemsCompanion> items, {int? accountId}) async {
    await _db.batch((batch) {
      for (final item in items) {
        var companion = item;
        if (accountId != null) {
          companion = companion.copyWith(accountId: Value(accountId));
        }
        batch.insert(
          _db.feedItems,
          companion,
          onConflict: DoUpdate(
            (_) => companion,
            target: [_db.feedItems.url],
          ),
        );
      }
    });
  }

  /// Gets a feed item by its ID.
  Future<FeedItem?> getById(int id, {int? accountId}) async {
    final query = _db.select(_db.feedItems)..where((t) => t.id.equals(id));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.getSingleOrNull();
  }

  /// Gets a feed item by its URL.
  Future<FeedItem?> getByUrl(String url, {int? accountId}) async {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.url.equals(url));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.getSingleOrNull();
  }

  /// Gets all items for a specific feed, ordered by publish date descending.
  Future<List<FeedItem>> getByFeedId(
    int feedId, {
    int? limit,
    int? offset,
    int? accountId,
  }) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.feedId.equals(feedId))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Gets all items ordered by publish date descending (unified timeline).
  Future<List<FeedItem>> getAll({
    int? limit,
    int? offset,
    bool unreadOnly = false,
    int? accountId,
  }) {
    final query = _db.select(_db.feedItems)
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (unreadOnly) {
      query.where((t) => t.isRead.equals(false));
    }
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Gets items by content type.
  Future<List<FeedItem>> getByContentType(
    ContentType type, {
    int? limit,
    int? offset,
    int? accountId,
  }) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.contentType.equalsValue(type))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Gets items for multiple feed IDs (for folder timeline).
  Future<List<FeedItem>> getByFeedIds(
    List<int> feedIds, {
    int? limit,
    int? offset,
    int? accountId,
  }) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.feedId.isIn(feedIds))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Full-text search across title, optionally filtered by [accountId].
  Future<List<FeedItem>> search(String query, {int limit = 50, int? accountId}) {
    final q = _db.select(_db.feedItems)
      ..where((t) => t.title.like('%$query%'))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)])
      ..limit(limit);
    if (accountId != null) {
      q.where((t) => t.accountId.equals(accountId));
    }
    return q.get();
  }

  /// Gets the total count of items, optionally filtered by [accountId].
  Future<int> count({int? accountId}) async {
    final countExp = _db.feedItems.id.count();
    final query = _db.selectOnly(_db.feedItems)..addColumns([countExp]);
    if (accountId != null) {
      query.where(_db.feedItems.accountId.equals(accountId));
    }
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Gets the count of unread items for a specific feed.
  Future<int> unreadCountForFeed(int feedId, {int? accountId}) async {
    final countExp = _db.feedItems.id.count();
    final query = _db.selectOnly(_db.feedItems)
      ..addColumns([countExp])
      ..where(_db.feedItems.feedId.equals(feedId))
      ..where(_db.feedItems.isRead.equals(false));
    if (accountId != null) {
      query.where(_db.feedItems.accountId.equals(accountId));
    }
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Marks an item as read.
  Future<void> markAsRead(int id) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.equals(id))).write(
      const FeedItemsCompanion(isRead: Value(true)),
    );
  }

  /// Marks an item as unread.
  Future<void> markAsUnread(int id) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.equals(id))).write(
      const FeedItemsCompanion(isRead: Value(false)),
    );
  }

  /// Marks multiple items as read by their IDs.
  Future<void> markMultipleAsRead(List<int> ids) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.isIn(ids))).write(
      const FeedItemsCompanion(isRead: Value(true)),
    );
  }

  /// Marks multiple items as unread by their IDs.
  Future<void> markMultipleAsUnread(List<int> ids) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.isIn(ids))).write(
      const FeedItemsCompanion(isRead: Value(false)),
    );
  }

  /// Marks an item as starred.
  Future<void> markAsStarred(int id) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.equals(id))).write(
      const FeedItemsCompanion(isStarred: Value(true)),
    );
  }

  /// Marks an item as unstarred.
  Future<void> markAsUnstarred(int id) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.equals(id))).write(
      const FeedItemsCompanion(isStarred: Value(false)),
    );
  }

  /// Marks all items for a feed as read.
  Future<void> markAllAsReadForFeed(int feedId, {int? accountId}) async {
    final updateQuery = _db.update(_db.feedItems)
      ..where((t) => t.feedId.equals(feedId) & t.isRead.equals(false));
    if (accountId != null) {
      updateQuery.where((t) => t.accountId.equals(accountId));
    }
    await updateQuery.write(const FeedItemsCompanion(isRead: Value(true)));
  }

  /// Marks all items as read, optionally filtered by [accountId].
  Future<void> markAllAsRead({int? accountId}) async {
    final updateQuery = _db.update(_db.feedItems)
      ..where((t) => t.isRead.equals(false));
    if (accountId != null) {
      updateQuery.where((t) => t.accountId.equals(accountId));
    }
    await updateQuery.write(const FeedItemsCompanion(isRead: Value(true)));
  }

  /// Toggles the starred state of an item.
  Future<void> toggleStarred(int id) async {
    final item = await getById(id);
    if (item != null) {
      await (_db.update(_db.feedItems)..where((t) => t.id.equals(id))).write(
        FeedItemsCompanion(isStarred: Value(!item.isStarred)),
      );
    }
  }

  /// Gets all starred items, optionally filtered by [accountId].
  Future<List<FeedItem>> getStarred({int? limit, int? offset, int? accountId}) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.isStarred.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Gets all unread item IDs, optionally filtered by [accountId].
  Future<List<int>> getUnreadIds({int? accountId}) async {
    final query = _db.selectOnly(_db.feedItems)
      ..addColumns([_db.feedItems.id])
      ..where(_db.feedItems.isRead.equals(false));
    if (accountId != null) {
      query.where(_db.feedItems.accountId.equals(accountId));
    }
    final results = await query.get();
    return results.map((r) => r.read(_db.feedItems.id)!).toList();
  }

  /// Gets all starred item IDs, optionally filtered by [accountId].
  Future<List<int>> getStarredIds({int? accountId}) async {
    final query = _db.selectOnly(_db.feedItems)
      ..addColumns([_db.feedItems.id])
      ..where(_db.feedItems.isStarred.equals(true));
    if (accountId != null) {
      query.where(_db.feedItems.accountId.equals(accountId));
    }
    final results = await query.get();
    return results.map((r) => r.read(_db.feedItems.id)!).toList();
  }

  /// Deletes a feed item by its ID.
  Future<bool> delete(int id) async {
    final rows = await (_db.delete(_db.feedItems)
          ..where((t) => t.id.equals(id)))
        .go();
    return rows > 0;
  }

  /// Deletes all items for a specific feed.
  Future<void> deleteByFeedId(int feedId) async {
    await (_db.delete(_db.feedItems)
          ..where((t) => t.feedId.equals(feedId)))
        .go();
  }

  /// Deletes all items for a specific account.
  Future<int> deleteByAccountId(int accountId) async {
    return (_db.delete(_db.feedItems)
          ..where((t) => t.accountId.equals(accountId)))
        .go();
  }

  /// Deletes items older than the specified date.
  Future<int> deleteOlderThan(DateTime date) async {
    return (_db.delete(_db.feedItems)
          ..where((t) => t.publishedAt.isSmallerThanValue(date)))
        .go();
  }

  /// Watches all items for changes, optionally filtered by [accountId].
  Stream<List<FeedItem>> watchAll({int? accountId}) {
    final query = _db.select(_db.feedItems)
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.watch();
  }

  /// Watches items for a specific feed.
  Stream<List<FeedItem>> watchByFeedId(int feedId) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.feedId.equals(feedId))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    return query.watch();
  }

  /// Checks if an item URL already exists, optionally scoped to [accountId].
  Future<bool> exists(String url, {int? accountId}) async {
    final item = await getByUrl(url, accountId: accountId);
    return item != null;
  }
}
