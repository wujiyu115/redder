import 'package:flutter/widgets.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Custom toggle switch for the Reeder app.
///
/// A minimal iOS-style toggle switch built without Material/Cupertino.
/// Features smooth animation and haptic-like visual feedback.
class ReederSwitch extends StatefulWidget {
  /// Whether the switch is on.
  final bool value;

  /// Called when the switch value changes.
  final ValueChanged<bool>? onChanged;

  /// Whether the switch is disabled.
  final bool disabled;

  /// Active track color override.
  final Color? activeColor;

  const ReederSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.disabled = false,
    this.activeColor,
  });

  @override
  State<ReederSwitch> createState() => _ReederSwitchState();
}

class _ReederSwitchState extends State<ReederSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  static const double _trackWidth = 51.0;
  static const double _trackHeight = 31.0;
  static const double _thumbSize = 27.0;
  static const double _thumbPadding = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.switchToggle,
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    _positionAnimation = Tween<double>(
      begin: _thumbPadding,
      end: _trackWidth - _thumbSize - _thumbPadding,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ReederSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.disabled) {
      widget.onChanged?.call(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final activeColor = widget.activeColor ?? theme.accentColor;
    final inactiveColor = theme.separatorColor;

    _colorAnimation = ColorTween(
      begin: inactiveColor,
      end: activeColor,
    ).animate(_controller);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1.0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: CustomPaint(
                painter: _SwitchPainter(
                  trackColor: _colorAnimation.value ?? inactiveColor,
                  thumbPosition: _positionAnimation.value,
                  thumbSize: _thumbSize,
                  trackHeight: _trackHeight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SwitchPainter extends CustomPainter {
  final Color trackColor;
  final double thumbPosition;
  final double thumbSize;
  final double trackHeight;

  _SwitchPainter({
    required this.trackColor,
    required this.thumbPosition,
    required this.thumbSize,
    required this.trackHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(trackHeight / 2),
    );
    canvas.drawRRect(trackRect, trackPaint);

    // Draw thumb
    final thumbPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    // Thumb shadow
    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final thumbCenter = Offset(
      thumbPosition + thumbSize / 2,
      size.height / 2,
    );

    canvas.drawCircle(thumbCenter, thumbSize / 2, shadowPaint);
    canvas.drawCircle(thumbCenter, thumbSize / 2, thumbPaint);
  }

  @override
  bool shouldRepaint(_SwitchPainter oldDelegate) {
    return trackColor != oldDelegate.trackColor ||
        thumbPosition != oldDelegate.thumbPosition;
  }
}
