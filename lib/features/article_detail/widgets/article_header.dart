import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/database/app_database.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/feed_icon.dart';

/// Article header widget displayed at the top of the detail page.
///
/// Shows:
/// - Hero image (if available, full-width)
/// - Article title
/// - Feed icon + feed name + publish date + reading time
class ArticleHeader extends StatelessWidget {
  /// The article data.
  final FeedItem article;

  /// The feed title.
  final String? feedTitle;

  /// The feed icon URL.
  final String? feedIconUrl;

  const ArticleHeader({
    super.key,
    required this.article,
    this.feedTitle,
    this.feedIconUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image
        if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
          _buildHeroImage(theme),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: article.imageUrl != null
                    ? AppDimensions.spacing
                    : AppDimensions.spacingXL,
              ),

              // Title
              Text(
                article.title,
                style: theme.typography.articleTitle.copyWith(
                  color: theme.primaryTextColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Feed info row
              _buildFeedInfoRow(theme),

              const SizedBox(height: AppDimensions.spacingXL),

              // Separator
              Container(
                height: AppDimensions.separatorThickness,
                color: theme.separatorColor,
              ),
              const SizedBox(height: AppDimensions.spacing),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(ReederThemeData theme) {
    return AspectRatio(
      aspectRatio: AppDimensions.imageAspectRatio,
      child: CachedNetworkImage(
        imageUrl: article.imageUrl!,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        errorWidget: (_, __, ___) => Container(
          color: theme.secondaryBackgroundColor,
          child: const Center(
            child: Text(
              '🖼',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
        placeholder: (_, __) => Container(
          color: theme.secondaryBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildFeedInfoRow(ReederThemeData theme) {
    return Row(
      children: [
        // Feed icon
        if (feedTitle != null)
          FeedIcon(
            iconUrl: feedIconUrl,
            title: feedTitle!,
            size: 18,
            borderRadius: 4,
          ),
        if (feedTitle != null)
          const SizedBox(width: AppDimensions.spacingS),

        // Feed name
        if (feedTitle != null)
          Flexible(
            child: Text(
              feedTitle!,
              style: theme.typography.caption.copyWith(
                color: theme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Separator
        if (feedTitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXS,
            ),
            child: Text(
              '·',
              style: TextStyle(
                fontSize: 12,
                color: theme.tertiaryTextColor,
              ),
            ),
          ),

        // Date
        Text(
          article.publishedAt.timeAgo,
          style: theme.typography.caption.copyWith(
            color: theme.tertiaryTextColor,
          ),
        ),

        // Reading time
        if (article.readingTimeMinutes != null &&
            article.readingTimeMinutes! > 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXS,
            ),
            child: Text(
              '·',
              style: TextStyle(
                fontSize: 12,
                color: theme.tertiaryTextColor,
              ),
            ),
          ),
          Text(
            '${article.readingTimeMinutes} min read',
            style: theme.typography.caption.copyWith(
              color: theme.tertiaryTextColor,
            ),
          ),
        ],

        // Author
        if (article.author != null && article.author!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXS,
            ),
            child: Text(
              '·',
              style: TextStyle(
                fontSize: 12,
                color: theme.tertiaryTextColor,
              ),
            ),
          ),
          Flexible(
            child: Text(
              article.author!,
              style: theme.typography.caption.copyWith(
                color: theme.tertiaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
