import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../models/feed_item.dart';

/// Local data source for FeedItem (article) operations using Drift.
///
/// Provides CRUD operations, queries, full-text search,
/// and pagination for the FeedItems table.
class ArticleLocalDataSource {
  AppDatabase get _db => AppDatabase.instance;

  /// Inserts or updates a feed item.
  Future<int> upsert(FeedItemsCompanion item) {
    return _db.into(_db.feedItems).insertOnConflictUpdate(item);
  }

  /// Inserts or updates multiple feed items.
  Future<void> upsertAll(List<FeedItemsCompanion> items) async {
    await _db.batch((batch) {
      for (final item in items) {
        batch.insert(_db.feedItems, item, onConflict: DoUpdate((_) => item));
      }
    });
  }

  /// Gets a feed item by its ID.
  Future<FeedItem?> getById(int id) async {
    final query = _db.select(_db.feedItems)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Gets a feed item by its URL.
  Future<FeedItem?> getByUrl(String url) async {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.url.equals(url));
    return query.getSingleOrNull();
  }

  /// Gets all items for a specific feed, ordered by publish date descending.
  Future<List<FeedItem>> getByFeedId(
    int feedId, {
    int? limit,
    int? offset,
  }) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.feedId.equals(feedId))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Gets all items ordered by publish date descending (unified timeline).
  Future<List<FeedItem>> getAll({
    int? limit,
    int? offset,
    bool unreadOnly = false,
  }) {
    final query = _db.select(_db.feedItems)
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
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
  }) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.contentType.equalsValue(type))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Gets items for multiple feed IDs (for folder timeline).
  Future<List<FeedItem>> getByFeedIds(
    List<int> feedIds, {
    int? limit,
    int? offset,
  }) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.feedId.isIn(feedIds))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    if (limit != null) query.limit(limit, offset: offset ?? 0);
    return query.get();
  }

  /// Full-text search across title.
  Future<List<FeedItem>> search(String query, {int limit = 50}) {
    final q = _db.select(_db.feedItems)
      ..where((t) => t.title.like('%$query%'))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)])
      ..limit(limit);
    return q.get();
  }

  /// Gets the total count of items.
  Future<int> count() async {
    final countExp = _db.feedItems.id.count();
    final query = _db.selectOnly(_db.feedItems)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Gets the count of unread items for a specific feed.
  Future<int> unreadCountForFeed(int feedId) async {
    final countExp = _db.feedItems.id.count();
    final query = _db.selectOnly(_db.feedItems)
      ..addColumns([countExp])
      ..where(_db.feedItems.feedId.equals(feedId))
      ..where(_db.feedItems.isRead.equals(false));
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Marks an item as read.
  Future<void> markAsRead(int id) async {
    await (_db.update(_db.feedItems)..where((t) => t.id.equals(id))).write(
      const FeedItemsCompanion(isRead: Value(true)),
    );
  }

  /// Marks all items for a feed as read.
  Future<void> markAllAsReadForFeed(int feedId) async {
    await (_db.update(_db.feedItems)
          ..where((t) => t.feedId.equals(feedId) & t.isRead.equals(false)))
        .write(const FeedItemsCompanion(isRead: Value(true)));
  }

  /// Marks all items as read.
  Future<void> markAllAsRead() async {
    await (_db.update(_db.feedItems)
          ..where((t) => t.isRead.equals(false)))
        .write(const FeedItemsCompanion(isRead: Value(true)));
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

  /// Deletes items older than the specified date.
  Future<int> deleteOlderThan(DateTime date) async {
    return (_db.delete(_db.feedItems)
          ..where((t) => t.publishedAt.isSmallerThanValue(date)))
        .go();
  }

  /// Watches all items for changes.
  Stream<List<FeedItem>> watchAll() {
    final query = _db.select(_db.feedItems)
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    return query.watch();
  }

  /// Watches items for a specific feed.
  Stream<List<FeedItem>> watchByFeedId(int feedId) {
    final query = _db.select(_db.feedItems)
      ..where((t) => t.feedId.equals(feedId))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    return query.watch();
  }

  /// Checks if an item URL already exists.
  Future<bool> exists(String url) async {
    final item = await getByUrl(url);
    return item != null;
  }
}
