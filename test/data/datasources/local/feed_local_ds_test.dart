import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/feed_local_ds.dart';
import 'package:reeder/data/models/feed.dart';

void main() {
  late AppDatabase testDb;
  late FeedLocalDataSource dataSource;

  setUp(() async {
    testDb = AppDatabase.forTesting();
    dataSource = FeedLocalDataSource(db: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('FeedLocalDataSource - upsert', () {
    test('should insert a new feed', () async {
      final feed = FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final id = await dataSource.upsert(feed);

      expect(id, greaterThan(0));

      final inserted = await dataSource.getById(id);
      expect(inserted, isNotNull);
      expect(inserted!.title, 'Test Feed');
      expect(inserted.feedUrl, 'https://example.com/feed');
    });

    test('should update an existing feed', () async {
      final feed = FeedsCompanion.insert(
        title: 'Original Title',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final id = await dataSource.upsert(feed);

      await Future.delayed(const Duration(milliseconds: 10));

      final updated = FeedsCompanion(
        id: Value(id),
        title: const Value('Updated Title'),
        feedUrl: const Value('https://example.com/feed'),
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: Value(DateTime(2025, 1, 1)),
        updatedAt: Value(DateTime(2025, 1, 1)),
      );

      await dataSource.upsert(updated);

      final result = await dataSource.getById(id);
      expect(result, isNotNull);
      expect(result!.title, 'Updated Title');
      expect(result.updatedAt.isAfter(DateTime(2025, 1, 1)), isTrue);
    });

    test('should insert feed with accountId', () async {
      final feed = FeedsCompanion.insert(
        title: 'Account Feed',
        feedUrl: 'https://example.com/account-feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final id = await dataSource.upsert(feed, accountId: 123);

      final inserted = await dataSource.getById(id, accountId: 123);
      expect(inserted, isNotNull);
      expect(inserted!.accountId, 123);
    });

    test('should insert multiple feeds with upsertAll', () async {
      final feeds = [
        FeedsCompanion.insert(
          title: 'Feed 1',
          feedUrl: 'https://example.com/feed1',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Feed 2',
          feedUrl: 'https://example.com/feed2',
          type: Value(FeedType.podcast),
          defaultViewer: Value(ViewerType.reader),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ];

      await dataSource.upsertAll(feeds);

      final all = await dataSource.getAll();
      expect(all.length, 2);
    });

    test('should insert multiple feeds with accountId using upsertAll', () async {
      final feeds = [
        FeedsCompanion.insert(
          title: 'Account Feed 1',
          feedUrl: 'https://example.com/account-feed1',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Account Feed 2',
          feedUrl: 'https://example.com/account-feed2',
          type: Value(FeedType.video),
          defaultViewer: Value(ViewerType.browser),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ];

      await dataSource.upsertAll(feeds, accountId: 456);

      final all = await dataSource.getAll(accountId: 456);
      expect(all.length, 2);
      expect(all.every((f) => f.accountId == 456), isTrue);
    });
  });

  group('FeedLocalDataSource - getById', () {
    test('should return null for non-existent id', () async {
      final result = await dataSource.getById(999);
      expect(result, isNull);
    });

    test('should return feed by id', () async {
      final feed = FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final id = await dataSource.upsert(feed);

      final result = await dataSource.getById(id);
      expect(result, isNotNull);
      expect(result!.id, id);
    });

    test('should return null when accountId does not match', () async {
      final feed = FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final id = await dataSource.upsert(feed, accountId: 100);

      final result = await dataSource.getById(id, accountId: 200);
      expect(result, isNull);
    });
  });

  group('FeedLocalDataSource - getByUrl', () {
    test('should return null for non-existent url', () async {
      final result = await dataSource.getByUrl('https://nonexistent.com/feed');
      expect(result, isNull);
    });

    test('should return feed by url', () async {
      final feed = FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await dataSource.upsert(feed);

      final result = await dataSource.getByUrl('https://example.com/feed');
      expect(result, isNotNull);
      expect(result!.feedUrl, 'https://example.com/feed');
    });

    test('should return null when accountId does not match', () async {
      final feed = FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await dataSource.upsert(feed, accountId: 100);

      final result = await dataSource.getByUrl('https://example.com/feed', accountId: 200);
      expect(result, isNull);
    });
  });

  group('FeedLocalDataSource - getAll', () {
    test('should return empty list when no feeds', () async {
      final result = await dataSource.getAll();
      expect(result, isEmpty);
    });

    test('should return all feeds', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Feed 1',
        feedUrl: 'https://example.com/feed1',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Feed 2',
        feedUrl: 'https://example.com/feed2',
        type: Value(FeedType.podcast),
        defaultViewer: Value(ViewerType.reader),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final result = await dataSource.getAll();
      expect(result.length, 2);
    });

    test('should filter by accountId', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Account 1 Feed',
        feedUrl: 'https://example.com/feed1',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 1);
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Account 2 Feed',
        feedUrl: 'https://example.com/feed2',
        type: Value(FeedType.podcast),
        defaultViewer: Value(ViewerType.reader),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 2);

      final result1 = await dataSource.getAll(accountId: 1);
      final result2 = await dataSource.getAll(accountId: 2);

      expect(result1.length, 1);
      expect(result2.length, 1);
      expect(result1[0].accountId, 1);
      expect(result2[0].accountId, 2);
    });
  });

  group('FeedLocalDataSource - getByType', () {
    test('should return feeds of specific type', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Blog Feed',
        feedUrl: 'https://example.com/blog',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Podcast Feed',
        feedUrl: 'https://example.com/podcast',
        type: Value(FeedType.podcast),
        defaultViewer: Value(ViewerType.reader),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final blogFeeds = await dataSource.getByType(FeedType.blog);
      final podcastFeeds = await dataSource.getByType(FeedType.podcast);

      expect(blogFeeds.length, 1);
      expect(podcastFeeds.length, 1);
      expect(blogFeeds[0].type, FeedType.blog);
      expect(podcastFeeds[0].type, FeedType.podcast);
    });

    test('should filter by accountId when getting by type', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Blog Feed 1',
        feedUrl: 'https://example.com/blog1',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 1);
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Blog Feed 2',
        feedUrl: 'https://example.com/blog2',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 2);

      final result = await dataSource.getByType(FeedType.blog, accountId: 1);
      expect(result.length, 1);
      expect(result[0].accountId, 1);
    });
  });

  group('FeedLocalDataSource - getByFolderId', () {
    test('should return feeds in specific folder', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Folder Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        folderId: Value(10),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Root Feed',
        feedUrl: 'https://example.com/root',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final folderFeeds = await dataSource.getByFolderId(10);
      expect(folderFeeds.length, 1);
      expect(folderFeeds[0].folderId, 10);
    });

    test('should filter by accountId when getting by folder', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Folder Feed 1',
        feedUrl: 'https://example.com/feed1',
        type: Value(FeedType.blog),
        folderId: Value(10),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 1);
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Folder Feed 2',
        feedUrl: 'https://example.com/feed2',
        type: Value(FeedType.blog),
        folderId: Value(10),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 2);

      final result = await dataSource.getByFolderId(10, accountId: 1);
      expect(result.length, 1);
      expect(result[0].accountId, 1);
    });
  });

  group('FeedLocalDataSource - getRootFeeds', () {
    test('should return feeds without folder', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Root Feed 1',
        feedUrl: 'https://example.com/root1',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Folder Feed',
        feedUrl: 'https://example.com/folder',
        type: Value(FeedType.blog),
        folderId: Value(10),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Root Feed 2',
        feedUrl: 'https://example.com/root2',
        type: Value(FeedType.podcast),
        defaultViewer: Value(ViewerType.reader),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final rootFeeds = await dataSource.getRootFeeds();
      expect(rootFeeds.length, 2);
      expect(rootFeeds.every((f) => f.folderId == null), isTrue);
    });

    test('should filter by accountId when getting root feeds', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Root Feed 1',
        feedUrl: 'https://example.com/root1',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 1);
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Root Feed 2',
        feedUrl: 'https://example.com/root2',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 2);

      final result = await dataSource.getRootFeeds(accountId: 1);
      expect(result.length, 1);
      expect(result[0].accountId, 1);
    });
  });

  group('FeedLocalDataSource - count', () {
    test('should return 0 when no feeds', () async {
      final count = await dataSource.count();
      expect(count, 0);
    });

    test('should return correct count', () async {
      await dataSource.upsertAll([
        FeedsCompanion.insert(
          title: 'Feed 1',
          feedUrl: 'https://example.com/feed1',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Feed 2',
          feedUrl: 'https://example.com/feed2',
          type: Value(FeedType.podcast),
          defaultViewer: Value(ViewerType.reader),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Feed 3',
          feedUrl: 'https://example.com/feed3',
          type: Value(FeedType.video),
          defaultViewer: Value(ViewerType.browser),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ]);

      final count = await dataSource.count();
      expect(count, 3);
    });

    test('should filter by accountId when counting', () async {
      await dataSource.upsertAll([
        FeedsCompanion.insert(
          title: 'Feed 1',
          feedUrl: 'https://example.com/feed1',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Feed 2',
          feedUrl: 'https://example.com/feed2',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ], accountId: 1);
      await dataSource.upsertAll([
        FeedsCompanion.insert(
          title: 'Feed 3',
          feedUrl: 'https://example.com/feed3',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ], accountId: 2);

      final count1 = await dataSource.count(accountId: 1);
      final count2 = await dataSource.count(accountId: 2);

      expect(count1, 2);
      expect(count2, 1);
    });
  });

  group('FeedLocalDataSource - delete', () {
    test('should delete feed by id', () async {
      final feed = FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final id = await dataSource.upsert(feed);

      final deleted = await dataSource.delete(id);
      expect(deleted, isTrue);

      final result = await dataSource.getById(id);
      expect(result, isNull);
    });

    test('should return false when deleting non-existent feed', () async {
      final deleted = await dataSource.delete(999);
      expect(deleted, isFalse);
    });
  });

  group('FeedLocalDataSource - deleteAll', () {
    test('should delete multiple feeds by ids', () async {
      final ids = <int>[];
      for (int i = 0; i < 3; i++) {
        final id = await dataSource.upsert(FeedsCompanion.insert(
          title: 'Feed $i',
          feedUrl: 'https://example.com/feed$i',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ));
        ids.add(id);
      }

      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Keep Feed',
        feedUrl: 'https://example.com/keep',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final deletedCount = await dataSource.deleteAll(ids);
      expect(deletedCount, 3);

      final remaining = await dataSource.getAll();
      expect(remaining.length, 1);
      expect(remaining[0].title, 'Keep Feed');
    });

    test('should return 0 when deleting empty list', () async {
      final deletedCount = await dataSource.deleteAll([]);
      expect(deletedCount, 0);
    });
  });

  group('FeedLocalDataSource - exists', () {
    test('should return false for non-existent feed', () async {
      final exists = await dataSource.exists('https://nonexistent.com/feed');
      expect(exists, isFalse);
    });

    test('should return true for existing feed', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final exists = await dataSource.exists('https://example.com/feed');
      expect(exists, isTrue);
    });

    test('should return false when accountId does not match', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 100);

      final exists = await dataSource.exists('https://example.com/feed', accountId: 200);
      expect(exists, isFalse);
    });

    test('should return true when accountId matches', () async {
      await dataSource.upsert(FeedsCompanion.insert(
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 100);

      final exists = await dataSource.exists('https://example.com/feed', accountId: 100);
      expect(exists, isTrue);
    });
  });

  group('FeedLocalDataSource - accountId isolation', () {
    test('should isolate data by accountId across all operations', () async {
      // Create feeds for different accounts
      final account1Id = await dataSource.upsert(FeedsCompanion.insert(
        title: 'Account 1 Feed',
        feedUrl: 'https://example.com/account1',
        type: Value(FeedType.blog),
        defaultViewer: Value(ViewerType.article),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 1);

      final account2Id = await dataSource.upsert(FeedsCompanion.insert(
        title: 'Account 2 Feed',
        feedUrl: 'https://example.com/account2',
        type: Value(FeedType.podcast),
        defaultViewer: Value(ViewerType.reader),
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ), accountId: 2);

      // Verify getById isolates by accountId
      expect(await dataSource.getById(account1Id, accountId: 1), isNotNull);
      expect(await dataSource.getById(account1Id, accountId: 2), isNull);
      expect(await dataSource.getById(account2Id, accountId: 2), isNotNull);
      expect(await dataSource.getById(account2Id, accountId: 1), isNull);

      // Verify getByUrl isolates by accountId
      expect(await dataSource.getByUrl('https://example.com/account1', accountId: 1), isNotNull);
      expect(await dataSource.getByUrl('https://example.com/account1', accountId: 2), isNull);

      // Verify getAll isolates by accountId
      final account1Feeds = await dataSource.getAll(accountId: 1);
      final account2Feeds = await dataSource.getAll(accountId: 2);
      expect(account1Feeds.length, 1);
      expect(account2Feeds.length, 1);
      expect(account1Feeds[0].accountId, 1);
      expect(account2Feeds[0].accountId, 2);

      // Verify count isolates by accountId
      expect(await dataSource.count(accountId: 1), 1);
      expect(await dataSource.count(accountId: 2), 1);

      // Verify exists isolates by accountId
      expect(await dataSource.exists('https://example.com/account1', accountId: 1), isTrue);
      expect(await dataSource.exists('https://example.com/account1', accountId: 2), isFalse);

      // Verify delete only affects specified account's feed
      await dataSource.delete(account1Id);
      expect(await dataSource.count(accountId: 1), 0);
      expect(await dataSource.count(accountId: 2), 1);
    });
  });

  group('FeedLocalDataSource - mixed feed types', () {
    test('should handle all feed types', () async {
      final feeds = [
        FeedsCompanion.insert(
          title: 'Blog Feed',
          feedUrl: 'https://example.com/blog',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Podcast Feed',
          feedUrl: 'https://example.com/podcast',
          type: Value(FeedType.podcast),
          defaultViewer: Value(ViewerType.reader),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Video Feed',
          feedUrl: 'https://example.com/video',
          type: Value(FeedType.video),
          defaultViewer: Value(ViewerType.browser),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Mixed Feed',
          feedUrl: 'https://example.com/mixed',
          type: Value(FeedType.mixed),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ];

      await dataSource.upsertAll(feeds);

      expect(await dataSource.getByType(FeedType.blog), hasLength(1));
      expect(await dataSource.getByType(FeedType.podcast), hasLength(1));
      expect(await dataSource.getByType(FeedType.video), hasLength(1));
      expect(await dataSource.getByType(FeedType.mixed), hasLength(1));
    });
  });

  group('FeedLocalDataSource - all viewer types', () {
    test('should handle all viewer types', () async {
      final feeds = [
        FeedsCompanion.insert(
          title: 'Article Viewer Feed',
          feedUrl: 'https://example.com/article',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.article),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Reader Viewer Feed',
          feedUrl: 'https://example.com/reader',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.reader),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
        FeedsCompanion.insert(
          title: 'Browser Viewer Feed',
          feedUrl: 'https://example.com/browser',
          type: Value(FeedType.blog),
          defaultViewer: Value(ViewerType.browser),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ];

      await dataSource.upsertAll(feeds);

      final all = await dataSource.getAll();
      expect(all.length, 3);
      expect(anyOf(all, (f) => f.defaultViewer == ViewerType.article), isTrue);
      expect(anyOf(all, (f) => f.defaultViewer == ViewerType.reader), isTrue);
      expect(anyOf(all, (f) => f.defaultViewer == ViewerType.browser), isTrue);
    });
  });
}

bool anyOf<T>(List<T> list, bool Function(T) predicate) {
  return list.any(predicate);
}
