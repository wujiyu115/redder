import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';
import 'package:reeder/data/services/sync/sync_queue.dart';
import 'package:reeder/data/services/sync/sync_service.dart';

import '../../../test_mocks.mocks.dart';

void main() {
  late SyncQueue syncQueue;
  late MockSyncLocalDataSource mockLocalDataSource;
  late MockSyncService mockSyncService;

  setUp(() {
    mockLocalDataSource = MockSyncLocalDataSource();
    mockSyncService = MockSyncService();
    syncQueue = SyncQueue(mockLocalDataSource);
  });

  group('SyncQueue', () {
    const testAccountId = 1;

    test('enqueue() - 正确调用 _localDataSource.enqueueAction()', () async {
      final action = SyncQueueAction.markRead;
      final itemIds = ['article1', 'article2'];

      when(mockLocalDataSource.enqueueAction(any))
          .thenAnswer((_) async => 1);

      await syncQueue.enqueue(testAccountId, action, itemIds);

      verify(mockLocalDataSource.enqueueAction(argThat(
        isA<SyncQueueItemsCompanion>()
            .having((c) => c.accountId.value, 'accountId', testAccountId)
            .having((c) => c.action.value, 'action', 'markRead')
            .having((c) => c.itemIds.value, 'itemIds', '["article1","article2"]'),
      ))).called(1);
    });

    test('processQueue() - 按顺序处理队列项', () async {
      final queueItem = SyncQueueItem(
        id: 1,
        accountId: testAccountId,
        action: 'markRead',
        itemIds: '["article1","article2"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: 0,
      );

      var dequeueCallCount = 0;
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async {
        dequeueCallCount++;
        return dequeueCallCount == 1 ? queueItem : null;
      });

      when(mockSyncService.markAsRead(['article1', 'article2']))
          .thenAnswer((_) async {});

      when(mockLocalDataSource.deleteQueueItem(1))
          .thenAnswer((_) async => true);

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockLocalDataSource.dequeueAction(testAccountId)).called(2);
      verify(mockSyncService.markAsRead(['article1', 'article2'])).called(1);
      verify(mockLocalDataSource.deleteQueueItem(1)).called(1);
    });

    test('processQueue() - 成功后删除队列项 deleteQueueItem', () async {
      final queueItem = SyncQueueItem(
        id: 1,
        accountId: testAccountId,
        action: 'markRead',
        itemIds: '["article1"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: 0,
      );

      var dequeueCallCount = 0;
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async {
        dequeueCallCount++;
        return dequeueCallCount == 1 ? queueItem : null;
      });

      when(mockSyncService.markAsRead(['article1']))
          .thenAnswer((_) async {});

      when(mockLocalDataSource.deleteQueueItem(1))
          .thenAnswer((_) async => true);

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockLocalDataSource.deleteQueueItem(1)).called(1);
    });

    test('processQueue() - 失败时增加重试次数 incrementRetryCount', () async {
      final queueItem = SyncQueueItem(
        id: 1,
        accountId: testAccountId,
        action: 'markRead',
        itemIds: '["article1"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: 0,
      );

      var dequeueCallCount = 0;
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async {
        dequeueCallCount++;
        return dequeueCallCount == 1 ? queueItem : null;
      });

      when(mockSyncService.markAsRead(['article1']))
          .thenThrow(Exception('Network error'));

      when(mockLocalDataSource.incrementRetryCount(1))
          .thenAnswer((_) async {});

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockLocalDataSource.incrementRetryCount(1)).called(1);
      verifyNever(mockLocalDataSource.deleteQueueItem(1));
    });

    test('processQueue() - 超过最大重试次数后丢弃（deleteQueueItem）', () async {
      final queueItem = SyncQueueItem(
        id: 1,
        accountId: testAccountId,
        action: 'markRead',
        itemIds: '["article1"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: 2,
      );

      var dequeueCallCount = 0;
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async {
        dequeueCallCount++;
        return dequeueCallCount == 1 ? queueItem : null;
      });

      when(mockSyncService.markAsRead(['article1']))
          .thenThrow(Exception('Network error'));

      when(mockLocalDataSource.deleteQueueItem(1))
          .thenAnswer((_) async => true);

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockLocalDataSource.deleteQueueItem(1)).called(1);
      verifyNever(mockLocalDataSource.incrementRetryCount(1));
    });

    test('processQueue() - 空队列时直接返回（dequeueAction 返回 null）', () async {
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async => null);

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockLocalDataSource.dequeueAction(testAccountId)).called(1);
      verifyNever(mockSyncService.markAsRead(any));
      verifyNever(mockLocalDataSource.deleteQueueItem(any));
    });

    test('processQueue() - markRead action 调用 syncService.markAsRead()', () async {
      final queueItem = SyncQueueItem(
        id: 1,
        accountId: testAccountId,
        action: 'markRead',
        itemIds: '["article1","article2"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: 0,
      );

      var dequeueCallCount = 0;
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async {
        dequeueCallCount++;
        return dequeueCallCount == 1 ? queueItem : null;
      });

      when(mockSyncService.markAsRead(['article1', 'article2']))
          .thenAnswer((_) async {});

      when(mockLocalDataSource.deleteQueueItem(1))
          .thenAnswer((_) async => true);

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockSyncService.markAsRead(['article1', 'article2'])).called(1);
    });

    test('processQueue() - star action 调用 syncService.markAsStarred()', () async {
      final queueItem = SyncQueueItem(
        id: 1,
        accountId: testAccountId,
        action: 'star',
        itemIds: '["article1"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: 0,
      );

      var dequeueCallCount = 0;
      when(mockLocalDataSource.dequeueAction(testAccountId))
          .thenAnswer((_) async {
        dequeueCallCount++;
        return dequeueCallCount == 1 ? queueItem : null;
      });

      when(mockSyncService.markAsStarred(['article1']))
          .thenAnswer((_) async {});

      when(mockLocalDataSource.deleteQueueItem(1))
          .thenAnswer((_) async => true);

      await syncQueue.processQueue(testAccountId, mockSyncService);

      verify(mockSyncService.markAsStarred(['article1'])).called(1);
    });

    test('getQueueSize() - 返回正确数量', () async {
      final queueItems = [
        SyncQueueItem(
          id: 1,
          accountId: testAccountId,
          action: 'markRead',
          itemIds: '["article1"]',
          createdAt: DateTime(2024, 1, 1),
          retryCount: 0,
        ),
        SyncQueueItem(
          id: 2,
          accountId: testAccountId,
          action: 'star',
          itemIds: '["article2"]',
          createdAt: DateTime(2024, 1, 2),
          retryCount: 0,
        ),
      ];

      when(mockLocalDataSource.getAllQueueItems(testAccountId))
          .thenAnswer((_) async => queueItems);

      final size = await syncQueue.getQueueSize(testAccountId);

      expect(size, equals(2));
      verify(mockLocalDataSource.getAllQueueItems(testAccountId)).called(1);
    });

    test('clearQueue() - 调用 deleteQueueItemsByAccountId()', () async {
      when(mockLocalDataSource.deleteQueueItemsByAccountId(testAccountId))
          .thenAnswer((_) async => 2);

      await syncQueue.clearQueue(testAccountId);

      verify(mockLocalDataSource.deleteQueueItemsByAccountId(testAccountId))
          .called(1);
    });
  });
}
