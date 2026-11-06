import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/models/feed_item.dart';
import 'package:reeder/features/article_list/grouped_items.dart';

FeedItem _item(int id, int feedId, int minute) => FeedItem(
      id: id,
      feedId: feedId,
      title: 'Item $id',
      url: 'https://example.com/$id',
      publishedAt: DateTime(2024, 1, 1, 0, minute),
      fetchedAt: DateTime(2024, 1, 1, 12),
      createdAt: DateTime(2024, 1, 1, 12),
      contentType: ContentType.article,
      isRead: false,
      isStarred: false,
    );

void main() {
  group('groupItemsByFeed', () {
    test('returns an empty list for no items', () {
      expect(groupItemsByFeed(const []), isEmpty);
    });

    test('emits one header per feed in first-seen order', () {
      // Newest-first ordering as the timeline would deliver it.
      final rows = groupItemsByFeed([
        _item(1, 7, 50),
        _item(2, 3, 40),
        _item(3, 7, 30),
        _item(4, 3, 20),
        _item(5, 9, 10),
      ]);

      final headers = rows.whereType<FeedGroupHeader>().toList();
      expect(headers.map((h) => h.feedId), [7, 3, 9]);
      expect(headers.map((h) => h.itemCount), [2, 2, 1]);
      // Headers stay attached to the group they introduce.
      expect(rows.first, isA<FeedGroupHeader>());
      expect((rows.first as FeedGroupHeader).feedId, 7);
    });

    test('keeps the incoming order inside a group', () {
      final rows = groupItemsByFeed([
        _item(1, 7, 50),
        _item(2, 7, 40),
        _item(3, 7, 30),
      ]);

      final ids = rows.whereType<GroupedArticle>().map((r) => r.item.id);
      expect(ids, [1, 2, 3]);
    });

    test('does not re-sort, so oldest-first stays oldest-first', () {
      final rows = groupItemsByFeed([
        _item(1, 7, 10),
        _item(2, 3, 20),
        _item(3, 7, 30),
      ]);

      expect(
        rows.whereType<FeedGroupHeader>().map((h) => h.feedId),
        [7, 3],
      );
      expect(
        rows.whereType<GroupedArticle>().map((r) => r.item.id),
        [1, 3, 2],
      );
    });

    test('every item appears exactly once', () {
      final items = [
        _item(1, 1, 5),
        _item(2, 2, 4),
        _item(3, 1, 3),
      ];
      final rows = groupItemsByFeed(items);

      final seen = rows.whereType<GroupedArticle>().map((r) => r.item.id);
      expect(seen.toSet(), {1, 2, 3});
      expect(seen.length, items.length);
      // Header rows never carry an item.
      expect(rows.length, items.length + 2);
    });
  });
}