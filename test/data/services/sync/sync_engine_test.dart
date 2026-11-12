import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/services/sync/sync_engine.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';

import '../../../test_mocks.mocks.dart';

void main() {
  late SyncEngine syncEngine;
  late MockSyncServiceRegistry mockRegistry;
  late MockSyncLocalDataSource mockLocalDataSource;
  late MockSyncQueue mockSyncQueue;
  late MockSyncService mockSyncService;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockRegistry = MockSyncServiceRegistry();
    mockLocalDataSource = MockSyncLocalDataSource();
    mockSyncQueue = MockSyncQueue();
    mockSyncService = MockSyncService();
    mockConnectivity = MockConnectivity();

    when(mockRegistry.activeService).thenReturn(mockSyncService);
    when(mockSyncService.serviceName).thenReturn('MockService');
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    syncEngine = SyncEngine(
      registry: mockRegistry,
      localDataSource: mockLocalDataSource,
      syncQueue: mockSyncQueue,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    syncEngine.dispose();
  });

  group('sync()', () {
    test('should return empty result when no active service', () async {
      when(mockRegistry.activeService).thenReturn(null);
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => null);

      final result = await syncEngine.sync();

      expect(result.hasChanges, isFalse);
      // The registry is in-memory, so a cold start has to retry the restore.
      verify(mockLocalDataSource.getActiveAccount()).called(1);
      verifyNever(mockSyncQueue.processQueue(any, any));
      verifyNever(mockSyncService.fullSync());
      verifyNever(mockSyncService.incrementalSync(since: anyNamed('since')));
    });

    test('should return empty result when no active account', () async {
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => null);

      final result = await syncEngine.sync();

      expect(result.hasChanges, isFalse);
      verify(mockLocalDataSource.getActiveAccount()).called(1);
      verifyNever(mockSyncQueue.processQueue(any, any));
      verifyNever(mockSyncService.fullSync());
      verifyNever(mockSyncService.incrementalSync(since: anyNamed('since')));
    });

    test('should call fullSync when lastSyncAt is null (first sync)', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync())
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.upsertAccount(any)).thenAnswer((_) async => 1);

      await syncEngine.sync();

      verify(mockSyncQueue.processQueue(1, mockSyncService)).called(1);
      verify(mockSyncService.fullSync()).called(1);
      verifyNever(mockSyncService.incrementalSync(since: anyNamed('since')));
    });

    test('should call incrementalSync when lastSyncAt is not null', () async {
      final lastSyncTime = DateTime(2024, 1, 1);
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: lastSyncTime,
        syncState: null,
        createdAt: DateTime(2023, 12, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.incrementalSync(since: anyNamed('since')))
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.upsertAccount(any)).thenAnswer((_) async => 1);

      await syncEngine.sync();

      verify(mockSyncQueue.processQueue(1, mockSyncService)).called(1);
      // The incremental window is widened by 10 minutes so items the server
      // crawled after our last sync are not missed; duplicates dedupe by URL.
      verify(
        mockSyncService.incrementalSync(
          since: lastSyncTime.subtract(const Duration(minutes: 10)),
        ),
      ).called(1);
      verifyNever(mockSyncService.fullSync());
    });

    test('should update lastSyncAt after successful sync', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync())
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.updateLastSyncAt(any, any))
          .thenAnswer((_) async {});

      await syncEngine.sync();

      // A partial `upsertAccount` companion made Drift throw, so the old code
      // never advanced the watermark: every launch re-ran a full sync.
      final captured =
          verify(mockLocalDataSource.updateLastSyncAt(1, captureAny)).captured;
      expect(captured.single, isA<DateTime>());
    });

    test('keeps lastSyncAt when the sync reports errors', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      // Services report recoverable failures through SyncResult.errors
      // instead of throwing.
      when(mockSyncService.fullSync()).thenAnswer(
        (_) async => SyncResult(
          errors: {'full_sync': 'boom'},
          completedAt: DateTime(2024, 1, 2),
          duration: Duration.zero,
        ),
      );

      await syncEngine.sync();

      // A failed window must be re-covered next time, not skipped.
      verifyNever(mockLocalDataSource.updateLastSyncAt(any, any));
    });

    test('should set status to error and rethrow when sync fails', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync()).thenThrow(Exception('Sync failed'));

      await expectLater(
        () => syncEngine.sync(),
        throwsA(isA<Exception>()),
      );

      expect(syncEngine.currentStatus, equals(SyncStatus.error));
    });
  });

  group('syncFeed()', () {
    test('should call incrementalSync for feed sync', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: DateTime(2024, 1, 1),
        syncState: null,
        createdAt: DateTime(2023, 12, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncService.incrementalSync())
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.updateLastSyncAt(any, any))
          .thenAnswer((_) async {});

      await syncEngine.syncFeed(123);

      verify(mockSyncService.incrementalSync()).called(1);
      verifyNever(mockSyncService.fullSync());
      verify(mockLocalDataSource.updateLastSyncAt(any, any)).called(1);
    });
  });

  group('pushStateChange()', () {
    test('should call remote service when online', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsRead(any)).thenAnswer((_) async {});

      await syncEngine
          .pushStateChange(SyncQueueAction.markRead, ['article1', 'article2']);

      verify(mockSyncService.markAsRead(['article1', 'article2'])).called(1);
      verifyNever(mockSyncQueue.enqueue(any, any, any));
    });

    test('should enqueue action when offline', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(mockSyncQueue.enqueue(any, any, any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.star, ['article1']);

      verify(mockSyncQueue.enqueue(1, SyncQueueAction.star, ['article1']))
          .called(1);
      verifyNever(mockSyncService.markAsStarred(any));
      expect(syncEngine.currentStatus, equals(SyncStatus.waitingForNetwork));
    });

    test(
        'enqueues when the service cannot be restored (cold start, offline auth)',
        () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      // Online per connectivity, but the in-memory registry is empty and no
      // service is registered — restoring fails. The user's action must be
      // queued rather than dropped.
      when(mockRegistry.activeService).thenReturn(null);
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncQueue.enqueue(any, any, any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1']);

      verify(mockSyncQueue.enqueue(1, SyncQueueAction.markRead, ['article1']))
          .called(1);
      verifyNever(mockSyncService.markAsRead(any));
    });

    test('should call markFeedAsRead when action is markFeedRead', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markFeedAsRead(any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(
        SyncQueueAction.markFeedRead,
        ['feed/1', 'feed/2'],
      );

      verify(mockSyncService.markFeedAsRead('feed/1')).called(1);
      verify(mockSyncService.markFeedAsRead('feed/2')).called(1);
    });

    test('should call markAsUnread when action is markUnread', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsUnread(any)).thenAnswer((_) async {});

      await syncEngine
          .pushStateChange(SyncQueueAction.markUnread, ['article1']);

      verify(mockSyncService.markAsUnread(['article1'])).called(1);
    });

    test('should call markAsStarred when action is star', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsStarred(any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.star, ['article1']);

      verify(mockSyncService.markAsStarred(['article1'])).called(1);
    });

    test('should call markAsUnstarred when action is unstar', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsUnstarred(any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.unstar, ['article1']);

      verify(mockSyncService.markAsUnstarred(['article1'])).called(1);
    });

    test('enqueues for retry when the online remote call fails (regression)',
        () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      // Remote call fails transiently.
      when(mockSyncService.markAsRead(any))
          .thenThrow(Exception('Network error'));
      when(mockSyncQueue.enqueue(any, any, any)).thenAnswer((_) async {});

      // Previously the exception propagated to the caller and the change was
      // lost; now it must be swallowed and enqueued for later retry.
      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1']);

      verify(mockSyncQueue.enqueue(1, SyncQueueAction.markRead, ['article1']))
          .called(1);
    });
  });

  group('status stream', () {
    test('should emit syncing then idle on successful sync', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync())
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.updateLastSyncAt(any, any))
          .thenAnswer((_) async {});

      final streamFuture = expectLater(
        syncEngine.syncStatusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.idle]),
      );

      await syncEngine.sync();
      await streamFuture;
    });

    test('should emit error on sync failure', () async {
      final mockAccount = SyncAccount(
        id: 1,
        serviceType: 0,
        serverUrl: null,
        username: 'test',
        isActive: true,
        lastSyncAt: null,
        syncState: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync()).thenThrow(Exception('Sync failed'));

      final streamFuture = expectLater(
        syncEngine.syncStatusStream,
        emitsInOrder([SyncStatus.syncing, SyncStatus.error]),
      );

      try {
        await syncEngine.sync();
      } catch (_) {}

      await streamFuture;
    });
  });

  group('edge cases', () {
    test('should return early when no active service in pushStateChange',
        () async {
      when(mockRegistry.activeService).thenReturn(null);
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => null);

      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1']);

      verifyNever(mockSyncService.markAsRead(any));
      verifyNever(mockSyncQueue.enqueue(any, any, any));
    });

    test('should return early when no active account in pushStateChange',
        () async {
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => null);

      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1']);

      verify(mockLocalDataSource.getActiveAccount()).called(1);
      verifyNever(mockSyncService.markAsRead(any));
      verifyNever(mockSyncQueue.enqueue(any, any, any));
    });
  });

  group('ensureActiveService()', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    SyncAccount readerAccount() => SyncAccount(
          id: 7,
          serviceType: SyncServiceType.reader.index,
          serverUrl: 'https://reader.example.com',
          username: 'reader-user',
          isActive: true,
          lastSyncAt: null,
          syncState: null,
          createdAt: DateTime(2024, 1, 1),
        );

    const credentials = SyncCredentials(
      serviceType: SyncServiceType.reader,
      serverUrl: 'https://reader.example.com',
      username: 'reader-user',
      password: 'secret',
    );

    SyncEngine buildEngine() => SyncEngine(
          registry: mockRegistry,
          localDataSource: mockLocalDataSource,
          syncQueue: mockSyncQueue,
          connectivity: mockConnectivity,
          authService: mockAuthService,
        );

    test('restores, authenticates and activates the service after a restart',
        () async {
      // A fresh process starts with an empty in-memory registry.
      when(mockRegistry.activeService).thenReturn(null);
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => readerAccount());
      when(mockRegistry.getService(SyncServiceType.reader))
          .thenReturn(mockSyncService);
      when(mockSyncService.isAuthenticated).thenReturn(false);
      when(mockAuthService.getCredentials(7))
          .thenAnswer((_) async => credentials);
      when(mockSyncService.authenticate(credentials))
          .thenAnswer((_) async => true);
      when(mockRegistry.setActiveService(SyncServiceType.reader))
          .thenReturn(true);

      final engine = buildEngine();
      addTearDown(engine.dispose);

      expect(await engine.ensureActiveService(), isTrue);
      verify(mockSyncService.authenticate(credentials)).called(1);
      verify(mockRegistry.setActiveService(SyncServiceType.reader)).called(1);
    });

    test('skips re-authentication when the service is already signed in',
        () async {
      when(mockRegistry.activeService).thenReturn(null);
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => readerAccount());
      when(mockRegistry.getService(SyncServiceType.reader))
          .thenReturn(mockSyncService);
      when(mockSyncService.isAuthenticated).thenReturn(true);
      when(mockRegistry.setActiveService(SyncServiceType.reader))
          .thenReturn(true);

      final engine = buildEngine();
      addTearDown(engine.dispose);

      expect(await engine.ensureActiveService(), isTrue);
      verifyNever(mockSyncService.authenticate(any));
    });

    test('fails without activating when stored credentials are missing',
        () async {
      when(mockRegistry.activeService).thenReturn(null);
      when(mockLocalDataSource.getActiveAccount())
          .thenAnswer((_) async => readerAccount());
      when(mockRegistry.getService(SyncServiceType.reader))
          .thenReturn(mockSyncService);
      when(mockSyncService.isAuthenticated).thenReturn(false);
      when(mockAuthService.getCredentials(7)).thenAnswer((_) async => null);

      final engine = buildEngine();
      addTearDown(engine.dispose);

      expect(await engine.ensureActiveService(), isFalse);
      verifyNever(mockRegistry.setActiveService(any));
    });

    test('is a no-op when a service is already active', () async {
      final engine = buildEngine();
      addTearDown(engine.dispose);

      expect(await engine.ensureActiveService(), isTrue);
      verifyNever(mockLocalDataSource.getActiveAccount());
    });
  });
}
