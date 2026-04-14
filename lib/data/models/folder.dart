import 'package:drift/drift.dart';

/// Drift table for folders that organize feed subscriptions.
///
/// Feeds can be grouped into folders for better organization.
/// Folders maintain a sort order and can have custom icons.
class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconName => text().nullable()();
  IntColumn get accountId => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isExpanded => boolean().withDefault(const Constant(true))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
