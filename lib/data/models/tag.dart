import 'package:drift/drift.dart';

/// Drift table for tags used to organize and bookmark feed items.
///
/// Includes built-in tags (Later, Bookmarks, Favorites) and
/// user-created custom tags.
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get iconName => text().nullable()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  TextColumn get sharedFeedUrl => text().nullable()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Built-in tag name constants.
class TagNames {
  static const String laterName = 'Later';
  static const String bookmarksName = 'Bookmarks';
  static const String favoritesName = 'Favorites';
}

/// Drift table for the many-to-many relationship between tags and feed items.
class TaggedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tagId => integer()();
  IntColumn get itemId => integer()();
  DateTimeColumn get taggedAt => dateTime()();
}
