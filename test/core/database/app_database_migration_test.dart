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
    expect(await userVersion(db), 8);
  });

  test('v7 database lacking notifications_enabled gets the columns added', () async {
    final file = createVersion7Database(withNotificationsColumns: false);
    final db = openDatabase(file);
    addTearDown(db.close);

    expect(await userVersion(db), 8);

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
}
