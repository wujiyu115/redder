import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/database/app_database.dart';
import '../../../core/extensions/datetime_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/feed_item.dart';
import '../../../data/services/image_cache_manager.dart';
import '../../../shared/providers/settings_provider.dart';

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
class ArticleListItem extends ConsumerStatefulWidget {
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

  /// Whether to play the entrance animation. Set false when the item has
  /// already animated once, so scroll-recycling doesn't replay it.
  final bool animate;

  const ArticleListItem({
    super.key,
    required this.item,
    this.feedTitle,
    this.feedIconUrl,
    this.onTap,
    this.onLongPress,
    this.index = 0,
    this.animate = true,
  });

  @override
  ConsumerState<ArticleListItem> createState() => _ArticleListItemState();
}

class _ArticleListItemState extends ConsumerState<ArticleListItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  /// Entrance animation. Only created when this item actually animates —
  /// recycled items (the vast majority while scrolling) skip the ticker.
  AnimationController? _appearController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  static const Animation<double> _visible =
      AlwaysStoppedAnimation<double>(1.0);
  static const Animation<Offset> _noSlide =
      AlwaysStoppedAnimation<Offset>(Offset.zero);

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;

    final controller = AnimationController(
      duration: AppDurations.listItemAppear,
      vsync: this,
    );
    _appearController = controller;
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    // Stagger the animation based on index (max 10 items staggered)
    final delay = Duration(
      milliseconds: (widget.index.clamp(0, 10)) * 30,
    );
    Future.delayed(delay, () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    _appearController?.dispose();
    super.dispose();
  }

  /// Alpha multiplier applied to read articles.
  double get _readAlpha => widget.item.isRead ? 0.6 : 1.0;

  /// Fades [color] by the read-article alpha.
  ///
  /// The item used to be wrapped in `Opacity(0.6)`, which pushes an opacity
  /// layer for every read article — i.e. for most rows of a long list, on
  /// every frame while scrolling. Fading the colors instead produces the same
  /// pixels (the item background matches the list background) without a layer.
  Color _fade(Color color) =>
      _readAlpha == 1.0 ? color : color.withValues(alpha: color.a * _readAlpha);

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final showThumbnails = ref.watch(showThumbnailsProvider);
    final cacheImages = ref.watch(cacheImagesProvider);
    final cacheManager = ref.read(reederImageCacheManagerProvider);
    final readAlpha = _readAlpha;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Semantics(
      label: '${widget.feedTitle ?? ""}, ${widget.item.title}, ${widget.item.summary ?? ""}, ${widget.item.publishedAt.timeAgoCompact}',
      button: true,
      enabled: true,
      onTap: widget.onTap,
      child: FadeTransition(
      opacity: _fadeAnimation ?? _visible,
      child: SlideTransition(
        position: _slideAnimation ?? _noSlide,
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
            ? theme.separatorColor.withValues(alpha: 0.3)
            : theme.backgroundColor,
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
                          _buildFeedInfoRow(theme, dpr),
                          const SizedBox(height: AppDimensions.spacingXS),

                          // Title
                          Text(
                            widget.item.title,
                            style: theme.typography.listTitle.copyWith(
                              color: _fade(theme.primaryTextColor),
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
                                color: _fade(theme.secondaryTextColor),
                              ),
                              maxLines: AppDimensions.summaryMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Thumbnail
                    if (showThumbnails && widget.item.imageUrl != null) ...[
                      const SizedBox(width: AppDimensions.spacingM),
                      // Only the thumbnail is dimmed (not the text) for read
                      // items, so the opacity layer stays small.
                      Opacity(
                        opacity: readAlpha,
                        child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        child: cacheImages
                            ? CachedNetworkImage(
                                imageUrl: widget.item.imageUrl!,
                                cacheManager: cacheManager,
                                // No fade-in: a fade per thumbnail starts an
                                // animation for every image scrolled in.
                                fadeInDuration: Duration.zero,
                                width: AppDimensions.thumbnailWidth,
                                height: AppDimensions.thumbnailHeight,
                                fit: BoxFit.cover,
                                memCacheWidth:
                                    (AppDimensions.thumbnailWidth * dpr)
                                        .round(),
                                errorWidget: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              )
                            : Image.network(
                                widget.item.imageUrl!,
                                width: AppDimensions.thumbnailWidth,
                                height: AppDimensions.thumbnailHeight,
                                fit: BoxFit.cover,
                                cacheWidth:
                                    (AppDimensions.thumbnailWidth * dpr)
                                        .round(),
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                                loadingBuilder: (context, child, progress) =>
                                    progress == null
                                        ? child
                                        : const SizedBox.shrink(),
                              ),
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
                  color: _fade(theme.separatorColor),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
      ),
      ),
    );
  }

  Widget _buildFeedInfoRow(ReederThemeData theme, double dpr) {
    final showAvatars = ref.watch(showAvatarsProvider);
    final cacheImages = ref.watch(cacheImagesProvider);
    final cacheManager = ref.read(reederImageCacheManagerProvider);
    return Row(
      children: [
        // Feed icon
        if (showAvatars &&
            widget.feedIconUrl != null &&
            widget.feedIconUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: cacheImages
                ? CachedNetworkImage(
                    imageUrl: widget.feedIconUrl!,
                    cacheManager: cacheManager,
                    fadeInDuration: Duration.zero,
                    width: 14,
                    height: 14,
                    fit: BoxFit.cover,
                    memCacheWidth: (14 * dpr).round(),
                    errorWidget: (_, __, ___) => const SizedBox(
                      width: 14,
                      height: 14,
                    ),
                  )
                : Image.network(
                    widget.feedIconUrl!,
                    width: 14,
                    height: 14,
                    fit: BoxFit.cover,
                    cacheWidth: (14 * dpr).round(),
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 14, height: 14),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const SizedBox(width: 14, height: 14),
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
                color: _fade(theme.secondaryTextColor),
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
                color: _fade(theme.tertiaryTextColor),
              ),
            ),
          ),

        // Relative time
        Text(
          widget.item.publishedAt.timeAgoCompact,
          style: theme.typography.caption.copyWith(
            color: _fade(theme.tertiaryTextColor),
          ),
        ),

        // Content type indicator
        if (widget.item.contentType == ContentType.audio) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          const Text('🎙', style: TextStyle(fontSize: 10)),
        ] else if (widget.item.contentType == ContentType.video) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          const Text('🎬', style: TextStyle(fontSize: 10)),
        ],
      ],
    );
  }
}
