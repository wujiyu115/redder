import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/article_local_ds.dart';
import 'package:reeder/data/models/feed_item.dart';

void main() {
  late AppDatabase testDb;
  late ArticleLocalDataSource dataSource;

  setUp(() async {
    testDb = AppDatabase.forTesting();
    dataSource = ArticleLocalDataSource(db: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('upsert', () {
    test('should insert a new feed item', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final id = await dataSource.upsert(item);
      expect(id, isPositive);

      final retrieved = await dataSource.getById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Test Article'));
    });

    test('should update an existing feed item', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Original Title',
        url: 'https://example.com/article2',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final id = await dataSource.upsert(item);

      final updatedItem = FeedItemsCompanion.insert(
        id: Value(id),
        feedId: 1,
        title: 'Updated Title',
        url: 'https://example.com/article2',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await dataSource.upsert(updatedItem);

      final retrieved = await dataSource.getById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Updated Title'));
    });

    test('should insert item with accountId', () async {
      const accountId = 1;
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article3',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final id = await dataSource.upsert(item, accountId: accountId);

      final retrieved = await dataSource.getById(id, accountId: accountId);
      expect(retrieved, isNotNull);
      expect(retrieved!.accountId, equals(accountId));
    });
  });

  group('upsertAll', () {
    test('should insert multiple feed items', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 3',
          url: 'https://example.com/article3',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final allItems = await dataSource.getAll();
      expect(allItems.length, equals(3));
    });

    test('should insert multiple items with accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items, accountId: accountId);

      final accountItems = await dataSource.getAll(accountId: accountId);
      expect(accountItems.length, equals(2));
      for (final item in accountItems) {
        expect(item.accountId, equals(accountId));
      }
    });
  });

  group('getById', () {
    test('should retrieve item by ID', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final id = await dataSource.upsert(item);

      final retrieved = await dataSource.getById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(id));
      expect(retrieved.title, equals('Test Article'));
    });

    test('should return null for non-existent ID', () async {
      final retrieved = await dataSource.getById(99999);
      expect(retrieved, isNull);
    });

    test('should filter by accountId', () async {
      const accountId1 = 1;
      const accountId2 = 2;

      final item1 = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Account 1 Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final item2 = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Account 2 Article',
        url: 'https://example.com/article2',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final id1 = await dataSource.upsert(item1, accountId: accountId1);
      final id2 = await dataSource.upsert(item2, accountId: accountId2);

      final retrieved1 = await dataSource.getById(id1, accountId: accountId1);
      expect(retrieved1, isNotNull);
      expect(retrieved1!.accountId, equals(accountId1));

      final retrieved2 = await dataSource.getById(id2, accountId: accountId2);
      expect(retrieved2, isNotNull);
      expect(retrieved2!.accountId, equals(accountId2));

      final wrongAccount = await dataSource.getById(id1, accountId: accountId2);
      expect(wrongAccount, isNull);
    });
  });

  group('getByUrl', () {
    test('should retrieve item by URL', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await dataSource.upsert(item);

      final retrieved = await dataSource.getByUrl('https://example.com/article1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Test Article'));
    });

    test('should return null for non-existent URL', () async {
      final retrieved = await dataSource.getByUrl('https://example.com/nonexistent');
      expect(retrieved, isNull);
    });

    test('should filter by accountId', () async {
      const accountId1 = 1;
      const accountId2 = 2;
      const url1 = 'https://example.com/article1';
      const url2 = 'https://example.com/article2';

      final item1 = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Account 1 Article',
        url: url1,
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final item2 = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Account 2 Article',
        url: url2,
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await dataSource.upsert(item1, accountId: accountId1);
      await dataSource.upsert(item2, accountId: accountId2);

      final retrieved1 = await dataSource.getByUrl(url1, accountId: accountId1);
      expect(retrieved1, isNotNull);
      expect(retrieved1!.accountId, equals(accountId1));

      final retrieved2 = await dataSource.getByUrl(url2, accountId: accountId2);
      expect(retrieved2, isNotNull);
      expect(retrieved2!.accountId, equals(accountId2));
    });
  });

  group('getByFeedId', () {
    test('should retrieve items by feed ID', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 2,
          title: 'Article 3',
          url: 'https://example.com/article3',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final feed1Items = await dataSource.getByFeedId(1);
      expect(feed1Items.length, equals(2));

      final feed2Items = await dataSource.getByFeedId(2);
      expect(feed2Items.length, equals(1));
    });

    test('should support pagination with limit and offset', () async {
      final items = List.generate(
        10,
        (index) => FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article $index',
          url: 'https://example.com/article$index',
          publishedAt: DateTime(2024, 1, index + 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      await dataSource.upsertAll(items);

      final page1 = await dataSource.getByFeedId(1, limit: 5, offset: 0);
      expect(page1.length, equals(5));

      final page2 = await dataSource.getByFeedId(1, limit: 5, offset: 5);
      expect(page2.length, equals(5));

      expect(page1[0].id, isNot(equals(page2[0].id)));
    });

    test('should order items by publishedAt descending', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Oldest',
          url: 'https://example.com/oldest',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Middle',
          url: 'https://example.com/middle',
          publishedAt: DateTime(2024, 1, 15),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Newest',
          url: 'https://example.com/newest',
          publishedAt: DateTime(2024, 2, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final feedItems = await dataSource.getByFeedId(1);
      expect(feedItems[0].title, equals('Newest'));
      expect(feedItems[1].title, equals('Middle'));
      expect(feedItems[2].title, equals('Oldest'));
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Article',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsert(items[0], accountId: accountId);
      await dataSource.upsert(items[1]);

      final accountItems = await dataSource.getByFeedId(1, accountId: accountId);
      expect(accountItems.length, equals(1));
      expect(accountItems[0].accountId, equals(accountId));
    });
  });

  group('getAll', () {
    test('should retrieve all items', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 2,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final allItems = await dataSource.getAll();
      expect(allItems.length, equals(2));
    });

    test('should filter unread items', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Read Article',
          url: 'https://example.com/read',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unread Article',
          url: 'https://example.com/unread',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      final unreadItems = await dataSource.getAll(unreadOnly: true);
      expect(unreadItems.length, equals(1));
      expect(unreadItems[0].title, equals('Unread Article'));
    });

    test('should support pagination', () async {
      final items = List.generate(
        10,
        (index) => FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article $index',
          url: 'https://example.com/article$index',
          publishedAt: DateTime(2024, 1, index + 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      await dataSource.upsertAll(items);

      final page1 = await dataSource.getAll(limit: 5, offset: 0);
      expect(page1.length, equals(5));

      final page2 = await dataSource.getAll(limit: 5, offset: 5);
      expect(page2.length, equals(5));
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Article',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      final accountItems = await dataSource.getAll(accountId: accountId);
      expect(accountItems.length, equals(1));
      expect(accountItems[0].accountId, equals(accountId));
    });
  });

  group('markAsRead / markAsUnread', () {
    test('should mark item as read', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isRead: const Value(false),
      );

      final id = await dataSource.upsert(item);

      await dataSource.markAsRead(id);

      final retrieved = await dataSource.getById(id);
      expect(retrieved!.isRead, isTrue);
    });

    test('should mark item as unread', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isRead: const Value(true),
      );

      final id = await dataSource.upsert(item);

      await dataSource.markAsUnread(id);

      final retrieved = await dataSource.getById(id);
      expect(retrieved!.isRead, isFalse);
    });
  });

  group('markAsStarred / markAsUnstarred', () {
    test('should mark item as starred', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isStarred: const Value(false),
      );

      final id = await dataSource.upsert(item);

      await dataSource.markAsStarred(id);

      final retrieved = await dataSource.getById(id);
      expect(retrieved!.isStarred, isTrue);
    });

    test('should mark item as unstarred', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isStarred: const Value(true),
      );

      final id = await dataSource.upsert(item);

      await dataSource.markAsUnstarred(id);

      final retrieved = await dataSource.getById(id);
      expect(retrieved!.isStarred, isFalse);
    });
  });

  group('markAllAsRead', () {
    test('should mark all items as read', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      await dataSource.markAllAsRead();

      final allItems = await dataSource.getAll();
      for (final item in allItems) {
        expect(item.isRead, isTrue);
      }
    });

    test('should mark all items as read for specific account', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Article',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      await dataSource.markAllAsRead(accountId: accountId);

      final accountItems = await dataSource.getAll(accountId: accountId);
      expect(accountItems.length, equals(1));
      expect(accountItems[0].isRead, isTrue);

      final otherItems = await dataSource.getAll();
      final unreadItems = otherItems.where((item) => !item.isRead).toList();
      expect(unreadItems.length, equals(1));
    });
  });

  group('markAllAsReadForFeed', () {
    test('should mark all items for a feed as read', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Feed 1 Article',
          url: 'https://example.com/feed1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 2,
          title: 'Feed 2 Article',
          url: 'https://example.com/feed2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      await dataSource.markAllAsReadForFeed(1);

      final feed1Items = await dataSource.getByFeedId(1);
      for (final item in feed1Items) {
        expect(item.isRead, isTrue);
      }

      final feed2Items = await dataSource.getByFeedId(2);
      for (final item in feed2Items) {
        expect(item.isRead, isFalse);
      }
    });

    test('should mark all items for a feed as read for specific account', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Article',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      await dataSource.markAllAsReadForFeed(1, accountId: accountId);

      final accountItems = await dataSource.getByFeedId(1, accountId: accountId);
      expect(accountItems.length, equals(1));
      expect(accountItems[0].isRead, isTrue);

      final otherItems = await dataSource.getByFeedId(1);
      final unreadItems = otherItems.where((item) => !item.isRead).toList();
      expect(unreadItems.length, equals(1));
    });
  });

  group('delete', () {
    test('should delete item by ID', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final id = await dataSource.upsert(item);

      final deleted = await dataSource.delete(id);
      expect(deleted, isTrue);

      final retrieved = await dataSource.getById(id);
      expect(retrieved, isNull);
    });

    test('should return false when deleting non-existent item', () async {
      final deleted = await dataSource.delete(99999);
      expect(deleted, isFalse);
    });
  });

  group('deleteByFeedId', () {
    test('should delete all items for a feed', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Feed 1 Article',
          url: 'https://example.com/feed1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 2,
          title: 'Feed 2 Article',
          url: 'https://example.com/feed2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      await dataSource.deleteByFeedId(1);

      final feed1Items = await dataSource.getByFeedId(1);
      expect(feed1Items, isEmpty);

      final feed2Items = await dataSource.getByFeedId(2);
      expect(feed2Items.length, equals(1));
    });
  });

  group('search', () {
    test('should search items by title', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Flutter Development',
          url: 'https://example.com/flutter',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Dart Programming',
          url: 'https://example.com/dart',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Mobile Development',
          url: 'https://example.com/mobile',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final results = await dataSource.search('Development');
      expect(results.length, equals(2));
    });

    test('should limit search results', () async {
      final items = List.generate(
        10,
        (index) => FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Test Article $index',
          url: 'https://example.com/article$index',
          publishedAt: DateTime(2024, 1, index + 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      await dataSource.upsertAll(items);

      final results = await dataSource.search('Test', limit: 5);
      expect(results.length, lessThanOrEqualTo(5));
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Flutter Development',
          url: 'https://example.com/flutter',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Dart Programming',
          url: 'https://example.com/dart',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      final results = await dataSource.search('Flutter', accountId: accountId);
      expect(results.length, equals(1));
      expect(results[0].accountId, equals(accountId));
    });
  });

  group('exists', () {
    test('should return true when item exists', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await dataSource.upsert(item);

      final exists = await dataSource.exists('https://example.com/article1');
      expect(exists, isTrue);
    });

    test('should return false when item does not exist', () async {
      final exists = await dataSource.exists('https://example.com/nonexistent');
      expect(exists, isFalse);
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      const url = 'https://example.com/article1';

      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: url,
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await dataSource.upsert(item, accountId: accountId);

      final exists = await dataSource.exists(url, accountId: accountId);
      expect(exists, isTrue);

      final notExists = await dataSource.exists(url, accountId: 999);
      expect(notExists, isFalse);
    });
  });

  group('count', () {
    test('should return total count of items', () async {
      final items = List.generate(
        5,
        (index) => FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article $index',
          url: 'https://example.com/article$index',
          publishedAt: DateTime(2024, 1, index + 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      await dataSource.upsertAll(items);

      final count = await dataSource.count();
      expect(count, equals(5));
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Article',
          url: 'https://example.com/article3',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[2]);

      final totalCount = await dataSource.count();
      expect(totalCount, equals(3));

      final accountCount = await dataSource.count(accountId: accountId);
      expect(accountCount, equals(2));
    });
  });

  group('unreadCountForFeed', () {
    test('should return count of unread items for a feed', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Read Article',
          url: 'https://example.com/read',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unread Article 1',
          url: 'https://example.com/unread1',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unread Article 2',
          url: 'https://example.com/unread2',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      final unreadCount = await dataSource.unreadCountForFeed(1);
      expect(unreadCount, equals(2));
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Unread',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Unread',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      final accountUnreadCount = await dataSource.unreadCountForFeed(1, accountId: accountId);
      expect(accountUnreadCount, equals(1));

      final totalUnreadCount = await dataSource.unreadCountForFeed(1);
      expect(totalUnreadCount, equals(2));
    });
  });

  group('markMultipleAsRead / markMultipleAsUnread', () {
    test('should mark multiple items as read', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 3',
          url: 'https://example.com/article3',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      final ids = [1, 2];
      await dataSource.markMultipleAsRead(ids);

      final item1 = await dataSource.getById(1);
      final item2 = await dataSource.getById(2);
      final item3 = await dataSource.getById(3);

      expect(item1!.isRead, isTrue);
      expect(item2!.isRead, isTrue);
      expect(item3!.isRead, isFalse);
    });

    test('should mark multiple items as unread', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 1',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article 2',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(true),
        ),
      ];

      await dataSource.upsertAll(items);

      final ids = [1, 2];
      await dataSource.markMultipleAsUnread(ids);

      final item1 = await dataSource.getById(1);
      final item2 = await dataSource.getById(2);

      expect(item1!.isRead, isFalse);
      expect(item2!.isRead, isFalse);
    });
  });

  group('toggleStarred', () {
    test('should toggle starred state from false to true', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isStarred: const Value(false),
      );

      final id = await dataSource.upsert(item);

      await dataSource.toggleStarred(id);

      final retrieved = await dataSource.getById(id);
      expect(retrieved!.isStarred, isTrue);
    });

    test('should toggle starred state from true to false', () async {
      final item = FeedItemsCompanion.insert(
        feedId: 1,
        title: 'Test Article',
        url: 'https://example.com/article1',
        publishedAt: DateTime(2024, 1, 1),
        fetchedAt: DateTime.now(),
        createdAt: DateTime.now(),
        isStarred: const Value(true),
      );

      final id = await dataSource.upsert(item);

      await dataSource.toggleStarred(id);

      final retrieved = await dataSource.getById(id);
      expect(retrieved!.isStarred, isFalse);
    });
  });

  group('getStarred', () {
    test('should retrieve all starred items', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Starred Article',
          url: 'https://example.com/starred',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unstarred Article',
          url: 'https://example.com/unstarred',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      final starredItems = await dataSource.getStarred();
      expect(starredItems.length, equals(1));
      expect(starredItems[0].title, equals('Starred Article'));
    });

    test('should support pagination', () async {
      final items = List.generate(
        5,
        (index) => FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Starred Article $index',
          url: 'https://example.com/starred$index',
          publishedAt: DateTime(2024, 1, index + 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(true),
        ),
      );

      await dataSource.upsertAll(items);

      final page1 = await dataSource.getStarred(limit: 3, offset: 0);
      expect(page1.length, equals(3));

      final page2 = await dataSource.getStarred(limit: 3, offset: 3);
      expect(page2.length, equals(2));
    });

    test('should filter by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Starred',
          url: 'https://example.com/starred1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Starred',
          url: 'https://example.com/starred2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(true),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      final accountStarred = await dataSource.getStarred(accountId: accountId);
      expect(accountStarred.length, equals(1));
      expect(accountStarred[0].accountId, equals(accountId));
    });
  });

  group('getUnreadIds / getStarredIds', () {
    test('should get all unread item IDs', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Read Article',
          url: 'https://example.com/read',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unread Article 1',
          url: 'https://example.com/unread1',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unread Article 2',
          url: 'https://example.com/unread2',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsertAll(items);

      final unreadIds = await dataSource.getUnreadIds();
      expect(unreadIds.length, equals(2));
    });

    test('should get all starred item IDs', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Starred Article 1',
          url: 'https://example.com/starred1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(true),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Unstarred Article',
          url: 'https://example.com/unstarred',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Starred Article 2',
          url: 'https://example.com/starred2',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isStarred: const Value(true),
        ),
      ];

      await dataSource.upsertAll(items);

      final starredIds = await dataSource.getStarredIds();
      expect(starredIds.length, equals(2));
    });

    test('should filter unread IDs by accountId', () async {
      const accountId = 1;
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Unread',
          url: 'https://example.com/article1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'No Account Unread',
          url: 'https://example.com/article2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          isRead: const Value(false),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1]);

      final accountUnreadIds = await dataSource.getUnreadIds(accountId: accountId);
      expect(accountUnreadIds.length, equals(1));
    });
  });

  group('getByContentType', () {
    test('should retrieve items by content type', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Article',
          url: 'https://example.com/article',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          contentType: const Value(ContentType.article),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Audio',
          url: 'https://example.com/audio',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          contentType: const Value(ContentType.audio),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Video',
          url: 'https://example.com/video',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          contentType: const Value(ContentType.video),
        ),
      ];

      await dataSource.upsertAll(items);

      final articles = await dataSource.getByContentType(ContentType.article);
      expect(articles.length, equals(1));
      expect(articles[0].contentType, equals(ContentType.article));

      final audios = await dataSource.getByContentType(ContentType.audio);
      expect(audios.length, equals(1));
      expect(audios[0].contentType, equals(ContentType.audio));

      final videos = await dataSource.getByContentType(ContentType.video);
      expect(videos.length, equals(1));
      expect(videos[0].contentType, equals(ContentType.video));
    });

    test('should support pagination', () async {
      final items = List.generate(
        5,
        (index) => FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Audio $index',
          url: 'https://example.com/audio$index',
          publishedAt: DateTime(2024, 1, index + 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          contentType: const Value(ContentType.audio),
        ),
      );

      await dataSource.upsertAll(items);

      final page1 = await dataSource.getByContentType(ContentType.audio, limit: 3, offset: 0);
      expect(page1.length, equals(3));

      final page2 = await dataSource.getByContentType(ContentType.audio, limit: 3, offset: 3);
      expect(page2.length, equals(2));
    });
  });

  group('getByFeedIds', () {
    test('should retrieve items for multiple feed IDs', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Feed 1 Article',
          url: 'https://example.com/feed1',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 2,
          title: 'Feed 2 Article',
          url: 'https://example.com/feed2',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 3,
          title: 'Feed 3 Article',
          url: 'https://example.com/feed3',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final itemsForFeeds = await dataSource.getByFeedIds([1, 2]);
      expect(itemsForFeeds.length, equals(2));

      final titles = itemsForFeeds.map((item) => item.title).toList();
      expect(titles, contains('Feed 1 Article'));
      expect(titles, contains('Feed 2 Article'));
      expect(titles, isNot(contains('Feed 3 Article')));
    });

    test('should support pagination', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Feed 1 Article 1',
          url: 'https://example.com/feed1a',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Feed 1 Article 2',
          url: 'https://example.com/feed1b',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 2,
          title: 'Feed 2 Article',
          url: 'https://example.com/feed2',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final page1 = await dataSource.getByFeedIds([1, 2], limit: 2, offset: 0);
      expect(page1.length, equals(2));

      final page2 = await dataSource.getByFeedIds([1, 2], limit: 2, offset: 2);
      expect(page2.length, equals(1));
    });
  });

  group('deleteByAccountId', () {
    test('should delete all items for a specific account', () async {
      const accountId = 1;
      const otherAccountId = 2;

      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article 1',
          url: 'https://example.com/account1a',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 1 Article 2',
          url: 'https://example.com/account1b',
          publishedAt: DateTime(2024, 1, 2),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Account 2 Article',
          url: 'https://example.com/account2',
          publishedAt: DateTime(2024, 1, 3),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsert(items[0].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[1].copyWith(accountId: Value(accountId)), accountId: accountId);
      await dataSource.upsert(items[2].copyWith(accountId: Value(otherAccountId)), accountId: otherAccountId);

      await dataSource.deleteByAccountId(accountId);

      final account1Items = await dataSource.getAll(accountId: accountId);
      expect(account1Items, isEmpty);

      final account2Items = await dataSource.getAll(accountId: otherAccountId);
      expect(account2Items.length, equals(1));
    });
  });

  group('deleteOlderThan', () {
    test('should delete items older than specified date', () async {
      final items = [
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'Old Article',
          url: 'https://example.com/old',
          publishedAt: DateTime(2023, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        FeedItemsCompanion.insert(
          feedId: 1,
          title: 'New Article',
          url: 'https://example.com/new',
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await dataSource.upsertAll(items);

      final cutoffDate = DateTime(2023, 6, 1);
      await dataSource.deleteOlderThan(cutoffDate);

      final allItems = await dataSource.getAll();
      expect(allItems.length, equals(1));
      expect(allItems[0].title, equals('New Article'));
    });
  });
}
