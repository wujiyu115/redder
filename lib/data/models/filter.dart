import 'package:drift/drift.dart';

/// Drift table for user-defined content filters.
///
/// Filters create custom timelines by matching items based on
/// keywords, media types, feed types, and other criteria.
/// List fields are stored as JSON-encoded text.
///
/// The [FilterHelpers] extension (providing `matches()`, keyword list getters,
/// etc.) is defined in `filter_helpers.dart` to avoid circular dependency
/// with `app_database.dart`.
class Filters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get accountId => integer().nullable()();
  /// JSON-encoded List<String> of include keywords.
  TextColumn get includeKeywords => text().withDefault(const Constant('[]'))();
  /// JSON-encoded List<String> of exclude keywords.
  TextColumn get excludeKeywords => text().withDefault(const Constant('[]'))();
  /// JSON-encoded List<String> of content types to include.
  TextColumn get mediaTypes => text().withDefault(const Constant('[]'))();
  /// JSON-encoded List<String> of feed types to include.
  TextColumn get feedTypes => text().withDefault(const Constant('[]'))();
  BoolColumn get matchWholeWord => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}