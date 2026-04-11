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
      await (_db.update(_db.syncAccounts)
            ..where((t) => t.id.equals(accountId)))
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
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(queueItemId)))
        .write(SyncQueueItemsCompanion(
      retryCount: const Value.absent(),
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
  Future<int> upsertMapping(RemoteIdMappingsCompanion mapping) async {
    return _db.into(_db.remoteIdMappings).insertOnConflictUpdate(mapping);
  }

  /// Gets the remote ID for a local entity.
  Future<String?> getRemoteId(int accountId, String localType, int localId) async {
    final query = _db.select(_db.remoteIdMappings)
      ..where((t) => t.accountId.equals(accountId))
      ..where((t) => t.localType.equals(localType))
      ..where((t) => t.localId.equals(localId))
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result?.remoteId;
  }

  /// Gets the local ID for a remote entity.
  Future<int?> getLocalId(int accountId, String localType, String remoteId) async {
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
}
