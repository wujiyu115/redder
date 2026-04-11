import 'sync_models.dart';

/// Abstract sync service interface.
///
/// All RSS sync services (Local, Feedbin, Feedly, Inoreader, FreshRSS, Reader)
/// implement this interface, providing a unified API for the sync engine
/// to interact with different backends.
///
/// The interface follows a plugin architecture pattern, allowing new services
/// to be added by simply implementing this interface and registering with
/// [SyncServiceRegistry].
abstract class SyncService {
  // ─── Service Identity ───────────────────────────────────────────────

  /// Unique service type identifier.
  SyncServiceType get serviceType;

  /// Human-readable service name for display.
  String get serviceName;

  /// Icon identifier for the service.
  String get serviceIcon;

  // ─── Authentication ─────────────────────────────────────────────────

  /// Authenticates with the service using the provided credentials.
  ///
  /// Returns `true` if authentication succeeds, `false` otherwise.
  /// Throws on network errors.
  Future<bool> authenticate(SyncCredentials credentials);

  /// Logs out and clears stored credentials.
  Future<void> logout();

  /// Whether the service is currently authenticated.
  bool get isAuthenticated;

  /// Validates that the current credentials are still valid.
  ///
  /// For OAuth services, this may trigger a token refresh.
  /// Returns `true` if credentials are valid.
  Future<bool> validateCredentials();

  // ─── Subscription Management ────────────────────────────────────────

  /// Gets all feed subscriptions from the remote service.
  Future<List<SyncFeed>> getFeeds();

  /// Adds a new feed subscription.
  ///
  /// Returns the created [SyncFeed] with its remote ID.
  Future<SyncFeed> addFeed(String feedUrl, {String? title, String? folderId});

  /// Removes a feed subscription by its remote ID.
  Future<void> removeFeed(String feedRemoteId);

  /// Renames a feed subscription.
  Future<void> renameFeed(String feedRemoteId, String newTitle);

  /// Moves a feed to a different folder.
  Future<void> moveFeed(String feedRemoteId, String? folderId);

  // ─── Folder/Category Management ─────────────────────────────────────

  /// Gets all folders/categories from the remote service.
  Future<List<SyncFolder>> getFolders();

  /// Creates a new folder/category.
  ///
  /// Returns the created [SyncFolder] with its remote ID.
  Future<SyncFolder> createFolder(String name);

  /// Deletes a folder/category by its remote ID.
  Future<void> deleteFolder(String folderRemoteId);

  /// Renames a folder/category.
  Future<void> renameFolder(String folderRemoteId, String newName);

  // ─── Article Retrieval ──────────────────────────────────────────────

  /// Gets articles from the remote service.
  ///
  /// [since] - Only return articles newer than this timestamp.
  /// [limit] - Maximum number of articles to return.
  Future<List<SyncArticle>> getArticles({DateTime? since, int? limit});

  /// Gets unread article IDs from the remote service.
  Future<List<String>> getUnreadArticleIds();

  /// Gets starred/saved article IDs from the remote service.
  Future<List<String>> getStarredArticleIds();

  // ─── Article State Management ───────────────────────────────────────

  /// Marks articles as read on the remote service.
  Future<void> markAsRead(List<String> articleRemoteIds);

  /// Marks articles as unread on the remote service.
  Future<void> markAsUnread(List<String> articleRemoteIds);

  /// Stars/saves articles on the remote service.
  Future<void> markAsStarred(List<String> articleRemoteIds);

  /// Unstars/unsaves articles on the remote service.
  Future<void> markAsUnstarred(List<String> articleRemoteIds);

  /// Marks all articles in a feed as read.
  Future<void> markFeedAsRead(String feedRemoteId);

  // ─── Sync Operations ───────────────────────────────────────────────

  /// Performs a full sync, fetching all data from the remote service.
  ///
  /// Used for initial sync after connecting an account.
  Future<SyncResult> fullSync();

  /// Performs an incremental sync, fetching only changes since [since].
  ///
  /// Used for subsequent syncs after the initial full sync.
  Future<SyncResult> incrementalSync({DateTime? since});
}
