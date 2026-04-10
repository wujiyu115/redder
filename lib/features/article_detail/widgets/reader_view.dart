import 'package:flutter/widgets.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_theme.dart';
import 'article_content_view.dart';

/// Reader View widget that displays cleaned-up article content.
///
/// Provides a distraction-free reading experience by:
/// - Removing ads, navigation, and other non-content elements
/// - Using a clean, readable typography
/// - Constraining content width for optimal readability
/// - Supporting configurable font size and line height
class ReaderView extends StatelessWidget {
  /// The cleaned HTML content from ReaderViewService.
  final String content;

  /// The article title.
  final String title;

  /// The article author.
  final String? author;

  /// The article publish date.
  final DateTime? publishedAt;

  /// Font size in logical pixels.
  final double fontSize;

  /// Line height multiplier.
  final double lineHeight;

  /// Callback when an image is tapped.
  final void Function(String imageUrl)? onImageTap;

  const ReaderView({
    super.key,
    required this.content,
    required this.title,
    this.author,
    this.publishedAt,
    this.fontSize = 16.0,
    this.lineHeight = 1.6,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.spacingXL,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize * 1.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: theme.primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),

              // Author and date
              if (author != null || publishedAt != null) ...[
                const SizedBox(height: AppDimensions.spacingM),
                Row(
                  children: [
                    if (author != null)
                      Text(
                        author!,
                        style: theme.typography.caption.copyWith(
                          color: theme.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (author != null && publishedAt != null)
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
                    if (publishedAt != null)
                      Text(
                        _formatDate(publishedAt!),
                        style: theme.typography.caption.copyWith(
                          color: theme.tertiaryTextColor,
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: AppDimensions.spacingXL),

              // Separator
              Container(
                height: AppDimensions.separatorThickness,
                color: theme.separatorColor,
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // Content
              ArticleContentView(
                content: content,
                fontSize: fontSize,
                lineHeight: lineHeight,
                maxWidth: AppDimensions.maxContentWidth,
                onImageTap: onImageTap,
              ),

              // Bottom spacing
              const SizedBox(height: AppDimensions.spacingXXL * 2),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
