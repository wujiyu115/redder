import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Custom navigation bar for the Reeder app.
///
/// Features:
/// - Back button (optional)
/// - Centered title
/// - Right-side action buttons
/// - Scroll-to-hide behavior (via [ReederNavBarController])
/// - Separator line at the bottom
class ReederNavBar extends StatelessWidget {
  /// Title text displayed in the center.
  final String? title;

  /// Custom title widget (overrides [title] text).
  final Widget? titleWidget;

  /// Leading widget (typically a back button).
  final Widget? leading;

  /// Whether to show a default back button as leading widget.
  final bool showBackButton;

  /// Callback when back button is pressed.
  final VoidCallback? onBack;

  /// Trailing action widgets.
  final List<Widget>? actions;

  /// Background color override.
  final Color? backgroundColor;

  /// Whether to show the bottom separator line.
  final bool showSeparator;

  /// Opacity for scroll-to-hide animation (0.0 to 1.0).
  final double opacity;

  const ReederNavBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.showSeparator = true,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final bgColor = backgroundColor ?? theme.backgroundColor;

    return AnimatedOpacity(
      opacity: opacity,
      duration: AppDurations.navBarToggle,
      child: Container(
        height: AppDimensions.navBarHeight,
        decoration: BoxDecoration(
          color: bgColor,
          border: showSeparator
              ? Border(
                  bottom: BorderSide(
                    color: theme.separatorColor,
                    width: AppDimensions.separatorThickness,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingS,
          ),
          child: Row(
            children: [
              // Leading
              if (leading != null)
                leading!
              else if (showBackButton)
                _BackButton(onTap: onBack, theme: theme),

              // Title
              Expanded(
                child: Center(
                  child: titleWidget ??
                      (title != null
                          ? Text(
                              title!,
                              style: theme.typography.navBarTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink()),
                ),
              ),

              // Actions
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              else
                // Placeholder to balance the leading widget
                const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final ReederThemeData theme;

  const _BackButton({this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Text(
            '‹',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: theme.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Controller for managing nav bar scroll-to-hide behavior.
class ReederNavBarController extends ChangeNotifier {
  double _opacity = 1.0;
  double _lastScrollOffset = 0.0;

  double get opacity => _opacity;

  /// Call this from a scroll listener to update nav bar visibility.
  void onScroll(double scrollOffset) {
    final delta = scrollOffset - _lastScrollOffset;
    _lastScrollOffset = scrollOffset;

    if (delta > 0 && scrollOffset > AppDimensions.navBarHeight) {
      // Scrolling down - hide
      _opacity = (_opacity - 0.1).clamp(0.0, 1.0);
    } else if (delta < 0) {
      // Scrolling up - show
      _opacity = (_opacity + 0.1).clamp(0.0, 1.0);
    }
    notifyListeners();
  }

  /// Force show the nav bar.
  void show() {
    _opacity = 1.0;
    notifyListeners();
  }

  /// Force hide the nav bar.
  void hide() {
    _opacity = 0.0;
    notifyListeners();
  }
}
