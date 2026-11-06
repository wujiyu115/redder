import 'dart:async';
import 'dart:developer' as developer;

import '../repositories/article_repository.dart';

/// Schedules periodic deletion of articles older than the configured
/// retention window.
///
/// The schedule is app-lifetime state, so this is a static holder rather than
/// an injected service: the bootstrap arms it at startup and
/// `SettingsNotifier.setContentExpiryDays` re-arms it when the user changes the
/// value, so the setting takes effect immediately instead of after a restart.
class ContentExpiryService {
  static Timer? _timer;

  /// How often the cleanup re-runs while the app stays open.
  static const period = Duration(hours: 24);

  /// (Re)arms the cleanup for [days]. `0` (never) cancels any pending timer.
  ///
  /// Runs once immediately so a lowered retention window prunes right away.
  static void schedule(int days) {
    _timer?.cancel();
    _timer = null;
    if (days <= 0) return;

    Future<void> cleanup() async {
      try {
        final deleted = await ArticleRepository().deleteOldArticles(days);
        developer.log(
          'Content expiry cleanup: removed $deleted articles older than '
          '$days days',
          name: 'Reeder.Expiry',
        );
      } catch (e) {
        developer.log(
          'Content expiry cleanup failed: $e',
          name: 'Reeder.Expiry',
          error: e,
        );
      }
    }

    cleanup();
    _timer = Timer.periodic(period, (_) => cleanup());
  }

  /// Cancels the pending timer (used by tests).
  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}