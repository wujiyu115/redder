import 'package:flutter_test/flutter_test.dart';

import 'package:reeder/core/utils/date_formatter.dart';
import 'package:reeder/core/utils/html_parser.dart';
import 'package:reeder/core/utils/opml_parser.dart';
import 'package:reeder/core/utils/bionic_reading.dart';

/// Unit tests for data layer: Repository, Service, and Utils classes.
///
/// Tests cover:
/// - DateFormatter: relative time, absolute time, reading time estimation
/// - HtmlParser: summary extraction, image URL extraction, word count
/// - OpmlParser: OPML 2.0 import/export
/// - BionicReading: text and HTML processing
void main() {
  group('DateFormatter', () {
    test('relativeTime returns "Just now" for recent dates', () {
      final now = DateTime.now();
      final result = DateFormatter.relativeTime(now);
      expect(result, contains('now'));
    });

    test('relativeTime returns minutes for dates within an hour', () {
      final date = DateTime.now().subtract(const Duration(minutes: 30));
      final result = DateFormatter.relativeTime(date);
      expect(result, contains('30'));
      expect(result.toLowerCase(), contains('m'));
    });

    test('relativeTime returns hours for dates within a day', () {
      final date = DateTime.now().subtract(const Duration(hours: 5));
      final result = DateFormatter.relativeTime(date);
      expect(result, contains('5'));
      expect(result.toLowerCase(), contains('h'));
    });

    test('readingTime calculates correctly', () {
      // 200 words per minute average, 400 words = 2 min
      final result = DateFormatter.readingTime(400);
      expect(result, equals('2 min read'));
    });

    test('readingTime returns 1 min for short text', () {
      final result = DateFormatter.readingTime(2);
      expect(result, equals('1 min read'));
    });
  });

  group('HtmlParser', () {
    test('extractSummary strips HTML tags', () {
      const html = '<p>This is a <strong>test</strong> paragraph.</p>';
      final summary = HtmlParser.extractSummary(html);
      expect(summary, isNotNull);
      expect(summary, isNot(contains('<')));
      expect(summary, contains('test'));
    });

    test('extractSummary truncates long content', () {
      final longHtml = '<p>${'word ' * 500}</p>';
      final summary = HtmlParser.extractSummary(longHtml, maxLength: 100);
      expect(summary.length, lessThanOrEqualTo(103)); // 100 + "..."
    });

    test('extractFirstImageUrl finds img src', () {
      const html = '<p>Text</p><img src="https://example.com/image.jpg" />';
      final url = HtmlParser.extractFirstImageUrl(html);
      expect(url, equals('https://example.com/image.jpg'));
    });

    test('extractFirstImageUrl returns null for no images', () {
      const html = '<p>No images here</p>';
      final url = HtmlParser.extractFirstImageUrl(html);
      expect(url, isNull);
    });

    test('extractImageUrls finds all images', () {
      const html = '''
        <img src="https://example.com/1.jpg" />
        <p>Text</p>
        <img src="https://example.com/2.jpg" />
      ''';
      final urls = HtmlParser.extractImageUrls(html);
      expect(urls, hasLength(2));
      expect(urls[0], contains('1.jpg'));
      expect(urls[1], contains('2.jpg'));
    });

    test('wordCount counts words correctly', () {
      const html = '<p>This is a test with <strong>seven</strong> words.</p>';
      final count = HtmlParser.wordCount(html);
      // Should count plain text words, not HTML tags
      expect(count, greaterThanOrEqualTo(6));
    });
  });

  group('BionicReading', () {
    test('applyToText bolds first part of words', () {
      const text = 'Hello world';
      final result = BionicReading.applyToText(text);
      expect(result, contains('<b>'));
      expect(result, contains('</b>'));
      expect(result, contains('Hel')); // "Hello" → bold first 2 chars
    });

    test('applyToText handles empty string', () {
      final result = BionicReading.applyToText('');
      expect(result, isEmpty);
    });

    test('applyToText handles single character words', () {
      const text = 'I a';
      final result = BionicReading.applyToText(text);
      expect(result, contains('<b>I</b>'));
    });

    test('applyToHtml preserves HTML structure', () {
      const html = '<p>Hello world</p>';
      final result = BionicReading.applyToHtml(html);
      expect(result, contains('<p>'));
      expect(result, contains('</p>'));
      expect(result, contains('<b>'));
    });

    test('applyToHtml skips code blocks', () {
      const html = '<code>function test()</code>';
      final result = BionicReading.applyToHtml(html);
      // Code blocks should not have bionic reading applied
      expect(result, contains('function'));
    });
  });

  group('OpmlParser', () {
    test('parse extracts feeds from valid OPML', () {
      const opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline text="Tech" title="Tech">
      <outline type="rss" text="Example Blog" xmlUrl="https://example.com/feed.xml" htmlUrl="https://example.com" />
    </outline>
  </body>
</opml>''';
      final result = OpmlParser.parse(opml);
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      // First item is the "Tech" folder, its child has the feed URL
      final flatFeeds = OpmlParser.flatten(result);
      expect(flatFeeds, isNotEmpty);
      expect(flatFeeds.first.feedUrl, equals('https://example.com/feed.xml'));
    });

    test('parse handles empty OPML', () {
      const opml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Empty</title></head>
  <body></body>
</opml>''';
      final result = OpmlParser.parse(opml);
      expect(result, isEmpty);
    });

    test('generate produces valid OPML 2.0', () {
      final outlines = [
        OpmlOutline(
          title: 'Test Blog',
          feedUrl: 'https://test.com/feed.xml',
          siteUrl: 'https://test.com',
        ),
      ];
      final opml = OpmlParser.generate(title: 'Reeder Export', outlines: outlines);
      expect(opml, contains('opml version="2.0"'));
      expect(opml, contains('https://test.com/feed.xml'));
      expect(opml, contains('Test Blog'));
    });
  });
}
