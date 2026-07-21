import 'package:flutter/widgets.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import 'reeder_toast.dart';

/// A refresh/sync icon button that spins while an async sync runs.
///
/// Gives the user immediate visual feedback: tapping starts a continuous
/// rotation that stops when [onSync] completes. An optional [externalActive]
/// flag keeps it spinning while some other sync signal (e.g. a background
/// sync status stream) is active.
class SyncIconButton extends StatefulWidget {
  /// The async action to run when tapped (a sync or local refresh).
  final Future<void> Function() onSync;

  /// Glyph size.
  final double fontSize;

  /// Icon color. Defaults to the theme accent color.
  final Color? color;

  /// Tap target size (square).
  final double size;

  /// When true, keeps spinning regardless of the local tap-driven run.
  final bool externalActive;

  /// Toast shown when a tap-driven sync succeeds. No toast if null.
  final String? successMessage;

  /// Toast shown when a tap-driven sync throws. No toast if null.
  final String? errorMessage;

  const SyncIconButton({
    super.key,
    required this.onSync,
    this.fontSize = 20,
    this.color,
    this.size = 44,
    this.externalActive = false,
    this.successMessage,
    this.errorMessage,
  });

  @override
  State<SyncIconButton> createState() => _SyncIconButtonState();
}

class _SyncIconButtonState extends State<SyncIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _running = false;

  bool get _spinning => _running || widget.externalActive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    if (widget.externalActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(SyncIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (_spinning) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_running) return;
    setState(() => _running = true);
    _syncAnimation();
    Object? error;
    try {
      await widget.onSync();
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        setState(() => _running = false);
        _syncAnimation();
      }
    }
    if (!mounted) return;
    if (error != null) {
      if (widget.errorMessage != null) {
        ReederToast.show(context, widget.errorMessage!, isError: true);
      }
    } else if (widget.successMessage != null) {
      ReederToast.show(context, widget.successMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.sync,
      child: GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: Text(
              '↻',
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.color ?? theme.accentColor,
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
