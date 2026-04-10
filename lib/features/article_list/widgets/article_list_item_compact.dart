import 'package:flutter/widgets.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/database/app_database.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/feed_item.dart';

/// Compact article list item widget (no thumbnail mode).
///
/// Displays a minimal view with:
/// - Feed name + relative time
/// - Article title (single line)
///
/// Used when compact mode is enabled in settings.
class ArticleListItemCompact extends StatefulWidget {
  /// The feed item data.
  final FeedItem item;

  /// The feed title (resolved from feed ID).
  final String? feedTitle;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Callback when long-pressed.
  final VoidCallback? onLongPress;

  const ArticleListItemCompact({
    super.key,
    required this.item,
    this.feedTitle,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<ArticleListItemCompact> createState() =>
      _ArticleListItemCompactState();
}

class _ArticleListItemCompactState extends State<ArticleListItemCompact> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final isRead = widget.item.isRead;
    final opacity = isRead ? 0.6 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.micro,
        color: _isPressed
            ? theme.separatorColor.withOpacity(0.3)
            : theme.backgroundColor,
        child: Opacity(
          opacity: opacity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.listItemPaddingH,
                  vertical: AppDimensions.spacingS,
                ),
                child: Row(
                  children: [
                    // Unread indicator dot
                    if (!isRead)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(
                          right: AppDimensions.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.item.title,
                            style: theme.typography.body.copyWith(
                              color: theme.primaryTextColor,
                              fontWeight:
                                  isRead ? FontWeight.w400 : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Feed name + time
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (widget.feedTitle != null) ...[
                                Flexible(
                                  child: Text(
                                    widget.feedTitle!,
                                    style: theme.typography.caption.copyWith(
                                      color: theme.secondaryTextColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                              ],
                              Text(
                                widget.item.publishedAt.timeAgoCompact,
                                style: theme.typography.caption.copyWith(
                                  color: theme.tertiaryTextColor,
                                ),
                              ),

                              // Content type indicator
                              if (widget.item.contentType ==
                                  ContentType.audio) ...[
                                const SizedBox(
                                    width: AppDimensions.spacingXS),
                                const Text('🎙',
                                    style: TextStyle(fontSize: 10)),
                              ] else if (widget.item.contentType ==
                                  ContentType.video) ...[
                                const SizedBox(
                                    width: AppDimensions.spacingXS),
                                const Text('🎬',
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Separator
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.listItemPaddingH,
                ),
                child: Container(
                  height: AppDimensions.separatorThickness,
                  color: theme.separatorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
