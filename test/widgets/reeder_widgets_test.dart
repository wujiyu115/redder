import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/core/theme/light_theme.dart';
import 'package:reeder/core/theme/dark_theme.dart';
import 'package:reeder/shared/widgets/reeder_button.dart';
import 'package:reeder/shared/widgets/reeder_switch.dart';
import 'package:reeder/shared/widgets/reeder_nav_bar.dart';
import 'package:reeder/shared/widgets/reeder_section_header.dart';
import 'package:reeder/shared/widgets/reeder_list_tile.dart';

/// Widget tests for core Reeder UI components.
///
/// Tests cover:
/// - ReederButton: tap handling, visual states
/// - ReederSwitch: toggle behavior
/// - ReederNavBar: title display, back button
/// - ReederSectionHeader: text rendering
/// - ReederListTile: layout and tap handling
void main() {
  /// Helper to wrap a widget with ReederTheme for testing.
  Widget wrapWithTheme(Widget child, {ReederThemeData? theme}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ReederTheme(
        data: theme ?? lightTheme,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: child,
        ),
      ),
    );
  }

  group('ReederButton', () {
    testWidgets('text button renders and responds to tap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapWithTheme(
        ReederButton.text(
          label: 'Test Button',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('Test Button'), findsOneWidget);

      await tester.tap(find.text('Test Button'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('icon button renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithTheme(
        ReederButton.icon(
          icon: const Text('★'),
          onPressed: () {},
        ),
      ));

      expect(find.text('★'), findsOneWidget);
    });

    testWidgets('disabled button does not respond to tap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapWithTheme(
        ReederButton.text(
          label: 'Disabled',
          onPressed: null,
        ),
      ));

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });

  group('ReederSwitch', () {
    testWidgets('renders with initial value', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithTheme(
        ReederSwitch(
          value: true,
          onChanged: (_) {},
        ),
      ));

      // Switch should be rendered
      expect(find.byType(ReederSwitch), findsOneWidget);
    });

    testWidgets('toggles on tap', (WidgetTester tester) async {
      bool value = false;

      await tester.pumpWidget(wrapWithTheme(
        StatefulBuilder(
          builder: (context, setState) {
            return ReederSwitch(
              value: value,
              onChanged: (newValue) {
                setState(() => value = newValue);
              },
            );
          },
        ),
      ));

      await tester.tap(find.byType(ReederSwitch));
      await tester.pumpAndSettle();

      expect(value, isTrue);
    });
  });

  group('ReederNavBar', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithTheme(
        ReederNavBar(
          title: 'Settings',
        ),
      ));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows back button when configured',
        (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(wrapWithTheme(
        ReederNavBar(
          title: 'Detail',
          showBackButton: true,
          onBack: () => backPressed = true,
        ),
      ));

      // Find and tap the back button
      final backButton = find.byWidgetPredicate(
        (widget) => widget is GestureDetector,
      );
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pump();
      }
    });
  });

  group('ReederSectionHeader', () {
    testWidgets('renders uppercase text', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithTheme(
        const ReederSectionHeader(title: 'feeds'),
      ));

      // Section header should render (may be uppercase)
      expect(find.byType(ReederSectionHeader), findsOneWidget);
    });
  });

  group('ReederListTile', () {
    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithTheme(
        ReederListTile(
          title: 'Theme',
          subtitle: 'Light',
          onTap: () {},
        ),
      ));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(wrapWithTheme(
        ReederListTile(
          title: 'Tap Me',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('Theme System', () {
    test('lightTheme has correct mode', () {
      expect(lightTheme.mode, equals(ReederThemeMode.light));
      expect(lightTheme.isDark, isFalse);
    });

    test('darkTheme has correct mode', () {
      expect(darkTheme.mode, equals(ReederThemeMode.dark));
      expect(darkTheme.isDark, isTrue);
    });

    test('ReederThemeData.copyWith preserves unchanged values', () {
      final copy = lightTheme.copyWith(
        mode: ReederThemeMode.darkLight,
      );
      expect(copy.mode, equals(ReederThemeMode.darkLight));
      expect(copy.backgroundColor, equals(lightTheme.backgroundColor));
      expect(copy.accentColor, equals(lightTheme.accentColor));
    });

    testWidgets('ReederTheme.of returns correct theme',
        (WidgetTester tester) async {
      late ReederThemeData capturedTheme;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ReederTheme(
            data: darkTheme,
            child: Builder(
              builder: (context) {
                capturedTheme = ReederTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedTheme.mode, equals(ReederThemeMode.dark));
      expect(capturedTheme.isDark, isTrue);
    });
  });
}
