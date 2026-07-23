import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/app_logger.dart';

/// Singleton wrapper around `flutter_local_notifications`.
///
/// Responsible only for showing OS-level local notifications. Callers
/// (e.g. [FeedRefreshService]) are responsible for checking the app-level
/// and per-feed `notificationsEnabled` flags before calling
/// [showArticleNotification] — this service does not gate on settings.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _log = AppLogger('Notifications');

  static const String _channelId = 'reeder_new_articles';
  static const String _channelName = 'New Articles';
  static const String _channelDescription =
      'Notifications about new articles from your subscriptions.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the plugin, requests permissions (iOS) and creates the
  /// Android notification channel. Safe to call multiple times (no-op after
  /// the first success). Failures are logged and swallowed so that a missing
  /// notification setup never blocks app functionality.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      // Do NOT request permissions during initialize(): on iOS that suspends
      // on the system permission dialog. Permissions are requested separately
      // via [requestPermissions] so app startup is never blocked.
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: iosInit,
      );

      final ok = await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      if (ok == null || !ok) {
        _log.warning('initialize: plugin reported not-initialized (ok=$ok)');
      }

      // Create the Android channel (API 26+). No-op on older versions / iOS.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.defaultImportance,
          ));

      _initialized = true;
      _log.info('initialize: ready (platform=${Platform.operatingSystem})');
    } catch (e, st) {
      _log.error('initialize: failed', error: e, stackTrace: st);
      // Leave _initialized false so a later retry is possible, but never throw.
    }
  }

  /// Requests OS notification permissions (iOS/macOS).
  ///
  /// On iOS/macOS this suspends until the user answers the system permission
  /// dialog, so it MUST NOT be awaited on the app-startup path (doing so
  /// before `runApp` blocks the first frame behind the dialog). Call it
  /// fire-and-forget so the UI renders while the prompt is shown.
  Future<void> requestPermissions() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e, st) {
      _log.error('requestPermissions: failed', error: e, stackTrace: st);
    }
  }

  /// Shows a single local notification. Silently no-ops if [initialize] has
  /// not succeeded.
  Future<void> showArticleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      _log.warning('showArticleNotification: not initialized, dropping "$title"');
      return;
    }
    try {
      await _plugin.show(
        _nextId(),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e, st) {
      _log.error('showArticleNotification: failed for "$title"', error: e, stackTrace: st);
    }
  }

  /// Clears all delivered notifications (e.g. on app foreground).
  Future<void> clearAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      _log.error('clearAll: failed', error: e);
    }
  }

  // ponytail: monotonic id from a single counter is plenty for a low-volume
  // RSS notification source; collisions under ~2^31 notifications are not a
  // concern. Switch to a persisted counter if dedup-by-id becomes a real need.
  static int _idCounter = 0;
  static int _nextId() => (_idCounter++) % 0x7FFFFFFF;

  // Tap handling is out of scope for the new-article flow (no deep link yet);
  // log only so the wiring is visible when it lands.
  static void _onNotificationResponse(NotificationResponse response) {
    _log.info('notification tapped: id=${response.id} payload=${response.payload}');
  }
}
