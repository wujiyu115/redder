import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/repositories/feed_repository.dart';
import 'package:reeder/features/article_detail/article_detail_controller.dart';
import 'package:reeder/features/source_list/source_list_controller.dart';
import 'package:reeder/shared/providers/settings_provider.dart';

/// Adds a delay to the feed lookup, i.e. after the article snapshot is taken.
class _SlowFeedRepository extends FeedRepository {
  @override
  Future<Feed?> getFeedById(int id, {int? accountId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return super.getFeedById(id, accountId: accountId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;
  late int itemId;

  setUp(() async {
    await AppDatabase.initializeForTesting();
    db = AppDatabase.instance;

    // Clean slate: the singleton memory database is reused across tests.
    await db.delete(db.feedItems).go();
    await db.delete(db.feeds).go();

    final feedId = await db.into(db.feeds).insert(FeedsCompanion.insert(
          title: 'Feed',
          feedUrl: 'https://example.com/feed.xml',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));

    itemId = await db.into(db.feedItems).insert(FeedItemsCompanion.insert(
          feedId: feedId,
          title: 'Read me',
          url: 'https://example.com/read-me',
          content: const Value('<p>body</p>'),
          publishedAt: DateTime(2024, 1, 1),
          fetchedAt: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        ));

    container = ProviderContainer(overrides: [
      // Widen the window between "article snapshot taken" (start of the load)
      // and "state published" (end of the load) so the race below is
      // deterministic instead of occasionally lucky.
      feedRepositoryProvider.overrideWithValue(_SlowFeedRepository()),
    ]);
    // Keep the family provider subscribed so it is not auto-disposed mid-load.
    container.listen(
      articleDetailControllerProvider((itemId, 'all')),
      (_, __) {},
    );
    // Auto-disposed providers would otherwise throw "after dispose" when their
    // async load lands after the test tore the container down.
    container.listen(settingsProvider, (_, __) {});
    container.listen(sourceListControllerProvider, (_, __) {});
    for (var i = 0; i < 100 && container.read(settingsProvider).isLoading; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  tearDown(() => container.dispose());


  test('markAsRead() while the initial load is in flight ends up read',
      () async {
    final controller = container.read(
      articleDetailControllerProvider((itemId, 'all')).notifier,
    );

    // The page marks the article read from a post-frame callback, i.e. while
    // the controller may still be loading. This used to race: the refresh saw a
    // loading state, did nothing, and the finished load shipped the pre-read
    // article (action bar still offering "mark as unread").
    await controller.markAsRead();

    final state = controller.state.valueOrNull;
    expect(state, isNotNull);
    expect(state!.article.isRead, isTrue);

    final row = await (db.select(db.feedItems)
          ..where((t) => t.id.equals(itemId)))
        .getSingle();
    expect(row.isRead, isTrue);
  });

  test('markAsUnread() flips the in-memory article back', () async {
    final controller = container.read(
      articleDetailControllerProvider((itemId, 'all')).notifier,
    );
    await controller.markAsRead();
    await controller.markAsUnread();

    expect(controller.state.valueOrNull!.article.isRead, isFalse);
  });
}