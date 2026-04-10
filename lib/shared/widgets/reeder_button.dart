import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Button variant types for the Reeder app.
enum ReederButtonVariant {
  /// Text-only button with accent color.
  text,

  /// Icon-only button.
  icon,

  /// Button with background fill.
  filled,

  /// Button with border outline.
  outlined,
}

/// Custom button component for the Reeder app.
///
/// Supports multiple variants: text, icon, filled, and outlined.
/// Includes press animation (opacity change) for tactile feedback.
class ReederButton extends StatefulWidget {
  /// Button label text (for text/filled/outlined variants).
  final String? label;

  /// Icon widget (for icon variant or leading icon).
  final Widget? icon;

  /// Button variant style.
  final ReederButtonVariant variant;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a disabled state.
  final bool disabled;

  /// Custom text color override.
  final Color? color;

  /// Custom background color (for filled variant).
  final Color? backgroundColor;

  /// Padding override.
  final EdgeInsets? padding;

  const ReederButton({
    super.key,
    this.label,
    this.icon,
    this.variant = ReederButtonVariant.text,
    this.onPressed,
    this.disabled = false,
    this.color,
    this.backgroundColor,
    this.padding,
  });

  /// Convenience constructor for text buttons.
  const ReederButton.text({
    super.key,
    required String this.label,
    this.onPressed,
    this.disabled = false,
    this.color,
  })  : icon = null,
        variant = ReederButtonVariant.text,
        backgroundColor = null,
        padding = null;

  /// Convenience constructor for icon buttons.
  const ReederButton.icon({
    super.key,
    required Widget this.icon,
    this.onPressed,
    this.disabled = false,
    this.color,
  })  : label = null,
        variant = ReederButtonVariant.icon,
        backgroundColor = null,
        padding = null;

  /// Convenience constructor for filled buttons.
  const ReederButton.filled({
    super.key,
    required String this.label,
    this.icon,
    this.onPressed,
    this.disabled = false,
    this.color,
    this.backgroundColor,
  })  : variant = ReederButtonVariant.filled,
        padding = null;

  @override
  State<ReederButton> createState() => _ReederButtonState();
}

class _ReederButtonState extends State<ReederButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final effectiveColor = widget.disabled
        ? theme.tertiaryTextColor
        : (widget.color ?? theme.accentColor);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.disabled ? null : widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _isPressed ? 0.5 : 1.0,
        duration: AppDurations.micro,
        child: _buildContent(theme, effectiveColor),
      ),
    );
  }

  Widget _buildContent(ReederThemeData theme, Color color) {
    switch (widget.variant) {
      case ReederButtonVariant.text:
        return Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: AppDimensions.spacingXS,
              ),
          child: Text(
            widget.label ?? '',
            style: theme.typography.button.copyWith(color: color),
          ),
        );

      case ReederButtonVariant.icon:
        return SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: color, size: AppDimensions.iconM),
              child: widget.icon ?? const SizedBox.shrink(),
            ),
          ),
        );

      case ReederButtonVariant.filled:
        final bgColor = widget.backgroundColor ?? theme.accentColor;
        return Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing,
                vertical: AppDimensions.spacingM,
              ),
          decoration: BoxDecoration(
            color: widget.disabled
                ? theme.tertiaryTextColor
                : bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: widget.color ?? theme.backgroundColor,
                    size: AppDimensions.icon,
                  ),
                  child: widget.icon!,
                ),
                const SizedBox(width: AppDimensions.spacingS),
              ],
              Text(
                widget.label ?? '',
                style: theme.typography.button.copyWith(
                  color: widget.color ?? theme.backgroundColor,
                ),
              ),
            ],
          ),
        );

      case ReederButtonVariant.outlined:
        return Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing,
                vertical: AppDimensions.spacingM,
              ),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: color, size: AppDimensions.icon),
                  child: widget.icon!,
                ),
                const SizedBox(width: AppDimensions.spacingS),
              ],
              Text(
                widget.label ?? '',
                style: theme.typography.button.copyWith(color: color),
              ),
            ],
          ),
        );
    }
  }
}
