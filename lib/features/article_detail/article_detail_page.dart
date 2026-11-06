import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/light_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_button.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/providers/settings_provider.dart';
import '../image_viewer/image_viewer_page.dart';
import '../media/media_launcher.dart';
import 'article_detail_controller.dart';
import 'widgets/article_header.dart';
import 'widgets/article_content_view.dart';
import 'widgets/article_action_bar.dart';

/// The article detail page for reading a single article.
///
/// Features:
/// - Article header with hero image, title, source, date
/// - HTML content rendering
/// - Bottom action bar (Later / Bookmark / Favorite / Share / Browser)
/// - Nav bar hides on scroll
/// - Left swipe to load next article
/// - Right swipe (edge gesture) to go back
class ArticleDetailPage extends ConsumerStatefulWidget {
  /// The article ID to display.
  final int articleId;

  /// The timeline ID (for navigating to next/previous articles).
  final String timelineId;

  /// When true, force reader view on initially (used when opening from
  /// `ViewerType.reader` in [launchMedia]).
  final bool forceReader;

  const ArticleDetailPage({
    super.key,
    required this.articleId,
    required this.timelineId,
    this.forceReader = false,
  });

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late final ReederNavBarController _navBarController;
  double _dragStartX = 0.0;
  bool _isDraggingFromEdge = false;
  bool _isFullscreen = false;

  /// Guards the force-reader toggle so it only fires once.
  bool _forceReaderApplied = false;

  @override
  void initState() {
    super.initState();
    _navBarController = ReederNavBarController();
    _scrollController.addListener(_onScroll);

    // Start in fullscreen when the user made it the default.
    _isFullscreen = ref.read(defaultFullscreenReadingProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Mark article as read when opened
      ref
          .read(articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
          .markAsRead();
      if (_isFullscreen) _applyFullscreen(true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _navBarController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _applyFullscreen(bool on) {
    SystemChrome.setEnabledSystemUIMode(
      on ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    _applyFullscreen(_isFullscreen);
  }

  void _onScroll() {
    _navBarController.onScroll(_scrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final detailState =
        ref.watch(articleDetailControllerProvider((widget.articleId, widget.timelineId)));

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragCancel: _onHorizontalDragCancel,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      // In fullscreen, a tap on empty content area restores the chrome.
      onTap: _isFullscreen ? _toggleFullscreen : null,
      child: ReederScaffold(
        useSafeAreaTop: !_isFullscreen,
        navBar: _isFullscreen
            ? null
            : ListenableBuilder(
          listenable: _navBarController,
          builder: (context, _) => ReederNavBar(
            title: '',
            showBackButton: true,
            onBack: () => context.pop(),
            opacity: _navBarController.opacity,
            actions: [
              // Play button for audio/video articles
              if (() {
                final a = detailState.valueOrNull?.article;
                return a != null && resolveMediaKind(a) != MediaKind.article;
              }())
                ReederButton.icon(
                  icon: Text(
                    '▶',
                    style: TextStyle(fontSize: 16, color: theme.accentColor),
                  ),
                  onPressed: () {
                    final state = detailState.valueOrNull;
                    if (state != null) {
                      launchMedia(
                        context,
                        ref,
                        state.article,
                        timelineId: widget.timelineId,
                        feedTitle: state.feedTitle,
                      );
                    }
                  },
                ),
              // Enter fullscreen reading
              ReederButton.icon(
                icon: Text(
                  '⛶',
                  style: TextStyle(fontSize: 18, color: theme.iconColor),
                ),
                onPressed: _toggleFullscreen,
              ),
              // Reader view toggle (active state reflected on the button)
              ReederButton.icon(
                icon: Text(
                  '⊙',
                  style: TextStyle(
                    fontSize: 18,
                    color: (detailState.valueOrNull?.isReaderView ?? false)
                        ? theme.accentColor
                        : theme.iconColor,
                  ),
                ),
                onPressed: () {
                  ref
                      .read(articleDetailControllerProvider((widget.articleId, widget.timelineId))
                          .notifier)
                      .toggleReaderView();
                },
              ),
            ],
          ),
        ),
        body: detailState.when(
          data: (state) {
            // Force reader view on entry when requested (e.g. opened from
            // ViewerType.reader via media_launcher). Applied exactly once,
            // deferred to a post-frame callback so we don't mutate state
            // mid-build.
            if (widget.forceReader &&
                !_forceReaderApplied &&
                !state.isReaderView) {
              _forceReaderApplied = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref
                    .read(articleDetailControllerProvider(
                        (widget.articleId, widget.timelineId)).notifier)
                    .toggleReaderView();
              });
            } else if (widget.forceReader && !_forceReaderApplied) {
              _forceReaderApplied = true;
            }
            return _buildContent(context, state, theme);
          },
          loading: () => const ShimmerLoading(itemCount: 1),
          error: (e, _) => ErrorState(
            message: AppLocalizations.of(context)!.failedToLoadArticle,
            details: '$e',
            onRetry: () => ref
                .read(articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
                .reload(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ArticleDetailState state,
    ReederThemeData theme,
  ) {
    // Dark Light hybrid: use light theme for the content area
    final isDarkLight = theme.mode == ReederThemeMode.darkLight;
    final contentTheme = isDarkLight ? lightTheme : theme;

    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: ColoredBox(
            color: isDarkLight
                ? contentTheme.backgroundColor
                : theme.backgroundColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxContentWidth = ref.watch(maxContentWidthProvider);

                // Centre the reading column on wide viewports instead of
                // letting the HTML stretch edge to edge.
                final hPadding = constraints.maxWidth > maxContentWidth
                    ? (constraints.maxWidth - maxContentWidth) / 2
                    : AppDimensions.pagePaddingH;

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Article header
                    SliverToBoxAdapter(
                      child: ArticleHeader(
                        article: state.article,
                        feedTitle: state.feedTitle,
                        feedIconUrl: state.feedIconUrl,
                      ),
                    ),

                    // Article content (uses light theme in Dark Light mode).
                    //
                    // `RenderMode.sliverList` builds only the blocks around the
                    // viewport, so images below the fold are never fetched and
                    // long articles do not parse/layout in one blocking pass.
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      sliver: ReederTheme(
                        data: contentTheme,
                        child: ArticleContentView(
                          content: state.isReaderView
                              ? (state.readerContent ?? state.displayContent)
                              : state.displayContent,
                          fontSize: state.fontSize,
                          lineHeight: state.lineHeight,
                          maxWidth: maxContentWidth,
                          bionicReading: state.bionicReading,
                          onImageTap: (imageUrl) {
                            _openImageViewer(context, imageUrl, state);
                          },
                        ),
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimensions.spacingXXL * 2),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Bottom action bar (hidden in fullscreen reading)
        if (!_isFullscreen)
        ArticleActionBar(
          articleId: widget.articleId,
          isStarred: state.article.isStarred,
          isRead: state.article.isRead,
          tagStates: state.tagStates,
          laterTagId: state.laterTagId,
          bookmarksTagId: state.bookmarksTagId,
          onToggleStar: () => ref
              .read(
                  articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
              .toggleStarred(),
          onToggleTag: (tagId) => ref
              .read(
                  articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
              .toggleTag(tagId),
          onMarkAsUnread: () {
            ref
                .read(
                    articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
                .markAsUnread();
          },
          onShare: () => ref
              .read(
                  articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
              .share(),
          onOpenInBrowser: () {
            context.push('/browser', extra: state.article.url);
          },
        ),
      ],
    );
  }

  // ─── Swipe Gesture Handling ─────────────────────────────

  /// Opens the image viewer with all images from the article content.
  void _openImageViewer(
    BuildContext context,
    String tappedImageUrl,
    ArticleDetailState state,
  ) {
    // Collect all image URLs from the article
    final content = state.isReaderView
        ? (state.readerContent ?? state.displayContent)
        : state.displayContent;

    final imageUrls = _extractImageUrls(content);

    // If tapped image is not in the list, add it
    if (!imageUrls.contains(tappedImageUrl)) {
      imageUrls.insert(0, tappedImageUrl);
    }

    final initialIndex = imageUrls.indexOf(tappedImageUrl);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ImageViewerPage(
              imageUrls: imageUrls,
              initialIndex: initialIndex >= 0 ? initialIndex : 0,
              heroTag: 'image_$tappedImageUrl',
            ),
          );
        },
        transitionDuration: AppDurations.imageZoom,
        reverseTransitionDuration: AppDurations.imageZoom,
      ),
    );
  }

  /// Extracts all image URLs from HTML content.
  List<String> _extractImageUrls(String htmlContent) {
    final regex = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false);
    final matches = regex.allMatches(htmlContent);
    return matches
        .map((m) => m.group(1))
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
  }

  // ─── Swipe Gesture Handling ─────────────────────────────
  //
  // Back navigation is handled by the route itself (`EdgeSwipeBack` in
  // `ReederPage`), which follows the finger and wins the gesture arena for
  // drags that start at the screen edge. Only "swipe in from the right edge to
  // open the next article" is page-specific.

  void _onHorizontalDragStart(DragStartDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    _dragStartX = details.globalPosition.dx;
    _isDraggingFromEdge = _dragStartX > screenWidth - 40;
  }

  void _onHorizontalDragCancel() => _isDraggingFromEdge = false;

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDraggingFromEdge) return;

    final velocity = details.primaryVelocity ?? 0;

    if (_dragStartX > MediaQuery.of(context).size.width - 40 &&
        velocity < -300) {
      // Left swipe from right edge → next article
      ref
          .read(articleDetailControllerProvider((widget.articleId, widget.timelineId)).notifier)
          .loadNextArticle()
          .then((nextId) {
        if (nextId != null && mounted) {
          context.pushReplacement(
            '/timeline/${widget.timelineId}/article/$nextId',
          );
        }
      });
    }

    _isDraggingFromEdge = false;
  }
}
