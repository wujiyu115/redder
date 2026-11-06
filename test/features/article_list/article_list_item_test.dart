import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/core/theme/light_theme.dart';
import 'package:reeder/data/models/feed_item.dart';
import 'package:reeder/features/article_list/widgets/article_list_item.dart';
import 'package:reeder/features/article_list/widgets/article_list_item_compact.dart';
import 'package:reeder/shared/providers/settings_provider.dart';

/// Scroll-performance regression tests for the article list rows.
///
/// The list is the app's main scroll surface, so each row must stay cheap to
/// paint: no full-row opacity layer, no fade-in animation per image, and no
/// entrance animation ticker for rows that no longer animate.
void main() {
  FeedItem buildItem({
    int id = 1,
    bool isRead = false,
    bool withThumbnail = false,
  }) {
    return FeedItem(
      id: id,
      feedId: 1,
      title: 'Headline $id',
      summary: 'Summary text for article $id',
      url: 'https://example.com/$id',
      imageUrl: withThumbnail ? 'https://example.com/$id.jpg' : null,
      publishedAt: DateTime(2024, 1, 1, 12),
      fetchedAt: DateTime(2024, 1, 1, 12),
      contentType: ContentType.article,
      isRead: isRead,
      isStarred: false,
      createdAt: DateTime(2024, 1, 1, 12),
    );
  }

  Widget wrap(
    Widget child, {
    bool showThumbnails = false,
    bool showAvatars = false,
  }) {
    return ProviderScope(
      overrides: [
        showThumbnailsProvider.overrideWithValue(showThumbnails),
        showAvatarsProvider.overrideWithValue(showAvatars),
        // Avoid network decoding in tests; layout is unaffected.
        cacheImagesProvider.overrideWithValue(false),
      ],
      child: ReederTheme(
        data: lightTheme,
        child: MediaQuery(
          data: const MediaQueryData(devicePixelRatio: 2.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(child: child),
          ),
        ),
      ),
    );
  }

  Color titleColor(WidgetTester tester, String title) {
    return tester.widget<Text>(find.text(title)).style!.color!;
  }

  group('ArticleListItem', () {
    testWidgets('read article dims text without an opacity layer',
        (tester) async {
      await tester.pumpWidget(
        wrap(ArticleListItem(item: buildItem(isRead: true), animate: false)),
      );

      // The dimming must come from the text colors, not from wrapping the whole
      // row in `Opacity` (one layer per read row, per frame).
      expect(find.byType(Opacity), findsNothing);
      expect(titleColor(tester, 'Headline 1').a, closeTo(0.6, 0.01));
    });

    testWidgets('unread article keeps full-opacity text', (tester) async {
      await tester.pumpWidget(
        wrap(ArticleListItem(item: buildItem(isRead: false), animate: false)),
      );

      expect(find.byType(Opacity), findsNothing);
      expect(titleColor(tester, 'Headline 1').a, closeTo(1.0, 0.01));
    });

    testWidgets('only the thumbnail is dimmed for read articles',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          ArticleListItem(
            item: buildItem(isRead: true, withThumbnail: true),
            animate: false,
          ),
          showThumbnails: true,
        ),
      );

      final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
      expect(opacities, hasLength(1));
      expect(opacities.single.opacity, closeTo(0.6, 0.01));
    });

    testWidgets('skips the entrance animation when animate is false',
        (tester) async {
      await tester.pumpWidget(
        wrap(ArticleListItem(item: buildItem(), animate: false)),
      );
      await tester.pump();

      // No ticker was created, so nothing is scheduled and the row is already
      // fully visible on its first frame.
      expect(tester.binding.transientCallbackCount, 0);
      final fade = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(fade.opacity.value, 1.0);
    });

    testWidgets('plays the entrance animation when animate is true',
        (tester) async {
      await tester.pumpWidget(
        wrap(ArticleListItem(item: buildItem(), animate: true, index: 0)),
      );

      var fade = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(fade.opacity.value, lessThan(1.0));

      await tester.pumpAndSettle();
      fade = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(fade.opacity.value, 1.0);
    });
  });

  group('ArticleListItemCompact', () {
    testWidgets('read article dims text without an opacity layer',
        (tester) async {
      await tester.pumpWidget(
        wrap(ArticleListItemCompact(item: buildItem(isRead: true))),
      );

      expect(find.byType(Opacity), findsNothing);
      expect(titleColor(tester, 'Headline 1').a, closeTo(0.6, 0.01));
    });
  });
}