import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Custom bottom sheet component for the Reeder app.
///
/// A slide-up panel from the bottom of the screen.
/// Built without Material/Cupertino dependencies.
class ReederBottomSheet extends StatelessWidget {
  /// Content of the bottom sheet.
  final Widget child;

  /// Optional title displayed at the top.
  final String? title;

  /// Whether to show the drag handle indicator.
  final bool showHandle;

  /// Whether to show a close button.
  final bool showCloseButton;

  /// Maximum height as a fraction of screen height (0.0 to 1.0).
  final double maxHeightFraction;

  /// Background color override.
  final Color? backgroundColor;

  const ReederBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.showCloseButton = false,
    this.maxHeightFraction = 0.9,
    this.backgroundColor,
  });

  /// Shows the bottom sheet with a slide-up animation.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      _BottomSheetRoute<T>(
        builder: builder,
        isDismissible: isDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bgColor = backgroundColor ?? theme.cardBackgroundColor;
    final maxHeight = mediaQuery.size.height * maxHeightFraction;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusL),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x33000000),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              if (showHandle)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spacingS),
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.tertiaryTextColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),

              // Title bar
              if (title != null || showCloseButton)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacing,
                    AppDimensions.spacingM,
                    AppDimensions.spacing,
                    AppDimensions.spacingS,
                  ),
                  child: Row(
                    children: [
                      if (showCloseButton)
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Done',
                            style: theme.typography.button,
                          ),
                        )
                      else
                        const SizedBox(width: 44),
                      Expanded(
                        child: title != null
                            ? Text(
                                title!,
                                style: theme.typography.navBarTitle,
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

              // Separator
              if (title != null || showCloseButton)
                Container(
                  height: AppDimensions.separatorThickness,
                  color: theme.separatorColor,
                ),

              // Content
              Flexible(child: child),

              // Bottom safe area
              SizedBox(height: mediaQuery.padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom route for showing bottom sheets with slide-up animation.
class _BottomSheetRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final bool isDismissible;

  _BottomSheetRoute({
    required this.builder,
    this.isDismissible = true,
  });

  @override
  bool get barrierDismissible => isDismissible;

  @override
  Color? get barrierColor => const Color(0x66000000);

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => AppDurations.bottomSheet;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      )),
      child: child,
    );
  }
}
