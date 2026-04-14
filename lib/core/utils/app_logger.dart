import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized logger for the Reeder app.
///
/// Outputs to both the debug console (via [debugPrint]) and the DevTools
/// Logging panel (via [developer.log]).  Console output is only enabled
/// in debug mode.
///
/// In debug mode, each log line includes the caller's file name and line
/// number for easy navigation (e.g. `feed_refresh_service.dart:42`).
///
/// Usage:
/// ```dart
/// static const _log = AppLogger('Sync');
/// _log.info('Account added');
/// _log.warning('Token expiring soon');
/// _log.error('Authentication failed', error: e);
/// ```
class AppLogger {
  /// The module name, used as the log tag (`Reeder.<module>`).
  final String _module;

  const AppLogger(this._module);

  String get _tag => 'Reeder.$_module';

  /// Logs an informational message (level 0 — default).
  void info(String message) {
    final location = _callerLocation();
    _print('💡 [$_tag] $location$message');
    developer.log('$location$message', name: _tag);
  }

  /// Logs a warning message (level 900).
  void warning(String message) {
    final location = _callerLocation();
    _print('⚠️ [$_tag] $location$message');
    developer.log('$location$message', name: _tag, level: 900);
  }

  /// Logs an error message (level 1000) with an optional [error] object
  /// and [stackTrace].
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final location = _callerLocation();
    _print('❌ [$_tag] $location$message${error != null ? ' | $error' : ''}');
    developer.log(
      '$location$message',
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Extracts the caller's file name and line number from the stack trace.
  ///
  /// Returns a string like ` (feed_refresh_service.dart:42)` in debug mode,
  /// or an empty string in release mode (zero overhead).
  static String _callerLocation() {
    if (!kDebugMode) return '';
    try {
      // Frame 0: _callerLocation
      // Frame 1: info/warning/error
      // Frame 2: actual caller
      final frames = StackTrace.current.toString().split('\n');
      if (frames.length < 3) return '';
      final callerFrame = frames[2];
      // Dart stack frames look like:
      //   #2      FeedRefreshService.refreshAll (package:reeder/data/services/feed_refresh_service.dart:42:5)
      final match = RegExp(r'\(package:.*?/(.+?):(\d+):\d+\)').firstMatch(callerFrame);
      if (match != null) {
        return ' (${match.group(1)}:${match.group(2)})';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  /// Prints to the debug console only in debug mode.
  static void _print(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
