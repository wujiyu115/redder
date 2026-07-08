import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/datasources/remote/rss_remote_ds.dart';
import 'package:reeder/data/models/feed.dart';
import 'package:reeder/data/services/feed_refresh_service.dart';

import '../../test_mocks.mocks.dart';

void main() {
  late MockFeedLocalDataSource mockFeedDs;
  late MockArticleLocalDataSource mockArticleDs;
  late MockRssRemoteDataSource mockRemoteDs;
  late FeedRefreshService service;

  /// Helper to create a test Feed.
  Feed createFeed({
    int id = 1,
    String title = 'Test Feed',
    String feedUrl = 'https://example.com/feed.xml',
  }) {
    return Feed(
      id: id,
      title: title,
      feedUrl: feedUrl,
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
  }

  /// Helper to create a ParsedFeedItem.
  ParsedFeedItem createParsedItem({
    String title = 'Test Article',
    String url = 'https://example.com/article',
  }) {
    return ParsedFeedItem()
      ..title = title
      ..url = url
      ..publishedAt = DateTime(2024, 1, 1);
  }

  setUp(() {
    mockFeedDs = MockFeedLocalDataSource();
    mockArticleDs = MockArticleLocalDataSource();
    mockRemoteDs = MockRssRemoteDataSource();
    service = FeedRefreshService(
      feedDs: mockFeedDs,
      articleDs: mockArticleDs,
      remoteDs: mockRemoteDs,
    );
  });

  group('refreshAll', () {
    test('should return empty result when no feeds exist', () async {
      when(mockFeedDs.getAll()).thenAnswer((_) async => []);

      final result = await service.refreshAll();

      expect(result.totalFeeds, equals(0));
      expect(result.updatedFeeds, equals(0));
      expect(result.failedFeeds, equals(0));
      expect(result.newItems, equals(0));
      expect(result.hasErrors, isFalse);
      verify(mockFeedDs.getAll()).called(1);
    });

    test('should refresh feeds and return result with new items', () async {
      final feed = createFeed();
      final item1 = createParsedItem(
        title: 'Article 1',
        url: 'https://example.com/article1',
      );
      final item2 = createParsedItem(
        title: 'Article 2',
        url: 'https://example.com/article2',
      );
      final parseResult = FeedParseResult(
        feed: ParsedFeed()..title = 'Test Feed'..feedUrl = feed.feedUrl,
        items: [item1, item2],
      );

      when(mockFeedDs.getAll()).thenAnswer((_) async => [feed]);
      when(mockRemoteDs.fetchFeed(feed.feedUrl))
          .thenAnswer((_) async => parseResult);
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => <String>{});
      when(mockArticleDs.upsertAll(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 2);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshAll();

      expect(result.totalFeeds, equals(1));
      expect(result.updatedFeeds, equals(1));
      expect(result.failedFeeds, equals(0));
      expect(result.newItems, equals(2));
      expect(result.hasNewItems, isTrue);
      verify(mockRemoteDs.fetchFeed(feed.feedUrl)).called(1);
      verify(mockArticleDs.upsertAll(any, accountId: anyNamed('accountId')))
          .called(1);
    });

    test('should record errors when feed refresh fails', () async {
      final feed1 = createFeed(id: 1, title: 'Good Feed', feedUrl: 'https://good.com/feed');
      final feed2 = createFeed(id: 2, title: 'Bad Feed', feedUrl: 'https://bad.com/feed');
      final parseResult = FeedParseResult(
        feed: ParsedFeed()..title = 'Good Feed'..feedUrl = feed1.feedUrl,
        items: [],
      );

      when(mockFeedDs.getAll()).thenAnswer((_) async => [feed1, feed2]);
      when(mockRemoteDs.fetchFeed(feed1.feedUrl))
          .thenAnswer((_) async => parseResult);
      when(mockRemoteDs.fetchFeed(feed2.feedUrl))
          .thenThrow(Exception('Network error'));
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => <String>{});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 0);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshAll();

      expect(result.totalFeeds, equals(2));
      expect(result.updatedFeeds, equals(0));
      expect(result.failedFeeds, equals(1));
      expect(result.hasErrors, isTrue);
      expect(result.errors.containsKey('Bad Feed'), isTrue);
    });
  });

  group('refreshFeed', () {
    test('should refresh a single feed when it exists', () async {
      final feed = createFeed();
      final item = createParsedItem();
      final parseResult = FeedParseResult(
        feed: ParsedFeed()..title = 'Test Feed'..feedUrl = feed.feedUrl,
        items: [item],
      );

      when(mockFeedDs.getById(1)).thenAnswer((_) async => feed);
      when(mockRemoteDs.fetchFeed(feed.feedUrl))
          .thenAnswer((_) async => parseResult);
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => <String>{});
      when(mockArticleDs.upsertAll(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 1);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshFeed(1);

      expect(result.totalFeeds, equals(1));
      expect(result.newItems, equals(1));
      verify(mockFeedDs.getById(1)).called(1);
      verify(mockRemoteDs.fetchFeed(feed.feedUrl)).called(1);
    });

    test('should return empty result when feed does not exist', () async {
      when(mockFeedDs.getById(999)).thenAnswer((_) async => null);

      final result = await service.refreshFeed(999);

      expect(result.totalFeeds, equals(0));
      expect(result.newItems, equals(0));
      verify(mockFeedDs.getById(999)).called(1);
      verifyNever(mockRemoteDs.fetchFeed(any));
    });
  });

  group('refreshFeeds', () {
    test('should refresh multiple feeds by IDs', () async {
      final feed1 = createFeed(id: 1, feedUrl: 'https://example1.com/feed');
      final feed2 = createFeed(id: 2, feedUrl: 'https://example2.com/feed');
      final item1 = createParsedItem(url: 'https://example1.com/article');
      final item2 = createParsedItem(url: 'https://example2.com/article');

      when(mockFeedDs.getByIds([1, 2], accountId: anyNamed('accountId')))
          .thenAnswer((_) async => [feed1, feed2]);
      when(mockRemoteDs.fetchFeed(feed1.feedUrl)).thenAnswer((_) async =>
          FeedParseResult(
            feed: ParsedFeed()..title = 'Feed 1'..feedUrl = feed1.feedUrl,
            items: [item1],
          ));
      when(mockRemoteDs.fetchFeed(feed2.feedUrl)).thenAnswer((_) async =>
          FeedParseResult(
            feed: ParsedFeed()..title = 'Feed 2'..feedUrl = feed2.feedUrl,
            items: [item2],
          ));
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => <String>{});
      when(mockArticleDs.upsertAll(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 1);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshFeeds([1, 2]);

      expect(result.totalFeeds, equals(2));
      expect(result.newItems, equals(2));
      verify(mockFeedDs.getByIds([1, 2], accountId: anyNamed('accountId')))
          .called(1);
    });

    test('should skip non-existent feeds', () async {
      final feed1 = createFeed(id: 1, feedUrl: 'https://example.com/feed');

      // getByIds only returns feeds that exist; 999 is silently absent.
      when(mockFeedDs.getByIds([1, 999], accountId: anyNamed('accountId')))
          .thenAnswer((_) async => [feed1]);
      when(mockRemoteDs.fetchFeed(feed1.feedUrl)).thenAnswer((_) async =>
          FeedParseResult(
            feed: ParsedFeed()..title = 'Feed 1'..feedUrl = feed1.feedUrl,
            items: [],
          ));
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => <String>{});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 0);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshFeeds([1, 999]);

      expect(result.totalFeeds, equals(1));
      verify(mockFeedDs.getByIds([1, 999], accountId: anyNamed('accountId')))
          .called(1);
    });
  });

  group('deduplication', () {
    test('should skip existing items and only save new ones', () async {
      final feed = createFeed();
      final existingItem = createParsedItem(
        title: 'Existing',
        url: 'https://example.com/existing',
      );
      final newItem = createParsedItem(
        title: 'New',
        url: 'https://example.com/new',
      );
      final parseResult = FeedParseResult(
        feed: ParsedFeed()..title = 'Test Feed'..feedUrl = feed.feedUrl,
        items: [existingItem, newItem],
      );

      when(mockFeedDs.getById(1)).thenAnswer((_) async => feed);
      when(mockRemoteDs.fetchFeed(feed.feedUrl))
          .thenAnswer((_) async => parseResult);
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => {'https://example.com/existing'});
      when(mockArticleDs.upsertAll(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async {});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 1);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshFeed(1);

      expect(result.newItems, equals(1));
      verify(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .called(1);
    });

    test('should not call upsertAll when all items already exist', () async {
      final feed = createFeed();
      final existingItem = createParsedItem(
        url: 'https://example.com/existing',
      );
      final parseResult = FeedParseResult(
        feed: ParsedFeed()..title = 'Test Feed'..feedUrl = feed.feedUrl,
        items: [existingItem],
      );

      when(mockFeedDs.getById(1)).thenAnswer((_) async => feed);
      when(mockRemoteDs.fetchFeed(feed.feedUrl))
          .thenAnswer((_) async => parseResult);
      when(mockArticleDs.existingUrls(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => {'https://example.com/existing'});
      when(mockFeedDs.updateLastFetched(any, durationMs: anyNamed('durationMs')))
          .thenAnswer((_) async {});
      when(mockArticleDs.unreadCountForFeed(any, accountId: anyNamed('accountId')))
          .thenAnswer((_) async => 0);
      when(mockFeedDs.updateUnreadCount(any, any))
          .thenAnswer((_) async {});

      final result = await service.refreshFeed(1);

      expect(result.newItems, equals(0));
      verifyNever(mockArticleDs.upsertAll(any, accountId: anyNamed('accountId')));
    });
  });
}
