import 'package:drift/drift.dart';

/// The type of content a feed primarily delivers.
enum FeedType {
  /// Blog / news articles (RSS/Atom with text content).
  blog,

  /// Podcast feed (RSS with audio enclosures).
  podcast,

  /// Video feed (RSS/Atom with video enclosures, YouTube).
  video,

  /// Mixed content type.
  mixed,
}

/// The default viewer to use when opening items from this feed.
enum ViewerType {
  /// Show parsed article content.
  article,

  /// Show Reader View (extracted content).
  reader,

  /// Show in-app browser.
  browser,
}

/// Drift table for RSS/Atom/JSON Feed subscription sources.
///
/// Each feed has a URL, metadata, and configuration for how
/// its content should be displayed and refreshed.
class Feeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get feedUrl => text().unique()();
  TextColumn get siteUrl => text().nullable()();
  TextColumn get iconUrl => text().nullable()();
  IntColumn get type => intEnum<FeedType>().withDefault(const Constant(0))();
  IntColumn get folderId => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastFetched => dateTime().nullable()();
  IntColumn get fetchDurationMs => integer().nullable()();
  IntColumn get defaultViewer => intEnum<ViewerType>().withDefault(const Constant(0))();
  BoolColumn get autoReaderView => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
