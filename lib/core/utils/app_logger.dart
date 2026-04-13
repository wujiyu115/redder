import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized logger for the Reeder app.
///
/// Outputs to both the debug console (via [debugPrint]) and the DevTools
/// Logging panel (via [developer.log]).  Console output is only enabled
/// in debug mode.
///
/// Usage:
/// ```dart
/// final _log = AppLogger('Sync');
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
    _print('💡 [$_tag] $message');
    developer.log(message, name: _tag);
  }

  /// Logs a warning message (level 900).
  void warning(String message) {
    _print('⚠️ [$_tag] $message');
    developer.log(message, name: _tag, level: 900);
  }

  /// Logs an error message (level 1000) with an optional [error] object
  /// and [stackTrace].
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _print('❌ [$_tag] $message${error != null ? ' | $error' : ''}');
    developer.log(
      message,
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Prints to the debug console only in debug mode.
  static void _print(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
