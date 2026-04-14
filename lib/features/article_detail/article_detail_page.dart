import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/light_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_button.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../image_viewer/image_viewer_page.dart';
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

  const ArticleDetailPage({
    super.key,
    required this.articleId,
    required this.timelineId,
  });

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late final ReederNavBarController _navBarController;
  double _dragStartX = 0.0;
  bool _isDraggingFromEdge = false;

  @override
  void initState() {
    super.initState();
    _navBarController = ReederNavBarController();
    _scrollController.addListener(_onScroll);

    // Mark article as read when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(articleDetailControllerProvider(widget.articleId).notifier)
          .markAsRead();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _navBarController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _navBarController.onScroll(_scrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final detailState =
        ref.watch(articleDetailControllerProvider(widget.articleId));

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: ReederScaffold(
        navBar: ListenableBuilder(
          listenable: _navBarController,
          builder: (context, _) => ReederNavBar(
            title: '',
            showBackButton: true,
            onBack: () => context.pop(),
            opacity: _navBarController.opacity,
            actions: [
              // Mark as Unread button
              ReederButton.icon(
                icon: const Text(
                  '●',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  ref
                      .read(articleDetailControllerProvider(widget.articleId).notifier)
                      .markAsUnread();
                  if (context.mounted) context.pop();
                },
              ),
              ReederButton.icon(
                icon: Text(
                  '⊙',
                  style: TextStyle(fontSize: 18, color: theme.accentColor),
                ),
                onPressed: () {
                  ref
                      .read(articleDetailControllerProvider(widget.articleId)
                          .notifier)
                      .toggleReaderView();
                },
              ),
              ReederButton.icon(
                icon: Text(
                  '↗',
                  style: TextStyle(fontSize: 18, color: theme.accentColor),
                ),
                onPressed: () {
                  final article = detailState.valueOrNull?.article;
                  if (article != null) {
                    context.push('/browser', extra: article.url);
                  }
                },
              ),
            ],
          ),
        ),
        body: detailState.when(
          data: (state) => _buildContent(context, state, theme),
          loading: () => const ShimmerLoading(itemCount: 1),
          error: (e, _) => ErrorState(
            message: 'Failed to load article',
            details: '$e',
            onRetry: () => ref
                .read(articleDetailControllerProvider(widget.articleId).notifier)
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
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article header
                  ArticleHeader(
                    article: state.article,
                    feedTitle: state.feedTitle,
                    feedIconUrl: state.feedIconUrl,
                  ),

                  // Article content (uses light theme in Dark Light mode)
                  ReederTheme(
                    data: contentTheme,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePaddingH,
                      ),
                      child: ArticleContentView(
                        content: state.isReaderView
                            ? (state.readerContent ??
                                state.article.content ??
                                '')
                            : (state.article.content ?? ''),
                        fontSize: state.fontSize,
                        lineHeight: state.lineHeight,
                        bionicReading: state.bionicReading,
                        onImageTap: (imageUrl) {
                          _openImageViewer(context, imageUrl, state);
                        },
                      ),
                    ),
                  ),

                  // Bottom spacing
                  const SizedBox(height: AppDimensions.spacingXXL * 2),
                ],
              ),
            ),
          ),
        ),

        // Bottom action bar
        ArticleActionBar(
          articleId: widget.articleId,
          isStarred: state.article.isStarred,
          isRead: state.article.isRead,
          tagStates: state.tagStates,
          onToggleStar: () => ref
              .read(
                  articleDetailControllerProvider(widget.articleId).notifier)
              .toggleStarred(),
          onToggleTag: (tagId) => ref
              .read(
                  articleDetailControllerProvider(widget.articleId).notifier)
              .toggleTag(tagId),
          onMarkAsUnread: () {
            ref
                .read(
                    articleDetailControllerProvider(widget.articleId).notifier)
                .markAsUnread();
          },
          onShare: () => ref
              .read(
                  articleDetailControllerProvider(widget.articleId).notifier)
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
        ? (state.readerContent ?? state.article.content ?? '')
        : (state.article.content ?? '');

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

  void _onHorizontalDragStart(DragStartDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    _dragStartX = details.globalPosition.dx;

    // Right edge: next article (left swipe)
    // Left edge: back (right swipe)
    _isDraggingFromEdge =
        _dragStartX > screenWidth - 40 || _dragStartX < 40;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Could add visual feedback here
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDraggingFromEdge) return;

    final velocity = details.primaryVelocity ?? 0;

    if (_dragStartX < 40 && velocity > 300) {
      // Right swipe from left edge → go back
      context.pop();
    } else if (_dragStartX > MediaQuery.of(context).size.width - 40 &&
        velocity < -300) {
      // Left swipe from right edge → next article
      ref
          .read(articleDetailControllerProvider(widget.articleId).notifier)
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
