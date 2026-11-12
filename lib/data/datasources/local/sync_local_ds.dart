import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Local data source for sync operations using Drift.
///
/// Provides CRUD operations for SyncAccounts, SyncQueueItems, and RemoteIdMappings tables.
class SyncLocalDataSource {
  AppDatabase get _db => AppDatabase.instance;

  // ==================== SyncAccounts Operations ====================

  /// Inserts or updates a sync account.
  Future<int> upsertAccount(SyncAccountsCompanion account) async {
    return _db.into(_db.syncAccounts).insertOnConflictUpdate(account);
  }

  /// Advances the sync watermark of one account, touching nothing else.
  ///
  /// This has to be an UPDATE: `insertOnConflictUpdate` rejects a partial
  /// companion (`serviceType`/`username` missing) with an
  /// `InvalidDataException`, which used to abort every sync right after it
  /// finished — so `lastSyncAt` never moved and every launch re-ran a full
  /// sync instead of an incremental one.
  Future<void> updateLastSyncAt(int accountId, DateTime lastSyncAt) {
    return (_db.update(_db.syncAccounts)..where((t) => t.id.equals(accountId)))
        .write(SyncAccountsCompanion(lastSyncAt: Value(lastSyncAt)));
  }

  /// Gets a sync account by its ID.
  Future<SyncAccount?> getAccountById(int id) async {
    final query = _db.select(_db.syncAccounts)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Gets all sync accounts.
  Future<List<SyncAccount>> getAllAccounts() {
    return _db.select(_db.syncAccounts).get();
  }

  /// Gets the currently active sync account.
  Future<SyncAccount?> getActiveAccount() async {
    final query = _db.select(_db.syncAccounts)
      ..where((t) => t.isActive.equals(true))
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Sets an account as active and deactivates all others.
  Future<void> setActiveAccount(int accountId) async {
    await _db.transaction(() async {
      // Deactivate all accounts
      await (_db.update(_db.syncAccounts)
            ..where((t) => t.isActive.equals(true)))
          .write(const SyncAccountsCompanion(isActive: Value(false)));

      // Activate the specified account
      await (_db.update(_db.syncAccounts)..where((t) => t.id.equals(accountId)))
          .write(const SyncAccountsCompanion(isActive: Value(true)));
    });
  }

  /// Deletes a sync account by its ID.
  Future<bool> deleteAccount(int id) async {
    final rows = await (_db.delete(_db.syncAccounts)
          ..where((t) => t.id.equals(id)))
        .go();
    return rows > 0;
  }

  // ==================== SyncQueueItems Operations ====================

  /// Enqueues a sync operation to the queue.
  Future<int> enqueueAction(SyncQueueItemsCompanion item) async {
    return _db.into(_db.syncQueueItems).insert(item);
  }

  /// Dequeues the oldest pending sync operation for an account.
  Future<SyncQueueItem?> dequeueAction(int accountId) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) => t.accountId.equals(accountId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Gets all pending sync operations for an account.
  Future<List<SyncQueueItem>> getAllQueueItems(int accountId) {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) => t.accountId.equals(accountId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  /// Deletes all queue items for an account.
  Future<int> deleteQueueItemsByAccountId(int accountId) {
    return (_db.delete(_db.syncQueueItems)
          ..where((t) => t.accountId.equals(accountId)))
        .go();
  }

  /// Increments the retry count for a queue item.
  Future<void> incrementRetryCount(int queueItemId) async {
    final item = await (_db.select(_db.syncQueueItems)
          ..where((t) => t.id.equals(queueItemId)))
        .getSingleOrNull();
    if (item == null) return;
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(queueItemId)))
        .write(SyncQueueItemsCompanion(
      retryCount: Value(item.retryCount + 1),
    ));
  }

  /// Moves a repeatedly failing queue item to the back of the queue.
  ///
  /// Used when an operation has burned its retries: older ordering is what
  /// keeps a broken item from blocking newer user actions, so we only bump
  /// `created_at` and reset the counter instead of dropping the row.
  Future<void> deferQueueItem(int queueItemId) async {
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(queueItemId)))
        .write(SyncQueueItemsCompanion(
      createdAt: Value(DateTime.now()),
      retryCount: const Value(0),
    ));
  }

  /// Deletes a specific queue item.
  Future<bool> deleteQueueItem(int queueItemId) async {
    final rows = await (_db.delete(_db.syncQueueItems)
          ..where((t) => t.id.equals(queueItemId)))
        .go();
    return rows > 0;
  }

  // ==================== RemoteIdMappings Operations ====================

  /// Inserts or updates a remote ID mapping.
  ///
  /// Upserts on `(account_id, local_type, local_id)`: the plain
  /// `insertOnConflictUpdate` targeted the auto-increment primary key, so every
  /// sync appended another row and lookups became ambiguous.
  Future<int> upsertMapping(RemoteIdMappingsCompanion mapping) async {
    final table = _db.remoteIdMappings;
    return _db.into(table).insert(
          mapping,
          onConflict: DoUpdate(
            (old) => mapping,
            target: [table.accountId, table.localType, table.localId],
          ),
        );
  }

  /// Gets the remote ID for a local entity.
  Future<String?> getRemoteId(
      int accountId, String localType, int localId) async {
    final query = _db.select(_db.remoteIdMappings)
      ..where((t) => t.accountId.equals(accountId))
      ..where((t) => t.localType.equals(localType))
      ..where((t) => t.localId.equals(localId))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result?.remoteId;
  }

  /// Gets the local ID for a remote entity.
  Future<int?> getLocalId(
      int accountId, String localType, String remoteId) async {
    final query = _db.select(_db.remoteIdMappings)
      ..where((t) => t.accountId.equals(accountId))
      ..where((t) => t.localType.equals(localType))
      ..where((t) => t.remoteId.equals(remoteId))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result?.localId;
  }

  /// Deletes all mappings for an account.
  Future<int> deleteMappingsByAccountId(int accountId) {
    return (_db.delete(_db.remoteIdMappings)
          ..where((t) => t.accountId.equals(accountId)))
        .go();
  }

  /// Deletes a specific mapping.
  Future<bool> deleteMapping(int mappingId) async {
    final rows = await (_db.delete(_db.remoteIdMappings)
          ..where((t) => t.id.equals(mappingId)))
        .go();
    return rows > 0;
  }

  // ==================== Account Data Cleanup ====================

  /// Clears all data associated with a specific account.
  ///
  /// Deletes feeds, feedItems, folders, tags, taggedItems,
  /// scrollPositions, filters, syncQueueItems, and remoteIdMappings
  /// for the given [accountId].
  Future<void> clearAccountData(int accountId) async {
    await _db.transaction(() async {
      // Delete feed items first (depends on feeds)
      await (_db.delete(_db.feedItems)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete tagged items (depends on tags)
      await (_db.delete(_db.taggedItems)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete feeds
      await (_db.delete(_db.feeds)..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete folders
      await (_db.delete(_db.folders)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete tags
      await (_db.delete(_db.tags)..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete filters
      await (_db.delete(_db.filters)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete scroll positions
      await (_db.delete(_db.scrollPositions)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete sync queue items
      await (_db.delete(_db.syncQueueItems)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
      // Delete remote ID mappings
      await (_db.delete(_db.remoteIdMappings)
            ..where((t) => t.accountId.equals(accountId)))
          .go();
    });
  }
}
