import '../../core/database/app_database.dart';
import '../datasources/local/article_local_ds.dart';
import '../models/feed_item.dart';

/// Repository for FeedItem (article) operations.
///
/// Provides a clean API for the presentation layer to interact with
/// article data. Handles pagination, filtering, and read state management.
/// All methods support optional [accountId] for multi-account data isolation.
///
/// Uses Drift-generated [FeedItem] (immutable) for reads and
/// [FeedItemsCompanion] for writes.
class ArticleRepository {
  final ArticleLocalDataSource _localDs;

  ArticleRepository({ArticleLocalDataSource? localDs})
      : _localDs = localDs ?? ArticleLocalDataSource();

  // ─── Read Operations ──────────────────────────────────────

  /// Gets a single article by ID.
  Future<FeedItem?> getArticleById(int id, {int? accountId}) {
    return _localDs.getById(id, accountId: accountId);
  }

  /// Gets a single article by URL.
  Future<FeedItem?> getArticleByUrl(String url, {int? accountId}) {
    return _localDs.getByUrl(url, accountId: accountId);
  }

  /// Gets all articles (unified timeline) with pagination.
  Future<List<FeedItem>> getArticles({
    int? limit,
    int? offset,
    bool unreadOnly = false,
    bool oldestFirst = false,
    int? accountId,
  }) {
    return _localDs.getAll(
      limit: limit,
      offset: offset,
      unreadOnly: unreadOnly,
      oldestFirst: oldestFirst,
      accountId: accountId,
    );
  }

  /// Gets articles for a specific feed with pagination.
  Future<List<FeedItem>> getArticlesByFeed(
    int feedId, {
    int? limit,
    int? offset,
    bool unreadOnly = false,
    bool oldestFirst = false,
    int? accountId,
  }) {
    return _localDs.getByFeedId(feedId, limit: limit, offset: offset, unreadOnly: unreadOnly, oldestFirst: oldestFirst, accountId: accountId);
  }

  /// Gets articles by content type (for category timelines).
  Future<List<FeedItem>> getArticlesByContentType(
    ContentType type, {
    int? limit,
    int? offset,
    bool unreadOnly = false,
    bool oldestFirst = false,
    int? accountId,
  }) {
    return _localDs.getByContentType(type, limit: limit, offset: offset, unreadOnly: unreadOnly, oldestFirst: oldestFirst, accountId: accountId);
  }

  /// Gets articles for multiple feeds (for folder timelines).
  Future<List<FeedItem>> getArticlesByFeeds(
    List<int> feedIds, {
    int? limit,
    int? offset,
    bool unreadOnly = false,
    bool oldestFirst = false,
    int? accountId,
  }) {
    return _localDs.getByFeedIds(feedIds, limit: limit, offset: offset, unreadOnly: unreadOnly, oldestFirst: oldestFirst, accountId: accountId);
  }

  /// Searches articles by title, optionally filtered by [accountId].
  Future<List<FeedItem>> searchArticles(String query, {int limit = 50, int? accountId}) {
    return _localDs.search(query, limit: limit, accountId: accountId);
  }

  /// Gets the total article count, optionally filtered by [accountId].
  Future<int> getArticleCount({int? accountId}) {
    return _localDs.count(accountId: accountId);
  }

  /// Gets the unread count for a specific feed.
  Future<int> getUnreadCount(int feedId, {int? accountId}) {
    return _localDs.unreadCountForFeed(feedId, accountId: accountId);
  }

  /// Gets unread counts for multiple feeds in a single query.
  ///
  /// Returns a map of `feedId -> unread count` for feeds with at least one
  /// unread item. Missing feedIds should be treated as 0.
  Future<Map<int, int>> getUnreadCounts(Set<int> feedIds, {int? accountId}) {
    return _localDs.unreadCountsForFeeds(feedIds, accountId: accountId);
  }

  /// Gets multiple articles by ID in a single query, ordered by publish date
  /// descending.
  Future<List<FeedItem>> getArticlesByIds(
    List<int> ids, {
    int offset = 0,
    int limit = 50,
    required int? accountId,
  }) {
    return _localDs.getByIds(ids, offset: offset, limit: limit, accountId: accountId);
  }

  /// Resolves the next (older) article id in the same timeline scope,
  /// published before [currentId]. See [ArticleLocalDataSource.getNextArticleId]
  /// for supported [timelineId] prefixes.
  Future<int?> getNextArticleId(
    int currentId, {
    required String timelineId,
    required int? accountId,
  }) {
    return _localDs.getNextArticleId(
      currentId,
      timelineId: timelineId,
      accountId: accountId,
    );
  }

  /// Gets all starred articles, optionally filtered by [accountId].
  Future<List<FeedItem>> getStarredArticles({int? limit, int? offset, int? accountId}) {
    return _localDs.getStarred(limit: limit, offset: offset, accountId: accountId);
  }

  /// Gets all unread article IDs, optionally filtered by [accountId].
  Future<List<int>> getUnreadArticleIds({int? accountId}) {
    return _localDs.getUnreadIds(accountId: accountId);
  }

  /// Gets all starred article IDs, optionally filtered by [accountId].
  Future<List<int>> getStarredArticleIds({int? accountId}) {
    return _localDs.getStarredIds(accountId: accountId);
  }

  // ─── Write Operations ─────────────────────────────────────

  /// Saves a single article.
  Future<int> saveArticle(FeedItemsCompanion item, {int? accountId}) {
    return _localDs.upsert(item, accountId: accountId);
  }

  /// Saves multiple articles (used during feed refresh).
  Future<void> saveArticles(List<FeedItemsCompanion> items, {int? accountId}) {
    return _localDs.upsertAll(items, accountId: accountId);
  }

  /// Marks an article as read.
  Future<void> markAsRead(int id) {
    return _localDs.markAsRead(id);
  }

  /// Marks an article as unread.
  Future<void> markAsUnread(int id) {
    return _localDs.markAsUnread(id);
  }

  /// Marks multiple articles as read.
  Future<void> markMultipleAsRead(List<int> ids) {
    return _localDs.markMultipleAsRead(ids);
  }

  /// Marks multiple articles as unread.
  Future<void> markMultipleAsUnread(List<int> ids) {
    return _localDs.markMultipleAsUnread(ids);
  }

  /// Marks an article as starred.
  Future<void> markAsStarred(int id) {
    return _localDs.markAsStarred(id);
  }

  /// Marks an article as unstarred.
  Future<void> markAsUnstarred(int id) {
    return _localDs.markAsUnstarred(id);
  }

  /// Marks all articles for a feed as read, optionally scoped to [accountId].
  Future<void> markAllAsReadForFeed(int feedId, {int? accountId}) {
    return _localDs.markAllAsReadForFeed(feedId, accountId: accountId);
  }

  /// Marks all articles as read, optionally scoped to [accountId].
  ///
  /// Pass [itemIds] to restrict to a specific set of articles, and/or
  /// [contentType] (timeline name or enum name) to restrict by content type.
  /// With no scope args, marks every unread item in the account (backward
  /// compatible with the original no-arg call).
  Future<void> markAllAsRead({
    int? accountId,
    List<int>? itemIds,
    String? contentType,
  }) {
    return _localDs.markAllAsRead(
      accountId: accountId,
      itemIds: itemIds,
      contentType: contentType,
    );
  }

  /// Toggles the starred state of an article.
  Future<void> toggleStarred(int id) {
    return _localDs.toggleStarred(id);
  }

  // ─── Delete Operations ────────────────────────────────────

  /// Deletes a single article.
  Future<bool> deleteArticle(int id) {
    return _localDs.delete(id);
  }

  /// Deletes all articles for a specific feed.
  Future<void> deleteArticlesByFeed(int feedId) {
    return _localDs.deleteByFeedId(feedId);
  }

  /// Deletes articles older than the specified number of days.
  Future<int> deleteOldArticles(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _localDs.deleteOlderThan(cutoff);
  }

  // ─── Streams ──────────────────────────────────────────────

  /// Watches all articles for changes, optionally filtered by [accountId].
  Stream<List<FeedItem>> watchAllArticles({int? accountId}) {
    return _localDs.watchAll(accountId: accountId);
  }

  /// Watches articles for a specific feed.
  Stream<List<FeedItem>> watchArticlesByFeed(int feedId) {
    return _localDs.watchByFeedId(feedId);
  }

  // ─── Helpers ──────────────────────────────────────────────

  /// Checks if an article URL already exists, optionally scoped to [accountId].
  Future<bool> articleExists(String url, {int? accountId}) {
    return _localDs.exists(url, accountId: accountId);
  }
}
