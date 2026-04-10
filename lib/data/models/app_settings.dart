import 'package:drift/drift.dart';

/// Drift table for user-configurable application settings.
///
/// Only one row exists in this table (singleton pattern, id = 0).
/// Settings are persisted across app restarts.
class AppSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  // ─── Theme ──────────────────────────────────────────────
  IntColumn get themeModeIndex => integer().withDefault(const Constant(4))();

  // ─── Reading ────────────────────────────────────────────
  IntColumn get fontSizeLevel => integer().withDefault(const Constant(3))();
  IntColumn get lineHeightLevel => integer().withDefault(const Constant(2))();
  RealColumn get maxContentWidth => real().withDefault(const Constant(680.0))();
  BoolColumn get bionicReading => boolean().withDefault(const Constant(false))();

  // ─── Display ────────────────────────────────────────────
  BoolColumn get showAvatars => boolean().withDefault(const Constant(true))();
  TextColumn get avatarStyle => text().withDefault(const Constant('rounded'))();
  BoolColumn get showFolderIcons => boolean().withDefault(const Constant(true))();
  BoolColumn get showThumbnails => boolean().withDefault(const Constant(true))();
  BoolColumn get compactMode => boolean().withDefault(const Constant(false))();

  // ─── Timeline ───────────────────────────────────────────
  TextColumn get sortOrder => text().withDefault(const Constant('newest'))();
  BoolColumn get groupByFeed => boolean().withDefault(const Constant(false))();
  BoolColumn get markReadOnScroll => boolean().withDefault(const Constant(false))();
  IntColumn get contentExpiryDays => integer().withDefault(const Constant(0))();

  // ─── Notifications ─────────────────────────────────────
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(false))();

  // ─── Data ───────────────────────────────────────────────
  BoolColumn get cacheImages => boolean().withDefault(const Constant(true))();
  IntColumn get maxCacheSizeMB => integer().withDefault(const Constant(500))();
  IntColumn get autoRefreshIntervalMinutes => integer().withDefault(const Constant(30))();

  // ─── Podcast ────────────────────────────────────────────
  RealColumn get playbackSpeed => real().withDefault(const Constant(1.0))();
  IntColumn get skipForwardSeconds => integer().withDefault(const Constant(30))();
  IntColumn get skipBackwardSeconds => integer().withDefault(const Constant(15))();

  @override
  Set<Column> get primaryKey => {id};
}

