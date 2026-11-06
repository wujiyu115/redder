import '../../core/database/app_database.dart';

/// One row of the feed-grouped article list: either a feed header or an item.
///
/// A sealed hierarchy instead of a `(header?, item?)` tuple keeps the list
/// builder exhaustive — adding a row kind forces every `switch` to handle it.
sealed class GroupedRow {
  const GroupedRow();
}

/// Header shown above the articles of a single feed.
class FeedGroupHeader extends GroupedRow {
  const FeedGroupHeader({required this.feedId, required this.itemCount});

  final int feedId;

  /// How many articles this feed contributes to the loaded window.
  final int itemCount;
}

/// An article row.
class GroupedArticle extends GroupedRow {
  const GroupedArticle(this.item);

  final FeedItem item;
}

/// Groups [items] by feed for the "Group by Feed" timeline option.
///
/// Feed groups are emitted in the order their first article appears in
/// [items] — the caller has already sorted with the user's sort order, and
/// grouping must not re-sort (that would make "oldest first" show the oldest
/// feed first but its newest article on top). Articles inside a group keep the
/// incoming order.
///
/// Returns `null`-free output: pass an empty list to get an empty list.
List<GroupedRow> groupItemsByFeed(List<FeedItem> items) {
  if (items.isEmpty) return const [];

  // LinkedHashMap iteration order == first-seen order, which is exactly the
  // group order we want.
  final groups = <int, List<FeedItem>>{};
  for (final item in items) {
    groups.putIfAbsent(item.feedId, () => <FeedItem>[]).add(item);
  }

  return [
    for (final entry in groups.entries) ...[
      FeedGroupHeader(feedId: entry.key, itemCount: entry.value.length),
      for (final item in entry.value) GroupedArticle(item),
    ],
  ];
}