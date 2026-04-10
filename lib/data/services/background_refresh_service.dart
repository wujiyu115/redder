import 'dart:async';
import 'dart:developer' as developer;

import 'feed_refresh_service.dart';

/// Service for managing background feed refresh.
///
/// Uses platform-specific background task APIs to periodically
/// refresh feed subscriptions even when the app is not in the foreground.
///
/// On iOS, uses Background App Refresh (BGAppRefreshTask).
/// On Android, uses WorkManager for periodic background work.
///
/// Since `workmanager` package is not yet added, this provides a
/// simplified implementation using Dart isolates and app lifecycle
/// callbacks for foreground periodic refresh, with hooks for
/// future platform-specific background task integration.
class BackgroundRefreshService {
  static Timer? _periodicTimer;
  static bool _isInitialized = false;

  /// Default refresh interval: 30 minutes.
  static const Duration defaultInterval = Duration(minutes: 30);

  /// Minimum refresh interval: 15 minutes.
  static const Duration minimumInterval = Duration(minutes: 15);

  BackgroundRefreshService._();

  /// Initializes the background refresh service.
  ///
  /// Sets up periodic refresh timer and registers platform callbacks.
  /// Should be called once at app startup.
  static Future<void> initialize({
    Duration interval = defaultInterval,
  }) async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Start periodic foreground refresh
    _startPeriodicRefresh(interval);

    developer.log(
      'Background refresh initialized with ${interval.inMinutes}min interval',
      name: 'Reeder.BackgroundRefresh',
    );
  }

  /// Starts periodic refresh timer.
  static void _startPeriodicRefresh(Duration interval) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) async {
      await _performRefresh();
    });
  }

  /// Updates the refresh interval.
  static void updateInterval(Duration interval) {
    final clampedInterval = interval < minimumInterval
        ? minimumInterval
        : interval;
    _periodicTimer?.cancel();
    _startPeriodicRefresh(clampedInterval);

    developer.log(
      'Refresh interval updated to ${clampedInterval.inMinutes}min',
      name: 'Reeder.BackgroundRefresh',
    );
  }

  /// Performs a background refresh of all feeds.
  static Future<void> _performRefresh() async {
    try {
      developer.log(
        'Starting background refresh...',
        name: 'Reeder.BackgroundRefresh',
      );

      final stopwatch = Stopwatch()..start();
      final service = FeedRefreshService();
      final result = await service.refreshAll();

      stopwatch.stop();
      developer.log(
        'Background refresh completed in ${stopwatch.elapsedMilliseconds}ms: '
        '${result.newItems} new items, '
        '${result.updatedFeeds}/${result.totalFeeds} feeds updated, '
        '${result.failedFeeds} failed',
        name: 'Reeder.BackgroundRefresh',
      );
    } catch (e) {
      developer.log(
        'Background refresh failed: $e',
        name: 'Reeder.BackgroundRefresh',
        error: e,
      );
    }
  }

  /// Triggers an immediate refresh (e.g., when app comes to foreground).
  static Future<void> refreshNow() async {
    await _performRefresh();
  }

  /// Pauses background refresh (e.g., when app goes to background
  /// and platform-specific background tasks take over).
  static void pause() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    developer.log(
      'Background refresh paused',
      name: 'Reeder.BackgroundRefresh',
    );
  }

  /// Resumes background refresh.
  static void resume({Duration interval = defaultInterval}) {
    _startPeriodicRefresh(interval);
    developer.log(
      'Background refresh resumed',
      name: 'Reeder.BackgroundRefresh',
    );
  }

  /// Disposes the background refresh service.
  static void dispose() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _isInitialized = false;
  }
}
