import 'package:drift/drift.dart';

/// Drift table for mapping local IDs to remote service IDs.
///
/// One row per local entity: the unique index lets `upsertMapping` overwrite a
/// mapping instead of appending a duplicate on every sync.
@TableIndex(
  name: 'idx_remote_id_mappings_entity',
  columns: {#accountId, #localType, #localId},
  unique: true,
)
class RemoteIdMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Reference to the sync account.
  IntColumn get accountId => integer()();
  /// Type of entity: feed, article, folder.
  TextColumn get localType => text()();
  /// Local database ID.
  IntColumn get localId => integer()();
  /// Remote service-specific ID.
  TextColumn get remoteId => text()();
}
