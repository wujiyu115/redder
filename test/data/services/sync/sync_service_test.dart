import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import 'package:reeder/data/services/sync/sync_service_registry.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';
import 'package:reeder/data/services/sync/local_sync_service.dart';
import 'package:reeder/data/services/sync/sync_service.dart';

void main() {
  group('SyncModels', () {
    group('SyncServiceType', () {
      test('has all required enum values', () {
        expect(SyncServiceType.values, contains(SyncServiceType.local));
        expect(SyncServiceType.values, contains(SyncServiceType.feedbin));
        expect(SyncServiceType.values, contains(SyncServiceType.feedly));
        expect(SyncServiceType.values, contains(SyncServiceType.inoreader));
        expect(SyncServiceType.values, contains(SyncServiceType.freshRss));
        expect(SyncServiceType.values, contains(SyncServiceType.reader));
      });

      test('displayName returns correct name for each type', () {
        expect(SyncServiceType.local.displayName, equals('Local'));
        expect(SyncServiceType.feedbin.displayName, equals('Feedbin'));
        expect(SyncServiceType.feedly.displayName, equals('Feedly'));
        expect(SyncServiceType.inoreader.displayName, equals('Inoreader'));
        expect(SyncServiceType.freshRss.displayName, equals('FreshRSS'));
        expect(SyncServiceType.reader.displayName, equals('Reader'));
      });

      test('iconName returns correct icon for each type', () {
        expect(SyncServiceType.local.iconName, equals('rss_feed'));
        expect(SyncServiceType.feedbin.iconName, equals('feedbin'));
        expect(SyncServiceType.feedly.iconName, equals('feedly'));
        expect(SyncServiceType.inoreader.iconName, equals('inoreader'));
        expect(SyncServiceType.freshRss.iconName, equals('freshrss'));
        expect(SyncServiceType.reader.iconName, equals('reader'));
      });

      test('requiresServerUrl is true for self-hosted services', () {
        expect(SyncServiceType.freshRss.requiresServerUrl, isTrue);
        expect(SyncServiceType.reader.requiresServerUrl, isTrue);
        expect(SyncServiceType.local.requiresServerUrl, isFalse);
        expect(SyncServiceType.feedbin.requiresServerUrl, isFalse);
        expect(SyncServiceType.feedly.requiresServerUrl, isFalse);
        expect(SyncServiceType.inoreader.requiresServerUrl, isFalse);
      });

      test('usesOAuth is true for OAuth services', () {
        expect(SyncServiceType.feedly.usesOAuth, isTrue);
        expect(SyncServiceType.inoreader.usesOAuth, isTrue);
        expect(SyncServiceType.local.usesOAuth, isFalse);
        expect(SyncServiceType.feedbin.usesOAuth, isFalse);
        expect(SyncServiceType.freshRss.usesOAuth, isFalse);
        expect(SyncServiceType.reader.usesOAuth, isFalse);
      });
    });

    group('SyncFeed', () {
      test('can be constructed with required parameters', () {
        final feed = SyncFeed(
          remoteId: 'feed-123',
          title: 'Test Feed',
          feedUrl: 'https://example.com/feed.xml',
        );
        expect(feed.remoteId, equals('feed-123'));
        expect(feed.title, equals('Test Feed'));
        expect(feed.feedUrl, equals('https://example.com/feed.xml'));
      });

      test('can be constructed with optional parameters', () {
        final feed = SyncFeed(
          remoteId: 'feed-123',
          title: 'Test Feed',
          feedUrl: 'https://example.com/feed.xml',
          siteUrl: 'https://example.com',
          iconUrl: 'https://example.com/icon.png',
          folderId: 'folder-456',
          description: 'Test description',
        );
        expect(feed.siteUrl, equals('https://example.com'));
        expect(feed.iconUrl, equals('https://example.com/icon.png'));
        expect(feed.folderId, equals('folder-456'));
        expect(feed.description, equals('Test description'));
      });

      test('toString returns formatted string', () {
        final feed = SyncFeed(
          remoteId: 'feed-123',
          title: 'Test Feed',
          feedUrl: 'https://example.com/feed.xml',
        );
        expect(feed.toString(), contains('feed-123'));
        expect(feed.toString(), contains('Test Feed'));
      });
    });

    group('SyncFolder', () {
      test('can be constructed with required parameters', () {
        final folder = SyncFolder(
          remoteId: 'folder-123',
          name: 'Tech',
        );
        expect(folder.remoteId, equals('folder-123'));
        expect(folder.name, equals('Tech'));
      });

      test('toString returns formatted string', () {
        final folder = SyncFolder(
          remoteId: 'folder-123',
          name: 'Tech',
        );
        expect(folder.toString(), contains('folder-123'));
        expect(folder.toString(), contains('Tech'));
      });
    });

    group('SyncArticle', () {
      test('can be constructed with required parameters', () {
        final article = SyncArticle(
          remoteId: 'article-123',
          feedRemoteId: 'feed-456',
          title: 'Test Article',
          url: 'https://example.com/article',
          publishedAt: DateTime(2024, 1, 1),
        );
        expect(article.remoteId, equals('article-123'));
        expect(article.feedRemoteId, equals('feed-456'));
        expect(article.title, equals('Test Article'));
        expect(article.url, equals('https://example.com/article'));
        expect(article.publishedAt, equals(DateTime(2024, 1, 1)));
      });

      test('has default values for boolean fields', () {
        final article = SyncArticle(
          remoteId: 'article-123',
          feedRemoteId: 'feed-456',
          title: 'Test Article',
          url: 'https://example.com/article',
          publishedAt: DateTime(2024, 1, 1),
        );
        expect(article.isRead, isFalse);
        expect(article.isStarred, isFalse);
      });

      test('can be constructed with all optional parameters', () {
        final article = SyncArticle(
          remoteId: 'article-123',
          feedRemoteId: 'feed-456',
          title: 'Test Article',
          summary: 'Test summary',
          content: '<p>Test content</p>',
          url: 'https://example.com/article',
          author: 'Test Author',
          publishedAt: DateTime(2024, 1, 1),
          isRead: true,
          isStarred: true,
          imageUrl: 'https://example.com/image.jpg',
          audioUrl: 'https://example.com/audio.mp3',
          videoUrl: 'https://example.com/video.mp4',
          audioDuration: 300,
        );
        expect(article.summary, equals('Test summary'));
        expect(article.content, equals('<p>Test content</p>'));
        expect(article.author, equals('Test Author'));
        expect(article.isRead, isTrue);
        expect(article.isStarred, isTrue);
        expect(article.imageUrl, equals('https://example.com/image.jpg'));
        expect(article.audioUrl, equals('https://example.com/audio.mp3'));
        expect(article.videoUrl, equals('https://example.com/video.mp4'));
        expect(article.audioDuration, equals(300));
      });

      test('toString returns formatted string', () {
        final article = SyncArticle(
          remoteId: 'article-123',
          feedRemoteId: 'feed-456',
          title: 'Test Article',
          url: 'https://example.com/article',
          publishedAt: DateTime(2024, 1, 1),
        );
        expect(article.toString(), contains('article-123'));
        expect(article.toString(), contains('Test Article'));
      });
    });

    group('SyncResult', () {
      test('can be constructed with default values', () {
        final result = SyncResult(
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.newFeeds, equals(0));
        expect(result.updatedFeeds, equals(0));
        expect(result.removedFeeds, equals(0));
        expect(result.newArticles, equals(0));
        expect(result.updatedArticles, equals(0));
        expect(result.removedArticles, equals(0));
        expect(result.errors, isEmpty);
      });

      test('can be constructed with custom values', () {
        final result = SyncResult(
          newFeeds: 5,
          updatedFeeds: 3,
          removedFeeds: 1,
          newArticles: 100,
          updatedArticles: 20,
          removedArticles: 2,
          errors: {'feed-1': 'Error message'},
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.newFeeds, equals(5));
        expect(result.updatedFeeds, equals(3));
        expect(result.removedFeeds, equals(1));
        expect(result.newArticles, equals(100));
        expect(result.updatedArticles, equals(20));
        expect(result.removedArticles, equals(2));
        expect(result.errors, isNotEmpty);
      });

      test('empty factory creates result with zero values', () {
        final result = SyncResult.empty();
        expect(result.newFeeds, equals(0));
        expect(result.updatedFeeds, equals(0));
        expect(result.removedFeeds, equals(0));
        expect(result.newArticles, equals(0));
        expect(result.updatedArticles, equals(0));
        expect(result.removedArticles, equals(0));
        expect(result.errors, isEmpty);
        expect(result.duration, equals(Duration.zero));
      });

      test('hasErrors returns true when errors exist', () {
        final result = SyncResult(
          errors: {'feed-1': 'Error message'},
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.hasErrors, isTrue);
      });

      test('hasErrors returns false when no errors', () {
        final result = SyncResult(
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.hasErrors, isFalse);
      });

      test('hasChanges returns true when there are changes', () {
        final result = SyncResult(
          newFeeds: 1,
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.hasChanges, isTrue);
      });

      test('hasChanges returns false when no changes', () {
        final result = SyncResult(
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.hasChanges, isFalse);
      });

      test('toString returns formatted string', () {
        final result = SyncResult(
          newFeeds: 5,
          updatedFeeds: 3,
          removedFeeds: 1,
          newArticles: 100,
          updatedArticles: 20,
          removedArticles: 2,
          errors: {'feed-1': 'Error message'},
          completedAt: DateTime(2024, 1, 1),
          duration: const Duration(seconds: 10),
        );
        expect(result.toString(), contains('+5'));
        expect(result.toString(), contains('~3'));
        expect(result.toString(), contains('-1'));
        expect(result.toString(), contains('+100'));
        expect(result.toString(), contains('~20'));
        expect(result.toString(), contains('-2'));
      });
    });

    group('SyncCredentials', () {
      test('can be constructed with required parameters', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedbin,
        );
        expect(credentials.serviceType, equals(SyncServiceType.feedbin));
      });

      test('can be constructed with all optional parameters', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedbin,
          serverUrl: 'https://example.com',
          username: 'test@example.com',
          password: 'password',
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenExpiresAt: DateTime(2024, 12, 31),
        );
        expect(credentials.serverUrl, equals('https://example.com'));
        expect(credentials.username, equals('test@example.com'));
        expect(credentials.password, equals('password'));
        expect(credentials.accessToken, equals('access-token'));
        expect(credentials.refreshToken, equals('refresh-token'));
        expect(credentials.tokenExpiresAt, equals(DateTime(2024, 12, 31)));
      });

      test('isBasicAuth returns true when username and password are set', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedbin,
          username: 'test@example.com',
          password: 'password',
        );
        expect(credentials.isBasicAuth, isTrue);
      });

      test('isBasicAuth returns false when username or password is missing', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedbin,
          username: 'test@example.com',
        );
        expect(credentials.isBasicAuth, isFalse);
      });

      test('isOAuth returns true when accessToken is set', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
          accessToken: 'access-token',
        );
        expect(credentials.isOAuth, isTrue);
      });

      test('isOAuth returns false when accessToken is not set', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
        );
        expect(credentials.isOAuth, isFalse);
      });

      test('isTokenExpired returns true when token has expired', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
          accessToken: 'access-token',
          tokenExpiresAt: pastDate,
        );
        expect(credentials.isTokenExpired, isTrue);
      });

      test('isTokenExpired returns false when token is valid', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
          accessToken: 'access-token',
          tokenExpiresAt: futureDate,
        );
        expect(credentials.isTokenExpired, isFalse);
      });

      test('isTokenExpired returns false when tokenExpiresAt is null', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
          accessToken: 'access-token',
        );
        expect(credentials.isTokenExpired, isFalse);
      });

      test('copyWithTokens updates token fields', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedly,
          accessToken: 'old-access-token',
          refreshToken: 'old-refresh-token',
          tokenExpiresAt: DateTime(2024, 1, 1),
        );
        final updated = credentials.copyWithTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          tokenExpiresAt: DateTime(2024, 12, 31),
        );
        expect(updated.accessToken, equals('new-access-token'));
        expect(updated.refreshToken, equals('new-refresh-token'));
        expect(updated.tokenExpiresAt, equals(DateTime(2024, 12, 31)));
        expect(updated.serviceType, equals(SyncServiceType.feedly));
      });

      test('copyWithTokens preserves unchanged fields', () {
        final credentials = SyncCredentials(
          serviceType: SyncServiceType.feedbin,
          username: 'test@example.com',
          password: 'password',
        );
        final updated = credentials.copyWithTokens(
          accessToken: 'new-access-token',
        );
        expect(updated.serviceType, equals(SyncServiceType.feedbin));
        expect(updated.username, equals('test@example.com'));
        expect(updated.password, equals('password'));
        expect(updated.accessToken, equals('new-access-token'));
      });
    });

    group('SyncStatus', () {
      test('has all required enum values', () {
        expect(SyncStatus.values, contains(SyncStatus.idle));
        expect(SyncStatus.values, contains(SyncStatus.syncing));
        expect(SyncStatus.values, contains(SyncStatus.error));
        expect(SyncStatus.values, contains(SyncStatus.waitingForNetwork));
      });
    });

    group('SyncAccountInfo', () {
      test('can be constructed with required parameters', () {
        final account = SyncAccountInfo(
          id: 1,
          serviceType: SyncServiceType.feedbin,
          createdAt: DateTime(2024, 1, 1),
        );
        expect(account.id, equals(1));
        expect(account.serviceType, equals(SyncServiceType.feedbin));
        expect(account.createdAt, equals(DateTime(2024, 1, 1)));
        expect(account.isActive, isFalse);
      });

      test('can be constructed with optional parameters', () {
        final account = SyncAccountInfo(
          id: 1,
          serviceType: SyncServiceType.feedbin,
          serverUrl: 'https://example.com',
          username: 'test@example.com',
          isActive: true,
          lastSyncAt: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 1),
        );
        expect(account.serverUrl, equals('https://example.com'));
        expect(account.username, equals('test@example.com'));
        expect(account.isActive, isTrue);
        expect(account.lastSyncAt, equals(DateTime(2024, 1, 15)));
      });

      test('displayLabel returns username when available', () {
        final account = SyncAccountInfo(
          id: 1,
          serviceType: SyncServiceType.feedbin,
          username: 'test@example.com',
          createdAt: DateTime(2024, 1, 1),
        );
        expect(account.displayLabel, contains('test@example.com'));
        expect(account.displayLabel, contains('Feedbin'));
      });

      test('displayLabel returns serverUrl when username is not available', () {
        final account = SyncAccountInfo(
          id: 1,
          serviceType: SyncServiceType.freshRss,
          serverUrl: 'https://example.com',
          createdAt: DateTime(2024, 1, 1),
        );
        expect(account.displayLabel, contains('https://example.com'));
        expect(account.displayLabel, contains('FreshRSS'));
      });

      test('displayLabel returns displayName when neither username nor serverUrl', () {
        final account = SyncAccountInfo(
          id: 1,
          serviceType: SyncServiceType.feedly,
          createdAt: DateTime(2024, 1, 1),
        );
        expect(account.displayLabel, equals('Feedly'));
      });
    });
  });

  group('SyncServiceRegistry', () {
    test('registerService adds service to registry', () {
      final registry = SyncServiceRegistry();
      final mockService = _MockSyncService(SyncServiceType.feedbin);
      registry.register(mockService);
      expect(registry.getService(SyncServiceType.feedbin), equals(mockService));
    });

    test('registerFactory adds factory to registry', () {
      final registry = SyncServiceRegistry();
      registry.registerFactory(
        SyncServiceType.feedly,
        () => _MockSyncService(SyncServiceType.feedly),
      );
      final service = registry.getService(SyncServiceType.feedly);
      expect(service, isNotNull);
      expect(service?.serviceType, equals(SyncServiceType.feedly));
    });

    test('getService returns cached instance', () {
      final registry = SyncServiceRegistry();
      final mockService = _MockSyncService(SyncServiceType.feedbin);
      registry.register(mockService);
      final service1 = registry.getService(SyncServiceType.feedbin);
      final service2 = registry.getService(SyncServiceType.feedbin);
      expect(identical(service1, service2), isTrue);
    });

    test('getService returns null for unregistered service', () {
      final registry = SyncServiceRegistry();
      final service = registry.getService(SyncServiceType.feedbin);
      expect(service, isNull);
    });

    test('registeredTypes returns all registered service types', () {
      final registry = SyncServiceRegistry();
      registry.register(_MockSyncService(SyncServiceType.feedbin));
      registry.registerFactory(
        SyncServiceType.feedly,
        () => _MockSyncService(SyncServiceType.feedly),
      );
      final types = registry.registeredTypes;
      expect(types, contains(SyncServiceType.feedbin));
      expect(types, contains(SyncServiceType.feedly));
    });

    test('activeService is null initially', () {
      final registry = SyncServiceRegistry();
      expect(registry.activeService, isNull);
    });

    test('setActiveService sets active service', () {
      final registry = SyncServiceRegistry();
      final mockService = _MockSyncService(SyncServiceType.feedbin);
      registry.register(mockService);
      registry.setActiveService(SyncServiceType.feedbin);
      expect(registry.activeService, equals(mockService));
    });

    test('setActiveService returns true for registered service', () {
      final registry = SyncServiceRegistry();
      registry.register(_MockSyncService(SyncServiceType.feedbin));
      final result = registry.setActiveService(SyncServiceType.feedbin);
      expect(result, isTrue);
    });

    test('setActiveService returns false for unregistered service', () {
      final registry = SyncServiceRegistry();
      final result = registry.setActiveService(SyncServiceType.feedbin);
      expect(result, isFalse);
    });

    test('clearActiveService clears active service', () {
      final registry = SyncServiceRegistry();
      registry.register(_MockSyncService(SyncServiceType.feedbin));
      registry.setActiveService(SyncServiceType.feedbin);
      registry.clearActiveService();
      expect(registry.activeService, isNull);
    });

    test('availableServices returns metadata for all services except local', () {
      final registry = SyncServiceRegistry();
      registry.register(_MockSyncService(SyncServiceType.feedbin));
      final services = registry.availableServices;
      expect(services, isNotEmpty);
      expect(services.any((s) => s.type == SyncServiceType.local), isFalse);
    });

    test('availableServices includes isRegistered flag', () {
      final registry = SyncServiceRegistry();
      registry.register(_MockSyncService(SyncServiceType.feedbin));
      final services = registry.availableServices;
      final feedbinService = services.firstWhere((s) => s.type == SyncServiceType.feedbin);
      expect(feedbinService.isRegistered, isTrue);
      final feedlyService = services.firstWhere((s) => s.type == SyncServiceType.feedly);
      expect(feedlyService.isRegistered, isFalse);
    });

    test('dispose clears cached instances and active service', () {
      final registry = SyncServiceRegistry();
      registry.register(_MockSyncService(SyncServiceType.feedbin));
      registry.setActiveService(SyncServiceType.feedbin);
      registry.dispose();
      expect(registry.activeService, isNull);
      expect(registry.registeredTypes, isEmpty);
    });
  });

  group('SyncQueue', () {
    group('SyncQueueAction', () {
      test('has all required enum values', () {
        expect(SyncQueueAction.values, contains(SyncQueueAction.markRead));
        expect(SyncQueueAction.values, contains(SyncQueueAction.markUnread));
        expect(SyncQueueAction.values, contains(SyncQueueAction.star));
        expect(SyncQueueAction.values, contains(SyncQueueAction.unstar));
        expect(SyncQueueAction.values, contains(SyncQueueAction.addFeed));
        expect(SyncQueueAction.values, contains(SyncQueueAction.removeFeed));
      });

      test('enum values are unique', () {
        final values = SyncQueueAction.values;
        final uniqueValues = values.toSet();
        expect(values.length, equals(uniqueValues.length));
      });
    });
  });

  group('LocalSyncService', () {
    test('serviceType returns local', () {
      final service = LocalSyncService();
      expect(service.serviceType, equals(SyncServiceType.local));
    });

    test('serviceName returns Local', () {
      final service = LocalSyncService();
      expect(service.serviceName, equals('Local'));
    });

    test('serviceIcon returns rss_feed', () {
      final service = LocalSyncService();
      expect(service.serviceIcon, equals('rss_feed'));
    });

    test('isAuthenticated returns true', () {
      final service = LocalSyncService();
      expect(service.isAuthenticated, isTrue);
    });
  });
}

/// Mock sync service for testing purposes.
class _MockSyncService extends SyncService {
  _MockSyncService(this._serviceType);

  final SyncServiceType _serviceType;

  @override
  SyncServiceType get serviceType => _serviceType;

  @override
  String get serviceName => _serviceType.displayName;

  @override
  String get serviceIcon => _serviceType.iconName;

  @override
  Future<bool> authenticate(SyncCredentials credentials) async => true;

  @override
  Future<void> logout() async {}

  @override
  bool get isAuthenticated => true;

  @override
  Future<bool> validateCredentials() async => true;

  @override
  Future<List<SyncFeed>> getFeeds() async => [];

  @override
  Future<SyncFeed> addFeed(String feedUrl, {String? title, String? folderId}) async {
    return SyncFeed(
      remoteId: 'mock-feed',
      title: title ?? 'Mock Feed',
      feedUrl: feedUrl,
    );
  }

  @override
  Future<void> removeFeed(String feedRemoteId) async {}

  @override
  Future<void> renameFeed(String feedRemoteId, String newTitle) async {}

  @override
  Future<void> moveFeed(String feedRemoteId, String? folderId) async {}

  @override
  Future<List<SyncFolder>> getFolders() async => [];

  @override
  Future<SyncFolder> createFolder(String name) async {
    return SyncFolder(remoteId: 'mock-folder', name: name);
  }

  @override
  Future<void> deleteFolder(String folderRemoteId) async {}

  @override
  Future<void> renameFolder(String folderRemoteId, String newName) async {}

  @override
  Future<List<SyncArticle>> getArticles({DateTime? since, int? limit}) async => [];

  @override
  Future<List<String>> getUnreadArticleIds() async => [];

  @override
  Future<List<String>> getStarredArticleIds() async => [];

  @override
  Future<void> markAsRead(List<String> articleRemoteIds) async {}

  @override
  Future<void> markAsUnread(List<String> articleRemoteIds) async {}

  @override
  Future<void> markAsStarred(List<String> articleRemoteIds) async {}

  @override
  Future<void> markAsUnstarred(List<String> articleRemoteIds) async {}

  @override
  Future<void> markFeedAsRead(String feedRemoteId) async {}

  @override
  Future<SyncResult> fullSync() async {
    return SyncResult.empty();
  }

  @override
  Future<SyncResult> incrementalSync({DateTime? since}) async {
    return SyncResult.empty();
  }
}
