import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import 'reeder_button.dart';

/// A widget displayed when a list or content area has no items.
///
/// Shows a centered message with an optional icon, description,
/// and action button to guide the user.
class EmptyState extends StatelessWidget {
  /// The main icon or emoji displayed above the title.
  final String icon;

  /// The primary message (e.g., "No articles yet").
  final String title;

  /// Optional description text below the title.
  final String? description;

  /// Optional action button label.
  final String? actionLabel;

  /// Callback when the action button is pressed.
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = '📭',
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  /// Creates an empty state for the article list.
  const EmptyState.articles({
    super.key,
    this.icon = '📰',
    this.title = 'No articles yet',
    this.description = 'Pull down to refresh or add a new feed',
    this.actionLabel,
    this.onAction,
  });

  /// Creates an empty state for search results.
  const EmptyState.search({
    super.key,
    this.icon = '🔍',
    this.title = 'No results found',
    this.description = 'Try a different search term',
    this.actionLabel,
    this.onAction,
  });

  /// Creates an empty state for feeds.
  const EmptyState.feeds({
    super.key,
    this.icon = '📡',
    this.title = 'No feeds yet',
    this.description = 'Add your first RSS feed to get started',
    this.actionLabel = 'Add Feed',
    this.onAction,
  });

  /// Creates an empty state for tags.
  const EmptyState.tags({
    super.key,
    this.icon = '🏷',
    this.title = 'No tagged items',
    this.description = 'Tag articles to find them here',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Translate default English values to localized strings
    final displayTitle = title == 'No articles yet' ? l10n.noArticlesYet
        : title == 'No results found' ? l10n.noResultsFound
        : title == 'No feeds yet' ? l10n.noFeedsYet
        : title == 'No tagged items' ? l10n.noTaggedItems
        : title;

    final displayDescription = description == 'Pull down to refresh or add a new feed' ? l10n.pullDownToRefresh
        : description == 'Try a different search term' ? l10n.tryDifferentKeywords
        : description == 'Add your first RSS feed to get started' ? l10n.addFeedToGetStarted
        : description == 'Tag articles to find them here' ? l10n.tagArticlesToFindHere
        : description;

    final displayActionLabel = actionLabel == 'Add Feed' ? l10n.addFeed
        : actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: AppDimensions.spacing),

            // Title
            Text(
              displayTitle,
              style: theme.typography.listTitle.copyWith(
                color: theme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (displayDescription != null) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                displayDescription,
                style: theme.typography.summary.copyWith(
                  color: theme.tertiaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (displayActionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingXL),
              ReederButton.filled(
                label: displayActionLabel,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
