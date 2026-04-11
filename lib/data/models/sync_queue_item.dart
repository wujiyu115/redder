import 'package:drift/drift.dart';

/// Drift table for offline sync operation queue.
class SyncQueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Reference to the sync account.
  IntColumn get accountId => integer()();
  /// Action type: markRead, markUnread, star, unstar, addFeed, removeFeed.
  TextColumn get action => text()();
  /// JSON-encoded list of item IDs affected by this action.
  TextColumn get itemIds => text()();
  DateTimeColumn get createdAt => dateTime()();
  /// Number of retry attempts.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
