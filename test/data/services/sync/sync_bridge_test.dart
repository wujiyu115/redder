import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';
import 'package:reeder/data/models/feed.dart';
import 'package:reeder/data/services/sync/sync_bridge.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';
import 'package:reeder/data/services/sync/sync_service.dart';
import 'package:reeder/data/services/sync/sync_service_registry.dart';

import '../../../test_mocks.mocks.dart';

void main() {
  late SyncBridge syncBridge;
  late MockFeedRepository mockFeedRepo;
  late MockArticleRepository mockArticleRepo;
  late MockSyncLocalDataSource mockSyncLocalDs;
  late MockSyncEngine mockSyncEngine;
  late MockSyncServiceRegistry mockRegistry;
  late MockSyncQueue mockSyncQueue;
  late MockSyncService mockSyncService;

  setUp(() {
    mockFeedRepo = MockFeedRepository();
    mockArticleRepo = MockArticleRepository();
    mockSyncLocalDs = MockSyncLocalDataSource();
    mockSyncEngine = MockSyncEngine();
    mockRegistry = MockSyncServiceRegistry();
    mockSyncQueue = MockSyncQueue();
    mockSyncService = MockSyncService();

    syncBridge = SyncBridge(
      feedRepo: mockFeedRepo,
      articleRepo: mockArticleRepo,
      syncLocalDs: mockSyncLocalDs,
      syncEngine: mockSyncEngine,
      registry: mockRegistry,
      syncQueue: mockSyncQueue,
    );
  });

  group('addFeedWithSync', () {
    const testFeedUrl = 'https://example.com/feed.xml';
    const testAccountId = 1;

    final testFeed = Feed(
      id: 1,
      title: 'Test Feed',
      feedUrl: testFeedUrl,
      type: FeedType.blog,
      sortOrder: 0,
      defaultViewer: ViewerType.article,
      autoReaderView: false,
      notificationsEnabled: false,
      unreadCount: 0,
      totalCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should add feed locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockFeedRepo.addFeed(testFeedUrl, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => testFeed);

      // Act
      final result = await syncBridge.addFeedWithSync(testFeedUrl);

      // Assert
      expect(result, equals(testFeed));
      verify(mockFeedRepo.addFeed(testFeedUrl, accountId: null)).called(1);
      verifyNever(mockSyncService.addFeed(any, title: anyNamed('title')));
    });

    test('should add feed locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockFeedRepo.addFeed(testFeedUrl, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => testFeed);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      final syncFeed = SyncFeed(remoteId: 'remote-1', title: 'Test Feed', feedUrl: testFeedUrl);
      when(mockSyncService.addFeed(testFeedUrl, title: anyNamed('title')))
          .thenAnswer((_) async => syncFeed);
      when(mockSyncLocalDs.upsertMapping(any)).thenAnswer((_) async => 0);

      // Act
      final result = await syncBridge.addFeedWithSync(testFeedUrl);
      // Wait for async remote push to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(result, equals(testFeed));
      verify(mockFeedRepo.addFeed(testFeedUrl, accountId: null)).called(1);
      verify(mockSyncService.addFeed(testFeedUrl, title: 'Test Feed')).called(1);
      verify(mockSyncLocalDs.upsertMapping(any)).called(1);
    });

    test('should enqueue action when remote push fails', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockFeedRepo.addFeed(testFeedUrl, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => testFeed);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockSyncService.addFeed(testFeedUrl, title: anyNamed('title')))
          .thenThrow(Exception('Network error'));
      when(mockSyncQueue.enqueue(any, any, any)).thenAnswer((_) async {});

      // Act
      final result = await syncBridge.addFeedWithSync(testFeedUrl);
      await Future.value(); // Let microtasks execute

      // Assert
      expect(result, equals(testFeed));
      verify(mockFeedRepo.addFeed(testFeedUrl, accountId: null)).called(1);
      verify(mockSyncService.addFeed(testFeedUrl, title: 'Test Feed')).called(1);
      verify(mockSyncQueue.enqueue(testAccountId, SyncQueueAction.addFeed, [testFeedUrl])).called(1);
    });
  });

  group('removeFeedWithSync', () {
    const testFeedId = 1;
    const testAccountId = 1;
    const testRemoteId = 'remote-1';

    test('should delete feed locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockFeedRepo.deleteFeed(testFeedId)).thenAnswer((_) async {});

      // Act
      await syncBridge.removeFeedWithSync(testFeedId);

      // Assert
      verify(mockFeedRepo.deleteFeed(testFeedId)).called(1);
      verifyNever(mockSyncService.removeFeed(any));
    });

    test('should delete feed locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockSyncLocalDs.getRemoteId(testAccountId, 'feed', testFeedId))
          .thenAnswer((_) async => testRemoteId);
      when(mockFeedRepo.deleteFeed(testFeedId)).thenAnswer((_) async {});
      when(mockSyncService.removeFeed(testRemoteId)).thenAnswer((_) async {});

      // Act
      await syncBridge.removeFeedWithSync(testFeedId);
      await Future.value(); // Let microtasks execute

      // Assert
      verify(mockFeedRepo.deleteFeed(testFeedId)).called(1);
      verify(mockSyncService.removeFeed(testRemoteId)).called(1);
    });

    test('should enqueue action when remote push fails', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockSyncLocalDs.getRemoteId(testAccountId, 'feed', testFeedId))
          .thenAnswer((_) async => testRemoteId);
      when(mockFeedRepo.deleteFeed(testFeedId)).thenAnswer((_) async {});
      when(mockSyncService.removeFeed(testRemoteId)).thenThrow(Exception('Network error'));
      when(mockSyncQueue.enqueue(any, any, any)).thenAnswer((_) async {});

      // Act
      await syncBridge.removeFeedWithSync(testFeedId);
      await Future.value(); // Let microtasks execute

      // Assert
      verify(mockFeedRepo.deleteFeed(testFeedId)).called(1);
      verify(mockSyncService.removeFeed(testRemoteId)).called(1);
      verify(mockSyncQueue.enqueue(testAccountId, SyncQueueAction.removeFeed, [testRemoteId])).called(1);
    });
  });

  group('markAsReadWithSync', () {
    const testArticleIds = [1, 2, 3];
    const testAccountId = 1;
    const testRemoteIds = ['remote-1', 'remote-2', 'remote-3'];

    test('should mark articles as read locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockArticleRepo.markMultipleAsRead(testArticleIds)).thenAnswer((_) async {});

      // Act
      await syncBridge.markAsReadWithSync(testArticleIds);

      // Assert
      verify(mockArticleRepo.markMultipleAsRead(testArticleIds)).called(1);
      verifyNever(mockSyncEngine.pushStateChange(any, any));
    });

    test('should mark articles as read locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockArticleRepo.markMultipleAsRead(testArticleIds)).thenAnswer((_) async {});
      for (var i = 0; i < testArticleIds.length; i++) {
        when(mockSyncLocalDs.getRemoteId(testAccountId, 'article', testArticleIds[i]))
            .thenAnswer((_) async => testRemoteIds[i]);
      }
      when(mockSyncEngine.pushStateChange(SyncQueueAction.markRead, testRemoteIds))
          .thenAnswer((_) async {});

      // Act
      await syncBridge.markAsReadWithSync(testArticleIds);

      // Assert
      verify(mockArticleRepo.markMultipleAsRead(testArticleIds)).called(1);
      verify(mockSyncEngine.pushStateChange(SyncQueueAction.markRead, testRemoteIds)).called(1);
    });
  });

  group('markAsUnreadWithSync', () {
    const testArticleIds = [1, 2, 3];
    const testAccountId = 1;
    const testRemoteIds = ['remote-1', 'remote-2', 'remote-3'];

    test('should mark articles as unread locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockArticleRepo.markMultipleAsUnread(testArticleIds)).thenAnswer((_) async {});

      // Act
      await syncBridge.markAsUnreadWithSync(testArticleIds);

      // Assert
      verify(mockArticleRepo.markMultipleAsUnread(testArticleIds)).called(1);
      verifyNever(mockSyncEngine.pushStateChange(any, any));
    });

    test('should mark articles as unread locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockArticleRepo.markMultipleAsUnread(testArticleIds)).thenAnswer((_) async {});
      for (var i = 0; i < testArticleIds.length; i++) {
        when(mockSyncLocalDs.getRemoteId(testAccountId, 'article', testArticleIds[i]))
            .thenAnswer((_) async => testRemoteIds[i]);
      }
      when(mockSyncEngine.pushStateChange(SyncQueueAction.markUnread, testRemoteIds))
          .thenAnswer((_) async {});

      // Act
      await syncBridge.markAsUnreadWithSync(testArticleIds);

      // Assert
      verify(mockArticleRepo.markMultipleAsUnread(testArticleIds)).called(1);
      verify(mockSyncEngine.pushStateChange(SyncQueueAction.markUnread, testRemoteIds)).called(1);
    });
  });

  group('markAsStarredWithSync', () {
    const testArticleIds = [1, 2, 3];
    const testAccountId = 1;
    const testRemoteIds = ['remote-1', 'remote-2', 'remote-3'];

    test('should mark articles as starred locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockArticleRepo.markAsStarred(any)).thenAnswer((_) async {});

      // Act
      await syncBridge.markAsStarredWithSync(testArticleIds);

      // Assert
      for (final id in testArticleIds) {
        verify(mockArticleRepo.markAsStarred(id)).called(1);
      }
      verifyNever(mockSyncEngine.pushStateChange(any, any));
    });

    test('should mark articles as starred locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockArticleRepo.markAsStarred(any)).thenAnswer((_) async {});
      for (var i = 0; i < testArticleIds.length; i++) {
        when(mockSyncLocalDs.getRemoteId(testAccountId, 'article', testArticleIds[i]))
            .thenAnswer((_) async => testRemoteIds[i]);
      }
      when(mockSyncEngine.pushStateChange(SyncQueueAction.star, testRemoteIds))
          .thenAnswer((_) async {});

      // Act
      await syncBridge.markAsStarredWithSync(testArticleIds);

      // Assert
      for (final id in testArticleIds) {
        verify(mockArticleRepo.markAsStarred(id)).called(1);
      }
      verify(mockSyncEngine.pushStateChange(SyncQueueAction.star, testRemoteIds)).called(1);
    });
  });

  group('markAsUnstarredWithSync', () {
    const testArticleIds = [1, 2, 3];
    const testAccountId = 1;
    const testRemoteIds = ['remote-1', 'remote-2', 'remote-3'];

    test('should mark articles as unstarred locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockArticleRepo.markAsUnstarred(any)).thenAnswer((_) async {});

      // Act
      await syncBridge.markAsUnstarredWithSync(testArticleIds);

      // Assert
      for (final id in testArticleIds) {
        verify(mockArticleRepo.markAsUnstarred(id)).called(1);
      }
      verifyNever(mockSyncEngine.pushStateChange(any, any));
    });

    test('should mark articles as unstarred locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockArticleRepo.markAsUnstarred(any)).thenAnswer((_) async {});
      for (var i = 0; i < testArticleIds.length; i++) {
        when(mockSyncLocalDs.getRemoteId(testAccountId, 'article', testArticleIds[i]))
            .thenAnswer((_) async => testRemoteIds[i]);
      }
      when(mockSyncEngine.pushStateChange(SyncQueueAction.unstar, testRemoteIds))
          .thenAnswer((_) async {});

      // Act
      await syncBridge.markAsUnstarredWithSync(testArticleIds);

      // Assert
      for (final id in testArticleIds) {
        verify(mockArticleRepo.markAsUnstarred(id)).called(1);
      }
      verify(mockSyncEngine.pushStateChange(SyncQueueAction.unstar, testRemoteIds)).called(1);
    });
  });

  group('markFeedAsReadWithSync', () {
    const testFeedId = 1;
    const testAccountId = 1;
    const testRemoteId = 'remote-1';

    test('should mark feed as read locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockArticleRepo.markAllAsReadForFeed(testFeedId, accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});

      // Act
      await syncBridge.markFeedAsReadWithSync(testFeedId);

      // Assert
      verify(mockArticleRepo.markAllAsReadForFeed(testFeedId, accountId: null)).called(1);
      verifyNever(mockSyncService.markFeedAsRead(any));
    });

    test('should mark feed as read locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockSyncLocalDs.getRemoteId(testAccountId, 'feed', testFeedId))
          .thenAnswer((_) async => testRemoteId);
      when(mockArticleRepo.markAllAsReadForFeed(testFeedId, accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});
      when(mockSyncService.markFeedAsRead(testRemoteId)).thenAnswer((_) async {});

      // Act
      await syncBridge.markFeedAsReadWithSync(testFeedId);
      await Future.value(); // Let microtasks execute

      // Assert
      verify(mockArticleRepo.markAllAsReadForFeed(testFeedId, accountId: testAccountId)).called(1);
      verify(mockSyncService.markFeedAsRead(testRemoteId)).called(1);
    });
  });

  group('markAllAsReadWithSync', () {
    const testAccountId = 1;
    const testFeedId = 1;
    const testRemoteId = 'remote-1';

    final testFeed = Feed(
      id: testFeedId,
      title: 'Test Feed',
      feedUrl: 'https://example.com/feed.xml',
      type: FeedType.blog,
      sortOrder: 0,
      defaultViewer: ViewerType.article,
      autoReaderView: false,
      notificationsEnabled: false,
      unreadCount: 0,
      totalCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should mark all as read locally when no active service', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(null);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => null);
      when(mockArticleRepo.markAllAsRead(accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});

      // Act
      await syncBridge.markAllAsReadWithSync();

      // Assert
      verify(mockArticleRepo.markAllAsRead(accountId: null)).called(1);
      verifyNever(mockFeedRepo.getAllFeeds(accountId: anyNamed('accountId')));
    });

    test('should mark all as read locally and push to remote when active service exists', () async {
      // Arrange
      when(mockRegistry.activeService).thenReturn(mockSyncService);
      when(mockSyncLocalDs.getActiveAccount()).thenAnswer((_) async => SyncAccount(
            id: testAccountId,
            serviceType: 0,
            username: 'test',
            isActive: true,
            createdAt: DateTime.now(),
          ));
      when(mockArticleRepo.markAllAsRead(accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});
      when(mockFeedRepo.getAllFeeds(accountId: testAccountId)).thenAnswer((_) async => [testFeed]);
      when(mockSyncLocalDs.getRemoteId(testAccountId, 'feed', testFeedId))
          .thenAnswer((_) async => testRemoteId);
      when(mockSyncService.markFeedAsRead(testRemoteId)).thenAnswer((_) async {});

      // Act
      await syncBridge.markAllAsReadWithSync();
      // Wait for async remote push to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(mockArticleRepo.markAllAsRead(accountId: testAccountId)).called(1);
      verify(mockFeedRepo.getAllFeeds(accountId: testAccountId)).called(1);
      verify(mockSyncService.markFeedAsRead(testRemoteId)).called(1);
    });
  });

  group('triggerFullSync', () {
    test('should delegate to syncEngine.sync()', () async {
      // Arrange
      final syncResult = SyncResult(
        newFeeds: 1,
        updatedFeeds: 0,
        removedFeeds: 0,
        newArticles: 10,
        updatedArticles: 5,
        removedArticles: 2,
        completedAt: DateTime.now(),
        duration: const Duration(seconds: 5),
      );
      when(mockSyncEngine.sync()).thenAnswer((_) async => syncResult);

      // Act
      final result = await syncBridge.triggerFullSync();

      // Assert
      expect(result, equals(syncResult));
      verify(mockSyncEngine.sync()).called(1);
    });
  });

  group('triggerIncrementalSync', () {
    test('should delegate to syncEngine.sync()', () async {
      // Arrange
      final syncResult = SyncResult(
        newFeeds: 0,
        updatedFeeds: 1,
        removedFeeds: 0,
        newArticles: 5,
        updatedArticles: 2,
        removedArticles: 0,
        completedAt: DateTime.now(),
        duration: const Duration(seconds: 2),
      );

      when(mockSyncEngine.sync()).thenAnswer((_) async => syncResult);

      // Act
      final result = await syncBridge.triggerIncrementalSync();

      // Assert
      expect(result, equals(syncResult));
      verify(mockSyncEngine.sync()).called(1);
    });
  });
}
