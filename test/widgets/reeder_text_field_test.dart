import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/core/theme/light_theme.dart';
import 'package:reeder/shared/widgets/reeder_text_field.dart';

void main() {
  // Harness that mirrors the real app shell: WidgetsApp provides the Overlay
  // and Material/Cupertino localizations that the selection/paste toolbar
  // depends on, wrapped in a ReederTheme for ReederTheme.of(context).
  Widget host(Widget child) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, __) => builder(context),
      ),
      home: ReederTheme(
        data: lightTheme,
        child: Center(child: child),
      ),
    );
  }

  testWidgets('renders a CupertinoTextField (enables selection + paste)',
      (tester) async {
    await tester.pumpWidget(host(const ReederTextField()));

    // The whole bug was that the field used a bare EditableText, which has no
    // selection toolbar / paste. It must now be a CupertinoTextField.
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('accepts entered/pasted text into its controller',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(host(ReederTextField(controller: controller)));

    await tester.enterText(find.byType(EditableText), 'https://rss.example.com');
    await tester.pump();

    expect(controller.text, 'https://rss.example.com');
  });

  testWidgets('fires onChanged exactly once per change (no double-fire)',
      (tester) async {
    var calls = 0;
    String? last;
    await tester.pumpWidget(host(ReederTextField(
      onChanged: (v) {
        calls++;
        last = v;
      },
    )));

    await tester.enterText(find.byType(EditableText), 'user1');
    await tester.pump();

    expect(last, 'user1');
    expect(calls, 1);
  });

  testWidgets('obscureText propagates to the field (password masking)',
      (tester) async {
    await tester.pumpWidget(host(const ReederTextField(obscureText: true)));

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
  });

  testWidgets('shows the placeholder when empty', (tester) async {
    await tester.pumpWidget(host(const ReederTextField(placeholder: 'Server URL')));

    expect(find.text('Server URL'), findsOneWidget);
  });

  testWidgets('clear button empties the field and reports the change',
      (tester) async {
    final controller = TextEditingController(text: 'seed');
    String? last = 'seed';
    await tester.pumpWidget(host(ReederTextField(
      controller: controller,
      onChanged: (v) => last = v,
    )));
    await tester.pump();

    // The '×' clear button is shown because there is text.
    await tester.tap(find.text('×'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(last, '');
  });
}
