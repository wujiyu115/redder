import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reeder/data/datasources/remote/rss_remote_ds.dart';

import '../../../test_mocks.mocks.dart';

void main() {
  late MockDioClient mockClient;
  late RssRemoteDataSource ds;

  setUp(() {
    mockClient = MockDioClient();
    ds = RssRemoteDataSource(client: mockClient);
  });

  group('Atom parsing', () {
    test('parses <published> date without throwing (regression)', () async {
      // AtomItem.published is a String in webfeed_plus; the code previously
      // cast it to DateTime, throwing a TypeError for any entry with a
      // <published> element.
      const atom = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Example</title>
  <link rel="alternate" href="https://example.com"/>
  <entry>
    <title>Entry One</title>
    <link rel="alternate" href="https://example.com/one"/>
    <published>2024-03-15T10:30:00Z</published>
    <updated>2024-03-16T08:00:00Z</updated>
  </entry>
</feed>''';

      when(mockClient.getString('https://example.com/atom'))
          .thenAnswer((_) async => atom);

      final result = await ds.fetchFeed('https://example.com/atom');

      expect(result.items, hasLength(1));
      final item = result.items.first;
      expect(item.title, 'Entry One');
      expect(item.url, 'https://example.com/one');
      expect(item.publishedAt, DateTime.utc(2024, 3, 15, 10, 30, 0));
    });

    test('falls back to <updated> when <published> is absent', () async {
      const atom = '''
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Example</title>
  <entry>
    <title>No Published</title>
    <link rel="alternate" href="https://example.com/two"/>
    <updated>2024-03-16T08:00:00Z</updated>
  </entry>
</feed>''';

      when(mockClient.getString('https://example.com/atom2'))
          .thenAnswer((_) async => atom);

      final result = await ds.fetchFeed('https://example.com/atom2');

      expect(result.items, hasLength(1));
      expect(result.items.first.publishedAt,
          DateTime.utc(2024, 3, 16, 8, 0, 0));
    });
  });

  group('RSS parsing', () {
    test('parses items and pubDate', () async {
      const rss = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>My Blog</title>
    <link>https://blog.example.com</link>
    <description>A blog</description>
    <item>
      <title>Post One</title>
      <link>https://blog.example.com/1</link>
      <description>Summary</description>
      <pubDate>Mon, 15 Mar 2024 10:30:00 GMT</pubDate>
    </item>
  </channel>
</rss>''';

      when(mockClient.getString('https://blog.example.com/feed'))
          .thenAnswer((_) async => rss);

      final result = await ds.fetchFeed('https://blog.example.com/feed');

      expect(result.feed.title, 'My Blog');
      expect(result.items, hasLength(1));
      expect(result.items.first.title, 'Post One');
      expect(result.items.first.url, 'https://blog.example.com/1');
    });

    test('throws FormatException for unparseable content', () async {
      when(mockClient.getString('https://bad.example.com/feed'))
          .thenAnswer((_) async => 'this is not a feed at all');

      expect(
        () => ds.fetchFeed('https://bad.example.com/feed'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
