import 'package:flutter_test/flutter_test.dart';

import 'package:reeder/features/article_list/scroll_read_buffer.dart';

/// Unit tests for the scrolled-past batching buffer.
///
/// The list reports a row on every frame it stays above the viewport, so the
/// dedupe and batching rules are what keep this feature from writing to the
/// database on every frame.
void main() {
  test('markSeen returns only ids seen for the first time', () {
    final buffer = ScrollReadBuffer();

    expect(buffer.markSeen([1, 2, 3]), [1, 2, 3]);
    // The same rows get reported again on the next frame and after recycling.
    expect(buffer.markSeen([1, 2, 3]), isEmpty);
    expect(buffer.markSeen([3, 4]), [4]);
    expect(buffer.seen, {1, 2, 3, 4});
  });

  test('enqueue + takePending drains the batch in order', () {
    final buffer = ScrollReadBuffer();

    buffer.enqueue([1, 2]);
    buffer.enqueue([3]);
    expect(buffer.hasPending, isTrue);

    expect(buffer.takePending(), [1, 2, 3]);
    expect(buffer.hasPending, isFalse);
    // Draining twice must not replay the batch.
    expect(buffer.takePending(), isEmpty);
  });

  test('takePending on an empty buffer is a const empty list', () {
    final buffer = ScrollReadBuffer();

    expect(buffer.takePending(), isEmpty);
    expect(buffer.pending, isEmpty);
  });

  test('clear forgets both the dedupe set and the pending batch', () {
    final buffer = ScrollReadBuffer();

    buffer.markSeen([1, 2]);
    buffer.enqueue([1, 2]);
    buffer.clear();

    expect(buffer.seen, isEmpty);
    expect(buffer.pending, isEmpty);
    expect(buffer.markSeen([1]), [1]);
  });
}