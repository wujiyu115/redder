import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/sync_local_ds.dart';
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

  /// Real v7-era DDL (copied from a device database).
  ///
  /// The v11 migration recreates `feeds` / `feed_items` from the Drift
  /// definition, so the fixture has to carry every column the real schema had —
  /// a minimal stub would fail the NOT NULL columns the migration copies.
  File createVersion7Database({required bool withNotificationsColumns}) {
    final file = File('${tempDir.path}/reeder.sqlite');
    final db = sqlite3.open(file.path);
    addTearDown(db.dispose);
    db.execute(
      'CREATE TABLE feeds (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'title TEXT NOT NULL, description TEXT NULL, '
      // Global UNIQUE on the URL: what v11 removes.
      'feed_url TEXT NOT NULL UNIQUE, site_url TEXT NULL, icon_url TEXT NULL, '
      'type INTEGER NOT NULL DEFAULT 0, folder_id INTEGER NULL, '
      'sort_order INTEGER NOT NULL DEFAULT 0, last_fetched INTEGER NULL, '
      'fetch_duration_ms INTEGER NULL, default_viewer INTEGER NOT NULL DEFAULT 0, '
      'auto_reader_view INTEGER NOT NULL DEFAULT 0, '
      '${withNotificationsColumns ? 'notifications_enabled INTEGER NOT NULL DEFAULT 0, ' : ''}'
      'account_id INTEGER NULL, unread_count INTEGER NOT NULL DEFAULT 0, '
      'total_count INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL)',
    );
    db.execute(
        'CREATE TABLE app_settings_table (id INTEGER PRIMARY KEY, theme TEXT NOT NULL)');
    // Present in every real v7 database; the v9 migration creates indexes on
    // them, so the fixture has to carry the columns those indexes need.
    db.execute(
      'CREATE TABLE feed_items (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'feed_id INTEGER NOT NULL, title TEXT NOT NULL, summary TEXT NULL, '
      'content TEXT NULL, '
      // Global UNIQUE on the URL: what v11 removes.
      'url TEXT NOT NULL UNIQUE, image_url TEXT NULL, image_urls TEXT NULL, '
      'audio_url TEXT NULL, video_url TEXT NULL, audio_duration INTEGER NULL, '
      'author TEXT NULL, published_at INTEGER NOT NULL, '
      'fetched_at INTEGER NOT NULL, content_type INTEGER NOT NULL DEFAULT 0, '
      'is_read INTEGER NOT NULL DEFAULT 0, is_starred INTEGER NOT NULL DEFAULT 0, '
      'reading_time_minutes INTEGER NULL, account_id INTEGER NULL, '
      'word_count INTEGER NULL, created_at INTEGER NOT NULL)',
    );
    db.execute(
      'CREATE TABLE tagged_items (id INTEGER PRIMARY KEY, tag_id INTEGER NOT NULL, '
      'item_id INTEGER NOT NULL, account_id INTEGER, tagged_at INTEGER NOT NULL)',
    );
    // Presented in every real v7 database (added by the v2 migration).
    db.execute(
      'CREATE TABLE remote_id_mappings (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'account_id INTEGER NOT NULL, local_type TEXT NOT NULL, '
      'local_id INTEGER NOT NULL, remote_id TEXT NOT NULL)',
    );
    if (withNotificationsColumns) {
      // `feeds` already got the column from its DDL above (the real v7 build
      // that shipped both columns without bumping the version); settings does
      // not carry it yet.
      db.execute(
          'ALTER TABLE app_settings_table ADD COLUMN notifications_enabled INTEGER NOT NULL DEFAULT 0');
    }
    db.execute('PRAGMA user_version = 7');
    return file;
  }

  /// Minimal v9 database carrying duplicate `remote_id_mappings` rows, which
  /// the v10 migration has to collapse before it can add the unique index.
  File createVersion9DatabaseWithDuplicateMappings() {
    final file = createVersion7Database(withNotificationsColumns: true);
    final db = sqlite3.open(file.path);
    addTearDown(db.dispose);
    // The same feed mapping appended three times, like `insertOnConflictUpdate`
    // did on every sync (it only matched the auto-increment primary key).
    for (var i = 0; i < 3; i++) {
      db.execute(
        "INSERT INTO remote_id_mappings (account_id, local_type, local_id, remote_id) "
        "VALUES (1, 'feed', 7, 'feed/http://example.com/rss')",
      );
    }
    db.execute(
      "INSERT INTO remote_id_mappings (account_id, local_type, local_id, remote_id) "
      "VALUES (1, 'article', 8, 'tag:google.com,2005:reader/item/abc')",
    );
    db.execute('PRAGMA user_version = 9');
    return file;
  }

  AppDatabase openDatabase(File file) =>
      AppDatabase.forTestingOn(NativeDatabase(file));

  Future<int> userVersion(AppDatabase db) async =>
      (await db.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version');

  test(
      'v7 database already having notifications_enabled migrates to v8 without crashing',
      () async {
    final file = createVersion7Database(withNotificationsColumns: true);
    final db = openDatabase(file);
    addTearDown(db.close);

    // Opening runs the migration; before the fix this threw
    // SqliteException(1): duplicate column name: notifications_enabled.
    expect(await userVersion(db), 11);
  });

  test('v7 database lacking notifications_enabled gets the columns added',
      () async {
    final file = createVersion7Database(withNotificationsColumns: false);
    final db = openDatabase(file);
    addTearDown(db.close);

    expect(await userVersion(db), 11);

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

    expect(await userVersion(db), 11);
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

  test('the "all" timeline plan uses an index instead of a table scan',
      () async {
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
    expect(
        detail, contains('USING INDEX idx_feed_items_account_read_published'));
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
        'idx_remote_id_mappings_entity',
      ]),
    );
  });

  group('v10: remote id mappings', () {
    test('collapses duplicate mappings and adds the unique index', () async {
      final file = createVersion9DatabaseWithDuplicateMappings();
      final db = openDatabase(file);
      addTearDown(db.close);

      expect(await userVersion(db), 11);
      expect(await indexNames(db), contains('idx_remote_id_mappings_entity'));

      final rows = await db
          .customSelect('SELECT local_id, remote_id FROM remote_id_mappings')
          .get();
      expect(rows.length, 2);
      expect(
        rows.map((r) => r.read<String>('remote_id')),
        containsAll([
          'feed/http://example.com/rss',
          'tag:google.com,2005:reader/item/abc',
        ]),
      );
    });

    test('upsertMapping overwrites instead of appending', () async {
      await AppDatabase.initializeForTesting();
      addTearDown(AppDatabase.shutdown);
      final ds = SyncLocalDataSource();

      for (var i = 0; i < 3; i++) {
        await ds.upsertMapping(RemoteIdMappingsCompanion.insert(
          accountId: 1,
          localType: 'feed',
          localId: 7,
          remoteId: 'feed/http://example.com/rss$i',
        ));
      }

      final db = AppDatabase.instance;
      final rows = await db
          .customSelect('SELECT remote_id FROM remote_id_mappings')
          .get();
      expect(rows.length, 1);
      expect(rows.single.read<String>('remote_id'),
          'feed/http://example.com/rss2');
    });
  });

  group('v11: per-account feed / article URLs', () {
    /// A v10 database holding one feed and one article for account 1.
    File createVersion10DatabaseWithRows() {
      final file = createVersion7Database(withNotificationsColumns: true);
      final db = sqlite3.open(file.path);
      addTearDown(db.dispose);
      db.execute(
        "INSERT INTO feeds (id, title, feed_url, account_id, created_at, "
        "updated_at) VALUES (?, ?, ?, ?, ?, ?)",
        [1, '测试日报', 'http://news.example/rss', 1, 1700000000, 1700000000],
      );
      db.execute(
        "INSERT INTO feed_items (id, feed_id, title, url, published_at, "
        "fetched_at, account_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        [
          1,
          1,
          '第一篇',
          'http://news.example/rss/1',
          1700000000,
          1700000000,
          1,
          1700000000
        ],
      );
      db.execute('PRAGMA user_version = 10');
      return file;
    }

    test('drops the global UNIQUE on feed / article URLs, keeping the rows',
        () async {
      final file = createVersion10DatabaseWithRows();
      final db = openDatabase(file);
      addTearDown(db.close);

      expect(await userVersion(db), 11);

      expect(
        await indexNames(db),
        containsAll([
          'idx_feeds_account_feed_url',
          'idx_feeds_local_feed_url',
          'idx_feed_items_account_url',
          'idx_feed_items_local_url',
          // Recreated by the migration after the tables were rebuilt.
          'idx_feed_items_account_read_published',
        ]),
      );

      final feeds = await db.customSelect('SELECT title FROM feeds').get();
      expect(feeds.single.read<String>('title'), '测试日报');
      final items = await db.customSelect('SELECT title FROM feed_items').get();
      expect(items.single.read<String>('title'), '第一篇');
    });

    test('two accounts can keep the same feed and article URL', () async {
      final file = createVersion10DatabaseWithRows();
      final db = openDatabase(file);
      addTearDown(db.close);

      // The point of v11: a second account subscribing to the same feed used to
      // die with "UNIQUE constraint failed: feeds.feed_url".
      await db.customStatement(
        "INSERT INTO feeds (id, title, feed_url, account_id, created_at, "
        "updated_at) VALUES (2, 'dup title', 'http://news.example/rss', 2, "
        "1700000001, 1700000001)",
      );
      await db.customStatement(
        "INSERT INTO feed_items (id, feed_id, title, url, published_at, "
        "fetched_at, account_id, created_at) VALUES "
        "(2, 2, 'dup title', 'http://news.example/rss/1', 1700000000, "
        "1700000000, 2, 1700000001)",
      );

      final feeds =
          await db.customSelect('SELECT count(*) AS c FROM feeds').get();
      expect(feeds.single.read<int>('c'), 2);
      final items =
          await db.customSelect('SELECT count(*) AS c FROM feed_items').get();
      expect(items.single.read<int>('c'), 2);
    });

    test('the same account still cannot duplicate a feed or article URL',
        () async {
      final file = createVersion10DatabaseWithRows();
      final db = openDatabase(file);
      addTearDown(db.close);

      await expectLater(
        db.customStatement(
          "INSERT INTO feeds (id, title, feed_url, account_id, created_at, "
          "updated_at) VALUES (3, 'dup', 'http://news.example/rss', 1, "
          "1700000002, 1700000002)",
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO feed_items (id, feed_id, title, url, published_at, "
          "fetched_at, account_id, created_at) VALUES "
          "(3, 1, 'dup', 'http://news.example/rss/1', 1700000000, 1700000000, "
          "1, 1700000002)",
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('local-mode rows (NULL account) keep their own uniqueness', () async {
      final file = createVersion10DatabaseWithRows();
      final db = openDatabase(file);
      addTearDown(db.close);

      // SQLite treats NULLs as distinct, so the partial index has to catch this.
      await db.customStatement(
        "INSERT INTO feeds (id, title, feed_url, account_id, created_at, "
        "updated_at) VALUES (10, 'local', 'http://local.example/rss', NULL, "
        "1700000003, 1700000003)",
      );
      await expectLater(
        db.customStatement(
          "INSERT INTO feeds (id, title, feed_url, account_id, created_at, "
          "updated_at) VALUES (11, 'local2', 'http://local.example/rss', NULL, "
          "1700000004, 1700000004)",
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

Future<List<String>> indexNames(AppDatabase db) async {
  final rows = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
      )
      .get();
  return rows.map((row) => row.read<String>('name')).toList();
}
