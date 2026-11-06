/// Accumulates the article ids that scrolled past the viewport.
///
/// Two responsibilities that are easy to get wrong, so they live in one small
/// testable object:
///
/// - **dedupe**: a row is reported on every frame it stays above the viewport,
///   and again whenever it is recycled back into view.
/// - **batching**: persisting + pushing to the remote service is debounced, so
///   the batch is drained in one call instead of one write per row.
class ScrollReadBuffer {
  final Set<int> _seen = {};
  final List<int> _pending = [];

  /// Ids recorded so far (debug aid / assertions in tests).
  Set<int> get seen => Set.unmodifiable(_seen);

  /// Ids waiting to be flushed.
  List<int> get pending => List.unmodifiable(_pending);

  bool get hasPending => _pending.isNotEmpty;

  /// Records [ids] as scrolled past and returns the ones seen for the first
  /// time, in input order.
  List<int> markSeen(Iterable<int> ids) {
    final fresh = <int>[];
    for (final id in ids) {
      if (_seen.add(id)) fresh.add(id);
    }
    return fresh;
  }

  /// Queues [ids] for the next flush.
  void enqueue(Iterable<int> ids) => _pending.addAll(ids);

  /// Returns the queued ids and clears the queue.
  List<int> takePending() {
    if (_pending.isEmpty) return const [];
    final batch = List<int>.of(_pending);
    _pending.clear();
    return batch;
  }

  /// Forgets everything (e.g. when a different timeline is loaded).
  void clear() {
    _seen.clear();
    _pending.clear();
  }
}