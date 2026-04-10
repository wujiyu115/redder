import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Custom list tile component for the Reeder app.
///
/// Used primarily in settings pages and source list.
/// Supports leading icon, title, subtitle, trailing widget,
/// and optional separator.
class ReederListTile extends StatefulWidget {
  /// Leading widget (icon or image).
  final Widget? leading;

  /// Title text.
  final String title;

  /// Subtitle text.
  final String? subtitle;

  /// Trailing widget (switch, chevron, value text, etc.).
  final Widget? trailing;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether to show a bottom separator.
  final bool showSeparator;

  /// Whether the tile is in a disabled state.
  final bool disabled;

  /// Custom padding override.
  final EdgeInsets? padding;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Whether to show a disclosure indicator (chevron) as trailing.
  final bool showDisclosure;

  const ReederListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.showSeparator = true,
    this.disabled = false,
    this.padding,
    this.backgroundColor,
    this.showDisclosure = false,
  });

  @override
  State<ReederListTile> createState() => _ReederListTileState();
}

class _ReederListTileState extends State<ReederListTile> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && widget.onTap != null) {
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

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.disabled ? null : widget.onTap,
      onLongPress: widget.disabled ? null : widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.micro,
        color: _isPressed
            ? theme.separatorColor.withOpacity(0.3)
            : (widget.backgroundColor ?? theme.backgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppDimensions.listItemPaddingH,
                    vertical: AppDimensions.listItemPaddingV,
                  ),
              child: Row(
                children: [
                  // Leading widget
                  if (widget.leading != null) ...[
                    Opacity(
                      opacity: widget.disabled ? 0.5 : 1.0,
                      child: IconTheme(
                        data: IconThemeData(
                          color: theme.iconColor,
                          size: AppDimensions.iconM,
                        ),
                        child: widget.leading!,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                  ],

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: theme.typography.body.copyWith(
                            color: widget.disabled
                                ? theme.tertiaryTextColor
                                : theme.primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: theme.typography.caption.copyWith(
                              color: theme.secondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing widget
                  if (widget.trailing != null) ...[
                    const SizedBox(width: AppDimensions.spacingS),
                    widget.trailing!,
                  ],

                  // Disclosure indicator
                  if (widget.showDisclosure) ...[
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      '›',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: theme.tertiaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Separator
            if (widget.showSeparator)
              Padding(
                padding: EdgeInsets.only(
                  left: widget.leading != null
                      ? AppDimensions.listItemPaddingH +
                          AppDimensions.iconM +
                          AppDimensions.spacingM
                      : AppDimensions.listItemPaddingH,
                ),
                child: Container(
                  height: AppDimensions.separatorThickness,
                  color: theme.separatorColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
