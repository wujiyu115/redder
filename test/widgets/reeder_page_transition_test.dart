import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:reeder/shared/widgets/reeder_page_transition.dart';

/// Regression tests for the iOS-style edge-swipe back gesture.
///
/// The gesture used to be dead code: it read the route animation as an
/// `AnimationController` (it is a `ProxyAnimation`), and its drag detector sat
/// *below* the page content, so every horizontal recognizer inside a page
/// (list row swipe actions, article swipe navigation) swallowed the drag.
void main() {
  late GoRouter router;

  /// Simulates the platform touch slop (Android reports ~8dp) which is
  /// smaller than [kTouchSlop], the value the back-gesture recognizer falls
  /// back to when it has no gesture settings of its own.
  DeviceGestureSettings platformGestureSettings() =>
      const DeviceGestureSettings(touchSlop: 8.0);

  Widget buildApp({
    required Widget pageA,
    required Widget pageB,
    DeviceGestureSettings? gestureSettings,
  }) {
    router = GoRouter(
      initialLocation: '/a',
      routes: [
        GoRoute(
          path: '/a',
          pageBuilder: (context, state) =>
              ReederPage(key: state.pageKey, child: pageA),
        ),
        GoRoute(
          path: '/b',
          pageBuilder: (context, state) =>
              ReederPage(key: state.pageKey, child: pageB),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
      builder: gestureSettings == null
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(gestureSettings: gestureSettings),
                child: child!,
              ),
    );
  }

  /// Drags from the left edge in small steps, the way a real finger arrives:
  /// with competing recognizers the back gesture accepts only once it crosses
  /// the touch slop, and the movement before that is not applied.
  Future<TestGesture> dragFromEdge(
    WidgetTester tester, {
    double total = 600,
    double step = 10,
    double y = 300,
  }) async {
    final gesture = await tester.startGesture(Offset(5, y));
    for (var moved = 0.0; moved < total; moved += step) {
      await gesture.moveBy(Offset(step, 0));
      await tester.pump();
    }
    return gesture;
  }

  Future<void> openSecondPage(WidgetTester tester) async {
    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('page B'), findsOneWidget);
  }

  testWidgets('edge drag makes the page follow the finger and pop',
      (tester) async {
    await tester.pumpWidget(
      buildApp(
        pageA: const Center(child: Text('page A')),
        pageB: const Center(child: Text('page B')),
      ),
    );

    await openSecondPage(tester);
    final restingLeft = tester.getTopLeft(find.text('page B')).dx;

    // Drag from the very left edge towards the right.
    final gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    // Mid-drag the incoming page is offset to the right: it follows the finger
    // instead of waiting for the fling to end.
    final draggedLeft = tester.getTopLeft(find.text('page B')).dx;
    expect(draggedLeft - restingLeft, closeTo(120, 1));

    // Past the halfway point the release pops the route.
    await gesture.moveBy(const Offset(400, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('page B'), findsNothing);
    expect(find.text('page A'), findsOneWidget);
  });

  testWidgets('releasing early snaps the page back', (tester) async {
    await tester.pumpWidget(
      buildApp(
        pageA: const Center(child: Text('page A')),
        pageB: const Center(child: Text('page B')),
      ),
    );

    await openSecondPage(tester);

    // A short, slow drag (no fling) must not pop.
    final gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('page B'), findsOneWidget);
  });

  testWidgets('a drag starting away from the edge does not pop',
      (tester) async {
    await tester.pumpWidget(
      buildApp(
        pageA: const Center(child: Text('page A')),
        pageB: const Center(child: Text('page B')),
      ),
    );

    await openSecondPage(tester);

    final gesture = await tester.startGesture(const Offset(200, 300));
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('page B'), findsOneWidget);
  });

  testWidgets('edge drag wins over a horizontal recognizer in the page',
      (tester) async {
    var pageDragStartCount = 0;
    var pageDragUpdateCount = 0;

    await tester.pumpWidget(
      buildApp(
        pageA: const Center(child: Text('page A')),
        pageB: GestureDetector(
          // Stands in for the list's row swipe actions.
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => pageDragStartCount++,
          onHorizontalDragUpdate: (_) => pageDragUpdateCount++,
          child: const Center(child: Text('page B')),
        ),
      ),
    );

    await openSecondPage(tester);

    final gesture = await dragFromEdge(tester);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(pageDragStartCount, 0, reason: 'the page gesture must lose the arena');
    expect(pageDragUpdateCount, 0);
    expect(find.text('page B'), findsNothing);
  });

  testWidgets('edge drag still wins with the platform touch slop on rows',
      (tester) async {
    // Regression: Android reports a touch slop (8dp) smaller than [kTouchSlop]
    // (18), which the back-gesture recognizer falls back to. The row's own
    // horizontal recognizer therefore accepted the pointer first and the edge
    // swipe over a list row did nothing on device.
    var pageDragStartCount = 0;
    var pageDragUpdateCount = 0;
    double? seenTouchSlop;

    await tester.pumpWidget(
      buildApp(
        gestureSettings: platformGestureSettings(),
        pageA: const Center(child: Text('page A')),
        pageB: Builder(builder: (context) {
          seenTouchSlop = MediaQuery.maybeGestureSettingsOf(context)?.touchSlop;
          return GestureDetector(
            // Stands in for the list's row swipe actions.
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => pageDragStartCount++,
            onHorizontalDragUpdate: (_) => pageDragUpdateCount++,
            child: const Center(child: Text('page B')),
          );
        }),
      ),
    );

    await openSecondPage(tester);
    // The page sees the route's normalised slop, not the platform's 8dp.
    expect(seenTouchSlop, kTouchSlop);

    final gesture = await dragFromEdge(tester);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(pageDragStartCount, 0,
        reason: 'the page gesture must lose the arena');
    expect(pageDragUpdateCount, 0);
    expect(find.text('page B'), findsNothing);
  });

  testWidgets('the first route cannot be swiped away', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/a',
          routes: [
            GoRoute(
              path: '/a',
              pageBuilder: (context, state) =>
                  ReederPage(key: state.pageKey, child: const Text('page A')),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('page A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}