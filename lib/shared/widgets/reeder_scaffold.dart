import 'package:flutter/widgets.dart';

import '../../core/theme/app_theme.dart';

/// Custom page scaffold for the Reeder app.
///
/// Provides a consistent page structure with:
/// - Optional navigation bar at the top
/// - Main content area
/// - Optional bottom bar (action bar or mini player)
///
/// This replaces [Scaffold] from Material to avoid Material dependencies.
class ReederScaffold extends StatelessWidget {
  /// Optional navigation bar widget displayed at the top.
  final Widget? navBar;

  /// The main content of the page.
  final Widget body;

  /// Optional bottom bar widget (e.g., action bar, mini player).
  final Widget? bottomBar;

  /// Background color override. Defaults to theme background.
  final Color? backgroundColor;

  /// Whether the body should extend behind the nav bar.
  /// Useful for scroll-to-hide nav bar behavior.
  final bool extendBodyBehindNavBar;

  /// Whether to add safe area padding at the top.
  final bool useSafeAreaTop;

  /// Whether to add safe area padding at the bottom.
  final bool useSafeAreaBottom;

  const ReederScaffold({
    super.key,
    this.navBar,
    required this.body,
    this.bottomBar,
    this.backgroundColor,
    this.extendBodyBehindNavBar = false,
    this.useSafeAreaTop = true,
    this.useSafeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final bgColor = backgroundColor ?? theme.backgroundColor;
    final mediaQuery = MediaQuery.of(context);

    return ColoredBox(
      color: bgColor,
      child: Column(
        children: [
          // Safe area top padding
          if (useSafeAreaTop)
            SizedBox(height: mediaQuery.padding.top),

          // Navigation bar
          if (navBar != null && !extendBodyBehindNavBar) navBar!,

          // Body content
          Expanded(
            child: Stack(
              children: [
                // Main content
                Positioned.fill(child: body),

                // Overlay nav bar (when extending behind)
                if (navBar != null && extendBodyBehindNavBar)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: navBar!,
                  ),
              ],
            ),
          ),

          // Bottom bar
          if (bottomBar != null) bottomBar!,

          // Safe area bottom padding
          if (useSafeAreaBottom)
            SizedBox(height: mediaQuery.padding.bottom),
        ],
      ),
    );
  }
}
