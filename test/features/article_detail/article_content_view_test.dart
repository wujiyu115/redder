import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    show RenderMode;

import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/core/theme/light_theme.dart';
import 'package:reeder/features/article_detail/widgets/article_content_view.dart';

void main() {
  Widget host(Widget child) {
    return ProviderScope(
      child: WidgetsApp(
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
            PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, __) => builder(context),
        ),
        home: ReederTheme(data: lightTheme, child: child),
      ),
    );
  }

  /// Builds HTML with [paragraphs] block-level elements so the sliver layout
  /// has plenty of separate children, plus one remote image.
  String buildHtml(int paragraphs) {
    final buffer = StringBuffer('<p>hello world</p>');
    for (var i = 0; i < paragraphs; i++) {
      buffer.write('<p>paragraph $i</p>');
    }
    buffer.write('<img src="https://example.com/a.png">');
    return buffer.toString();
  }

  testWidgets('renders text inside a CustomScrollView (sliver mode)',
      (tester) async {
    // Mirrors the real page structure: header sliver, then the HTML wrapped in
    // SliverPadding + ReederTheme (both proxy widgets).
    await tester.pumpWidget(
      host(
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: ReederTheme(
                data: lightTheme,
                child: const ArticleContentView(
                  content: '<p>hello world</p>',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('hello world', findRichText: true), findsOneWidget);
  });

  testWidgets('does not build off-screen blocks eagerly', (tester) async {
    // 300 paragraphs is far taller than the 600px test viewport.
    final html = buildHtml(300);

    await tester.pumpWidget(
      host(
        CustomScrollView(
          slivers: [ArticleContentView(content: html)],
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('hello world', findRichText: true), findsOneWidget);
    // The trailing paragraphs are outside the viewport and must not be built,
    // which is what keeps off-screen images from being fetched.
    expect(find.text('paragraph 299', findRichText: true), findsNothing);
  });

  testWidgets('renders in column mode when embedded in a box scroll view',
      (tester) async {
    await tester.pumpWidget(
      host(
        const SingleChildScrollView(
          child: ArticleContentView(
            content: '<p>hello world</p>',
            renderMode: RenderMode.column,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('hello world', findRichText: true), findsOneWidget);
  });

  testWidgets('remote <img> is rendered by the caching image widget',
      (tester) async {
    await tester.pumpWidget(
      host(
        const CustomScrollView(
          slivers: [
            ArticleContentView(
              content:
                  '<p>hello</p><img src="https://example.com/a.png">',
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    // The custom factory must take over remote images instead of the default
    // uncapped one. `CachedNetworkImage` is what enforces memCacheWidth.
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bionic reading stays synchronous for short content',
      (tester) async {
    await tester.pumpWidget(
      host(
        const CustomScrollView(
          slivers: [
            ArticleContentView(content: '<p>hello world</p>', bionicReading: true),
          ],
        ),
      ),
    );
    await tester.pump();

    // First frame already carries the bolded text (no isolate round-trip).
    expect(find.text('hello world', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bionic reading on a large document renders via isolate',
      (tester) async {
    final paragraph = '<p>' + ('lorem ipsum dolor sit amet ' * 4) + '</p>';
    final html = List.filled(300, paragraph).join();
    // Sanity: this must exceed the synchronous transform limit.
    expect(html.length, greaterThan(20000));

    await tester.pumpWidget(
      host(
        CustomScrollView(
          slivers: [ArticleContentView(content: html, bionicReading: true)],
        ),
      ),
    );
    await tester.pump();

    // Nothing is rendered while the transform runs off-thread.
    expect(find.textContaining('lorem ipsum', findRichText: true), findsNothing);

    // Let the isolate finish, then pump the resulting frame.
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      if (find.textContaining('lorem ipsum', findRichText: true).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('lorem ipsum', findRichText: true),
      findsWidgets,
    );
  });
}
