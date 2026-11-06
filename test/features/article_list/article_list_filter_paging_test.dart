import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/features/article_list/article_list_controller.dart';
import 'package:reeder/features/source_list/source_list_controller.dart';
import 'package:reeder/shared/providers/account_provider.dart';
import 'package:reeder/shared/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;
  late int filterId;

  setUp(() async {
    await AppDatabase.initializeForTesting();
    db = AppDatabase.instance;

    await db.delete(db.feedItems).go();
    await db.delete(db.feeds).go();
    await db.delete(db.filters).go();

    final feedId = await db.into(db.feeds).insert(FeedsCompanion.insert(
          title: 'Feed',
          feedUrl: 'https://example.com/feed.xml',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));

    // 45 matching items interleaved with 45 non-matching ones, so the filter
    // has to actually scan instead of taking the first N rows.
    for (var i = 0; i < 90; i++) {
      await db.into(db.feedItems).insert(FeedItemsCompanion.insert(
            feedId: feedId,
            title: i.isEven ? 'Flutter $i' : 'Rust $i',
            url: 'https://example.com/item-$i',
            content: const Value('<p>body</p>'),
            publishedAt: DateTime(2024, 1, 1).add(Duration(minutes: i)),
            fetchedAt: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ));
    }

    filterId = await db.into(db.filters).insert(FiltersCompanion.insert(
          name: 'Flutter only',
          includeKeywords: const Value('["flutter"]'),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));

    container = ProviderContainer(overrides: [
      // The real provider resolves through the sync repository, which needs
      // plugin channels that do not exist in a widget test — it never
      // completes, and the list controller gates its first load on it.
      activeAccountIdProvider.overrideWith((ref) async => null),
    ]);
    container.listen(
      articleListControllerProvider('filter_$filterId'),
      (_, __) {},
    );
    container.listen(settingsProvider, (_, __) {});
    container.listen(sourceListControllerProvider, (_, __) {});
    for (var i = 0; i < 100 && container.read(settingsProvider).isLoading; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  tearDown(() => container.dispose());

  AsyncValue<ArticleListState> read(String timelineId) =>
      container.read(articleListControllerProvider(timelineId));

  /// Polls until the controller publishes data (drift runs off the microtask
  /// queue, so a fixed number of `Future.delayed(Duration.zero)` hops is not
  /// enough).
  Future<ArticleListState> settle(String timelineId) async {
    for (var i = 0; i < 200; i++) {
      final state = read(timelineId);
      if (state.valueOrNull != null) return state.valueOrNull!;
      if (state.hasError) fail('load failed: ${state.error}');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('timed out waiting for article list state');
  }

  test('filter timeline pages through every match exactly once', () async {
    final key = 'filter_$filterId';
    final controller = container.read(articleListControllerProvider(key).notifier);
    await settle(key);

    // Page until the list reports no more.
    var guard = 0;
    while (read(key).valueOrNull!.hasMore) {
      await controller.loadMore();
      await settle(key);
      if (++guard > 10) break;
    }

    final state = read(key).valueOrNull!;

    expect(state.items.length, 45);
    expect(state.items.map((i) => i.title).every((t) => t.startsWith('Flutter')),
        isTrue);
    expect(state.items.map((i) => i.id).toSet().length, 45,
        reason: 'a match must never be returned twice across pages');
    // Newest first: item 88 is the newest even index.
    expect(state.items.first.title, 'Flutter 88');
    expect(state.items.last.title, 'Flutter 0');
  });

  test('reload rebuilds the scan cache from scratch', () async {
    final key = 'filter_$filterId';
    final controller = container.read(articleListControllerProvider(key).notifier);
    final firstLoad = (await settle(key)).items.map((i) => i.id).toList();

    await controller.reload();
    final secondLoad = (await settle(key)).items.map((i) => i.id).toList();

    expect(secondLoad, firstLoad);
  });
}