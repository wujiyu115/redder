import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';

/// Provider for the scroll position service.
final scrollPositionServiceProvider = Provider<ScrollPositionService>((ref) {
  return ScrollPositionService();
});

/// Service for managing scroll position persistence.
///
/// Each timeline (unified, category, folder, single feed, tag, filter)
/// has its own independent scroll position that is:
/// - Saved with 500ms debouncing to avoid excessive writes
/// - Restored when the timeline is reopened
class ScrollPositionService {
  AppDatabase get _db => AppDatabase.instance;

  /// Map of active debounce timers per timeline.
  final Map<String, Timer> _debounceTimers = {};

  /// Debounce delay for saving scroll positions.
  static const _debounceDelay = Duration(milliseconds: 500);

  /// Saves the scroll position for a timeline with debouncing.
  void savePositionDebounced({
    required String timelineId,
    required double scrollOffset,
    int? lastItemId,
  }) {
    _debounceTimers[timelineId]?.cancel();

    _debounceTimers[timelineId] = Timer(_debounceDelay, () {
      _savePosition(
        timelineId: timelineId,
        scrollOffset: scrollOffset,
        lastItemId: lastItemId,
      );
      _debounceTimers.remove(timelineId);
    });
  }

  /// Saves the scroll position immediately (no debouncing).
  Future<void> savePositionImmediate({
    required String timelineId,
    required double scrollOffset,
    int? lastItemId,
  }) {
    _debounceTimers[timelineId]?.cancel();
    _debounceTimers.remove(timelineId);
    return _savePosition(
      timelineId: timelineId,
      scrollOffset: scrollOffset,
      lastItemId: lastItemId,
    );
  }

  /// Internal method to persist the scroll position.
  Future<void> _savePosition({
    required String timelineId,
    required double scrollOffset,
    int? lastItemId,
  }) async {
    try {
      await _db.into(_db.scrollPositions).insertOnConflictUpdate(
        ScrollPositionsCompanion.insert(
          timelineId: timelineId,
          scrollOffset: Value(scrollOffset),
          lastItemId: Value(lastItemId),
          savedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Silently fail on scroll position save errors
    }
  }

  /// Restores the scroll position for a timeline.
  ///
  /// Returns null if no saved position exists.
  Future<ScrollPosition?> getPosition(String timelineId) async {
    try {
      return await (_db.select(_db.scrollPositions)
            ..where((t) => t.timelineId.equals(timelineId)))
          .getSingleOrNull();
    } catch (_) {
      return null;
    }
  }

  /// Deletes the saved scroll position for a timeline.
  Future<void> deletePosition(String timelineId) async {
    try {
      await (_db.delete(_db.scrollPositions)
            ..where((t) => t.timelineId.equals(timelineId)))
          .go();
    } catch (_) {
      // Silently fail
    }
  }

  /// Deletes all saved scroll positions.
  Future<void> deleteAllPositions() async {
    try {
      await _db.delete(_db.scrollPositions).go();
    } catch (_) {
      // Silently fail
    }
  }

  /// Cancels all pending debounce timers.
  void cancelAll() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }
}
