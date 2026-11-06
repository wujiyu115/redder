import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/features/article_list/article_list_page.dart';
import 'package:reeder/l10n/app_localizations.dart';
import 'package:reeder/shared/providers/account_provider.dart';
import 'package:reeder/shared/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<int> itemIds;

  setUp(() async {
    await AppDatabase.initializeForTesting();
    db = AppDatabase.instance;
    await db.delete(db.feedItems).go();
    await db.delete(db.feeds).go();

    final feedId = await db.into(db.feeds).insert(FeedsCompanion.insert(
          title: 'Feed',
          feedUrl: 'https://example.com/feed.xml',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ));

    itemIds = [];
    for (var i = 0; i < 5; i++) {
      itemIds.add(await db.into(db.feedItems).insert(FeedItemsCompanion.insert(
            feedId: feedId,
            title: 'Item $i',
            url: 'https://example.com/item-$i',
            summary: const Value('<p>summary</p>'),
            publishedAt: DateTime(2024, 1, 1).add(Duration(minutes: i)),
            fetchedAt: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          )));
    }
  });

  testWidgets('rows are keyed by item id', (tester) async {
    final container = ProviderContainer(
      overrides: [
        activeAccountIdProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => ReederTheme(
              data: ProviderScope.containerOf(context, listen: false)
                  .read(currentThemeProvider),
              child: const ArticleListPage(timelineId: 'all'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // SliverChildBuilderDelegate.findChildIndexCallback matches rows by these
    // keys; without them every row below a removed item is rebuilt.
    for (final id in itemIds) {
      expect(
        find.byKey(ValueKey<int>(id)),
        findsOneWidget,
        reason: 'row $id must be keyed by its item id',
      );
    }
  });
}