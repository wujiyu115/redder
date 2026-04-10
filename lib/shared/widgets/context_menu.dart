import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// A single item in a [ContextMenu].
class ContextMenuItem {
  /// Unique identifier for this item.
  final String id;

  /// Display label.
  final String label;

  /// Optional leading icon text (emoji or symbol).
  final String? icon;

  /// Whether this is a destructive action (red text).
  final bool isDestructive;

  /// Whether this item is disabled.
  final bool isDisabled;

  /// Whether to show a separator after this item.
  final bool showSeparatorAfter;

  /// Whether this item is currently selected/checked.
  final bool isSelected;

  const ContextMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
    this.showSeparatorAfter = false,
    this.isSelected = false,
  });
}

/// A custom context menu that appears at a long-press location.
///
/// Similar to [ReederPopupMenu] but designed specifically for
/// long-press context menus with a slightly different visual style
/// (larger blur, rounded corners, haptic feedback area).
///
/// Built without Material/Cupertino dependencies.
class ContextMenu extends StatelessWidget {
  /// Menu items to display.
  final List<ContextMenuItem> items;

  /// Called when an item is selected.
  final ValueChanged<String>? onSelected;

  /// Menu width.
  final double width;

  /// Optional header widget displayed above the items.
  final Widget? header;

  const ContextMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.width = 240,
    this.header,
  });

  /// Shows the context menu at the given position.
  ///
  /// Returns the selected item ID, or null if dismissed.
  static Future<String?> show({
    required BuildContext context,
    required Offset position,
    required List<ContextMenuItem> items,
    double width = 240,
    Widget? header,
  }) {
    final theme = ReederTheme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Calculate menu position to keep it on screen
    double left = position.dx;
    double top = position.dy;

    // Estimate menu height
    final headerHeight = header != null ? 60.0 : 0.0;
    final menuHeight = items.length * 44.0 +
        items.where((i) => i.showSeparatorAfter).length * 0.5 +
        headerHeight;

    // Adjust horizontal position
    if (left + width > screenSize.width - 12) {
      left = screenSize.width - width - 12;
    }
    if (left < 12) left = 12;

    // Adjust vertical position
    if (top + menuHeight > screenSize.height - 12) {
      top = position.dy - menuHeight;
    }
    if (top < 12) top = 12;

    return Navigator.of(context).push<String>(
      _ContextMenuRoute(
        position: Offset(left, top),
        items: items,
        width: width,
        header: header,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: const Color(0x40000000),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional header
            if (header != null) ...[
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: header!,
              ),
              Container(
                height: AppDimensions.separatorThickness,
                color: theme.separatorColor,
              ),
            ],

            // Menu items
            for (int i = 0; i < items.length; i++) ...[
              _ContextMenuItemWidget(
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

/// A single item widget in the context menu.
class _ContextMenuItemWidget extends StatefulWidget {
  final ContextMenuItem item;
  final ReederThemeData theme;
  final VoidCallback? onTap;

  const _ContextMenuItemWidget({
    required this.item,
    required this.theme,
    this.onTap,
  });

  @override
  State<_ContextMenuItemWidget> createState() =>
      _ContextMenuItemWidgetState();
}

class _ContextMenuItemWidgetState extends State<_ContextMenuItemWidget> {
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
            // Icon
            if (item.icon != null) ...[
              SizedBox(
                width: 24,
                child: Center(
                  child: Text(
                    item.icon!,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
            ],

            // Label
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

            // Selected indicator
            if (item.isSelected)
              Text(
                '✓',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom route for showing context menus with scale + fade animation.
class _ContextMenuRoute extends PopupRoute<String> {
  final Offset position;
  final List<ContextMenuItem> items;
  final double width;
  final Widget? header;
  final ReederThemeData theme;

  _ContextMenuRoute({
    required this.position,
    required this.items,
    required this.width,
    this.header,
    required this.theme,
  });

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => const Color(0x33000000);

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
          child: ContextMenu(
            items: items,
            width: width,
            header: header,
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
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}
