import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/app_logger.dart';
import '../../datasources/local/feed_local_ds.dart';
import '../../datasources/local/article_local_ds.dart';
import '../../datasources/local/sync_local_ds.dart';
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
  static const _log = AppLogger('ReaderSync');
  
  ReaderRemoteDataSource? _remoteDataSource;
  SyncCredentials? _credentials;

  /// The account ID associated with this sync service instance.
  /// Set during [authenticate] when the service is linked to a specific account.
  int? accountId;

  // Local data sources for writing sync data to the database
  final FeedLocalDataSource _feedLocalDs;
  final ArticleLocalDataSource _articleLocalDs;
  final SyncLocalDataSource _syncLocalDs;

  ReaderSyncService({
    FeedLocalDataSource? feedLocalDs,
    ArticleLocalDataSource? articleLocalDs,
    SyncLocalDataSource? syncLocalDs,
  })  : _feedLocalDs = feedLocalDs ?? FeedLocalDataSource(),
        _articleLocalDs = articleLocalDs ?? ArticleLocalDataSource(),
        _syncLocalDs = syncLocalDs ?? SyncLocalDataSource();

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
    _log.info('authenticate: serverUrl=${credentials.serverUrl}');
    
    if (credentials.serverUrl == null ||
        credentials.serverUrl!.isEmpty ||
        credentials.username == null ||
        credentials.username!.isEmpty ||
        credentials.password == null ||
        credentials.password!.isEmpty) {
      _log.warning('authenticate: invalid credentials');
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
        _log.info('authenticate: success');
      } else {
        _remoteDataSource = null;
        _credentials = null;
        _log.warning('authenticate: failed - login returned false');
      }

      return success;
    } catch (e) {
      _remoteDataSource = null;
      _credentials = null;
      _log.error('authenticate: failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    _log.info('logout');
    _remoteDataSource?.logout();
    _remoteDataSource = null;
    _credentials = null;
    _log.info('logout: completed');
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
    _log.info('getFeeds: starting');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final subscriptions = await _remoteDataSource!.getSubscriptions();
    final feeds = subscriptions.map(_convertSubscriptionToSyncFeed).toList();
    _log.info('getFeeds: success - ${feeds.length} feeds');
    return feeds;
  }

  @override
  Future<SyncFeed> addFeed(
    String feedUrl, {
    String? title,
    String? folderId,
  }) async {
    _log.info('addFeed: feedUrl=$feedUrl');
    
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

    final feed = _convertSubscriptionToSyncFeed(newSubscription);
    _log.info('addFeed: success - ${feed.title}');
    return feed;
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {
    _log.info('removeFeed: feedRemoteId=$feedRemoteId');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final streamId = _convertFeedIdToStreamId(feedRemoteId);
    await _remoteDataSource!.removeSubscription(streamId);
    _log.info('removeFeed: success');
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
    _log.info('getArticles: since=$since, limit=$limit');
    
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

    final articles = contents.items.map(_convertItemToSyncArticle).toList();
    _log.info('getArticles: success - ${articles.length} articles');
    return articles;
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
    _log.info('markAsRead: ${articleRemoteIds.length} articles');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.markAsRead(articleRemoteIds);
    _log.info('markAsRead: success');
  }

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {
    _log.info('markAsUnread: ${articleRemoteIds.length} articles');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.markAsUnread(articleRemoteIds);
    _log.info('markAsUnread: success');
  }

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {
    _log.info('markAsStarred: ${articleRemoteIds.length} articles');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.starItems(articleRemoteIds);
    _log.info('markAsStarred: success');
  }

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {
    _log.info('markAsUnstarred: ${articleRemoteIds.length} articles');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    await _remoteDataSource!.unstarItems(articleRemoteIds);
    _log.info('markAsUnstarred: success');
  }

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {
    _log.info('markFeedAsRead: feedRemoteId=$feedRemoteId');
    
    if (_remoteDataSource == null) {
      throw StateError('Not authenticated');
    }

    final streamId = _convertFeedIdToStreamId(feedRemoteId);
    await _remoteDataSource!.markAllAsRead(streamId);
    _log.info('markFeedAsRead: success');
  }

  @override
  Future<SyncResult> fullSync() async {
    if (accountId == null) {
      throw StateError('accountId must be set before calling fullSync');
    }

    final startTime = DateTime.now();
    int newFeeds = 0;
    int updatedFeeds = 0;
    int removedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;
    final errors = <String, String>{};
    final acctId = accountId!;
    
    _log.info('fullSync: starting for account $acctId');

    try {
      // 1. Sync folders
      final remoteFolders = await getFolders();
      _log.info('fullSync: synced ${remoteFolders.length} folders');
      final remoteFolderIdToLocalId = <String, int>{};
      final db = AppDatabase.instance;
      final now = DateTime.now();

      for (final remoteFolder in remoteFolders) {
        // Check if folder already exists for this account by name
        final existingFolders = await (db.select(db.folders)
              ..where((t) => t.name.equals(remoteFolder.name))
              ..where((t) => t.accountId.equals(acctId)))
            .get();

        int localFolderId;
        if (existingFolders.isNotEmpty) {
          localFolderId = existingFolders.first.id;
        } else {
          localFolderId = await db.into(db.folders).insert(
            FoldersCompanion.insert(
              name: remoteFolder.name,
              createdAt: now,
              updatedAt: now,
            ).copyWith(accountId: Value(acctId)),
          );
        }

        remoteFolderIdToLocalId[remoteFolder.remoteId] = localFolderId;

        // Save remote ID mapping
        await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
          accountId: acctId,
          localType: 'folder',
          localId: localFolderId,
          remoteId: remoteFolder.remoteId,
        ));
      }

      // 2. Sync feeds
      final remoteFeeds = await getFeeds();
      _log.info('fullSync: syncing ${remoteFeeds.length} feeds');

      for (final remoteFeed in remoteFeeds) {
        // Check if feed already exists for this account
        final existing = await _feedLocalDs.getByUrl(remoteFeed.feedUrl, accountId: acctId);

        final localFolderId = remoteFeed.folderId != null
            ? remoteFolderIdToLocalId[remoteFeed.folderId]
            : null;

        if (existing != null) {
          // Update existing feed
          await _feedLocalDs.upsert(FeedsCompanion(
            id: Value(existing.id),
            title: Value(remoteFeed.title),
            feedUrl: Value(remoteFeed.feedUrl),
            siteUrl: Value(remoteFeed.siteUrl),
            iconUrl: Value(remoteFeed.iconUrl),
            description: Value(remoteFeed.description),
            folderId: Value(localFolderId),
            updatedAt: Value(now),
            createdAt: Value(existing.createdAt),
          ), accountId: acctId);
          updatedFeeds++;

          // Update remote ID mapping
          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: acctId,
            localType: 'feed',
            localId: existing.id,
            remoteId: remoteFeed.remoteId,
          ));
        } else {
          // Insert new feed
          final feedId = await _feedLocalDs.upsert(FeedsCompanion.insert(
            title: remoteFeed.title,
            feedUrl: remoteFeed.feedUrl,
            siteUrl: Value(remoteFeed.siteUrl),
            iconUrl: Value(remoteFeed.iconUrl),
            description: Value(remoteFeed.description),
            folderId: Value(localFolderId),
            createdAt: now,
            updatedAt: now,
          ), accountId: acctId);
          newFeeds++;

          // Save remote ID mapping
          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: acctId,
            localType: 'feed',
            localId: feedId,
            remoteId: remoteFeed.remoteId,
          ));
        }
      }

      // 3. Sync articles
      final remoteArticles = await getArticles(limit: 1000);
      _log.info('fullSync: syncing ${remoteArticles.length} articles');

      for (final article in remoteArticles) {
        // Resolve feed remote ID to local feed ID
        final localFeedId = await _syncLocalDs.getLocalId(acctId, 'feed', 'feed/${article.feedRemoteId}');
        if (localFeedId == null) continue; // Skip if feed not found locally

        final existingArticle = await _articleLocalDs.getByUrl(article.url, accountId: acctId);

        if (existingArticle != null) {
          // Update read/starred state
          if (existingArticle.isRead != article.isRead || existingArticle.isStarred != article.isStarred) {
            await _articleLocalDs.upsert(FeedItemsCompanion(
              id: Value(existingArticle.id),
              feedId: Value(existingArticle.feedId),
              title: Value(existingArticle.title),
              url: Value(existingArticle.url),
              isRead: Value(article.isRead),
              isStarred: Value(article.isStarred),
              publishedAt: Value(existingArticle.publishedAt),
              fetchedAt: Value(existingArticle.fetchedAt),
              createdAt: Value(existingArticle.createdAt),
            ), accountId: acctId);
            updatedArticles++;
          }
        } else {
          // Insert new article
          final articleId = await _articleLocalDs.upsert(FeedItemsCompanion.insert(
            feedId: localFeedId,
            title: article.title,
            summary: Value(article.summary),
            content: Value(article.content),
            url: article.url,
            imageUrl: Value(article.imageUrl),
            audioUrl: Value(article.audioUrl),
            videoUrl: Value(article.videoUrl),
            audioDuration: Value(article.audioDuration),
            author: Value(article.author),
            publishedAt: article.publishedAt,
            fetchedAt: now,
            isRead: Value(article.isRead),
            isStarred: Value(article.isStarred),
            createdAt: now,
          ), accountId: acctId);
          newArticles++;

          // Save remote ID mapping
          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: acctId,
            localType: 'article',
            localId: articleId,
            remoteId: article.remoteId,
          ));
        }
      }

      // 4. Sync unread/starred state from remote
      try {
        _log.info('fullSync: syncing unread/starred state');
        final unreadRemoteIds = await getUnreadArticleIds();
        final starredRemoteIds = await getStarredArticleIds();

        // Update local articles based on remote unread/starred state
        final allLocalArticles = await _articleLocalDs.getAll(accountId: acctId);
        for (final localArticle in allLocalArticles) {
          final remoteId = await _syncLocalDs.getRemoteId(acctId, 'article', localArticle.id);
          if (remoteId == null) continue;

          final shouldBeUnread = unreadRemoteIds.contains(remoteId);
          final shouldBeStarred = starredRemoteIds.contains(remoteId);

          if (localArticle.isRead == shouldBeUnread || localArticle.isStarred != shouldBeStarred) {
            if (localArticle.isRead == shouldBeUnread) {
              // isRead is opposite of unread
              if (shouldBeUnread) {
                await _articleLocalDs.markAsUnread(localArticle.id);
              } else {
                await _articleLocalDs.markAsRead(localArticle.id);
              }
            }
            if (localArticle.isStarred != shouldBeStarred) {
              if (shouldBeStarred) {
                await _articleLocalDs.markAsStarred(localArticle.id);
              } else {
                await _articleLocalDs.markAsUnstarred(localArticle.id);
              }
            }
            updatedArticles++;
          }
        }
      } catch (e) {
        errors['sync_state'] = e.toString();
      }

      // 5. Update feed unread counts
      final allFeeds = await _feedLocalDs.getAll(accountId: acctId);
      for (final feed in allFeeds) {
        final unreadCount = await _articleLocalDs.unreadCountForFeed(feed.id, accountId: acctId);
        await _feedLocalDs.updateUnreadCount(feed.id, unreadCount);
      }

      _log.info('fullSync: completed — newFeeds=$newFeeds, updatedFeeds=$updatedFeeds, newArticles=$newArticles, updatedArticles=$updatedArticles');
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
      _log.error('fullSync: failed', error: e);
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
    if (accountId == null) {
      throw StateError('accountId must be set before calling incrementalSync');
    }

    final startTime = DateTime.now();
    int newFeeds = 0;
    int updatedFeeds = 0;
    int removedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;
    final errors = <String, String>{};
    final acctId = accountId!;
    
    _log.info('incrementalSync: starting for account $acctId, since=$since');

    try {
      // 1. Sync feeds (detect new/removed)
      final remoteFeeds = await getFeeds();
      final localFeeds = await _feedLocalDs.getAll(accountId: acctId);
      final localFeedUrls = localFeeds.map((f) => f.feedUrl).toSet();
      final remoteFeedUrls = remoteFeeds.map((f) => f.feedUrl).toSet();
      final now = DateTime.now();

      // Add new feeds
      for (final remoteFeed in remoteFeeds) {
        if (!localFeedUrls.contains(remoteFeed.feedUrl)) {
          // Resolve folder
          int? localFolderId;
          if (remoteFeed.folderId != null) {
            localFolderId = await _syncLocalDs.getLocalId(acctId, 'folder', remoteFeed.folderId!);
          }

          final feedId = await _feedLocalDs.upsert(FeedsCompanion.insert(
            title: remoteFeed.title,
            feedUrl: remoteFeed.feedUrl,
            siteUrl: Value(remoteFeed.siteUrl),
            iconUrl: Value(remoteFeed.iconUrl),
            description: Value(remoteFeed.description),
            folderId: Value(localFolderId),
            createdAt: now,
            updatedAt: now,
          ), accountId: acctId);
          newFeeds++;

          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: acctId,
            localType: 'feed',
            localId: feedId,
            remoteId: remoteFeed.remoteId,
          ));
        }
      }

      // Detect removed feeds
      for (final localFeed in localFeeds) {
        if (!remoteFeedUrls.contains(localFeed.feedUrl)) {
          await _feedLocalDs.delete(localFeed.id);
          removedFeeds++;
        }
      }

      // 2. Fetch new articles since last sync
      final remoteArticles = await getArticles(since: since, limit: 1000);
      _log.info('incrementalSync: syncing ${remoteArticles.length} new articles');

      for (final article in remoteArticles) {
        final localFeedId = await _syncLocalDs.getLocalId(acctId, 'feed', 'feed/${article.feedRemoteId}');
        if (localFeedId == null) continue;

        final existingArticle = await _articleLocalDs.getByUrl(article.url, accountId: acctId);

        if (existingArticle != null) {
          // Update state
          if (existingArticle.isRead != article.isRead || existingArticle.isStarred != article.isStarred) {
            await _articleLocalDs.upsert(FeedItemsCompanion(
              id: Value(existingArticle.id),
              feedId: Value(existingArticle.feedId),
              title: Value(existingArticle.title),
              url: Value(existingArticle.url),
              isRead: Value(article.isRead),
              isStarred: Value(article.isStarred),
              publishedAt: Value(existingArticle.publishedAt),
              fetchedAt: Value(existingArticle.fetchedAt),
              createdAt: Value(existingArticle.createdAt),
            ), accountId: acctId);
            updatedArticles++;
          }
        } else {
          final articleId = await _articleLocalDs.upsert(FeedItemsCompanion.insert(
            feedId: localFeedId,
            title: article.title,
            summary: Value(article.summary),
            content: Value(article.content),
            url: article.url,
            imageUrl: Value(article.imageUrl),
            audioUrl: Value(article.audioUrl),
            videoUrl: Value(article.videoUrl),
            audioDuration: Value(article.audioDuration),
            author: Value(article.author),
            publishedAt: article.publishedAt,
            fetchedAt: now,
            isRead: Value(article.isRead),
            isStarred: Value(article.isStarred),
            createdAt: now,
          ), accountId: acctId);
          newArticles++;

          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: acctId,
            localType: 'article',
            localId: articleId,
            remoteId: article.remoteId,
          ));
        }
      }

      // 3. Update feed unread counts
      final allFeeds = await _feedLocalDs.getAll(accountId: acctId);
      for (final feed in allFeeds) {
        final unreadCount = await _articleLocalDs.unreadCountForFeed(feed.id, accountId: acctId);
        await _feedLocalDs.updateUnreadCount(feed.id, unreadCount);
      }

      _log.info('incrementalSync: completed — newFeeds=$newFeeds, removedFeeds=$removedFeeds, newArticles=$newArticles, updatedArticles=$updatedArticles');
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
      _log.error('incrementalSync: failed', error: e);
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

    // Prefer the explicit `url` field from the API response.
    // Fall back to extracting from subscription.id (format: 'feed/https://...')
    // only when the id actually contains a URL after the 'feed/' prefix.
    String feedUrl;
    if (subscription.url != null && subscription.url!.isNotEmpty) {
      feedUrl = subscription.url!;
    } else {
      feedUrl = subscription.id;
      if (feedUrl.startsWith('feed/')) {
        feedUrl = feedUrl.substring(5);
      }
    }

    // Validate that feedUrl looks like a real URL
    if (!feedUrl.startsWith('http://') && !feedUrl.startsWith('https://')) {
      _log.warning('_convertSubscriptionToSyncFeed: invalid feedUrl "$feedUrl" for "${subscription.title}" (id=${subscription.id}), skipping URL extraction');
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
