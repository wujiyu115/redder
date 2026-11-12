import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';

void main() {
  late SyncLocalDataSource ds;

  setUp(() async {
    await AppDatabase.initializeForTesting();
    ds = SyncLocalDataSource();
  });

  tearDown(() async {
    await AppDatabase.shutdown();
  });

  Future<int> makeAccount() {
    return ds.upsertAccount(SyncAccountsCompanion.insert(
      serviceType: 0,
      createdAt: DateTime(2024, 1, 1),
    ));
  }

  group('incrementRetryCount', () {
    test('actually increments the persisted retry count (regression)',
        () async {
      final accountId = await makeAccount();
      final queueId = await ds.enqueueAction(SyncQueueItemsCompanion.insert(
        accountId: accountId,
        action: 'markRead',
        itemIds: '["1"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: const Value(0),
      ));

      await ds.incrementRetryCount(queueId);
      var item = await ds.dequeueAction(accountId);
      expect(item!.retryCount, 1);

      await ds.incrementRetryCount(queueId);
      item = await ds.dequeueAction(accountId);
      expect(item!.retryCount, 2);
    });

    test('is a no-op for a missing queue item', () async {
      // Should not throw when the id does not exist.
      await ds.incrementRetryCount(999999);
    });
  });

  group('deferQueueItem', () {
    test('moves the item behind newer ones and resets the retry count',
        () async {
      final accountId = await makeAccount();
      final stuckId = await ds.enqueueAction(SyncQueueItemsCompanion.insert(
        accountId: accountId,
        action: 'markRead',
        itemIds: '["stuck"]',
        createdAt: DateTime(2024, 1, 1),
        retryCount: const Value(3),
      ));
      await ds.enqueueAction(SyncQueueItemsCompanion.insert(
        accountId: accountId,
        action: 'markRead',
        itemIds: '["fresh"]',
        createdAt: DateTime(2024, 1, 2),
        retryCount: const Value(0),
      ));

      await ds.deferQueueItem(stuckId);

      final head = await ds.dequeueAction(accountId);
      expect(head!.itemIds, '["fresh"]');

      final all = await ds.getAllQueueItems(accountId);
      final stuck = all.firstWhere((i) => i.id == stuckId);
      expect(stuck.retryCount, 0);
    });

    test('is a no-op for a missing queue item', () async {
      await ds.deferQueueItem(999999);
    });
  });

  group('updateLastSyncAt', () {
    test('advances the watermark without touching other columns', () async {
      final accountId = await makeAccount();
      final before = await ds.getAccountById(accountId);
      expect(before!.lastSyncAt, isNull);

      final watermark = DateTime(2024, 6, 1, 12);
      await ds.updateLastSyncAt(accountId, watermark);

      final after = await ds.getAccountById(accountId);
      expect(after!.lastSyncAt, watermark);
      expect(after.serviceType, before.serviceType);
      expect(after.isActive, before.isActive);
      expect(after.createdAt, before.createdAt);
    });

    test('a partial upsert companion is rejected (regression)', () async {
      final accountId = await makeAccount();
      // This is exactly what the sync engine used to do after every sync: it
      // threw InvalidDataException, so `lastSyncAt` never moved and each
      // launch re-ran a full sync.
      await expectLater(
        ds.upsertAccount(SyncAccountsCompanion(
          id: Value(accountId),
          lastSyncAt: Value(DateTime(2024, 6, 1)),
        )),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('remote id mappings', () {
    test('round-trips a mapping', () async {
      final accountId = await makeAccount();
      await ds.upsertMapping(RemoteIdMappingsCompanion.insert(
        accountId: accountId,
        localType: 'article',
        localId: 42,
        remoteId: 'r-42',
      ));

      expect(await ds.getRemoteId(accountId, 'article', 42), 'r-42');
      expect(await ds.getLocalId(accountId, 'article', 'r-42'), 42);
    });
  });
}
