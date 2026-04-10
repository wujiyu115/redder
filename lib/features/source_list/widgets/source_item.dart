import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/theme/app_theme.dart';

/// A single item in the source list.
///
/// Displays a feed or navigation entry with:
/// - Leading icon (emoji, network image, or custom widget)
/// - Title text
/// - Optional unread count badge
///
/// Supports tap and long-press interactions.
class SourceItem extends StatefulWidget {
  /// Custom icon widget (takes priority over iconUrl).
  final Widget? icon;

  /// URL of the feed icon (used if icon is null).
  final String? iconUrl;

  /// Title text.
  final String title;

  /// Unread/item count (0 = hidden).
  final int count;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Callback when long-pressed.
  final VoidCallback? onLongPress;

  /// Whether to indent the item (for items inside folders).
  final bool indented;

  const SourceItem({
    super.key,
    this.icon,
    this.iconUrl,
    required this.title,
    this.count = 0,
    this.onTap,
    this.onLongPress,
    this.indented = false,
  });

  @override
  State<SourceItem> createState() => _SourceItemState();
}

class _SourceItemState extends State<SourceItem> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
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

    return Semantics(
      label: widget.count > 0
          ? '${widget.title}, ${widget.count} unread'
          : widget.title,
      button: true,
      enabled: true,
      onTap: widget.onTap,
      child: GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ExcludeSemantics(
        child: AnimatedContainer(
        duration: AppDurations.micro,
        color: _isPressed
            ? theme.separatorColor.withOpacity(0.3)
            : theme.backgroundColor,
        padding: EdgeInsets.only(
          left: widget.indented
              ? AppDimensions.listItemPaddingH + AppDimensions.spacingXL
              : AppDimensions.listItemPaddingH,
          right: AppDimensions.listItemPaddingH,
          top: AppDimensions.spacingS + 2,
          bottom: AppDimensions.spacingS + 2,
        ),
        child: Row(
          children: [
            // Icon
            SizedBox(
              width: AppDimensions.feedIconSize,
              height: AppDimensions.feedIconSize,
              child: _buildIcon(theme),
            ),
            const SizedBox(width: AppDimensions.spacingM),

            // Title
            Expanded(
              child: Text(
                widget.title,
                style: theme.typography.body.copyWith(
                  color: theme.primaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Count badge
            if (widget.count > 0) ...[
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                '${widget.count}',
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildIcon(ReederThemeData theme) {
    // Custom icon widget
    if (widget.icon != null) {
      return Center(child: widget.icon!);
    }

    // Network image icon
    if (widget.iconUrl != null && widget.iconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: CachedNetworkImage(
          imageUrl: widget.iconUrl!,
          width: AppDimensions.feedIconSize,
          height: AppDimensions.feedIconSize,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _defaultIcon(theme),
        ),
      );
    }

    // Default icon
    return _defaultIcon(theme);
  }

  Widget _defaultIcon(ReederThemeData theme) {
    return Container(
      width: AppDimensions.feedIconSize,
      height: AppDimensions.feedIconSize,
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Center(
        child: Text(
          widget.title.isNotEmpty ? widget.title[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.accentColor,
          ),
        ),
      ),
    );
  }
}
