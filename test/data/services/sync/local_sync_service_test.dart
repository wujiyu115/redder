import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/article_local_ds.dart';
import 'package:reeder/data/services/sync/local_sync_service.dart';

void main() {
  late AppDatabase db;
  late ArticleLocalDataSource articleDs;
  late LocalSyncService service;

  setUp(() {
    db = AppDatabase.forTesting();
    articleDs = ArticleLocalDataSource(db: db);
    service = LocalSyncService(articleDs: articleDs);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertArticle({bool starred = false, bool read = false}) {
    return articleDs.upsert(FeedItemsCompanion.insert(
      feedId: 1,
      title: 'T',
      url: 'https://example.com/${starred}_${read}_${DateTime.now().microsecondsSinceEpoch}',
      publishedAt: DateTime(2024, 1, 1),
      fetchedAt: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
      isStarred: Value(starred),
      isRead: Value(read),
    ));
  }

  group('markAsStarred / markAsUnstarred are idempotent (regression)', () {
    test('markAsStarred always sets starred = true', () async {
      final id = await insertArticle(starred: true);

      // Previously this toggled, so starring an already-starred item unstarred it.
      await service.markAsStarred([id.toString()]);

      final item = await articleDs.getById(id);
      expect(item!.isStarred, isTrue);
    });

    test('markAsStarred stars an unstarred item', () async {
      final id = await insertArticle(starred: false);

      await service.markAsStarred([id.toString()]);

      expect((await articleDs.getById(id))!.isStarred, isTrue);
    });

    test('markAsUnstarred always sets starred = false', () async {
      final id = await insertArticle(starred: false);

      // Previously this toggled, so unstarring an already-unstarred item starred it.
      await service.markAsUnstarred([id.toString()]);

      expect((await articleDs.getById(id))!.isStarred, isFalse);
    });

    test('markAsUnstarred unstars a starred item', () async {
      final id = await insertArticle(starred: true);

      await service.markAsUnstarred([id.toString()]);

      expect((await articleDs.getById(id))!.isStarred, isFalse);
    });
  });

  group('markAsRead / markAsUnread', () {
    test('markAsRead sets read = true', () async {
      final id = await insertArticle(read: false);

      await service.markAsRead([id.toString()]);

      expect((await articleDs.getById(id))!.isRead, isTrue);
    });

    test('markAsUnread sets read = false (regression: was a no-op)', () async {
      final id = await insertArticle(read: true);

      await service.markAsUnread([id.toString()]);

      expect((await articleDs.getById(id))!.isRead, isFalse);
    });
  });
}
