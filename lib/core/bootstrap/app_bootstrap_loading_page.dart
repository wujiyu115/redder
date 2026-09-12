import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/app_colors.dart';
import 'boot_progress.dart';

/// Solid-color gate UI shown while the app initializes before [ReederApp]
/// mounts. Normal startup is just a colored layer (light: white, dark: the
/// app's dark background), so the native launch window hands off to real UI
/// without a stray white flash in dark mode.
///
/// After [_stallAfter] it names the startup stage it is waiting on: a hang
/// would otherwise be indistinguishable from a crash. Built from raw widgets
/// (no WidgetsApp above it yet), so it carries its own [Directionality].
class AppBootstrapLoadingPage extends StatefulWidget {
  const AppBootstrapLoadingPage({super.key});

  /// How long startup may sit silently before the page explains itself.
  static const _stallAfter = Duration(seconds: 8);

  @override
  State<AppBootstrapLoadingPage> createState() =>
      _AppBootstrapLoadingPageState();
}

class _AppBootstrapLoadingPageState extends State<AppBootstrapLoadingPage> {
  Timer? _stallTimer;
  var _stalled = false;

  @override
  void initState() {
    super.initState();
    _stallTimer = Timer(AppBootstrapLoadingPage._stallAfter, () {
      if (mounted) setState(() => _stalled = true);
    });
  }

  @override
  void dispose() {
    _stallTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Settings (including the app theme) are not loaded yet; the system
    // brightness is the only signal available at this point.
    final dark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: dark ? AppColors.darkBackground : AppColors.lightBackground,
        child: _stalled
            ? Center(child: _StallDiagnostics(dark: dark))
            : null,
      ),
    );
  }
}

/// Names the stage startup is stuck on, and for how long.
///
/// Deliberately unlocalized: the l10n delegates are themselves part of what
/// may have failed to load.
class _StallDiagnostics extends StatefulWidget {
  const _StallDiagnostics({required this.dark});

  final bool dark;

  @override
  State<_StallDiagnostics> createState() => _StallDiagnosticsState();
}

class _StallDiagnosticsState extends State<_StallDiagnostics> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The stuck duration is the load-bearing number, so it has to keep
    // moving — a frozen "12s" reads as a frozen UI.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ValueListenableBuilder<String>(
        valueListenable: BootProgress.stage,
        builder: (context, stage, _) {
          final stuckSeconds =
              (BootProgress.elapsedMs - BootProgress.enteredAtMs) ~/ 1000;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Still starting…',
                style: TextStyle(
                  color: widget.dark
                      ? const Color(0xFFBBBBBB)
                      : const Color(0xFF444444),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$stage — ${stuckSeconds}s',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.dark
                      ? const Color(0xFF999999)
                      : const Color(0xFF888888),
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
