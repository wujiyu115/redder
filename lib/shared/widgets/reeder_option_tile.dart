import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// A selectable row used inside picker dialogs.
///
/// Shows [label] with a check mark when [isSelected]. Kept public so every
/// settings picker shares one look instead of each page re-declaring a
/// private copy.
class ReederOptionTile extends StatelessWidget {
  const ReederOptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingS,
          horizontal: AppDimensions.spacing,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.typography.body.copyWith(
                  color: theme.primaryTextColor,
                ),
              ),
            ),
            if (isSelected)
              Text(
                '✓',
                style: TextStyle(
                  fontSize: 18,
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