import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/pull_to_refresh.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/providers/settings_provider.dart';
import '../../data/services/scroll_position_service.dart';
import '../source_list/source_list_controller.dart';
import 'article_list_controller.dart';
import 'widgets/article_list_item.dart';
import 'widgets/article_list_item_compact.dart';
import 'widgets/timeline_control_button.dart';
import 'widgets/swipe_action_widget.dart';

/// The article list page displaying a timeline of feed items.
///
/// Supports multiple timeline types:
/// - Unified timeline (all feeds)
/// - Category timeline (articles/podcasts/videos)
/// - Folder timeline (feeds in a folder)
/// - Single feed timeline
/// - Tag timeline
class ArticleListPage extends ConsumerStatefulWidget {
  /// The timeline identifier (e.g., "all", "feed_123", "tag_5").
  final String timelineId;

  const ArticleListPage({
    super.key,
    required this.timelineId,
  });

  @override
  ConsumerState<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends ConsumerState<ArticleListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _hasRestoredPosition = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _restoreScrollPosition();
  }

  @override
  void dispose() {
    // Save position immediately on dispose
    final scrollService = ref.read(scrollPositionServiceProvider);
    if (_scrollController.hasClients) {
      scrollService.savePositionImmediate(
        timelineId: widget.timelineId,
        scrollOffset: _scrollController.offset,
      );
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Restores the saved scroll position for this timeline.
  Future<void> _restoreScrollPosition() async {
    final scrollService = ref.read(scrollPositionServiceProvider);
    final savedPosition = await scrollService.getPosition(widget.timelineId);
    if (savedPosition != null && mounted && !_hasRestoredPosition) {
      _hasRestoredPosition = true;
      // Wait for the list to be built before jumping to position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && mounted) {
          _scrollController.jumpTo(savedPosition.scrollOffset);
        }
      });
    }
  }

  void _onScroll() {
    // Infinite scroll: load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(articleListControllerProvider(widget.timelineId).notifier)
          .loadMore();
    }

    // Save scroll position with debouncing (500ms)
    final scrollService = ref.read(scrollPositionServiceProvider);
    scrollService.savePositionDebounced(
      timelineId: widget.timelineId,
      scrollOffset: _scrollController.offset,
    );
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    await ref
        .read(articleListControllerProvider(widget.timelineId).notifier)
        .refresh();

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final listState = ref.watch(articleListControllerProvider(widget.timelineId));
    final isCompact = ref.watch(compactModeProvider);

    return ReederScaffold(
      navBar: ReederNavBar(
        title: _resolveTitle(widget.timelineId),
        showBackButton: true,
        onBack: () => context.pop(),
        actions: [
          TimelineControlButton(
            timelineId: widget.timelineId,
            onRefresh: _onRefresh,
          ),
        ],
      ),
      body: listState.when(
        data: (state) => PullToRefresh(
          onRefresh: _onRefresh,
          child: _buildList(context, state, theme, isCompact),
        ),
        loading: () => ShimmerLoading(compact: isCompact),
        error: (e, _) => ErrorState(
          message: 'Failed to load articles',
          details: '$e',
          onRetry: _onRefresh,
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ArticleListState state,
    ReederThemeData theme,
    bool isCompact,
  ) {
    if (state.items.isEmpty) {
      return const EmptyState.articles();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          // Loading indicator at bottom
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing),
            child: Center(
              child: Text(
                'Loading more...',
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            ),
          );
        }

        final item = state.items[index];

        // Wrap list items with swipe actions
        final listItemWidget = isCompact
            ? ArticleListItemCompact(
                item: item,
                feedTitle: state.feedTitles[item.feedId],
                onTap: () => context.push(
                  '/timeline/${widget.timelineId}/article/${item.id}',
                ),
              )
            : ArticleListItem(
                item: item,
                feedTitle: state.feedTitles[item.feedId],
                feedIconUrl: state.feedIcons[item.feedId],
                onTap: () => context.push(
                  '/timeline/${widget.timelineId}/article/${item.id}',
                ),
              );

        return SwipeActionWidget(
          leftSwipeActions: [
            SwipeAction(
              id: 'share',
              label: 'Share',
              icon: '↗',
              color: theme.accentColor,
              onTriggered: () {
                if (item.url.isNotEmpty) {
                  Share.share(item.url);
                }
              },
            ),
          ],
          rightSwipeActions: [
            SwipeAction(
              id: 'later',
              label: 'Later',
              icon: '🕐',
              color: const Color(0xFFFF9500),
              onTriggered: () => _toggleLater(item.id),
            ),
          ],
          child: listItemWidget,
        );
      },
    );
  }

  /// Toggles the "Later" tag on an article.
  Future<void> _toggleLater(int itemId) async {
    final tagRepo = ref.read(tagRepositoryProvider);
    final laterTag = await tagRepo.getLaterTag();
    if (laterTag != null) {
      await tagRepo.toggleTag(laterTag.id, itemId);
    }
  }

  String _resolveTitle(String timelineId) {
    if (timelineId == 'all') return 'All';
    if (timelineId == 'articles') return 'Articles';
    if (timelineId == 'podcasts') return 'Podcasts';
    if (timelineId == 'videos') return 'Videos';
    if (timelineId.startsWith('feed_')) return 'Feed';
    if (timelineId.startsWith('folder_')) return 'Folder';
    if (timelineId.startsWith('tag_')) return 'Tag';
    if (timelineId.startsWith('filter_')) return 'Filter';
    return 'Timeline';
  }
}
