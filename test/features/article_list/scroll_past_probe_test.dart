import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reeder/features/article_list/widgets/scroll_past_probe.dart';

/// Geometry tests for the "mark as read on scroll" probe.
///
/// The probe must report a row exactly when it has left the viewport, and must
/// never report a row that is still visible.
void main() {
  const rowHeight = 100.0;

  Future<ScrollPastReporter> pumpRows(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final reporter = ScrollPastReporter();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.builder(
          itemExtent: rowHeight,
          itemCount: 40,
          itemBuilder: (context, index) => ScrollPastProbe(
            itemId: index,
            reporter: reporter,
            child: SizedBox(
              height: rowHeight,
              child: Text('row $index'),
            ),
          ),
        ),
      ),
    );
    return reporter;
  }

  testWidgets('reports nothing while the list sits at the top',
      (tester) async {
    final reporter = await pumpRows(tester);

    expect(reporter.collectScrolledPast(), isEmpty);
  });

  testWidgets('reports rows once they leave the viewport', (tester) async {
    final reporter = await pumpRows(tester);

    // 600px viewport / 100px rows => rows 0-5 visible. Scrolling ~230px pushes
    // rows 0 and 1 completely above the top while row 2 is still on screen.
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pump();

    final scrolledPast = reporter.collectScrolledPast();
    expect(scrolledPast, containsAll(<int>[0, 1]));
    expect(scrolledPast, isNot(contains(2)));
    expect(scrolledPast.every((id) => id < 2), isTrue);
  });

  testWidgets('stops reporting a row that is scrolled back into view',
      (tester) async {
    final reporter = await pumpRows(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pump();
    expect(reporter.collectScrolledPast(), isNotEmpty);

    await tester.drag(find.byType(ListView), const Offset(0, 250));
    await tester.pump();

    expect(reporter.collectScrolledPast(), isEmpty);
  });

  testWidgets('tracks recycled rows by their current item id', (tester) async {
    final reporter = await pumpRows(tester);

    // Fling far enough that the first rows are destroyed and later rows are
    // recycled into the tree; those recycled rows must not be reported while
    // they are visible.
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 2000);
    await tester.pumpAndSettle();

    final visibleRows = <int>[
      for (final element in find.byType(Text).evaluate())
        int.parse(
          (element.widget as Text).data!.replaceAll('row ', ''),
        ),
    ];
    expect(visibleRows, isNotEmpty);

    final scrolledPast = reporter.collectScrolledPast();
    expect(scrolledPast.toSet().intersection(visibleRows.toSet()), isEmpty);
  });

  testWidgets('works with variable row heights (real SliverList)',
      (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    double rowHeight(int index) => 80.0 + (index % 3) * 30.0;
    final reporter = ScrollPastReporter();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, index) => ScrollPastProbe(
            itemId: index,
            reporter: reporter,
            child: SizedBox(
              height: rowHeight(index),
              child: Text('row $index'),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    final scrolledPast = reporter.collectScrolledPast();
    expect(scrolledPast, isNotEmpty);
    for (final id in scrolledPast) {
      final row = find.text('row $id');
      // Rows already recycled by the sliver can't be measured; the ones still
      // mounted must really be entirely above the viewport top.
      if (row.evaluate().isEmpty) continue;
      final top = tester.getTopLeft(row).dy;
      expect(
        top + rowHeight(id),
        lessThanOrEqualTo(0),
        reason: 'row $id is still on screen but was reported as scrolled past',
      );
    }
  });

  testWidgets('unregisters probes when the list is disposed', (tester) async {
    final reporter = await pumpRows(tester);
    expect(reporter.debugMountedCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());

    expect(reporter.debugMountedCount, 0);
  });
}