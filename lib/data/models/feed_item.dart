import 'package:drift/drift.dart';

/// The type of content an item contains.
enum ContentType {
  /// Standard text article.
  article,

  /// Audio content (podcast episode).
  audio,

  /// Video content.
  video,

  /// Image gallery.
  image,
}

/// Drift table for feed items (articles, episodes, videos).
///
/// Contains the full content, metadata, and read/tag state.
class FeedItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get feedId => integer()();
  TextColumn get title => text()();
  TextColumn get summary => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get url => text().unique()();
  TextColumn get imageUrl => text().nullable()();
  /// JSON-serialized list of additional image URLs.
  TextColumn get imageUrls => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get videoUrl => text().nullable()();
  IntColumn get audioDuration => integer().nullable()();
  TextColumn get author => text().nullable()();
  DateTimeColumn get publishedAt => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();
  IntColumn get contentType => intEnum<ContentType>().withDefault(const Constant(0))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  IntColumn get readingTimeMinutes => integer().nullable()();
  IntColumn get accountId => integer().nullable()();
  IntColumn get wordCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
