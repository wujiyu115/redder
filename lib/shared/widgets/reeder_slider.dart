import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// Custom slider component for the Reeder app.
///
/// Used for font size, line height, volume, and other continuous settings.
/// Built without Material/Cupertino dependencies.
class ReederSlider extends StatefulWidget {
  /// Current value (between [min] and [max]).
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Number of discrete divisions. If null, the slider is continuous.
  final int? divisions;

  /// Called when the value changes during dragging.
  final ValueChanged<double>? onChanged;

  /// Called when the user finishes dragging.
  final ValueChanged<double>? onChangeEnd;

  /// Active track color override.
  final Color? activeColor;

  /// Inactive track color override.
  final Color? inactiveColor;

  /// Whether the slider is disabled.
  final bool disabled;

  /// Optional label widget displayed at the start.
  final Widget? startLabel;

  /// Optional label widget displayed at the end.
  final Widget? endLabel;

  const ReederSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.activeColor,
    this.inactiveColor,
    this.disabled = false,
    this.startLabel,
    this.endLabel,
  });

  @override
  State<ReederSlider> createState() => _ReederSliderState();
}

class _ReederSliderState extends State<ReederSlider> {
  static const double _trackHeight = 4.0;
  static const double _thumbSize = 28.0;
  static const double _hitAreaHeight = 44.0;

  double _currentValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(ReederSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  double _clampValue(double value) {
    double clamped = value.clamp(widget.min, widget.max);
    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      clamped = (clamped / step).round() * step;
      clamped = clamped.clamp(widget.min, widget.max);
    }
    return clamped;
  }

  double _valueToPosition(double value, double trackWidth) {
    if (widget.max == widget.min) return 0;
    return ((value - widget.min) / (widget.max - widget.min)) * trackWidth;
  }

  double _positionToValue(double position, double trackWidth) {
    if (trackWidth == 0) return widget.min;
    return widget.min +
        (position / trackWidth) * (widget.max - widget.min);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1.0,
      child: Row(
        children: [
          if (widget.startLabel != null) ...[
            widget.startLabel!,
            const SizedBox(width: AppDimensions.spacingS),
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth - _thumbSize;
                final thumbPosition =
                    _valueToPosition(_currentValue, trackWidth);

                return GestureDetector(
                  onHorizontalDragStart: widget.disabled
                      ? null
                      : (details) {
                          setState(() => _isDragging = true);
                          _updateValue(details.localPosition.dx, trackWidth);
                        },
                  onHorizontalDragUpdate: widget.disabled
                      ? null
                      : (details) {
                          _updateValue(details.localPosition.dx, trackWidth);
                        },
                  onHorizontalDragEnd: widget.disabled
                      ? null
                      : (details) {
                          setState(() => _isDragging = false);
                          widget.onChangeEnd?.call(_currentValue);
                        },
                  onTapDown: widget.disabled
                      ? null
                      : (details) {
                          _updateValue(details.localPosition.dx, trackWidth);
                          widget.onChangeEnd?.call(_currentValue);
                        },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: _hitAreaHeight,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, _hitAreaHeight),
                      painter: _SliderPainter(
                        activeColor:
                            widget.activeColor ?? theme.accentColor,
                        inactiveColor:
                            widget.inactiveColor ?? theme.separatorColor,
                        thumbPosition: thumbPosition + _thumbSize / 2,
                        trackHeight: _trackHeight,
                        thumbSize: _thumbSize,
                        trackWidth: constraints.maxWidth,
                        divisions: widget.divisions,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.endLabel != null) ...[
            const SizedBox(width: AppDimensions.spacingS),
            widget.endLabel!,
          ],
        ],
      ),
    );
  }

  void _updateValue(double localX, double trackWidth) {
    final adjustedX = (localX - _thumbSize / 2).clamp(0.0, trackWidth);
    final newValue = _clampValue(_positionToValue(adjustedX, trackWidth));
    if (newValue != _currentValue) {
      setState(() => _currentValue = newValue);
      widget.onChanged?.call(newValue);
    }
  }
}

class _SliderPainter extends CustomPainter {
  final Color activeColor;
  final Color inactiveColor;
  final double thumbPosition;
  final double trackHeight;
  final double thumbSize;
  final double trackWidth;
  final int? divisions;

  _SliderPainter({
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbPosition,
    required this.trackHeight,
    required this.thumbSize,
    required this.trackWidth,
    this.divisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackRadius = trackHeight / 2;

    // Inactive track
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, centerY - trackRadius, size.width, trackHeight),
        Radius.circular(trackRadius),
      ),
      inactivePaint,
    );

    // Active track
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, centerY - trackRadius, thumbPosition, trackHeight),
        Radius.circular(trackRadius),
      ),
      activePaint,
    );

    // Division marks
    if (divisions != null && divisions! > 0) {
      final divisionPaint = Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.fill;

      for (int i = 1; i < divisions!; i++) {
        final x = (i / divisions!) * trackWidth;
        canvas.drawCircle(
          Offset(x, centerY),
          2,
          divisionPaint,
        );
      }
    }

    // Thumb shadow
    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
      Offset(thumbPosition, centerY),
      thumbSize / 2,
      shadowPaint,
    );

    // Thumb
    final thumbPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(thumbPosition, centerY),
      thumbSize / 2,
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return thumbPosition != oldDelegate.thumbPosition ||
        activeColor != oldDelegate.activeColor;
  }
}
