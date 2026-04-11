import '../../datasources/remote/reader_remote_ds.dart';
import '../../datasources/remote/google_reader_api.dart';
import 'sync_models.dart';
import 'sync_service.dart';

/// Sync service implementation for Reader.
///
/// Reader is a self-hosted RSS reader that provides a Google Reader API
/// compatible interface. This service handles authentication, feed management,
/// folder management, article retrieval, and sync operations.
class ReaderSyncService implements SyncService {
  ReaderRemoteDataSource? _remoteDataSource;
  SyncCredentials? _credentials;

  @override
  SyncServiceType get serviceType => SyncServiceType.reader;

  @override
  String get serviceName => 'Reader';

  @override
  String get serviceIcon => 'reader';

  @override
  bool get isAuthenticated => _credentials != null && _remoteDataSource != null;

  @override
  Future<bool> authenticate(SyncCredentials credentials) async {
    if (credentials.serverUrl == null ||
        credentials.serverUrl!.isEmpty ||
        credentials.username == null ||
        credentials.username!.isEmpty ||
        credentials.password == null ||
        credentials.password!.isEmpty) {
      return false;
    }

    try {
      _remoteDataSource = ReaderRemoteDataSource(
        serverUrl: credentials.serverUrl!,
      );

      final success = await _remoteDataSource!.login(
        credentials.username!,
        credentials.password!,
      );

      if (success) {
        _credentials = credentials;
      } else {
        _remoteDataSource = null;
        _credentials = null;
      }

      return success;
    } catch (e) {
      _remoteDataSource = null;
      _credentials = null;
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    _remoteDataSource?.logout();
    _remoteDataSource = null;
    _credentials = null;
  }

  @override
  Future<bool> validateCredentials() async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      await _remoteDataSource!.getSubscriptions();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<SyncFeed>> getFeeds() async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final subscriptions = await _remoteDataSource!.getSubscriptions();
    return subscriptions.map(_convertSubscriptionToSyncFeed).toList();
  }

  @override
  Future<SyncFeed> addFeed(
    String feedUrl, {
    String? title,
    String? folderId,
  }) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final label = folderId != null ? _convertFolderIdToLabel(folderId) : null;
    await _remoteDataSource!.addSubscription(
      feedUrl,
      title: title,
      label: label,
    );

    final subscriptions = await _remoteDataSource!.getSubscriptions();
    final newSubscription = subscriptions.firstWhere(
      (sub) => sub.id == 'feed/$feedUrl',
      orElse: () => throw StateError('Failed to retrieve created subscription'),
    );

    return _convertSubscriptionToSyncFeed(newSubscription);
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final streamId = _convertFeedIdToStreamId(feedRemoteId);
    await _remoteDataSource!.removeSubscription(streamId);
  }

  @override
  Future<void> renameFeed(String feedRemoteId, String newTitle) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final streamId = _convertFeedIdToStreamId(feedRemoteId);
    await _remoteDataSource!.renameSubscription(streamId, newTitle);
  }

  @override
  Future<void> moveFeed(String feedRemoteId, String? folderId) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final streamId = _convertFeedIdToStreamId(feedRemoteId);
    final label = folderId != null ? _convertFolderIdToLabel(folderId) : null;

    // Reader uses tags for folders, so we edit the subscription's tags
    // This is a simplified approach - in practice, you might need to handle
    // removing old labels and adding new ones
    await _remoteDataSource!.editTags(
      [streamId],
      addTag: label,
    );
  }

  @override
  Future<List<SyncFolder>> getFolders() async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final tags = await _remoteDataSource!.getTags();
    return tags
        .where((tag) => tag.id.contains('/label/'))
        .map(_convertTagToSyncFolder)
        .toList();
  }

  @override
  Future<SyncFolder> createFolder(String name) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    // Reader doesn't have a direct create folder API
    // Folders are created implicitly when you add a subscription with a label
    // For now, we'll create a tag that acts as a folder
    final label = "user/-/label/$name";
    await _remoteDataSource!.editTags([], addTag: label);

    // Refresh to get the created folder
    final tags = await _remoteDataSource!.getTags();
    final newFolder = tags.firstWhere(
      (tag) => tag.id == label,
      orElse: () => throw StateError('Failed to retrieve created folder'),
    );

    return _convertTagToSyncFolder(newFolder);
  }

  @override
  Future<void> deleteFolder(String folderRemoteId) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final tagId = _convertFolderIdToTagId(folderRemoteId);
    await _remoteDataSource!.deleteTag(tagId);
  }

  @override
  Future<void> renameFolder(String folderRemoteId, String newName) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final tagId = _convertFolderIdToTagId(folderRemoteId);
    await _remoteDataSource!.renameTag(tagId, newName);
  }

  @override
  Future<List<SyncArticle>> getArticles({
    DateTime? since,
    int? limit,
  }) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    // Get articles from reading list
    const streamId = 'user/-/state/com.google/reading-list';
    final sinceTimestamp = since?.millisecondsSinceEpoch;

    final contents = await _remoteDataSource!.getStreamContents(
      streamId,
      count: limit,
      sinceTimestamp: sinceTimestamp,
    );

    return contents.items.map(_convertItemToSyncArticle).toList();
  }

  @override
  Future<List<String>> getUnreadArticleIds() async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    return await _remoteDataSource!.getUnreadItemIds();
  }

  @override
  Future<List<String>> getStarredArticleIds() async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    return await _remoteDataSource!.getStarredItemIds();
  }

  @override
  Future<void> markAsRead(List<String> articleRemoteIds) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.markAsRead(articleRemoteIds);
  }

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.markAsUnread(articleRemoteIds);
  }

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.starItems(articleRemoteIds);
  }

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.unstarItems(articleRemoteIds);
  }

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final streamId = _convertFeedIdToStreamId(feedRemoteId);
    await _remoteDataSource!.markAllAsRead(streamId);
  }

  @override
  Future<SyncResult> fullSync() async {
    final startTime = DateTime.now();
    int newFeeds = 0;
    int updatedFeeds = 0;
    int removedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;
    final errors = <String, String>{};

    try {
      // Fetch all feeds
      final feeds = await getFeeds();

      // Fetch all articles (no since parameter for full sync)
      final articles = await getArticles(limit: 1000);

      // Note: In a real implementation, you would:
      // 1. Compare with local database to determine new/updated/removed
      // 2. Store the data locally
      // For now, we just count what we received
      newFeeds = feeds.length;
      newArticles = articles.length;

      return SyncResult(
        newFeeds: newFeeds,
        updatedFeeds: updatedFeeds,
        removedFeeds: removedFeeds,
        newArticles: newArticles,
        updatedArticles: updatedArticles,
        errors: errors,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      errors['full_sync'] = e.toString();
      return SyncResult(
        errors: errors,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<SyncResult> incrementalSync({DateTime? since}) async {
    final startTime = DateTime.now();
    int newFeeds = 0;
    int updatedFeeds = 0;
    int removedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;
    final errors = <String, String>{};

    try {
      // Fetch feeds (to detect changes)
      final feeds = await getFeeds();

      // Fetch articles since the last sync
      final articles = await getArticles(since: since, limit: 1000);

      // Note: In a real implementation, you would:
      // 1. Compare with local database to determine new/updated/removed
      // 2. Store the data locally
      // For now, we just count what we received
      newFeeds = feeds.length;
      newArticles = articles.length;

      return SyncResult(
        newFeeds: newFeeds,
        updatedFeeds: updatedFeeds,
        removedFeeds: removedFeeds,
        newArticles: newArticles,
        updatedArticles: updatedArticles,
        errors: errors,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      errors['incremental_sync'] = e.toString();
      return SyncResult(
        errors: errors,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  // ─── Conversion Helpers ─────────────────────────────────────────────

  SyncFeed _convertSubscriptionToSyncFeed(GReaderSubscription subscription) {
    String? folderId;
    if (subscription.categories.isNotEmpty) {
      // Extract folder ID from the first category
      // Category format: user/-/label/FolderName
      final category = subscription.categories.first;
      folderId = _convertLabelToFolderId(category.id);
    }

    // Extract feedUrl from subscription.id (format: 'feed/https://...')
    String feedUrl = subscription.id;
    if (feedUrl.startsWith('feed/')) {
      feedUrl = feedUrl.substring(5);
    }

    return SyncFeed(
      remoteId: subscription.id,
      title: subscription.title,
      feedUrl: feedUrl,
      siteUrl: subscription.htmlUrl,
      iconUrl: subscription.iconUrl,
      folderId: folderId,
      description: null,
    );
  }

  SyncFolder _convertTagToSyncFolder(GReaderTag tag) {
    // Tag format: user/-/label/FolderName
    final name = tag.id.split('/').last;
    return SyncFolder(
      remoteId: _convertLabelToFolderId(tag.id),
      name: name,
    );
  }

  SyncArticle _convertItemToSyncArticle(GReaderItem item) {
    // Extract feed ID from the stream ID
    // Stream format: feed/http://example.com/feed.xml
    final streamId = item.origin?.streamId;
    String feedRemoteId = streamId ?? '';
    if (feedRemoteId.startsWith('feed/')) {
      feedRemoteId = feedRemoteId.substring(5);
    }

    // Check if article is starred
    final isStarred = item.categories.any(
      (category) => category == 'user/-/state/com.google/starred',
    );

    // Check if article is read (not in unread state)
    final isRead = !item.categories.any(
      (category) => category == 'user/-/state/com.google/unread',
    );

    // Extract image URL from content
    String? imageUrl;
    if (item.content?.content != null) {
      // Simple regex to find first image URL
      final imgRegex = RegExp(r'<img[^>]+src="([^"]+)"');
      final imageMatch = imgRegex.firstMatch(item.content!.content ?? '');
      if (imageMatch != null) {
        imageUrl = imageMatch.group(1);
      }
    }

    // Extract audio enclosure
    String? audioUrl;
    int? audioDuration;
    if (item.enclosure != null && item.enclosure!.isNotEmpty) {
      final enclosure = item.enclosure!.first;
      if (enclosure.type?.contains('audio') == true) {
        audioUrl = enclosure.href;
        audioDuration = null; // GReaderEnclosure doesn't have length field
      }
    }

    return SyncArticle(
      remoteId: item.id,
      feedRemoteId: feedRemoteId,
      title: item.title ?? '',
      summary: item.summary?.content,
      content: item.content?.content,
      url: item.canonical ?? '',
      author: item.author,
      publishedAt: DateTime.fromMillisecondsSinceEpoch((item.published ?? 0) * 1000),
      isRead: isRead,
      isStarred: isStarred,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      audioDuration: audioDuration,
    );
  }

  // ─── ID Conversion Helpers ───────────────────────────────────────────

  String _convertFeedIdToStreamId(String feedId) {
    return 'feed/$feedId';
  }

  String _convertFolderIdToLabel(String folderId) {
    // Folder ID format: folder/FolderName
    // Label format: user/-/label/FolderName
    final folderName = folderId.startsWith('folder/') ? folderId.substring(7) : folderId;
    return 'user/-/label/$folderName';
  }

  String _convertLabelToFolderId(String label) {
    // Label format: user/-/label/FolderName
    // Folder ID format: folder/FolderName
    if (label.startsWith('user/-/label/')) {
      final folderName = label.substring(14);
      return 'folder/$folderName';
    }
    return label;
  }

  String _convertFolderIdToTagId(String folderId) {
    // Folder ID format: folder/FolderName
    // Tag ID format: user/-/label/FolderName
    return _convertFolderIdToLabel(folderId);
  }
}
