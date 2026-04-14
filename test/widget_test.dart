// Basic smoke test for the Reeder app.
//
// Verifies that the app can be instantiated and rendered
// without throwing any errors.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reeder/app.dart';
import 'package:reeder/core/database/app_database.dart';

void main() {
  setUpAll(() async {
    // Initialize an in-memory database for testing
    await AppDatabase.initializeForTesting();
  });

  tearDownAll(() async {
    await AppDatabase.shutdown();
  });

  testWidgets('ReederApp smoke test - app renders without errors',
      (WidgetTester tester) async {
    // Build the app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ReederApp(),
      ),
    );

    // Verify the app renders without throwing.
    expect(tester.takeException(), isNull);
  });
}
