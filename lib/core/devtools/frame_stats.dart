// ignore_for_file: avoid_print — the whole point is console output that
// survives AOT: `developer.log` is dropped without an attached debugger.
import 'package:flutter/scheduler.dart';

/// Compile-time switch for the on-device frame-time probe.
///
/// Enable with `--dart-define=FRAME_LOG=true` and read the summaries in
/// logcat (`adb logcat -s flutter`). Off by default, zero cost in normal
/// builds: the whole module compiles to a no-op `if (false)` return.
const bool frameLogEnabled = bool.fromEnvironment('FRAME_LOG');

/// Prints aggregated frame timings every [_windowFrames] frames.
///
/// Numbers reported per window:
/// - build / raster p50, p95, max in ms
/// - how many frames missed 16.7 ms (60 Hz budget), and 33.4 ms (dropped 2+)
///
/// This exists because "it feels janky" is not actionable: it tells you
/// whether the cost is on the UI thread (build/layout/paint) or on the raster
/// thread (image decoding, shader compilation, big repaints).
void enableFrameStats() {
  if (!frameLogEnabled) return;

  const windowFrames = 90;
  final build = <int>[];
  final raster = <int>[];
  var windows = 0;

  SchedulerBinding.instance.addTimingsCallback((timings) {
    for (final t in timings) {
      build.add(t.buildDuration.inMicroseconds);
      raster.add(t.rasterDuration.inMicroseconds);
      // Spike log: names the thread that blew the 60 Hz budget, which is what
      // decides whether the fix belongs in Dart (build) or in the image /
      // GPU path (raster).
      if (t.buildDuration.inMicroseconds > 16667 ||
          t.rasterDuration.inMicroseconds > 16667) {
        print('FrameSpike build=${(t.buildDuration.inMicroseconds / 1000).toStringAsFixed(1)} '
            'raster=${(t.rasterDuration.inMicroseconds / 1000).toStringAsFixed(1)} '
            'span=${(t.totalSpan.inMicroseconds / 1000).toStringAsFixed(1)}');
      }
    }
    if (build.length < windowFrames) return;

    windows++;
    final buildUs = List<int>.of(build);
    final rasterUs = List<int>.of(raster);
    build.clear();
    raster.clear();
    buildUs.sort();
    rasterUs.sort();

    String pct(List<int> us, double p) =>
        (us[(us.length - 1) * p ~/ 1] / 1000).toStringAsFixed(1);
    int missed(List<int> us, int budgetUs) => us.where((v) => v > budgetUs).length;

    print(
      'FrameStats#$windows n=${buildUs.length} '
      'build p50=${pct(buildUs, 0.5)} p95=${pct(buildUs, 0.95)} max=${pct(buildUs, 1.0)} '
      'raster p50=${pct(rasterUs, 0.5)} p95=${pct(rasterUs, 0.95)} max=${pct(rasterUs, 1.0)} '
      'missed16=${missed(buildUs, 16667) + missed(rasterUs, 16667)}'
      ' missed33=${missed(buildUs, 33333) + missed(rasterUs, 33333)}',
    );
  });
}