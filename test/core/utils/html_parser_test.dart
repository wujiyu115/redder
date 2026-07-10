import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/utils/html_parser.dart';

void main() {
  group('stripTags', () {
    test('removes tags, keeps text', () {
      expect(HtmlParser.stripTags('<p>Hello <b>world</b></p>'), 'Hello world');
    });

    test('empty html -> empty', () {
      expect(HtmlParser.stripTags(''), '');
    });
  });

  group('extractSummary', () {
    test('short text returned as-is', () {
      expect(HtmlParser.extractSummary('<p>Short</p>'), 'Short');
    });

    test('long text truncated with ellipsis at word boundary', () {
      final text = List.filled(100, 'word').join(' ');
      final summary = HtmlParser.extractSummary('<p>$text</p>', maxLength: 20);
      expect(summary.endsWith('…'), isTrue);
      expect(summary.length, lessThanOrEqualTo(21));
      expect(summary.contains('word'), isTrue);
    });
  });

  group('extractImageUrls', () {
    test('collects all img src', () {
      const html = '<img src="a.png"><p>x</p><img src="b.jpg">';
      expect(HtmlParser.extractImageUrls(html), ['a.png', 'b.jpg']);
    });

    test('ignores empty src', () {
      const html = '<img src=""><img src="ok.png">';
      expect(HtmlParser.extractImageUrls(html), ['ok.png']);
    });

    test('no images -> empty', () {
      expect(HtmlParser.extractImageUrls('<p>no images</p>'), isEmpty);
    });
  });

  group('extractFirstImageUrl', () {
    test('returns first', () {
      expect(
        HtmlParser.extractFirstImageUrl('<img src="1.png"><img src="2.png">'),
        '1.png',
      );
    });

    test('null when none', () {
      expect(HtmlParser.extractFirstImageUrl('<p>x</p>'), isNull);
    });
  });

  group('wordCount', () {
    test('counts words in text', () {
      expect(HtmlParser.wordCount('<p>one two three</p>'), 3);
    });

    test('empty -> 0', () {
      expect(HtmlParser.wordCount('<p></p>'), 0);
    });
  });

  group('extractLinks', () {
    test('collects anchors with href', () {
      const html = '<a href="https://x.com">X</a><a>no href</a>';
      final links = HtmlParser.extractLinks(html);
      expect(links.length, 1);
      expect(links.first.url, 'https://x.com');
      expect(links.first.text, 'X');
    });
  });

  group('hasContent', () {
    test('null / empty -> false', () {
      expect(HtmlParser.hasContent(null), isFalse);
      expect(HtmlParser.hasContent(''), isFalse);
    });

    test('tags only -> false', () {
      expect(HtmlParser.hasContent('<p></p><br>'), isFalse);
    });

    test('real text -> true', () {
      expect(HtmlParser.hasContent('<p>hi</p>'), isTrue);
    });
  });

  group('discoverFeeds', () {
    test('finds rss/atom alternate links', () {
      const html = '''
        <link rel="alternate" type="application/rss+xml" href="/rss" title="RSS">
        <link rel="alternate" type="application/atom+xml" href="/atom">
        <link rel="alternate" type="text/html" href="/page">
      ''';
      final feeds = HtmlParser.discoverFeeds(html);
      expect(feeds.length, 2);
      expect(feeds.first.url, '/rss');
      expect(feeds.first.title, 'RSS');
    });

    test('ignores non-feed types and empty href', () {
      const html =
          '<link rel="alternate" type="application/rss+xml" href="">';
      expect(HtmlParser.discoverFeeds(html), isEmpty);
    });
  });
}
