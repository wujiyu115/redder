import 'package:dio/dio.dart';

import '../../datasources/remote/feedbin_remote_ds.dart';
import 'sync_models.dart';
import 'sync_service.dart';

/// Feedbin sync service implementation.
///
/// Implements the [SyncService] interface for Feedbin's REST API v2.
/// Uses HTTP Basic Authentication (email + password) and converts
/// Feedbin data models to the generic Sync DTOs.
class FeedbinSyncService implements SyncService {
  /// Remote data source for Feedbin API calls.
  final FeedbinRemoteDataSource _remoteDataSource;

  /// Current credentials.
  SyncCredentials? _credentials;

  /// Cached subscriptions (feed ID -> subscription).
  final Map<String, FeedbinSubscription> _subscriptionsCache = {};

  /// Cached taggings (tagging ID -> tagging).
  final Map<String, FeedbinTagging> _taggingsCache = {};

  /// Creates a new FeedbinSyncService instance.
  FeedbinSyncService({
    FeedbinRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? FeedbinRemoteDataSource();

  // ─── Service Identity ────────────────────────────────────────────────────

  @override
  SyncServiceType get serviceType => SyncServiceType.feedbin;

  @override
  String get serviceName => 'Feedbin';

  @override
  String get serviceIcon => 'feedbin';

  // ─── Authentication ──────────────────────────────────────────────────────

  @override
  Future<bool> authenticate(SyncCredentials credentials) async {
    if (!credentials.isBasicAuth) {
      return false;
    }

    _credentials = credentials;
    _remoteDataSource.setCredentials(
      credentials.username!,
      credentials.password!,
    );

    try {
      // Validate credentials by fetching subscriptions
      await _remoteDataSource.getSubscriptions();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _remoteDataSource.clearCredentials();
        _credentials = null;
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    _remoteDataSource.clearCredentials();
    _credentials = null;
    _subscriptionsCache.clear();
    _taggingsCache.clear();
  }

  @override
  bool get isAuthenticated => _credentials != null && _credentials!.isBasicAuth;

  @override
  Future<bool> validateCredentials() async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      await _remoteDataSource.getSubscriptions();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        return false;
      }
      rethrow;
    }
  }

  // ─── Subscription Management ─────────────────────────────────────────────

  @override
  Future<List<SyncFeed>> getFeeds() async {
    final subscriptions = await _remoteDataSource.getSubscriptions();
    
    // Update cache
    _subscriptionsCache.clear();
    for (final sub in subscriptions) {
      _subscriptionsCache[sub.feedId] = sub;
    }

    // Get taggings to determine folder assignments
    final taggings = await _remoteDataSource.getTaggings();
    _taggingsCache.clear();
    for (final tagging in taggings) {
      _taggingsCache[tagging.id] = tagging;
    }

    // Build feed ID to folder ID mapping
    final feedIdToFolderId = <String, String>{};
    for (final tagging in taggings) {
      feedIdToFolderId[tagging.feedId] = tagging.name;
    }

    // Convert to SyncFeed
    return subscriptions.map((sub) {
      return SyncFeed(
        remoteId: sub.feedId,
        title: sub.title,
        feedUrl: sub.feedUrl,
        siteUrl: sub.siteUrl,
        iconUrl: sub.iconUrl,
        folderId: feedIdToFolderId[sub.feedId],
        description: null,
      );
    }).toList();
  }

  @override
  Future<SyncFeed> addFeed(String feedUrl, {String? title, String? folderId}) async {
    final subscription = await _remoteDataSource.createSubscription(
      feedUrl: feedUrl,
      title: title,
    );

    // If folderId is provided, create a tagging
    if (folderId != null) {
      try {
        final feedId = int.tryParse(subscription.feedId);
        if (feedId != null) {
          await _remoteDataSource.createTagging(
            name: folderId,
            feedId: feedId,
          );
        }
      } catch (e) {
        // Ignore tagging errors, feed is still created
      }
    }

    return SyncFeed(
      remoteId: subscription.feedId,
      title: subscription.title,
      feedUrl: subscription.feedUrl,
      siteUrl: subscription.siteUrl,
      iconUrl: subscription.iconUrl,
      folderId: folderId,
    );
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {
    // First, remove any taggings for this feed
    final taggings = await _remoteDataSource.getTaggings();
    for (final tagging in taggings) {
      if (tagging.feedId == feedRemoteId) {
        try {
          await _remoteDataSource.deleteTagging(tagging.id);
        } catch (e) {
          // Ignore tagging deletion errors
        }
      }
    }

    // Then delete the subscription
    await _remoteDataSource.deleteSubscription(feedRemoteId);
  }

  @override
  Future<void> renameFeed(String feedRemoteId, String newTitle) async {
    await _remoteDataSource.updateSubscription(
      subscriptionId: feedRemoteId,
      title: newTitle,
    );
  }

  @override
  Future<void> moveFeed(String feedRemoteId, String? folderId) async {
    // Remove existing taggings for this feed
    final taggings = await _remoteDataSource.getTaggings();
    for (final tagging in taggings) {
      if (tagging.feedId == feedRemoteId) {
        try {
          await _remoteDataSource.deleteTagging(tagging.id);
        } catch (e) {
          // Ignore tagging deletion errors
        }
      }
    }

    // If folderId is provided, create a new tagging
    if (folderId != null) {
      final feedId = int.tryParse(feedRemoteId);
      if (feedId != null) {
        try {
          await _remoteDataSource.createTagging(
            name: folderId,
            feedId: feedId,
          );
        } catch (e) {
          // Ignore tagging errors
        }
      }
    }
  }

  // ─── Folder/Category Management ────────────────────────────────────────

  @override
  Future<List<SyncFolder>> getFolders() async {
    final taggings = await _remoteDataSource.getTaggings();
    
    // Extract unique folder names
    final folderNames = taggings.map((t) => t.name).toSet();
    
    // Convert to SyncFolder
    return folderNames.map((name) {
      return SyncFolder(
        remoteId: name, // Feedbin uses folder names as IDs
        name: name,
      );
    }).toList();
  }

  @override
  Future<SyncFolder> createFolder(String name) async {
    // In Feedbin, folders are created implicitly by creating a tagging
    // We'll return a SyncFolder with the name as the ID
    return SyncFolder(
      remoteId: name,
      name: name,
    );
  }

  @override
  Future<void> deleteFolder(String folderRemoteId) async {
    // Delete all taggings with this folder name
    final taggings = await _remoteDataSource.getTaggings();
    for (final tagging in taggings) {
      if (tagging.name == folderRemoteId) {
        try {
          await _remoteDataSource.deleteTagging(tagging.id);
        } catch (e) {
          // Ignore tagging deletion errors
        }
      }
    }
  }

  @override
  Future<void> renameFolder(String folderRemoteId, String newName) async {
    // Update all taggings with the old folder name to the new name
    final taggings = await _remoteDataSource.getTaggings();
    for (final tagging in taggings) {
      if (tagging.name == folderRemoteId) {
        try {
          await _remoteDataSource.updateTagging(
            taggingId: tagging.id,
            name: newName,
          );
        } catch (e) {
          // Ignore tagging update errors
        }
      }
    }
  }

  // ─── Article Retrieval ─────────────────────────────────────────────────

  @override
  Future<List<SyncArticle>> getArticles({DateTime? since, int? limit}) async {
    // Fetch entries
    final entriesResponse = await _remoteDataSource.getEntries(
      since: since,
      perPage: limit,
    );

    // Fetch unread and starred IDs to determine state
    final unreadIds = await _remoteDataSource.getUnreadEntries();
    final starredIds = await _remoteDataSource.getStarredEntries();

    final unreadIdSet = unreadIds.toSet();
    final starredIdSet = starredIds.toSet();

    // Convert to SyncArticle
    return entriesResponse.entries.map((entry) {
      return SyncArticle(
        remoteId: entry.id,
        feedRemoteId: entry.feedId,
        title: entry.title,
        summary: entry.summary,
        content: entry.content,
        url: entry.url,
        author: entry.author,
        publishedAt: entry.publishedAt,
        isRead: !unreadIdSet.contains(entry.id),
        isStarred: starredIdSet.contains(entry.id),
        imageUrl: entry.imageUrl,
        audioUrl: null,
        videoUrl: null,
        audioDuration: null,
      );
    }).toList();
  }

  @override
  Future<List<String>> getUnreadArticleIds() async {
    return await _remoteDataSource.getUnreadEntries();
  }

  @override
  Future<List<String>> getStarredArticleIds() async {
    return await _remoteDataSource.getStarredEntries();
  }

  // ─── Article State Management ───────────────────────────────────────────

  @override
  Future<void> markAsRead(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _remoteDataSource.markAsRead(articleRemoteIds);
  }

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _remoteDataSource.markAsUnread(articleRemoteIds);
  }

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _remoteDataSource.starEntries(articleRemoteIds);
  }

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _remoteDataSource.unstarEntries(articleRemoteIds);
  }

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {
    // Get all entries for this feed
    final entriesResponse = await _remoteDataSource.getEntries();
    final feedEntryIds = entriesResponse.entries
        .where((e) => e.feedId == feedRemoteId)
        .map((e) => e.id)
        .toList();

    // Mark them as read
    if (feedEntryIds.isNotEmpty) {
      await _remoteDataSource.markAsRead(feedEntryIds);
    }
  }

  // ─── Sync Operations ────────────────────────────────────────────────────

  @override
  Future<SyncResult> fullSync() async {
    final startTime = DateTime.now();
    final errors = <String, String>{};

    int newFeeds = 0;
    int updatedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;

    try {
      // Get subscriptions
      final subscriptions = await _remoteDataSource.getSubscriptions();
      newFeeds = subscriptions.length;

      // Get entries
      final entriesResponse = await _remoteDataSource.getEntries();
      newArticles = entriesResponse.entries.length;

      // Get unread and starred state
      await _remoteDataSource.getUnreadEntries();
      await _remoteDataSource.getStarredEntries();

    } on DioException catch (e) {
      errors['full_sync'] = e.message ?? 'Unknown error';
    } catch (e) {
      errors['full_sync'] = e.toString();
    }

    final duration = DateTime.now().difference(startTime);

    return SyncResult(
      newFeeds: newFeeds,
      updatedFeeds: updatedFeeds,
      removedFeeds: 0,
      newArticles: newArticles,
      updatedArticles: updatedArticles,
      removedArticles: 0,
      errors: errors,
      completedAt: DateTime.now(),
      duration: duration,
    );
  }

  @override
  Future<SyncResult> incrementalSync({DateTime? since}) async {
    final startTime = DateTime.now();
    final errors = <String, String>{};

    int newArticles = 0;
    int updatedArticles = 0;

    try {
      // Get entries since the last sync
      final entriesResponse = await _remoteDataSource.getEntries(since: since);
      newArticles = entriesResponse.entries.length;

      // Get updated unread and starred state
      await _remoteDataSource.getUnreadEntries();
      await _remoteDataSource.getStarredEntries();

      // Note: Feedbin doesn't provide incremental subscription updates
      // We would need to compare with local state to determine changes

    } on DioException catch (e) {
      errors['incremental_sync'] = e.message ?? 'Unknown error';
    } catch (e) {
      errors['incremental_sync'] = e.toString();
    }

    final duration = DateTime.now().difference(startTime);

    return SyncResult(
      newFeeds: 0,
      updatedFeeds: 0,
      removedFeeds: 0,
      newArticles: newArticles,
      updatedArticles: updatedArticles,
      removedArticles: 0,
      errors: errors,
      completedAt: DateTime.now(),
      duration: duration,
    );
  }
}
