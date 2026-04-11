import 'package:drift/drift.dart';

/// Drift table for mapping local IDs to remote service IDs.
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
