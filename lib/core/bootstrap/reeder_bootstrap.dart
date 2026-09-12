import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import '../../app.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/background_refresh_service.dart';
import '../../data/services/notification_service.dart';
import '../constants/app_colors.dart';
import '../database/app_database.dart';
import 'app_bootstrap_loading_page.dart';
import 'boot_progress.dart';

/// Startup gate ("wrap a layer"): mounts immediately at runApp with a
/// solid-color loading page, runs the initialization chain that used to block
/// main() before the first frame, then swaps in [ReederApp].
///
/// This is what removes the startup white screen: the first frame paints as
/// soon as the engine is ready instead of after database + settings load, and
/// a hang no longer renders as a silent blank screen — the loading page names
/// the stuck stage after 8s, and a failure shows an error view with retry.
class ReederBootstrap extends StatefulWidget {
  const ReederBootstrap({super.key});

  @override
  State<ReederBootstrap> createState() => _ReederBootstrapState();
}

class _ReederBootstrapState extends State<ReederBootstrap> {
  final _bootWatch = Stopwatch()..start();
  var _ready = false;
  Object? _error;
  var _retrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_start());
    });
  }

  Future<void> _start() async {
    try {
      await _initializeApp();
      if (!mounted) return;
      developer.log(
        'Cold start completed in ${_bootWatch.elapsedMilliseconds}ms',
        name: 'Reeder.Startup',
      );
      setState(() {
        _ready = true;
        _error = null;
        _retrying = false;
      });
    } on Object catch (error, stackTrace) {
      developer.log(
        'Bootstrap failed',
        error: error,
        stackTrace: stackTrace,
        name: 'Reeder.Startup',
      );
      if (!mounted) return;
      setState(() {
        _error = error;
        _retrying = false;
      });
    }
  }

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    await _start();
  }

  Future<void> _initializeApp() async {
    // Initialize Drift (SQLite) database
    BootProgress.mark('database');
    await AppDatabase.initialize();

    // Initialize local notifications (Android channel + plugin setup).
    // Wrapped so a failure here never blocks app startup.
    BootProgress.mark('notifications');
    try {
      await NotificationService.instance.initialize();
      // Request OS permissions non-blocking: on iOS this awaits the system
      // dialog, which must not gate the first frame. The prompt appears over
      // the already-rendered UI.
      unawaited(NotificationService.instance.requestPermissions());
    } catch (e) {
      developer.log('Notification init failed: $e', name: 'Reeder.Startup');
    }

    // Load persisted settings to drive background refresh + content expiry.
    BootProgress.mark('settings');
    final settings = await SettingsRepository().getSettings();

    // Initialize background refresh with the persisted interval.
    // 0 = manual only: skip auto-start (service stays inert until a non-zero
    // interval is set in Settings).
    BootProgress.mark('background_refresh');
    final refreshMinutes = settings.autoRefreshIntervalMinutes;
    if (refreshMinutes > 0) {
      await BackgroundRefreshService.initialize(
        interval: Duration(minutes: refreshMinutes),
      );
    } else {
      // Still mark initialized so later `updateInterval` calls don't no-op-start.
      await BackgroundRefreshService.initialize(
        interval: BackgroundRefreshService.defaultInterval,
      );
      BackgroundRefreshService.pause();
    }

    // Schedule periodic cleanup of articles older than contentExpiryDays.
    // Runs once at startup and then every 24h.
    BootProgress.mark('cleanup');
    _scheduleContentExpiryCleanup(settings.contentExpiryDays);

    BootProgress.mark('ready');
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return _BootstrapErrorView(
        error: error,
        retrying: _retrying,
        onRetry: _retry,
      );
    }
    if (!_ready) return const AppBootstrapLoadingPage();
    return const ReederApp();
  }
}

/// Schedules a periodic cleanup of articles older than `contentExpiryDays`.
///
/// Runs immediately (if days > 0) and then every 24h. When days == 0 the
/// cleanup is a no-op and no timer is scheduled.
Timer? _contentExpiryTimer;
void _scheduleContentExpiryCleanup(int contentExpiryDays) {
  _contentExpiryTimer?.cancel();
  if (contentExpiryDays <= 0) return;

  Future<void> cleanup() async {
    try {
      final deleted =
          await ArticleRepository().deleteOldArticles(contentExpiryDays);
      developer.log(
        'Content expiry cleanup: removed $deleted articles older than '
        '$contentExpiryDays days',
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

  // Kick off immediately on startup.
  cleanup();
  _contentExpiryTimer =
      Timer.periodic(const Duration(hours: 24), (_) => cleanup());
}

/// Startup failure surface. Plain widgets (no theme/l10n machinery that may
/// itself have failed to load); unlocalized by design.
class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({
    required this.error,
    required this.retrying,
    required this.onRetry,
  });

  final Object error;
  final bool retrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Settings (including the app theme) are not loaded yet; the system
    // brightness is the only signal available at this point.
    final dark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryText =
        dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        dark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = dark ? AppColors.darkAccent : AppColors.lightAccent;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Startup failed',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: retrying ? null : onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: accent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      retrying ? 'Retrying…' : 'Retry',
                      style: TextStyle(color: accent, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
