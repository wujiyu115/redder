/// Feedly sync service implementation.
///
/// Implements [SyncService] interface for Feedly Cloud API v3.
library;

import '../../datasources/remote/feedly_remote_ds.dart';
import 'sync_models.dart';
import 'sync_service.dart';

/// Feedly sync service implementation.
class FeedlySyncService implements SyncService {
  /// Feedly remote data source.
  late final FeedlyRemoteDataSource _dataSource;

  /// Current credentials.
  SyncCredentials? _credentials;

  /// User ID (extracted from Feedly profile).
  String? _userId;

  /// Creates a new FeedlySyncService instance.
  FeedlySyncService() {
    _dataSource = FeedlyRemoteDataSource();
  }

  @override
  SyncServiceType get serviceType => SyncServiceType.feedly;

  @override
  String get serviceName => 'Feedly';

  @override
  String get serviceIcon => 'feedly';

  @override
  bool get isAuthenticated => _credentials?.accessToken != null;

  // ─── Authentication ─────────────────────────────────────────────────

  @override
  Future<bool> authenticate(SyncCredentials credentials) async {
    if (credentials.serviceType != SyncServiceType.feedly) {
      return false;
    }

    if (credentials.accessToken == null) {
      throw ArgumentError('Feedly requires OAuth access token');
    }

    _credentials = credentials;
    _dataSource.setAccessToken(credentials.accessToken!);

    // Validate credentials by fetching subscriptions
    try {
      await _dataSource.getSubscriptions();
      return true;
    } catch (e) {
      _credentials = null;
      _dataSource.clearAccessToken();
      return false;
    }
  }

  @override
  Future<void> logout() async {
    _credentials = null;
    _userId = null;
    _dataSource.clearAccessToken();
  }

  @override
  Future<bool> validateCredentials() async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      await _dataSource.getSubscriptions();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Subscription Management ────────────────────────────────────────

  @override
  Future<List<SyncFeed>> getFeeds() async {
    final subscriptions = await _dataSource.getSubscriptions();

    return subscriptions.map((sub) {
      String? folderId;
      if (sub.categories.isNotEmpty) {
        folderId = sub.categories.first.id;
      }

      return SyncFeed(
        remoteId: sub.id,
        title: sub.title,
        feedUrl: sub.feedUrl,
        siteUrl: sub.website.isNotEmpty ? sub.website : null,
        iconUrl: sub.iconUrl,
        folderId: folderId,
        description: sub.description,
      );
    }).toList();
  }

  @override
  Future<SyncFeed> addFeed(
    String feedUrl, {
    String? title,
    String? folderId,
  }) async {
    final subscription = await _dataSource.addSubscription(
      feedUrl: feedUrl,
      title: title,
      categoryId: folderId,
    );

    return SyncFeed(
      remoteId: subscription.id,
      title: subscription.title,
      feedUrl: subscription.feedUrl,
      siteUrl: subscription.website.isNotEmpty ? subscription.website : null,
      iconUrl: subscription.iconUrl,
      folderId: folderId,
      description: subscription.description,
    );
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {
    await _dataSource.removeSubscription(feedRemoteId);
  }

  @override
  Future<void> renameFeed(String feedRemoteId, String newTitle) async {
    // Feedly doesn't have a direct rename endpoint for subscriptions.
    // We need to delete and recreate with the new title.
    // First, get the current subscription details.
    final subscriptions = await _dataSource.getSubscriptions();
    final subscription =
        subscriptions.firstWhere((sub) => sub.id == feedRemoteId);

    // Remove the old subscription
    await _dataSource.removeSubscription(feedRemoteId);

    // Add it back with the new title
    final folderId = subscription.categories.isNotEmpty
        ? subscription.categories.first.id
        : null;

    await _dataSource.addSubscription(
      feedUrl: subscription.feedUrl,
      title: newTitle,
      categoryId: folderId,
    );
  }

  @override
  Future<void> moveFeed(String feedRemoteId, String? folderId) async {
    // Similar to rename, we need to delete and recreate.
    final subscriptions = await _dataSource.getSubscriptions();
    final subscription =
        subscriptions.firstWhere((sub) => sub.id == feedRemoteId);

    await _dataSource.removeSubscription(feedRemoteId);

    await _dataSource.addSubscription(
      feedUrl: subscription.feedUrl,
      title: subscription.title,
      categoryId: folderId,
    );
  }

  // ─── Folder/Category Management ─────────────────────────────────────

  @override
  Future<List<SyncFolder>> getFolders() async {
    final categories = await _dataSource.getCategories();

    return categories.map((cat) {
      return SyncFolder(
        remoteId: cat.id,
        name: cat.label,
      );
    }).toList();
  }

  @override
  Future<SyncFolder> createFolder(String name) async {
    // Feedly doesn't have a dedicated create category endpoint.
    // Categories are created implicitly when adding a subscription with a new category.
    // We'll create a temporary subscription to create the category, then remove it.
    // This is a workaround - in production, you'd use a different approach.

    // For now, we'll return a folder with a generated ID
    // The actual category will be created when a feed is added to it.
    final userId = await _getUserId();
    final categoryId = 'user/$userId/category/$name';

    return SyncFolder(
      remoteId: categoryId,
      name: name,
    );
  }

  @override
  Future<void> deleteFolder(String folderRemoteId) async {
    await _dataSource.deleteCategory(folderRemoteId);
  }

  @override
  Future<void> renameFolder(String folderRemoteId, String newName) async {
    await _dataSource.renameCategory(folderRemoteId, newName);
  }

  // ─── Article Retrieval ──────────────────────────────────────────────

  @override
  Future<List<SyncArticle>> getArticles({
    DateTime? since,
    int? limit,
  }) async {
    // Get all subscriptions to fetch articles from each feed
    final subscriptions = await _dataSource.getSubscriptions();
    final articles = <SyncArticle>[];

    for (final subscription in subscriptions) {
      final streamId = subscription.id;
      final newerThan = since != null ? since.millisecondsSinceEpoch : null;

      try {
        final contents = await _dataSource.getStreamContents(
          streamId: streamId,
          count: limit,
          newerThan: newerThan,
        );

        for (final entry in contents.items) {
          articles.add(_convertFeedlyEntryToSyncArticle(entry));
        }
      } catch (e) {
        // Continue with other feeds if one fails
        continue;
      }
    }

    // Sort by published date descending
    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Apply limit if specified
    if (limit != null && articles.length > limit) {
      return articles.sublist(0, limit);
    }

    return articles;
  }

  @override
  Future<List<String>> getUnreadArticleIds() async {
    // Use the "global.all" stream to get all unread articles
    final userId = await _getUserId();
    final streamIds = await _dataSource.getStreamIds(
      streamId: 'user/$userId/category/global.all',
      unreadOnly: true,
    );

    return streamIds.ids;
  }

  @override
  Future<List<String>> getStarredArticleIds() async {
    // Use the "global.saved" stream to get all starred articles
    final userId = await _getUserId();
    final streamIds = await _dataSource.getStreamIds(
      streamId: 'user/$userId/category/global.saved',
    );

    return streamIds.ids;
  }

  // ─── Article State Management ───────────────────────────────────────

  @override
  Future<void> markAsRead(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _dataSource.markEntries(
      action: 'markAsRead',
      entryIds: articleRemoteIds,
    );
  }

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _dataSource.markEntries(
      action: 'keepUnread',
      entryIds: articleRemoteIds,
    );
  }

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _dataSource.markEntries(
      action: 'markAsSaved',
      entryIds: articleRemoteIds,
    );
  }

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {
    if (articleRemoteIds.isEmpty) return;
    await _dataSource.markEntries(
      action: 'markAsUnsaved',
      entryIds: articleRemoteIds,
    );
  }

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {
    // To mark a feed as read, we need to get all unread article IDs
    // and mark them as read
    final streamIds = await _dataSource.getStreamIds(
      streamId: feedRemoteId,
      unreadOnly: true,
    );

    if (streamIds.ids.isNotEmpty) {
      await markAsRead(streamIds.ids);
    }
  }

  // ─── Sync Operations ───────────────────────────────────────────────

  @override
  Future<SyncResult> fullSync() async {
    final startTime = DateTime.now();
    final errors = <String, String>{};

    int newFeeds = 0;
    int updatedFeeds = 0;
    int removedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;

    try {
      // Fetch all subscriptions (feeds)
      final feeds = await getFeeds();
      newFeeds = feeds.length;

      // Fetch all categories (folders)
      await getFolders();

      // Fetch all articles
      final articles = await getArticles();
      newArticles = articles.length;

      // Fetch unread and starred article IDs
      await getUnreadArticleIds();
      await getStarredArticleIds();

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
      errors['fullSync'] = e.toString();
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
    }
  }

  @override
  Future<SyncResult> incrementalSync({DateTime? since}) async {
    final startTime = DateTime.now();
    final errors = <String, String>{};

    int newFeeds = 0;
    int updatedFeeds = 0;
    int removedFeeds = 0;
    int newArticles = 0;
    int updatedArticles = 0;

    try {
      // Fetch articles since the specified time
      final articles = await getArticles(since: since);
      newArticles = articles.length;

      // Fetch updated unread and starred article IDs
      await getUnreadArticleIds();
      await getStarredArticleIds();

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
      errors['incrementalSync'] = e.toString();
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
    }
  }

  // ─── Helper Methods ────────────────────────────────────────────────

  /// Converts a Feedly entry to a SyncArticle DTO.
  SyncArticle _convertFeedlyEntryToSyncArticle(FeedlyEntry entry) {
    String? audioUrl;
    String? videoUrl;
    int? audioDuration;

    // Check for audio/video enclosures
    if (entry.enclosures != null) {
      for (final enclosure in entry.enclosures!) {
        if (enclosure.isAudio && audioUrl == null) {
          audioUrl = enclosure.href;
        } else if (enclosure.isVideo && videoUrl == null) {
          videoUrl = enclosure.href;
        }
      }
    }

    return SyncArticle(
      remoteId: entry.id,
      feedRemoteId: entry.origin.feedId,
      title: entry.title,
      summary: entry.summary,
      content: entry.contentHtml,
      url: entry.url ?? '',
      author: entry.authorName,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(entry.published),
      isRead: !entry.unread,
      isStarred: false, // Starred status is determined from getStarredArticleIds()
      imageUrl: entry.thumbnail?.url,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      audioDuration: audioDuration,
    );
  }

  /// Gets the Feedly user ID.
  ///
  /// The user ID is extracted from the first subscription or category.
  Future<String> _getUserId() async {
    if (_userId != null) {
      return _userId!;
    }

    // Try to get user ID from subscriptions
    try {
      final subscriptions = await _dataSource.getSubscriptions();
      if (subscriptions.isNotEmpty) {
        // Extract user ID from subscription ID or category ID
        // Format: user/{userId}/category/{categoryName} or feed/{url}
        for (final sub in subscriptions) {
          if (sub.categories.isNotEmpty) {
            final categoryId = sub.categories.first.id;
            if (categoryId.startsWith('user/')) {
              final parts = categoryId.split('/');
              if (parts.length >= 2) {
                _userId = parts[1];
                return _userId!;
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore error and try categories
    }

    // Try to get user ID from categories
    try {
      final categories = await _dataSource.getCategories();
      if (categories.isNotEmpty) {
        final categoryId = categories.first.id;
        if (categoryId.startsWith('user/')) {
          final parts = categoryId.split('/');
          if (parts.length >= 2) {
            _userId = parts[1];
            return _userId!;
          }
        }
      }
    } catch (e) {
      // Ignore error
    }

    // If we still don't have a user ID, use a default
    _userId = 'default';
    return _userId!;
  }
}
