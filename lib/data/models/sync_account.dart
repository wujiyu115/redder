import 'package:drift/drift.dart';

/// Drift table for sync service accounts.
class SyncAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Index into SyncServiceType enum.
  IntColumn get serviceType => integer()();
  /// Server URL for self-hosted services (FreshRSS, Reader).
  TextColumn get serverUrl => text().nullable()();
  /// Username or email for display.
  TextColumn get username => text().nullable()();
  /// Whether this is the currently active sync account.
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  /// Last successful sync timestamp.
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  /// JSON-encoded sync state metadata.
  TextColumn get syncState => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
