import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Regression tests for the v7 -> v8 migration (notifications_enabled).
///
/// Commit 03bc53b added the notifications_enabled columns to the Drift schema
/// without bumping schemaVersion, so databases created on that build already
/// contain the columns while still being recorded as user_version = 7. The v8
/// migration must skip the ALTER in that case instead of crashing with
/// "duplicate column name".
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('reeder_db_migration');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File createVersion7Database({required bool withNotificationsColumns}) {
    final file = File('${tempDir.path}/reeder.sqlite');
    final db = sqlite3.open(file.path);
    addTearDown(db.dispose);
    db.execute('CREATE TABLE feeds (id INTEGER PRIMARY KEY, url TEXT NOT NULL, account_id INTEGER)');
    db.execute('CREATE TABLE app_settings_table (id INTEGER PRIMARY KEY, theme TEXT NOT NULL)');
    // Present in every real v7 database; the v9 migration creates indexes on
    // them, so the fixture has to carry the columns those indexes need.
    db.execute(
      'CREATE TABLE feed_items (id INTEGER PRIMARY KEY, feed_id INTEGER NOT NULL, '
      'account_id INTEGER, published_at INTEGER NOT NULL, is_read INTEGER NOT NULL DEFAULT 0)',
    );
    db.execute(
      'CREATE TABLE tagged_items (id INTEGER PRIMARY KEY, tag_id INTEGER NOT NULL, '
      'item_id INTEGER NOT NULL, account_id INTEGER, tagged_at INTEGER NOT NULL)',
    );
    if (withNotificationsColumns) {
      db.execute('ALTER TABLE feeds ADD COLUMN notifications_enabled INTEGER NOT NULL DEFAULT 0');
      db.execute('ALTER TABLE app_settings_table ADD COLUMN notifications_enabled INTEGER NOT NULL DEFAULT 0');
    }
    db.execute('PRAGMA user_version = 7');
    return file;
  }

  AppDatabase openDatabase(File file) =>
      AppDatabase.forTestingOn(NativeDatabase(file));

  Future<int> userVersion(AppDatabase db) async =>
      (await db.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version');

  test('v7 database already having notifications_enabled migrates to v8 without crashing', () async {
    final file = createVersion7Database(withNotificationsColumns: true);
    final db = openDatabase(file);
    addTearDown(db.close);

    // Opening runs the migration; before the fix this threw
    // SqliteException(1): duplicate column name: notifications_enabled.
    expect(await userVersion(db), 9);
  });

  test('v7 database lacking notifications_enabled gets the columns added', () async {
    final file = createVersion7Database(withNotificationsColumns: false);
    final db = openDatabase(file);
    addTearDown(db.close);

    expect(await userVersion(db), 9);

    final feedsColumns =
        await db.customSelect('PRAGMA table_info(feeds)').get();
    expect(
      feedsColumns.map((row) => row.read<String>('name')),
      contains('notifications_enabled'),
    );

    final settingsColumns =
        await db.customSelect('PRAGMA table_info(app_settings_table)').get();
    expect(
      settingsColumns.map((row) => row.read<String>('name')),
      contains('notifications_enabled'),
    );
  });

  test('v9 migration adds the timeline indexes', () async {
    final file = createVersion7Database(withNotificationsColumns: true);
    final db = openDatabase(file);
    addTearDown(db.close);

    expect(await userVersion(db), 9);
    expect(
      await indexNames(db),
      containsAll([
        'idx_feed_items_account_read_published',
        'idx_feed_items_account_published',
        'idx_feed_items_published',
        'idx_feed_items_feed_published',
        'idx_tagged_items_tag_item',
      ]),
    );
  });

  test('the "all" timeline plan uses an index instead of a table scan', () async {
    final file = createVersion7Database(withNotificationsColumns: true);
    final db = openDatabase(file);
    addTearDown(db.close);

    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN SELECT * FROM feed_items '
          'WHERE account_id = 1 AND is_read = 0 '
          'ORDER BY published_at DESC LIMIT 30',
        )
        .get();
    final detail = plan.map((row) => row.read<String>('detail')).join(' | ');
    expect(detail, contains('USING INDEX idx_feed_items_account_read_published'));
    expect(detail, isNot(contains('TEMP B-TREE')));
  });

  test('a fresh database ships with the same indexes', () async {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);
    // Force the onCreate migration to run.
    await db.customSelect('SELECT 1').get();

    expect(
      await indexNames(db),
      containsAll([
        'idx_feed_items_account_read_published',
        'idx_feed_items_feed_published',
        'idx_tagged_items_tag_item',
      ]),
    );
  });
}

Future<List<String>> indexNames(AppDatabase db) async {
  final rows = await db.customSelect(
    "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
  ).get();
  return rows.map((row) => row.read<String>('name')).toList();
}
