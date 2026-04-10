import '../../core/database/app_database.dart';
import '../datasources/local/article_local_ds.dart';
import '../models/feed_item.dart';

/// Repository for FeedItem (article) operations.
///
/// Provides a clean API for the presentation layer to interact with
/// article data. Handles pagination, filtering, and read state management.
///
/// Uses Drift-generated [FeedItem] (immutable) for reads and
/// [FeedItemsCompanion] for writes.
class ArticleRepository {
  final ArticleLocalDataSource _localDs;

  ArticleRepository({ArticleLocalDataSource? localDs})
      : _localDs = localDs ?? ArticleLocalDataSource();

  // ─── Read Operations ──────────────────────────────────────

  /// Gets a single article by ID.
  Future<FeedItem?> getArticleById(int id) {
    return _localDs.getById(id);
  }

  /// Gets a single article by URL.
  Future<FeedItem?> getArticleByUrl(String url) {
    return _localDs.getByUrl(url);
  }

  /// Gets all articles (unified timeline) with pagination.
  Future<List<FeedItem>> getArticles({
    int? limit,
    int? offset,
    bool unreadOnly = false,
  }) {
    return _localDs.getAll(
      limit: limit,
      offset: offset,
      unreadOnly: unreadOnly,
    );
  }

  /// Gets articles for a specific feed with pagination.
  Future<List<FeedItem>> getArticlesByFeed(
    int feedId, {
    int? limit,
    int? offset,
  }) {
    return _localDs.getByFeedId(feedId, limit: limit, offset: offset);
  }

  /// Gets articles by content type (for category timelines).
  Future<List<FeedItem>> getArticlesByContentType(
    ContentType type, {
    int? limit,
    int? offset,
  }) {
    return _localDs.getByContentType(type, limit: limit, offset: offset);
  }

  /// Gets articles for multiple feeds (for folder timelines).
  Future<List<FeedItem>> getArticlesByFeeds(
    List<int> feedIds, {
    int? limit,
    int? offset,
  }) {
    return _localDs.getByFeedIds(feedIds, limit: limit, offset: offset);
  }

  /// Searches articles by title.
  Future<List<FeedItem>> searchArticles(String query, {int limit = 50}) {
    return _localDs.search(query, limit: limit);
  }

  /// Gets the total article count.
  Future<int> getArticleCount() {
    return _localDs.count();
  }

  /// Gets the unread count for a specific feed.
  Future<int> getUnreadCount(int feedId) {
    return _localDs.unreadCountForFeed(feedId);
  }

  // ─── Write Operations ─────────────────────────────────────

  /// Saves a single article.
  Future<int> saveArticle(FeedItemsCompanion item) {
    return _localDs.upsert(item);
  }

  /// Saves multiple articles (used during feed refresh).
  Future<void> saveArticles(List<FeedItemsCompanion> items) {
    return _localDs.upsertAll(items);
  }

  /// Marks an article as read.
  Future<void> markAsRead(int id) {
    return _localDs.markAsRead(id);
  }

  /// Marks all articles for a feed as read.
  Future<void> markAllAsReadForFeed(int feedId) {
    return _localDs.markAllAsReadForFeed(feedId);
  }

  /// Marks all articles as read.
  Future<void> markAllAsRead() {
    return _localDs.markAllAsRead();
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

  /// Watches all articles for changes.
  Stream<List<FeedItem>> watchAllArticles() {
    return _localDs.watchAll();
  }

  /// Watches articles for a specific feed.
  Stream<List<FeedItem>> watchArticlesByFeed(int feedId) {
    return _localDs.watchByFeedId(feedId);
  }

  // ─── Helpers ──────────────────────────────────────────────

  /// Checks if an article URL already exists.
  Future<bool> articleExists(String url) {
    return _localDs.exists(url);
  }
}
