import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/utils/feed_discoverer.dart';

void main() {
  group('discoverFromHtml', () {
    const html = '''
      <link rel="alternate" type="application/rss+xml" href="/feed.xml" title="RSS">
    ''';

    test('returns relative url unchanged when no baseUrl', () {
      final feeds = FeedDiscoverer.discoverFromHtml(html);
      expect(feeds.single.url, '/feed.xml');
    });

    test('resolves relative url against baseUrl', () {
      final feeds = FeedDiscoverer.discoverFromHtml(
        html,
        baseUrl: 'https://example.com/blog/',
      );
      expect(feeds.single.url, 'https://example.com/feed.xml');
    });

    test('leaves absolute url untouched', () {
      const absHtml =
          '<link rel="alternate" type="application/atom+xml" href="https://cdn.example.com/atom">';
      final feeds = FeedDiscoverer.discoverFromHtml(
        absHtml,
        baseUrl: 'https://example.com/',
      );
      expect(feeds.single.url, 'https://cdn.example.com/atom');
    });
  });

  group('generateCommonFeedUrls', () {
    test('builds candidate urls from scheme+host', () {
      final urls = FeedDiscoverer.generateCommonFeedUrls(
        'https://example.com/some/path?q=1',
      );
      expect(urls, contains('https://example.com/feed'));
      expect(urls, contains('https://example.com/rss.xml'));
      expect(urls, contains('https://example.com/index.xml'));
      expect(urls.every((u) => u.startsWith('https://example.com/')), isTrue);
    });

    test('empty for unparseable input', () {
      expect(FeedDiscoverer.generateCommonFeedUrls('::::'), isEmpty);
    });
  });
}
