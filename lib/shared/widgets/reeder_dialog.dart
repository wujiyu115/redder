import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Custom dialog component for the Reeder app.
///
/// A centered modal dialog with title, content, and action buttons.
/// Built without Material/Cupertino dependencies.
class ReederDialog extends StatelessWidget {
  /// Dialog title.
  final String? title;

  /// Dialog message text.
  final String? message;

  /// Custom content widget (overrides [message]).
  final Widget? content;

  /// Action buttons displayed at the bottom.
  final List<ReederDialogAction> actions;

  /// Whether the dialog can be dismissed by tapping outside.
  final bool barrierDismissible;

  /// Dialog width override.
  final double? width;

  const ReederDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions = const [],
    this.barrierDismissible = true,
    this.width,
  });

  /// Shows the dialog with a fade-in animation.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      _DialogRoute<T>(
        builder: builder,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final dialogWidth = width ?? 280.0;

    return Center(
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: const Color(0x33000000),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingXL,
                  AppDimensions.spacingXL,
                  AppDimensions.spacingXL,
                  AppDimensions.spacingS,
                ),
                child: Text(
                  title!,
                  style: theme.typography.listTitle,
                  textAlign: TextAlign.center,
                ),
              ),

            // Content
            if (content != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.spacingXL,
                  title != null ? 0 : AppDimensions.spacingXL,
                  AppDimensions.spacingXL,
                  AppDimensions.spacing,
                ),
                child: content,
              )
            else if (message != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.spacingXL,
                  title != null ? 0 : AppDimensions.spacingXL,
                  AppDimensions.spacingXL,
                  AppDimensions.spacing,
                ),
                child: Text(
                  message!,
                  style: theme.typography.summary,
                  textAlign: TextAlign.center,
                ),
              ),

            // Separator
            if (actions.isNotEmpty)
              Container(
                height: AppDimensions.separatorThickness,
                color: theme.separatorColor,
              ),

            // Actions
            if (actions.isNotEmpty)
              _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ReederThemeData theme) {
    if (actions.length <= 2) {
      // Horizontal layout for 1-2 actions
      return SizedBox(
        height: 44,
        child: Row(
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0)
                Container(
                  width: AppDimensions.separatorThickness,
                  color: theme.separatorColor,
                ),
              Expanded(
                child: _buildActionButton(context, theme, actions[i]),
              ),
            ],
          ],
        ),
      );
    } else {
      // Vertical layout for 3+ actions
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0)
              Container(
                height: AppDimensions.separatorThickness,
                color: theme.separatorColor,
              ),
            SizedBox(
              height: 44,
              child: _buildActionButton(context, theme, actions[i]),
            ),
          ],
        ],
      );
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    ReederThemeData theme,
    ReederDialogAction action,
  ) {
    final color = action.isDestructive
        ? theme.destructiveColor
        : theme.accentColor;

    return GestureDetector(
      onTap: () {
        action.onPressed?.call();
        if (action.dismissOnTap) {
          Navigator.of(context).pop(action.value);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          action.label,
          style: TextStyle(
            fontSize: 17,
            fontWeight:
                action.isDefault ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Represents a single action button in a [ReederDialog].
class ReederDialogAction {
  /// Button label text.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether this is the default/primary action (bold text).
  final bool isDefault;

  /// Whether this is a destructive action (red text).
  final bool isDestructive;

  /// Whether to dismiss the dialog when tapped.
  final bool dismissOnTap;

  /// Optional return value when this action is selected.
  final dynamic value;

  const ReederDialogAction({
    required this.label,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
    this.dismissOnTap = true,
    this.value,
  });
}

/// Custom route for showing dialogs with fade animation.
class _DialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;

  _DialogRoute({
    required this.builder,
    bool barrierDismissible = true,
  }) : _barrierDismissible = barrierDismissible;

  final bool _barrierDismissible;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color? get barrierColor => const Color(0x66000000);

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => AppDurations.dialogAppear;

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
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.05, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: child,
      ),
    );
  }
}
