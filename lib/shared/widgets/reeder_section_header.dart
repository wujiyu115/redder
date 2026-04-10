import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// Custom section header component for the Reeder app.
///
/// Displays an uppercase, small-font, gray label used to separate
/// sections in lists (e.g., HOME / FEEDS / TAGS / SAVED in source list).
///
/// Optionally includes a trailing action button.
class ReederSectionHeader extends StatelessWidget {
  /// Section title text (will be displayed in uppercase).
  final String title;

  /// Optional trailing action widget (e.g., add button, edit button).
  final Widget? trailing;

  /// Custom padding override.
  final EdgeInsets? padding;

  /// Whether to automatically uppercase the title.
  final bool uppercase;

  const ReederSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final displayTitle = uppercase ? title.toUpperCase() : title;

    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            left: AppDimensions.listItemPaddingH,
            right: AppDimensions.spacingS,
            top: AppDimensions.spacingXL,
            bottom: AppDimensions.spacingS,
          ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayTitle,
              style: theme.typography.sectionHeader.copyWith(
                color: theme.secondaryTextColor,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
