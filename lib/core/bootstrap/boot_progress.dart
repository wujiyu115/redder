import 'package:flutter/foundation.dart';

/// Last startup stage announced by the bootstrap gate, plus how long ago.
///
/// A global rather than a provider: it is written from the bootstrap gate
/// before any provider scope exists, and read by the bootstrap loading page,
/// the only thing on screen at the time.
///
/// Exists because a *stalled* startup and a *crashed* startup look identical
/// (blank screen), and there is no log file to consult on a stock device.
class BootProgress {
  BootProgress._();

  /// Notifies on every [mark]; the loading page rebuilds its status line.
  static final ValueNotifier<String> stage = ValueNotifier<String>('starting');

  static final _clock = Stopwatch()..start();

  /// Milliseconds since the process began recording stages.
  static int get elapsedMs => _clock.elapsedMilliseconds;

  /// When the current [stage] was entered, in [elapsedMs] terms. A large gap
  /// between this and now is exactly the "stuck here" signal.
  static int enteredAtMs = 0;

  static void mark(String phase) {
    enteredAtMs = _clock.elapsedMilliseconds;
    stage.value = phase;
  }

  @visibleForTesting
  static void reset() {
    enteredAtMs = 0;
    stage.value = 'starting';
  }
}
