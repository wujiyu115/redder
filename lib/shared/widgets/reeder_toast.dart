import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// Lightweight transient toast shown via the app [Overlay].
///
/// The app uses custom scaffolding (no Material [ScaffoldMessenger]), so this
/// provides a themed, auto-dismissing message for success/failure feedback.
class ReederToast {
  const ReederToast._();

  /// Shows a toast with [message]. Set [isError] for an error-styled toast.
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final theme = ReederTheme.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        isError: isError,
        theme: theme,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final ReederThemeData theme;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.isError,
    required this.theme,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _run();
  }

  Future<void> _run() async {
    await _controller.forward();
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final mq = MediaQuery.of(context);
    final accent =
        widget.isError ? theme.destructiveColor : theme.successColor;

    return Positioned(
      left: AppDimensions.spacingXL,
      right: AppDimensions.spacingXL,
      bottom: mq.padding.bottom + AppDimensions.spacingXXL,
      child: FadeTransition(
        opacity: _controller,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingL,
              vertical: AppDimensions.spacing,
            ),
            decoration: BoxDecoration(
              color: theme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: theme.separatorColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isError ? '✕' : '✓',
                  style: TextStyle(fontSize: 15, color: accent),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Flexible(
                  child: Text(
                    widget.message,
                    style: theme.typography.body.copyWith(
                      color: theme.primaryTextColor,
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
