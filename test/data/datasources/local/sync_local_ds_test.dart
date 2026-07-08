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
    test('actually increments the persisted retry count (regression)', () async {
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
