import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';
import 'package:reeder/data/services/sync/sync_engine.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';
import 'package:reeder/data/services/sync/sync_service.dart';
import 'package:reeder/data/services/sync/sync_service_registry.dart';

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

      final result = await syncEngine.sync();

      expect(result.hasChanges, isFalse);
      verifyNever(mockLocalDataSource.getActiveAccount());
      verifyNever(mockSyncQueue.processQueue(any, any));
      verifyNever(mockSyncService.fullSync());
      verifyNever(mockSyncService.incrementalSync(since: anyNamed('since')));
    });

    test('should return empty result when no active account', () async {
      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => null);

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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync()).thenAnswer((_) async => SyncResult.empty());
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.incrementalSync(since: anyNamed('since')))
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.upsertAccount(any)).thenAnswer((_) async => 1);

      await syncEngine.sync();

      verify(mockSyncQueue.processQueue(1, mockSyncService)).called(1);
      verify(mockSyncService.incrementalSync(since: lastSyncTime)).called(1);
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync()).thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.upsertAccount(any)).thenAnswer((_) async => 1);

      await syncEngine.sync();

      final captured = verify(mockLocalDataSource.upsertAccount(captureAny)).captured.single as SyncAccountsCompanion;
      expect(captured.id.value, equals(1));
      expect(captured.lastSyncAt.value, isNotNull);
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockSyncService.incrementalSync())
          .thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.upsertAccount(any)).thenAnswer((_) async => 1);

      await syncEngine.syncFeed(123);

      verify(mockSyncService.incrementalSync()).called(1);
      verifyNever(mockSyncService.fullSync());
      verify(mockLocalDataSource.upsertAccount(argThat(isA<SyncAccountsCompanion>()))).called(1);
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsRead(any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1', 'article2']);

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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(mockSyncQueue.enqueue(any, any, any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.star, ['article1']);

      verify(mockSyncQueue.enqueue(1, SyncQueueAction.star, ['article1'])).called(1);
      verifyNever(mockSyncService.markAsStarred(any));
      expect(syncEngine.currentStatus, equals(SyncStatus.waitingForNetwork));
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsUnread(any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.markUnread, ['article1']);

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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(mockSyncService.markAsUnstarred(any)).thenAnswer((_) async {});

      await syncEngine.pushStateChange(SyncQueueAction.unstar, ['article1']);

      verify(mockSyncService.markAsUnstarred(['article1'])).called(1);
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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
      when(mockSyncQueue.processQueue(any, any)).thenAnswer((_) async {});
      when(mockSyncService.fullSync()).thenAnswer((_) async => SyncResult.empty());
      when(mockLocalDataSource.upsertAccount(any)).thenAnswer((_) async => 1);

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

      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => mockAccount);
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
    test('should return early when no active service in pushStateChange', () async {
      when(mockRegistry.activeService).thenReturn(null);

      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1']);

      verifyNever(mockLocalDataSource.getActiveAccount());
      verifyNever(mockSyncService.markAsRead(any));
      verifyNever(mockSyncQueue.enqueue(any, any, any));
    });

    test('should return early when no active account in pushStateChange', () async {
      when(mockLocalDataSource.getActiveAccount()).thenAnswer((_) async => null);

      await syncEngine.pushStateChange(SyncQueueAction.markRead, ['article1']);

      verify(mockLocalDataSource.getActiveAccount()).called(1);
      verifyNever(mockSyncService.markAsRead(any));
      verifyNever(mockSyncQueue.enqueue(any, any, any));
    });
  });
}
