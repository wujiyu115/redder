import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../data/models/feed.dart';
import '../../data/models/feed_item.dart';
import '../../data/models/folder.dart';
import '../../data/models/tag.dart';
import '../../data/models/filter.dart';
import '../../data/models/scroll_position.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/sync_account.dart';
import '../../data/models/sync_queue_item.dart';
import '../../data/models/remote_id_mapping.dart';

part 'app_database.g.dart';

/// Manages Drift (SQLite) database initialization and access.
///
/// Call [initialize] once at app startup before using the database.
/// Access the database instance via [instance].
///
/// Performance targets:
/// - All queries should complete in < 50ms
/// - Database initialization should complete in < 500ms
@DriftDatabase(tables: [
  Feeds,
  FeedItems,
  Tags,
  TaggedItems,
  Folders,
  Filters,
  ScrollPositions,
  AppSettingsTable,
  SyncAccounts,
  SyncQueueItems,
  RemoteIdMappings,
])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  AppDatabase._() : super(_openConnection());

  /// Returns the database instance.
  ///
  /// Throws if [initialize] has not been called.
  static AppDatabase get instance {
    assert(_instance != null, 'AppDatabase.initialize() must be called first');
    return _instance!;
  }

  /// Whether the database has been initialized.
  static bool get isInitialized => _instance != null;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(syncAccounts);
            await m.createTable(syncQueueItems);
            await m.createTable(remoteIdMappings);
          }
        },
      );

  /// Initializes the database.
  ///
  /// Must be called once at app startup (in main.dart).
  static Future<void> initialize() async {
    if (_instance != null) return;

    final stopwatch = Stopwatch()..start();

    _instance = AppDatabase._();

    // Ensure tables are created by running a simple query
    await _instance!.customSelect('SELECT 1').get();

    stopwatch.stop();
    developer.log(
      'Database initialized in ${stopwatch.elapsedMilliseconds}ms',
      name: 'Reeder.Database',
    );
  }

  /// Closes the database connection and resets the singleton.
  ///
  /// Named `shutdown` to avoid conflict with [GeneratedDatabase.close].
  static Future<void> shutdown() async {
    await _instance?.close();
    _instance = null;
  }

  /// Clears all data from the database.
  /// Use with caution - this is irreversible.
  Future<void> clearAll() async {
    await transaction(() async {
      await delete(feedItems).go();
      await delete(taggedItems).go();
      await delete(feeds).go();
      await delete(tags).go();
      await delete(folders).go();
      await delete(filters).go();
      await delete(scrollPositions).go();
      await delete(appSettingsTable).go();
      await delete(syncAccounts).go();
      await delete(syncQueueItems).go();
      await delete(remoteIdMappings).go();
    });
  }

  /// Executes a query with performance logging.
  ///
  /// Logs a warning if the query takes longer than [warnThresholdMs].
  static Future<T> timedQuery<T>(
    String queryName,
    Future<T> Function() query, {
    int warnThresholdMs = 50,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await query();
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed > warnThresholdMs) {
        developer.log(
          'SLOW QUERY [$queryName]: ${elapsed}ms (threshold: ${warnThresholdMs}ms)',
          name: 'Reeder.Database',
          level: 900,
        );
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      developer.log(
        'FAILED QUERY [$queryName]: ${stopwatch.elapsedMilliseconds}ms - $e',
        name: 'Reeder.Database',
        level: 1000,
        error: e,
      );
      rethrow;
    }
  }

  /// Returns database statistics for debugging.
  Future<Map<String, int>> getStats() async {
    return {
      'feeds': (await (selectOnly(feeds)..addColumns([feeds.id.count()])).getSingle()).read(feeds.id.count())!,
      'feedItems': (await (selectOnly(feedItems)..addColumns([feedItems.id.count()])).getSingle()).read(feedItems.id.count())!,
      'tags': (await (selectOnly(tags)..addColumns([tags.id.count()])).getSingle()).read(tags.id.count())!,
      'taggedItems': (await (selectOnly(taggedItems)..addColumns([taggedItems.id.count()])).getSingle()).read(taggedItems.id.count())!,
      'folders': (await (selectOnly(folders)..addColumns([folders.id.count()])).getSingle()).read(folders.id.count())!,
      'filters': (await (selectOnly(filters)..addColumns([filters.id.count()])).getSingle()).read(filters.id.count())!,
    };
  }
}

/// Opens a native SQLite connection for the database.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'reeder.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
