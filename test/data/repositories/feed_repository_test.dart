import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/local/feed_local_ds.dart';
import 'package:reeder/data/datasources/remote/rss_remote_ds.dart';
import 'package:reeder/data/repositories/feed_repository.dart';
import 'package:reeder/data/services/sync/sync_models.dart';
import 'package:reeder/data/models/feed.dart';
import '../../test_mocks.mocks.dart';

void main() {
  late FeedRepository repository;
  late MockFeedLocalDataSource mockLocalDs;
  late MockRssRemoteDataSource mockRemoteDs;
  late MockSyncEngine mockSyncEngine;

  setUp(() {
    mockLocalDs = MockFeedLocalDataSource();
    mockRemoteDs = MockRssRemoteDataSource();
    mockSyncEngine = MockSyncEngine();

    repository = FeedRepository(
      localDs: mockLocalDs,
      remoteDs: mockRemoteDs,
      syncEngine: mockSyncEngine,
    );
  });

  group('addFeed', () {
    const testFeedUrl = 'https://example.com/feed.xml';
    const testAccountId = 1;

    test('should successfully add a new feed', () async {
      // Arrange
      final parsedFeed = ParsedFeed()
        ..title = 'Test Feed'
        ..feedUrl = testFeedUrl
        ..siteUrl = 'https://example.com'
        ..type = FeedType.blog;

      final feedParseResult = FeedParseResult(
        feed: parsedFeed,
        items: [],
      );

      final testFeed = Feed(
        id: 1,
        title: 'Test Feed',
        feedUrl: testFeedUrl,
        siteUrl: 'https://example.com',
        type: FeedType.blog,
        sortOrder: 0,
        defaultViewer: ViewerType.article,
        autoReaderView: false,
        notificationsEnabled: false,
        unreadCount: 0,
        totalCount: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(mockLocalDs.exists(testFeedUrl, accountId: testAccountId))
          .thenAnswer((_) async => false);
      when(mockRemoteDs.fetchFeed(testFeedUrl))
          .thenAnswer((_) async => feedParseResult);
      when(mockLocalDs.upsert(any, accountId: testAccountId))
          .thenAnswer((_) async => 1);
      when(mockLocalDs.getById(1, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => testFeed);
      when(mockLocalDs.getById(1))
          .thenAnswer((_) async => testFeed);

      // Act
      final result = await repository.addFeed(testFeedUrl, accountId: testAccountId);

      // Assert
      expect(result, equals(testFeed));
      verify(mockLocalDs.exists(testFeedUrl, accountId: testAccountId)).called(1);
      verify(mockRemoteDs.fetchFeed(testFeedUrl)).called(1);
      verify(mockLocalDs.upsert(any, accountId: testAccountId)).called(1);
    });

    test('should throw exception when feed already exists', () async {
      // Arrange
      when(mockLocalDs.exists(testFeedUrl, accountId: testAccountId))
          .thenAnswer((_) async => true);

      // Act & Assert
      expect(
        () => repository.addFeed(testFeedUrl, accountId: testAccountId),
        throwsException,
      );
      verify(mockLocalDs.exists(testFeedUrl, accountId: testAccountId)).called(1);
      verifyNever(mockRemoteDs.fetchFeed(any));
      verifyNever(mockLocalDs.upsert(any, accountId: anyNamed('accountId')));
    });
  });

  group('getAllFeeds', () {
    test('should get all feeds without accountId', () async {
      // Arrange
      final feeds = [
        Feed(
          id: 1,
          title: 'Feed 1',
          feedUrl: 'https://example1.com/feed.xml',
          type: FeedType.blog,
          sortOrder: 0,
          defaultViewer: ViewerType.article,
          autoReaderView: false,
          notificationsEnabled: false,
          unreadCount: 0,
          totalCount: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        Feed(
          id: 2,
          title: 'Feed 2',
          feedUrl: 'https://example2.com/feed.xml',
          type: FeedType.podcast,
          sortOrder: 1,
          defaultViewer: ViewerType.article,
          autoReaderView: false,
          notificationsEnabled: false,
          unreadCount: 0,
          totalCount: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockLocalDs.getAll(accountId: null)).thenAnswer((_) async => feeds);

      // Act
      final result = await repository.getAllFeeds();

      // Assert
      expect(result, equals(feeds));
      expect(result.length, equals(2));
      verify(mockLocalDs.getAll(accountId: null)).called(1);
    });

    test('should get all feeds with accountId', () async {
      // Arrange
      const accountId = 1;
      final feeds = [
        Feed(
          id: 1,
          title: 'Feed 1',
          feedUrl: 'https://example1.com/feed.xml',
          type: FeedType.blog,
          accountId: accountId,
          sortOrder: 0,
          defaultViewer: ViewerType.article,
          autoReaderView: false,
          notificationsEnabled: false,
          unreadCount: 0,
          totalCount: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockLocalDs.getAll(accountId: accountId)).thenAnswer((_) async => feeds);

      // Act
      final result = await repository.getAllFeeds(accountId: accountId);

      // Assert
      expect(result, equals(feeds));
      verify(mockLocalDs.getAll(accountId: accountId)).called(1);
    });
  });

  group('getFeedById', () {
    test('should return feed when found', () async {
      // Arrange
      const feedId = 1;
      const accountId = 1;
      final feed = Feed(
        id: feedId,
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed.xml',
        type: FeedType.blog,
        accountId: accountId,
        sortOrder: 0,
        defaultViewer: ViewerType.article,
        autoReaderView: false,
        notificationsEnabled: false,
        unreadCount: 0,
        totalCount: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => feed);

      // Act
      final result = await repository.getFeedById(feedId, accountId: accountId);

      // Assert
      expect(result, equals(feed));
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
    });

    test('should return null when feed not found', () async {
      // Arrange
      const feedId = 999;
      const accountId = 1;
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getFeedById(feedId, accountId: accountId);

      // Assert
      expect(result, isNull);
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
    });
  });

  group('getFeedByUrl', () {
    test('should return feed when found', () async {
      // Arrange
      const feedUrl = 'https://example.com/feed.xml';
      const accountId = 1;
      final feed = Feed(
        id: 1,
        title: 'Test Feed',
        feedUrl: feedUrl,
        type: FeedType.blog,
        accountId: accountId,
        sortOrder: 0,
        defaultViewer: ViewerType.article,
        autoReaderView: false,
        notificationsEnabled: false,
        unreadCount: 0,
        totalCount: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      when(mockLocalDs.getByUrl(feedUrl, accountId: accountId))
          .thenAnswer((_) async => feed);

      // Act
      final result = await repository.getFeedByUrl(feedUrl, accountId: accountId);

      // Assert
      expect(result, equals(feed));
      verify(mockLocalDs.getByUrl(feedUrl, accountId: accountId)).called(1);
    });

    test('should return null when feed not found', () async {
      // Arrange
      const feedUrl = 'https://example.com/nonexistent.xml';
      const accountId = 1;
      when(mockLocalDs.getByUrl(feedUrl, accountId: accountId))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getFeedByUrl(feedUrl, accountId: accountId);

      // Assert
      expect(result, isNull);
      verify(mockLocalDs.getByUrl(feedUrl, accountId: accountId)).called(1);
    });
  });

  group('getFeedsByType', () {
    test('should return feeds of specified type', () async {
      // Arrange
      const accountId = 1;
      final feeds = [
        Feed(
          id: 1,
          title: 'Podcast Feed',
          feedUrl: 'https://example.com/podcast.xml',
          type: FeedType.podcast,
          accountId: accountId,
          sortOrder: 0,
          defaultViewer: ViewerType.article,
          autoReaderView: false,
          notificationsEnabled: false,
          unreadCount: 0,
          totalCount: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockLocalDs.getByType(FeedType.podcast, accountId: accountId))
          .thenAnswer((_) async => feeds);

      // Act
      final result = await repository.getFeedsByType(FeedType.podcast, accountId: accountId);

      // Assert
      expect(result, equals(feeds));
      expect(result.length, equals(1));
      expect(result.first.type, equals(FeedType.podcast));
      verify(mockLocalDs.getByType(FeedType.podcast, accountId: accountId)).called(1);
    });
  });

  group('getFeedsByFolder', () {
    test('should return feeds in specified folder', () async {
      // Arrange
      const folderId = 1;
      const accountId = 1;
      final feeds = [
        Feed(
          id: 1,
          title: 'Feed in Folder',
          feedUrl: 'https://example.com/feed.xml',
          folderId: folderId,
          type: FeedType.blog,
          accountId: accountId,
          sortOrder: 0,
          defaultViewer: ViewerType.article,
          autoReaderView: false,
          notificationsEnabled: false,
          unreadCount: 0,
          totalCount: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockLocalDs.getByFolderId(folderId, accountId: accountId))
          .thenAnswer((_) async => feeds);

      // Act
      final result = await repository.getFeedsByFolder(folderId, accountId: accountId);

      // Assert
      expect(result, equals(feeds));
      expect(result.length, equals(1));
      expect(result.first.folderId, equals(folderId));
      verify(mockLocalDs.getByFolderId(folderId, accountId: accountId)).called(1);
    });
  });

  group('getRootFeeds', () {
    test('should return feeds without folder', () async {
      // Arrange
      const accountId = 1;
      final feeds = [
        Feed(
          id: 1,
          title: 'Root Feed',
          feedUrl: 'https://example.com/feed.xml',
          folderId: null,
          type: FeedType.blog,
          accountId: accountId,
          sortOrder: 0,
          defaultViewer: ViewerType.article,
          autoReaderView: false,
          notificationsEnabled: false,
          unreadCount: 0,
          totalCount: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];
      when(mockLocalDs.getRootFeeds(accountId: accountId))
          .thenAnswer((_) async => feeds);

      // Act
      final result = await repository.getRootFeeds(accountId: accountId);

      // Assert
      expect(result, equals(feeds));
      expect(result.length, equals(1));
      expect(result.first.folderId, isNull);
      verify(mockLocalDs.getRootFeeds(accountId: accountId)).called(1);
    });
  });

  group('getFeedCount', () {
    test('should return total feed count', () async {
      // Arrange
      const accountId = 1;
      const expectedCount = 5;
      when(mockLocalDs.count(accountId: accountId))
          .thenAnswer((_) async => expectedCount);

      // Act
      final result = await repository.getFeedCount(accountId: accountId);

      // Assert
      expect(result, equals(expectedCount));
      verify(mockLocalDs.count(accountId: accountId)).called(1);
    });
  });

  group('renameFeed', () {
    test('should rename feed when it exists', () async {
      // Arrange
      const feedId = 1;
      const accountId = 1;
      const newTitle = 'New Title';
      final feed = Feed(
        id: feedId,
        title: 'Old Title',
        feedUrl: 'https://example.com/feed.xml',
        type: FeedType.blog,
        accountId: accountId,
        sortOrder: 0,
        defaultViewer: ViewerType.article,
        autoReaderView: false,
        notificationsEnabled: false,
        unreadCount: 0,
        totalCount: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => feed);
      when(mockLocalDs.upsert(any, accountId: accountId))
          .thenAnswer((_) async => feedId);

      // Act
      await repository.renameFeed(feedId, newTitle, accountId: accountId);

      // Assert
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
      verify(mockLocalDs.upsert(
        argThat(isA<FeedsCompanion>()),
        accountId: accountId,
      )).called(1);
    });

    test('should do nothing when feed does not exist', () async {
      // Arrange
      const feedId = 999;
      const accountId = 1;
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => null);

      // Act
      await repository.renameFeed(feedId, 'New Title', accountId: accountId);

      // Assert
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
      verifyNever(mockLocalDs.upsert(any, accountId: anyNamed('accountId')));
    });
  });

  group('moveFeedToFolder', () {
    test('should move feed to folder when it exists', () async {
      // Arrange
      const feedId = 1;
      const folderId = 2;
      const accountId = 1;
      final feed = Feed(
        id: feedId,
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed.xml',
        folderId: null,
        type: FeedType.blog,
        accountId: accountId,
        sortOrder: 0,
        defaultViewer: ViewerType.article,
        autoReaderView: false,
        notificationsEnabled: false,
        unreadCount: 0,
        totalCount: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => feed);
      when(mockLocalDs.upsert(any, accountId: accountId))
          .thenAnswer((_) async => feedId);

      // Act
      await repository.moveFeedToFolder(feedId, folderId, accountId: accountId);

      // Assert
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
      verify(mockLocalDs.upsert(
        argThat(isA<FeedsCompanion>()),
        accountId: accountId,
      )).called(1);
    });

    test('should move feed to root when folderId is null', () async {
      // Arrange
      const feedId = 1;
      const accountId = 1;
      final feed = Feed(
        id: feedId,
        title: 'Test Feed',
        feedUrl: 'https://example.com/feed.xml',
        folderId: 2,
        type: FeedType.blog,
        accountId: accountId,
        sortOrder: 0,
        defaultViewer: ViewerType.article,
        autoReaderView: false,
        notificationsEnabled: false,
        unreadCount: 0,
        totalCount: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => feed);
      when(mockLocalDs.upsert(any, accountId: accountId))
          .thenAnswer((_) async => feedId);

      // Act
      await repository.moveFeedToFolder(feedId, null, accountId: accountId);

      // Assert
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
      verify(mockLocalDs.upsert(
        argThat(isA<FeedsCompanion>()),
        accountId: accountId,
      )).called(1);
    });

    test('should do nothing when feed does not exist', () async {
      // Arrange
      const feedId = 999;
      const accountId = 1;
      when(mockLocalDs.getById(feedId, accountId: accountId))
          .thenAnswer((_) async => null);

      // Act
      await repository.moveFeedToFolder(feedId, 1, accountId: accountId);

      // Assert
      verify(mockLocalDs.getById(feedId, accountId: accountId)).called(1);
      verifyNever(mockLocalDs.upsert(any, accountId: anyNamed('accountId')));
    });
  });

  group('deleteFeed', () {
    test('should delete feed successfully', () async {
      // Arrange
      const feedId = 1;
      when(mockLocalDs.delete(feedId)).thenAnswer((_) async => true);

      // Act
      await repository.deleteFeed(feedId);

      // Assert
      verify(mockLocalDs.delete(feedId)).called(1);
    });
  });

  group('deleteFeeds', () {
    test('should delete multiple feeds successfully', () async {
      // Arrange
      final feedIds = [1, 2, 3];
      when(mockLocalDs.deleteAll(feedIds)).thenAnswer((_) async => 3);

      // Act
      await repository.deleteFeeds(feedIds);

      // Assert
      verify(mockLocalDs.deleteAll(feedIds)).called(1);
    });
  });

  group('isSubscribed', () {
    test('should return true when feed is subscribed', () async {
      // Arrange
      const feedUrl = 'https://example.com/feed.xml';
      const accountId = 1;
      when(mockLocalDs.exists(feedUrl, accountId: accountId))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.isSubscribed(feedUrl, accountId: accountId);

      // Assert
      expect(result, isTrue);
      verify(mockLocalDs.exists(feedUrl, accountId: accountId)).called(1);
    });

    test('should return false when feed is not subscribed', () async {
      // Arrange
      const feedUrl = 'https://example.com/feed.xml';
      const accountId = 1;
      when(mockLocalDs.exists(feedUrl, accountId: accountId))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.isSubscribed(feedUrl, accountId: accountId);

      // Assert
      expect(result, isFalse);
      verify(mockLocalDs.exists(feedUrl, accountId: accountId)).called(1);
    });
  });

  group('setSyncEngine', () {
    test('should set sync engine', () {
      // Act
      repository.setSyncEngine(mockSyncEngine);

      // Assert - verify the engine is set by checking syncFeeds works
      final syncResult = SyncResult.empty();
      when(mockSyncEngine.sync()).thenAnswer((_) async => syncResult);

      repository.syncFeeds();
      verify(mockSyncEngine.sync()).called(1);
    });
  });

  group('syncFeeds', () {
    test('should return sync result when syncEngine is set', () async {
      // Arrange
      final syncResult = SyncResult(
        newFeeds: 1,
        updatedFeeds: 0,
        removedFeeds: 0,
        newArticles: 10,
        updatedArticles: 0,
        removedArticles: 0,
        completedAt: DateTime(2024, 1, 1),
        duration: const Duration(seconds: 5),
      );
      when(mockSyncEngine.sync()).thenAnswer((_) async => syncResult);

      // Act
      final result = await repository.syncFeeds();

      // Assert
      expect(result, equals(syncResult));
      verify(mockSyncEngine.sync()).called(1);
    });

    test('should return null when syncEngine is not set', () async {
      // Arrange
      final repositoryWithoutSync = FeedRepository(
        localDs: mockLocalDs,
        remoteDs: mockRemoteDs,
        syncEngine: null,
      );

      // Act
      final result = await repositoryWithoutSync.syncFeeds();

      // Assert
      expect(result, isNull);
      verifyNever(mockSyncEngine.sync());
    });
  });

  group('syncSingleFeed', () {
    test('should return sync result when syncEngine is set', () async {
      // Arrange
      const feedId = 1;
      final syncResult = SyncResult(
        newFeeds: 0,
        updatedFeeds: 1,
        removedFeeds: 0,
        newArticles: 5,
        updatedArticles: 0,
        removedArticles: 0,
        completedAt: DateTime(2024, 1, 1),
        duration: const Duration(seconds: 2),
      );
      when(mockSyncEngine.syncFeed(feedId)).thenAnswer((_) async => syncResult);

      // Act
      final result = await repository.syncSingleFeed(feedId);

      // Assert
      expect(result, equals(syncResult));
      verify(mockSyncEngine.syncFeed(feedId)).called(1);
    });

    test('should return null when syncEngine is not set', () async {
      // Arrange
      final repositoryWithoutSync = FeedRepository(
        localDs: mockLocalDs,
        remoteDs: mockRemoteDs,
        syncEngine: null,
      );
      const feedId = 1;

      // Act
      final result = await repositoryWithoutSync.syncSingleFeed(feedId);

      // Assert
      expect(result, isNull);
      verifyNever(mockSyncEngine.syncFeed(any));
    });
  });
}
