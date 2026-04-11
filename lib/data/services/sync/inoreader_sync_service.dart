import 'package:dio/dio.dart';

import '../../datasources/remote/inoreader_remote_ds.dart';
import '../../datasources/remote/google_reader_api.dart';
import 'sync_models.dart';
import 'sync_service.dart';

/// Inoreader sync service implementation.
///
/// Implements [SyncService] interface for Inoreader RSS service.
/// Uses Google Reader API compatible protocol with OAuth 2.0 authentication.
class InoreaderSyncService implements SyncService {
  /// Remote data source for Inoreader API calls.
  final InoreaderRemoteDataSource _remoteDataSource;

  /// Current credentials.
  SyncCredentials? _credentials;

  /// Whether the service is authenticated.
  bool _isAuthenticated = false;

  InoreaderSyncService({
    InoreaderRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? InoreaderRemoteDataSource();

  // ─── Service Identity ───────────────────────────────────────────────

  @override
  SyncServiceType get serviceType => SyncServiceType.inoreader;

  @override
  String get serviceName => 'Inoreader';

  @override
  String get serviceIcon => 'inoreader';

  // ─── Authentication ─────────────────────────────────────────────────

  @override
  Future<bool> authenticate(SyncCredentials credentials) async {
    _credentials = credentials;

    // For Inoreader, we use OAuth access token
    if (credentials.accessToken == null) {
      return false;
    }

    try {
      // Set the access token
      _remoteDataSource.setAccessToken(credentials.accessToken!);

      // Validate by making a simple API call
      await _remoteDataSource.getSubscriptionList();

      _isAuthenticated = true;
      return true;
    } on DioException {
      _isAuthenticated = false;
      // Authentication failed
      return false;
    }
  }

  @override
  Future<void> logout() async {
    _remoteDataSource.clearAccessToken();
    _credentials = null;
    _isAuthenticated = false;
  }

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<bool> validateCredentials() async {
    if (_credentials == null || !_isAuthenticated) {
      return false;
    }

    // Check if token is expired
    if (_credentials!.isTokenExpired) {
      return false;
    }

    try {
      // Make a simple API call to validate
      await _remoteDataSource.getSubscriptionList();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Subscription Management ────────────────────────────────────────

  @override
  Future<List<SyncFeed>> getFeeds() async {
    final subscriptions = await _remoteDataSource.getSubscriptionList();

    return subscriptions.map((sub) {
      // Extract folder ID from categories if present
      String? folderId;
      if (sub.categories.isNotEmpty) {
        // Categories are like 'user/-/label/FolderName'
        folderId = sub.categories.first.id;
      }

      return SyncFeed(
        remoteId: sub.id,
        title: sub.title,
        feedUrl: _extractFeedUrl(sub.id),
        siteUrl: sub.htmlUrl,
        iconUrl: sub.iconUrl,
        folderId: folderId,
      );
    }).toList();
  }

  @override
  Future<SyncFeed> addFeed(String feedUrl, {String? title, String? folderId}) async {
    String? label;
    if (folderId != null) {
      // Extract folder name from folderId (e.g., 'user/-/label/Tech' -> 'Tech')
      label = _extractLabelFromFolderId(folderId);
    }

    await _remoteDataSource.addSubscription(
      feedUrl,
      title: title,
      label: label,
    );

    // Fetch updated subscription list to get the created feed
    final subscriptions = await _remoteDataSource.getSubscriptionList();
    final createdSub = subscriptions.firstWhere(
      (sub) => _extractFeedUrl(sub.id) == feedUrl || sub.id == 'feed/$feedUrl',
    );

    String? createdFolderId;
    if (createdSub.categories.isNotEmpty) {
      createdFolderId = createdSub.categories.first.id;
    }

    return SyncFeed(
      remoteId: createdSub.id,
      title: createdSub.title,
      feedUrl: _extractFeedUrl(createdSub.id),
      siteUrl: createdSub.htmlUrl,
      iconUrl: createdSub.iconUrl,
      folderId: createdFolderId,
    );
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {
    await _remoteDataSource.removeSubscription(feedRemoteId);
  }

  @override
  Future<void> renameFeed(String feedRemoteId, String newTitle) async {
    await _remoteDataSource.renameSubscription(feedRemoteId, newTitle);
  }

  @override
  Future<void> moveFeed(String feedRemoteId, String? folderId) async {
    // Inoreader doesn't have a direct "move" API
    // We need to remove and re-add the subscription with the new label
    final subscriptions = await _remoteDataSource.getSubscriptionList();
    final sub = subscriptions.firstWhere((s) => s.id == feedRemoteId);

    String? label;
    if (folderId != null) {
      label = _extractLabelFromFolderId(folderId);
    }

    // Remove the subscription
    await _remoteDataSource.removeSubscription(feedRemoteId);

    // Re-add with new label
    await _remoteDataSource.addSubscription(
      _extractFeedUrl(feedRemoteId),
      title: sub.title,
      label: label,
    );
  }

  // ─── Folder/Category Management ─────────────────────────────────────

  @override
  Future<List<SyncFolder>> getFolders() async {
    final tags = await _remoteDataSource.getTagList();

    // Filter for label tags (folders)
    final folders = <SyncFolder>[];
    for (final tag in tags) {
      if (tag.id.startsWith('user/-/label/')) {
        final name = tag.id.substring('user/-/label/'.length);
        folders.add(SyncFolder(
          remoteId: tag.id,
          name: name,
        ));
      }
    }

    return folders;
  }

  @override
  Future<SyncFolder> createFolder(String name) async {
    // Inoreader creates folders implicitly when you add a subscription with a label
    // We'll create a tag by using the rename-tag API with a special approach
    // Actually, Inoreader doesn't have a direct "create folder" API
    // We'll create a dummy subscription with the label to create the folder
    // This is a workaround - in practice, folders are created when you add feeds to them

    // For now, we'll return a folder object with the expected ID
    final folderId = 'user/-/label/$name';
    return SyncFolder(
      remoteId: folderId,
      name: name,
    );
  }

  @override
  Future<void> deleteFolder(String folderRemoteId) async {
    await _remoteDataSource.deleteTag(folderRemoteId);
  }

  @override
  Future<void> renameFolder(String folderRemoteId, String newName) async {
    await _remoteDataSource.renameTag(folderRemoteId, newName);
  }

  // ─── Article Retrieval ──────────────────────────────────────────────

  @override
  Future<List<SyncArticle>> getArticles({DateTime? since, int? limit}) async {
    final articles = <SyncArticle>[];

    // Fetch articles from reading list stream
    String? sinceTimestamp;
    if (since != null) {
      sinceTimestamp = (since.millisecondsSinceEpoch ~/ 1000).toString();
    }

    final contents = await _remoteDataSource.getStreamContents(
      'user/-/state/com.google/reading-list',
      count: limit,
      sinceTimestamp: sinceTimestamp != null ? int.parse(sinceTimestamp) : null,
      excludeTarget: 'user/-/state/com.google/read',
    );

    for (final item in contents.items) {
      articles.add(_convertGReaderItemToSyncArticle(item));
    }

    return articles;
  }

  @override
  Future<List<String>> getUnreadArticleIds() async {
    return await _remoteDataSource.getUnreadItemIds();
  }

  @override
  Future<List<String>> getStarredArticleIds() async {
    return await _remoteDataSource.getStarredItemIds();
  }

  // ─── Article State Management ───────────────────────────────────────

  @override
  Future<void> markAsRead(List<String> articleRemoteIds) async {
    await _remoteDataSource.markAsRead(articleRemoteIds);
  }

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {
    await _remoteDataSource.markAsUnread(articleRemoteIds);
  }

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {
    await _remoteDataSource.starItems(articleRemoteIds);
  }

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {
    await _remoteDataSource.unstarItems(articleRemoteIds);
  }

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {
    await _remoteDataSource.markAllAsRead(feedRemoteId);
  }

  // ─── Sync Operations ───────────────────────────────────────────────

  @override
  Future<SyncResult> fullSync() async {
    final startTime = DateTime.now();
    final errors = <String, String>{};

    int newFeeds = 0;
    int updatedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;

    try {
      // Fetch all feeds
      final feeds = await getFeeds();
      newFeeds = feeds.length;

      // Fetch all folders
      await getFolders();

      // Fetch all articles
      final articles = await getArticles();
      newArticles = articles.length;

      // Fetch unread and starred article IDs
      await getUnreadArticleIds();
      await getStarredArticleIds();
    } catch (e) {
      errors['fullSync'] = e.toString();
    }

    final endTime = DateTime.now();
    return SyncResult(
      newFeeds: newFeeds,
      updatedFeeds: updatedFeeds,
      removedFeeds: 0,
      newArticles: newArticles,
      updatedArticles: updatedArticles,
      removedArticles: 0,
      errors: errors,
      completedAt: endTime,
      duration: endTime.difference(startTime),
    );
  }

  @override
  Future<SyncResult> incrementalSync({DateTime? since}) async {
    final startTime = DateTime.now();
    final errors = <String, String>{};

    int newFeeds = 0;
    int updatedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;

    try {
      // Fetch articles since the given timestamp
      final articles = await getArticles(since: since);
      newArticles = articles.length;

      // Fetch updated unread and starred IDs
      await getUnreadArticleIds();
      await getStarredArticleIds();

      // Note: Inoreader doesn't provide a way to get "updated feeds"
      // So we just return 0 for feed updates
    } catch (e) {
      errors['incrementalSync'] = e.toString();
    }

    final endTime = DateTime.now();
    return SyncResult(
      newFeeds: newFeeds,
      updatedFeeds: updatedFeeds,
      removedFeeds: 0,
      newArticles: newArticles,
      updatedArticles: updatedArticles,
      removedArticles: 0,
      errors: errors,
      completedAt: endTime,
      duration: endTime.difference(startTime),
    );
  }

  // ─── Private Helpers ───────────────────────────────────────────────

  /// Extracts feed URL from stream ID.
  ///
  /// Stream ID format: 'feed/https://example.com/feed.xml'
  String _extractFeedUrl(String streamId) {
    if (streamId.startsWith('feed/')) {
      return streamId.substring(5);
    }
    return streamId;
  }

  /// Extracts label name from folder ID.
  ///
  /// Folder ID format: 'user/-/label/Tech'
  String _extractLabelFromFolderId(String folderId) {
    if (folderId.startsWith('user/-/label/')) {
      return folderId.substring('user/-/label/'.length);
    }
    return folderId;
  }

  /// Converts a GReaderItem to a SyncArticle.
  SyncArticle _convertGReaderItemToSyncArticle(GReaderItem item) {
    // Extract feed remote ID from origin
    final feedRemoteId = item.origin?.streamId ?? '';

    // Determine if article is read or starred
    final isRead = item.categories.contains('user/-/state/com.google/read');
    final isStarred = item.categories.contains('user/-/state/com.google/starred');

    // Extract publication date
    DateTime publishedAt = DateTime.now();
    if (item.published != null) {
      publishedAt = DateTime.fromMillisecondsSinceEpoch(item.published! * 1000);
    }

    // Extract content (prefer content over summary)
    String? content;
    String? summary;
    if (item.content?.content != null) {
      content = item.content!.content;
    } else if (item.summary?.content != null) {
      summary = item.summary!.content;
    }

    // Extract enclosure (audio/video)
    String? audioUrl;
    String? videoUrl;
    int? audioDuration;
    if (item.enclosure != null && item.enclosure!.isNotEmpty) {
      for (final enc in item.enclosure!) {
        if (enc.type?.contains('audio') == true) {
          audioUrl = enc.href;
        } else if (enc.type?.contains('video') == true) {
          videoUrl = enc.href;
        }
      }
    }

    return SyncArticle(
      remoteId: item.id,
      feedRemoteId: feedRemoteId,
      title: item.title ?? '',
      summary: summary,
      content: content,
      url: item.canonical ?? '',
      author: item.author,
      publishedAt: publishedAt,
      isRead: isRead,
      isStarred: isStarred,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      audioDuration: audioDuration,
    );
  }
}
