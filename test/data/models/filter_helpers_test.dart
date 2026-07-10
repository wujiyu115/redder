import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/models/feed.dart';
import 'package:reeder/data/models/feed_item.dart';
import 'package:reeder/data/models/filter_helpers.dart';

Filter _filter({
  List<String> include = const [],
  List<String> exclude = const [],
  List<String> media = const [],
  List<String> feedTypes = const [],
  bool matchWholeWord = false,
}) {
  final now = DateTime(2024, 1, 1);
  return Filter(
    id: 1,
    name: 'f',
    includeKeywords: jsonEncode(include),
    excludeKeywords: jsonEncode(exclude),
    mediaTypes: jsonEncode(media),
    feedTypes: jsonEncode(feedTypes),
    matchWholeWord: matchWholeWord,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

FeedItem _item({
  String title = 'Title',
  String? summary,
  String? content,
  ContentType contentType = ContentType.article,
}) {
  final now = DateTime(2024, 1, 1);
  return FeedItem(
    id: 1,
    feedId: 1,
    title: title,
    url: 'https://example.com/1',
    summary: summary,
    content: content,
    publishedAt: now,
    fetchedAt: now,
    contentType: contentType,
    isRead: false,
    isStarred: false,
    createdAt: now,
  );
}

void main() {
  group('list decoding', () {
    test('parses JSON lists', () {
      final f = _filter(include: ['a', 'b']);
      expect(f.includeKeywordsList, ['a', 'b']);
    });

    test('malformed JSON -> empty list', () {
      final now = DateTime(2024, 1, 1);
      final f = Filter(
        id: 1,
        name: 'f',
        includeKeywords: 'not json',
        excludeKeywords: '[]',
        mediaTypes: '[]',
        feedTypes: '[]',
        matchWholeWord: false,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );
      expect(f.includeKeywordsList, isEmpty);
    });
  });

  group('matches - no criteria', () {
    test('empty filter matches everything', () {
      expect(_filter().matches(_item(), FeedType.blog), isTrue);
    });
  });

  group('matches - media type', () {
    test('matching content type passes', () {
      final f = _filter(media: ['audio']);
      expect(
        f.matches(_item(contentType: ContentType.audio), FeedType.podcast),
        isTrue,
      );
    });

    test('non-matching content type fails', () {
      final f = _filter(media: ['audio']);
      expect(
        f.matches(_item(contentType: ContentType.article), FeedType.blog),
        isFalse,
      );
    });
  });

  group('matches - feed type', () {
    test('matching feed type passes', () {
      final f = _filter(feedTypes: ['podcast']);
      expect(f.matches(_item(), FeedType.podcast), isTrue);
    });

    test('non-matching feed type fails', () {
      final f = _filter(feedTypes: ['podcast']);
      expect(f.matches(_item(), FeedType.blog), isFalse);
    });
  });

  group('matches - exclude keywords', () {
    test('excluded keyword in title fails', () {
      final f = _filter(exclude: ['spam']);
      expect(f.matches(_item(title: 'This is SPAM'), FeedType.blog), isFalse);
    });

    test('excluded keyword absent passes', () {
      final f = _filter(exclude: ['spam']);
      expect(f.matches(_item(title: 'clean'), FeedType.blog), isTrue);
    });

    test('searches summary and content too', () {
      final f = _filter(exclude: ['bad']);
      expect(
        f.matches(_item(title: 't', content: 'has bad word'), FeedType.blog),
        isFalse,
      );
    });
  });

  group('matches - include keywords', () {
    test('include keyword present passes', () {
      final f = _filter(include: ['flutter']);
      expect(
        f.matches(_item(title: 'Learning Flutter'), FeedType.blog),
        isTrue,
      );
    });

    test('no include keyword present fails', () {
      final f = _filter(include: ['flutter']);
      expect(f.matches(_item(title: 'Learning Rust'), FeedType.blog), isFalse);
    });
  });

  group('matches - whole word', () {
    test('whole word does not match substring', () {
      final f = _filter(include: ['cat'], matchWholeWord: true);
      expect(f.matches(_item(title: 'category'), FeedType.blog), isFalse);
    });

    test('whole word matches standalone', () {
      final f = _filter(include: ['cat'], matchWholeWord: true);
      expect(f.matches(_item(title: 'a cat here'), FeedType.blog), isTrue);
    });

    test('substring mode matches within word', () {
      final f = _filter(include: ['cat'], matchWholeWord: false);
      expect(f.matches(_item(title: 'category'), FeedType.blog), isTrue);
    });
  });

  group('matches - combined', () {
    test('exclude takes precedence over include', () {
      final f = _filter(include: ['flutter'], exclude: ['beta']);
      expect(
        f.matches(_item(title: 'flutter beta release'), FeedType.blog),
        isFalse,
      );
    });
  });
}
