import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:reeder/data/services/feed_discovery_service.dart';
import 'package:reeder/data/datasources/remote/rss_remote_ds.dart';
import 'package:reeder/core/network/dio_client.dart';
import 'package:reeder/data/models/feed.dart';

import '../../test_mocks.mocks.dart';

@GenerateMocks([DioClient, RssRemoteDataSource])
void main() {
  late FeedDiscoveryService service;
  late MockDioClient mockClient;
  late MockRssRemoteDataSource mockRemoteDs;

  setUp(() {
    mockClient = MockDioClient();
    mockRemoteDs = MockRssRemoteDataSource();
    service = FeedDiscoveryService(
      client: mockClient,
      remoteDs: mockRemoteDs,
    );
  });

  group('FeedDiscoveryService - discover', () {
    test('discover: 直接 Feed URL 成功解析', () async {
      // Arrange
      final feedUrl = 'https://example.com/feed.xml';
      final parsedFeed = ParsedFeed()
        ..title = 'Test Feed'
        ..description = 'Test Description'
        ..feedUrl = feedUrl
        ..type = FeedType.blog;

      final parsedItems = [
        ParsedFeedItem()..title = 'Item 1',
        ParsedFeedItem()..title = 'Item 2',
      ];

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: parsedItems,
      );

      when(mockRemoteDs.fetchFeed(feedUrl))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(feedUrl);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, feedUrl);
      expect(result[0].title, 'Test Feed');
      expect(result[0].description, 'Test Description');
      expect(result[0].type, FeedType.blog);
      expect(result[0].itemCount, 2);
      verify(mockRemoteDs.fetchFeed(feedUrl)).called(1);
      verifyNever(mockClient.getString(any));
    });

    test('discover: URL 不是 Feed，但 HTML 页面包含 feed link 标签', () async {
      // Arrange
      final url = 'https://example.com';
      final htmlContent = '''
        <html>
          <head>
            <link rel="alternate" type="application/rss+xml" 
                  title="Blog Feed" href="/feed.xml" />
          </head>
          <body></body>
        </html>
      ''';

      final parsedFeed = ParsedFeed()
        ..title = 'Blog Feed'
        ..description = 'Blog Description'
        ..feedUrl = 'https://example.com/feed.xml'
        ..type = FeedType.blog;

      final parsedItems = [
        ParsedFeedItem()..title = 'Item 1',
      ];

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: parsedItems,
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenAnswer((_) async => htmlContent);
      when(mockRemoteDs.fetchFeed('https://example.com/feed.xml'))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'https://example.com/feed.xml');
      expect(result[0].title, 'Blog Feed');
      expect(result[0].itemCount, 1);
      verify(mockRemoteDs.fetchFeed(url)).called(1);
      verify(mockClient.getString(url)).called(1);
      verify(mockRemoteDs.fetchFeed('https://example.com/feed.xml')).called(1);
    });

    test('discover: URL 不是 Feed，HTML 无 feed link，尝试常见路径', () async {
      // Arrange
      final url = 'https://example.com';

      final parsedFeed = ParsedFeed()
        ..title = 'Example Feed'
        ..description = 'Feed Description'
        ..feedUrl = 'https://example.com/feed'
        ..type = FeedType.blog;

      final parsedItems = [
        ParsedFeedItem()..title = 'Item 1',
      ];

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: parsedItems,
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenThrow(Exception('Failed to fetch HTML'));
      when(mockRemoteDs.fetchFeed('https://example.com/feed'))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'https://example.com/feed');
      expect(result[0].title, 'Example Feed');
      verify(mockRemoteDs.fetchFeed(url)).called(1);
      verify(mockClient.getString(url)).called(1);
      verify(mockRemoteDs.fetchFeed('https://example.com/feed')).called(1);
    });

    test('discover: 完全找不到 Feed 返回空列表', () async {
      // Arrange
      final url = 'https://example.com';

      when(mockRemoteDs.fetchFeed(any))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenThrow(Exception('Failed to fetch HTML'));

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.isEmpty, true);
      verify(mockRemoteDs.fetchFeed(url)).called(1);
      verify(mockClient.getString(url)).called(1);
      // Should have tried common paths
      verify(mockRemoteDs.fetchFeed('https://example.com/feed')).called(1);
    });

    test('URL 规范化：自动添加 https:// 前缀', () async {
      // Arrange
      final urlWithoutScheme = 'example.com/feed.xml';
      final normalizedUrl = 'https://example.com/feed.xml';

      final parsedFeed = ParsedFeed()
        ..title = 'Test Feed'
        ..feedUrl = normalizedUrl
        ..type = FeedType.blog;

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: [],
      );

      when(mockRemoteDs.fetchFeed(normalizedUrl))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(urlWithoutScheme);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, normalizedUrl);
      verify(mockRemoteDs.fetchFeed(normalizedUrl)).called(1);
      verifyNever(mockRemoteDs.fetchFeed(urlWithoutScheme));
    });

    test('discover: HTML 包含多个 feed link 标签', () async {
      // Arrange
      final url = 'https://example.com';
      final htmlContent = '''
        <html>
          <head>
            <link rel="alternate" type="application/rss+xml" 
                  title="RSS Feed" href="/rss.xml" />
            <link rel="alternate" type="application/atom+xml" 
                  title="Atom Feed" href="/atom.xml" />
          </head>
          <body></body>
        </html>
      ''';

      final rssFeed = ParsedFeed()
        ..title = 'RSS Feed'
        ..feedUrl = 'https://example.com/rss.xml'
        ..type = FeedType.blog;

      final atomFeed = ParsedFeed()
        ..title = 'Atom Feed'
        ..feedUrl = 'https://example.com/atom.xml'
        ..type = FeedType.blog;

      final rssResult = FeedParseResult(
        feed: rssFeed,
        items: [ParsedFeedItem()..title = 'RSS Item'],
      );

      final atomResult = FeedParseResult(
        feed: atomFeed,
        items: [ParsedFeedItem()..title = 'Atom Item'],
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenAnswer((_) async => htmlContent);
      when(mockRemoteDs.fetchFeed('https://example.com/rss.xml'))
          .thenAnswer((_) async => rssResult);
      when(mockRemoteDs.fetchFeed('https://example.com/atom.xml'))
          .thenAnswer((_) async => atomResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 2);
      expect(result[0].feedUrl, 'https://example.com/rss.xml');
      expect(result[0].title, 'RSS Feed');
      expect(result[1].feedUrl, 'https://example.com/atom.xml');
      expect(result[1].title, 'Atom Feed');
    });

    test('discover: HTML feed link 但无法解析，跳过该 feed', () async {
      // Arrange
      final url = 'https://example.com';
      final htmlContent = '''
        <html>
          <head>
            <link rel="alternate" type="application/rss+xml" 
                  title="Valid Feed" href="/valid.xml" />
            <link rel="alternate" type="application/rss+xml" 
                  title="Invalid Feed" href="/invalid.xml" />
          </head>
          <body></body>
        </html>
      ''';

      final validFeed = ParsedFeed()
        ..title = 'Valid Feed'
        ..feedUrl = 'https://example.com/valid.xml'
        ..type = FeedType.blog;

      final validResult = FeedParseResult(
        feed: validFeed,
        items: [ParsedFeedItem()..title = 'Item'],
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenAnswer((_) async => htmlContent);
      when(mockRemoteDs.fetchFeed('https://example.com/valid.xml'))
          .thenAnswer((_) async => validResult);
      when(mockRemoteDs.fetchFeed('https://example.com/invalid.xml'))
          .thenThrow(Exception('Invalid feed'));

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'https://example.com/valid.xml');
      verify(mockRemoteDs.fetchFeed('https://example.com/invalid.xml')).called(1);
    });

    test('discover: 常见路径按顺序尝试，找到后停止', () async {
      // Arrange
      final url = 'https://example.com';

      final parsedFeed = ParsedFeed()
        ..title = 'Feed'
        ..feedUrl = 'https://example.com/rss'
        ..type = FeedType.blog;

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: [],
      );

      when(mockRemoteDs.fetchFeed(any))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenThrow(Exception('Failed to fetch HTML'));
      when(mockRemoteDs.fetchFeed('https://example.com/feed'))
          .thenThrow(Exception('Not found'));
      when(mockRemoteDs.fetchFeed('https://example.com/rss'))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'https://example.com/rss');
      verify(mockRemoteDs.fetchFeed('https://example.com/feed')).called(1);
      verify(mockRemoteDs.fetchFeed('https://example.com/rss')).called(1);
      // Should not try /rss.xml since we found a feed at /rss
      verifyNever(mockRemoteDs.fetchFeed('https://example.com/rss.xml'));
    });

    test('discover: 相对 URL 正确解析为绝对 URL', () async {
      // Arrange
      final url = 'https://example.com/blog';
      final htmlContent = '''
        <html>
          <head>
            <link rel="alternate" type="application/rss+xml" 
                  title="Feed" href="../feed.xml" />
          </head>
          <body></body>
        </html>
      ''';

      final parsedFeed = ParsedFeed()
        ..title = 'Feed'
        ..feedUrl = 'https://example.com/feed.xml'
        ..type = FeedType.blog;

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: [],
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenThrow(Exception('Not a feed'));
      when(mockClient.getString(url))
          .thenAnswer((_) async => htmlContent);
      when(mockRemoteDs.fetchFeed('https://example.com/feed.xml'))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'https://example.com/feed.xml');
    });

    test('discover: 已有 http:// 前缀的 URL 不再添加', () async {
      // Arrange
      final url = 'http://example.com/feed.xml';

      final parsedFeed = ParsedFeed()
        ..title = 'Feed'
        ..feedUrl = url
        ..type = FeedType.blog;

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: [],
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'http://example.com/feed.xml');
      verify(mockRemoteDs.fetchFeed('http://example.com/feed.xml')).called(1);
      verifyNever(mockRemoteDs.fetchFeed('https://example.com/feed.xml'));
    });

    test('discover: 已有 https:// 前缀的 URL 不再添加', () async {
      // Arrange
      final url = 'https://example.com/feed.xml';

      final parsedFeed = ParsedFeed()
        ..title = 'Feed'
        ..feedUrl = url
        ..type = FeedType.blog;

      final parseResult = FeedParseResult(
        feed: parsedFeed,
        items: [],
      );

      when(mockRemoteDs.fetchFeed(url))
          .thenAnswer((_) async => parseResult);

      // Act
      final result = await service.discover(url);

      // Assert
      expect(result.length, 1);
      expect(result[0].feedUrl, 'https://example.com/feed.xml');
      verify(mockRemoteDs.fetchFeed('https://example.com/feed.xml')).called(1);
    });
  });
}
