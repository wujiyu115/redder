import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// A single item in a [ReederPopupMenu].
class ReederPopupMenuItem {
  /// Unique identifier for this item.
  final String id;

  /// Display label.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// Whether this is a destructive action (red text).
  final bool isDestructive;

  /// Whether this item is disabled.
  final bool isDisabled;

  /// Whether to show a separator after this item.
  final bool showSeparatorAfter;

  const ReederPopupMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
    this.showSeparatorAfter = false,
  });
}

/// Custom popup menu component for the Reeder app.
///
/// A floating menu that appears near the trigger point.
/// Built without Material/Cupertino dependencies.
class ReederPopupMenu extends StatelessWidget {
  /// Menu items to display.
  final List<ReederPopupMenuItem> items;

  /// Called when an item is selected.
  final ValueChanged<String>? onSelected;

  /// Menu width.
  final double width;

  const ReederPopupMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.width = 220,
  });

  /// Shows the popup menu at the given position.
  static Future<String?> show({
    required BuildContext context,
    required Offset position,
    required List<ReederPopupMenuItem> items,
    double width = 220,
  }) {
    final theme = ReederTheme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Calculate menu position to keep it on screen
    double left = position.dx;
    double top = position.dy;

    // Estimate menu height
    final menuHeight = items.length * 44.0 +
        items.where((i) => i.showSeparatorAfter).length * 0.5;

    // Adjust horizontal position
    if (left + width > screenSize.width - 8) {
      left = screenSize.width - width - 8;
    }
    if (left < 8) left = 8;

    // Adjust vertical position
    if (top + menuHeight > screenSize.height - 8) {
      top = position.dy - menuHeight;
    }
    if (top < 8) top = 8;

    return Navigator.of(context).push<String>(
      _PopupMenuRoute(
        position: Offset(left, top),
        items: items,
        width: width,
        theme: theme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _MenuItem(
                item: items[i],
                theme: theme,
                onTap: () => onSelected?.call(items[i].id),
              ),
              if (items[i].showSeparatorAfter && i < items.length - 1)
                Container(
                  height: AppDimensions.separatorThickness,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing,
                  ),
                  color: theme.separatorColor,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final ReederPopupMenuItem item;
  final ReederThemeData theme;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.item,
    required this.theme,
    this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = widget.theme;

    final textColor = item.isDestructive
        ? theme.destructiveColor
        : item.isDisabled
            ? theme.tertiaryTextColor
            : theme.primaryTextColor;

    return GestureDetector(
      onTapDown: (_) {
        if (!item.isDisabled) setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: item.isDisabled ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        color: _isPressed
            ? theme.separatorColor
            : const Color(0x00000000),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: textColor,
                  size: AppDimensions.icon,
                ),
                child: item.icon!,
              ),
              const SizedBox(width: AppDimensions.spacingM),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom route for showing popup menus with fade animation.
class _PopupMenuRoute extends PopupRoute<String> {
  final Offset position;
  final List<ReederPopupMenuItem> items;
  final double width;
  final ReederThemeData theme;

  _PopupMenuRoute({
    required this.position,
    required this.items,
    required this.width,
    required this.theme,
  });

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => const Color(0x00000000);

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => AppDurations.popupMenu;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: ReederPopupMenu(
            items: items,
            width: width,
            onSelected: (id) => Navigator.of(context).pop(id),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}
