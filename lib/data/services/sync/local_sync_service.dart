import '../../../data/datasources/local/feed_local_ds.dart';
import '../../../data/datasources/local/article_local_ds.dart';
import '../../../data/datasources/remote/rss_remote_ds.dart';
import '../feed_refresh_service.dart';
import 'sync_models.dart';
import 'sync_service.dart';

/// Local sync service implementation.
///
/// Wraps the existing [FeedRefreshService] and local data sources
/// to conform to the [SyncService] interface. This serves as the
/// default "no remote sync" mode where feeds are fetched directly
/// from their RSS/Atom/JSON Feed URLs.
///
/// This implementation does not require authentication and always
/// reports as authenticated.
class LocalSyncService extends SyncService {
  final FeedLocalDataSource _feedDs;
  final ArticleLocalDataSource _articleDs;
  final FeedRefreshService _refreshService;

  LocalSyncService({
    FeedLocalDataSource? feedDs,
    ArticleLocalDataSource? articleDs,
    FeedRefreshService? refreshService,
  })  : _feedDs = feedDs ?? FeedLocalDataSource(),
        _articleDs = articleDs ?? ArticleLocalDataSource(),
        _refreshService = refreshService ?? FeedRefreshService();

  // ─── Service Identity ───────────────────────────────────────────────

  @override
  SyncServiceType get serviceType => SyncServiceType.local;

  @override
  String get serviceName => 'Local';

  @override
  String get serviceIcon => 'rss_feed';

  // ─── Authentication ─────────────────────────────────────────────────

  @override
  Future<bool> authenticate(SyncCredentials credentials) async => true;

  @override
  Future<void> logout() async {}

  @override
  bool get isAuthenticated => true;

  @override
  Future<bool> validateCredentials() async => true;

  // ─── Subscription Management ────────────────────────────────────────

  @override
  Future<List<SyncFeed>> getFeeds() async {
    final feeds = await _feedDs.getAll();
    return feeds
        .map((f) => SyncFeed(
              remoteId: f.id.toString(),
              title: f.title,
              feedUrl: f.feedUrl,
              siteUrl: f.siteUrl,
              iconUrl: f.iconUrl,
              folderId: f.folderId?.toString(),
              description: f.description,
            ))
        .toList();
  }

  @override
  Future<SyncFeed> addFeed(String feedUrl, {String? title, String? folderId}) async {
    final remoteDs = RssRemoteDataSource();
    final result = await remoteDs.fetchFeed(feedUrl);
    final companion = result.feed.toCompanion();
    final feedId = await _feedDs.upsert(companion);
    final saved = await _feedDs.getById(feedId);

    return SyncFeed(
      remoteId: feedId.toString(),
      title: saved?.title ?? result.feed.title,
      feedUrl: feedUrl,
      siteUrl: saved?.siteUrl,
      iconUrl: saved?.iconUrl,
    );
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {
    final id = int.tryParse(feedRemoteId);
    if (id != null) {
      await _articleDs.deleteByFeedId(id);
      await _feedDs.delete(id);
    }
  }

  @override
  Future<void> renameFeed(String feedRemoteId, String newTitle) async {
    // Handled locally via FeedRepository
  }

  @override
  Future<void> moveFeed(String feedRemoteId, String? folderId) async {
    // Handled locally via FeedRepository
  }

  // ─── Folder/Category Management ─────────────────────────────────────

  @override
  Future<List<SyncFolder>> getFolders() async {
    // Local folders are managed directly via the database
    return [];
  }

  @override
  Future<SyncFolder> createFolder(String name) async {
    // Handled locally
    return SyncFolder(remoteId: '', name: name);
  }

  @override
  Future<void> deleteFolder(String folderRemoteId) async {
    // Handled locally
  }

  @override
  Future<void> renameFolder(String folderRemoteId, String newName) async {
    // Handled locally
  }

  // ─── Article Retrieval ──────────────────────────────────────────────

  @override
  Future<List<SyncArticle>> getArticles({DateTime? since, int? limit}) async {
    final items = await _articleDs.getAll(limit: limit);
    return items
        .map((item) => SyncArticle(
              remoteId: item.id.toString(),
              feedRemoteId: item.feedId.toString(),
              title: item.title,
              summary: item.summary,
              content: item.content,
              url: item.url,
              author: item.author,
              publishedAt: item.publishedAt,
              isRead: item.isRead,
              isStarred: item.isStarred,
              imageUrl: item.imageUrl,
              audioUrl: item.audioUrl,
              videoUrl: item.videoUrl,
              audioDuration: item.audioDuration,
            ))
        .toList();
  }

  @override
  Future<List<String>> getUnreadArticleIds() async {
    final items = await _articleDs.getAll(unreadOnly: true);
    return items.map((item) => item.id.toString()).toList();
  }

  @override
  Future<List<String>> getStarredArticleIds() async {
    // Local implementation - query starred items
    return [];
  }

  // ─── Article State Management ───────────────────────────────────────

  @override
  Future<void> markAsRead(List<String> articleRemoteIds) async {
    for (final id in articleRemoteIds) {
      final intId = int.tryParse(id);
      if (intId != null) {
        await _articleDs.markAsRead(intId);
      }
    }
  }

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {
    // Local implementation - no remote call needed
  }

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {
    for (final id in articleRemoteIds) {
      final intId = int.tryParse(id);
      if (intId != null) {
        await _articleDs.toggleStarred(intId);
      }
    }
  }

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {
    for (final id in articleRemoteIds) {
      final intId = int.tryParse(id);
      if (intId != null) {
        await _articleDs.toggleStarred(intId);
      }
    }
  }

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {
    final id = int.tryParse(feedRemoteId);
    if (id != null) {
      await _articleDs.markAllAsReadForFeed(id);
    }
  }

  // ─── Sync Operations ───────────────────────────────────────────────

  @override
  Future<SyncResult> fullSync() async {
    final stopwatch = Stopwatch()..start();
    final result = await _refreshService.refreshAll();
    stopwatch.stop();

    return SyncResult(
      newArticles: result.newItems,
      updatedFeeds: result.updatedFeeds,
      errors: result.errors,
      completedAt: DateTime.now(),
      duration: stopwatch.elapsed,
    );
  }

  @override
  Future<SyncResult> incrementalSync({DateTime? since}) async {
    // For local mode, incremental sync is the same as full sync
    return fullSync();
  }
}
