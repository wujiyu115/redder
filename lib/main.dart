import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'data/repositories/article_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/background_refresh_service.dart';
import 'data/services/notification_service.dart';

void main() async {
  // Track cold start time
  final startTime = DateTime.now();

  WidgetsFlutterBinding.ensureInitialized();

  // Silence image loading HTTP errors (e.g. 403 from CDN)
  // These are already handled by CachedNetworkImage's errorWidget,
  // but Flutter's Image Resource Service still logs them as exceptions.
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final exception = details.exception;
    if (exception is HttpException &&
        details.library == 'image resource service') {
      developer.log(
        'Image load failed: ${exception.message}',
        name: 'Reeder.Image',
      );
      return;
    }
    originalOnError?.call(details);
  };

  // Initialize Drift (SQLite) database
  await AppDatabase.initialize();

  // Initialize local notifications (iOS permission prompt + Android channel).
  // Wrapped so a failure here never blocks app startup.
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    developer.log('Notification init failed: $e', name: 'Reeder.Startup');
  }

  // Load persisted settings to drive background refresh + content expiry.
  final settings = await SettingsRepository().getSettings();

  // Initialize background refresh with the persisted interval.
  // 0 = manual only: skip auto-start (service stays inert until a non-zero
  // interval is set in Settings).
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
  _scheduleContentExpiryCleanup(settings.contentExpiryDays);

  // Log cold start duration
  final startDuration = DateTime.now().difference(startTime);
  developer.log(
    'Cold start completed in ${startDuration.inMilliseconds}ms',
    name: 'Reeder.Startup',
  );

  runApp(
    const ProviderScope(
      child: ReederApp(),
    ),
  );
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
      final deleted = await ArticleRepository().deleteOldArticles(contentExpiryDays);
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
  _contentExpiryTimer = Timer.periodic(const Duration(hours: 24), (_) => cleanup());
}
