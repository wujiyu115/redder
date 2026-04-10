import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/database/app_database.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/feed_item.dart';

/// Standard article list item widget.
///
/// Displays:
/// - Feed icon + feed name + relative time (top row)
/// - Article title (bold)
/// - Summary text (2-3 lines)
/// - Thumbnail image (right side, if available)
/// - Read state (dimmed if read)
///
/// Includes a staggered appear animation: fade-in + slight upward
/// slide over 200ms with easeOut curve.
class ArticleListItem extends StatefulWidget {
  /// The feed item data.
  final FeedItem item;

  /// The feed title (resolved from feed ID).
  final String? feedTitle;

  /// The feed icon URL.
  final String? feedIconUrl;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Callback when long-pressed.
  final VoidCallback? onLongPress;

  /// Index in the list, used for staggered animation delay.
  final int index;

  const ArticleListItem({
    super.key,
    required this.item,
    this.feedTitle,
    this.feedIconUrl,
    this.onTap,
    this.onLongPress,
    this.index = 0,
  });

  @override
  State<ArticleListItem> createState() => _ArticleListItemState();
}

class _ArticleListItemState extends State<ArticleListItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _appearController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      duration: AppDurations.listItemAppear,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOut),
    );

    // Stagger the animation based on index (max 10 items staggered)
    final delay = Duration(
      milliseconds: (widget.index.clamp(0, 10)) * 30,
    );
    Future.delayed(delay, () {
      if (mounted) _appearController.forward();
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final isRead = widget.item.isRead;
    final opacity = isRead ? 0.6 : 1.0;

    return Semantics(
      label: '${widget.feedTitle ?? ""}, ${widget.item.title}, ${widget.item.summary ?? ""}, ${widget.item.publishedAt.timeAgoCompact}',
      button: true,
      enabled: true,
      onTap: widget.onTap,
      child: FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ExcludeSemantics(
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
                  vertical: AppDimensions.listItemPaddingV,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Feed info row
                          _buildFeedInfoRow(theme),
                          const SizedBox(height: AppDimensions.spacingXS),

                          // Title
                          Text(
                            widget.item.title,
                            style: theme.typography.listTitle.copyWith(
                              color: theme.primaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Summary
                          if (widget.item.summary != null &&
                              widget.item.summary!.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.spacingXS),
                            Text(
                              widget.item.summary!,
                              style: theme.typography.summary.copyWith(
                                color: theme.secondaryTextColor,
                              ),
                              maxLines: AppDimensions.summaryMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Thumbnail
                    if (widget.item.imageUrl != null) ...[
                      const SizedBox(width: AppDimensions.spacingM),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.item.imageUrl!,
                          width: AppDimensions.thumbnailWidth,
                          height: AppDimensions.thumbnailHeight,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
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
      ),
      ),
      ),
      ),
    );
  }

  Widget _buildFeedInfoRow(ReederThemeData theme) {
    return Row(
      children: [
        // Feed icon
        if (widget.feedIconUrl != null &&
            widget.feedIconUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CachedNetworkImage(
              imageUrl: widget.feedIconUrl!,
              width: 14,
              height: 14,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox(
                width: 14,
                height: 14,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXS),
        ],

        // Feed name
        if (widget.feedTitle != null)
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

        // Separator dot
        if (widget.feedTitle != null)
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

        // Relative time
        Text(
          widget.item.publishedAt.timeAgoCompact,
          style: theme.typography.caption.copyWith(
            color: theme.tertiaryTextColor,
          ),
        ),

        // Content type indicator
        if (widget.item.contentType == ContentType.audio) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          Text('🎙', style: const TextStyle(fontSize: 10)),
        ] else if (widget.item.contentType == ContentType.video) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          Text('🎬', style: const TextStyle(fontSize: 10)),
        ],
      ],
    );
  }
}
