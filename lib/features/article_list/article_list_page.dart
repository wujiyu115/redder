import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/pull_to_refresh.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/providers/sync_provider.dart';
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

  /// Cached reference to avoid using ref after dispose.
  late final ScrollPositionService _scrollService;

  @override
  void initState() {
    super.initState();
    _scrollService = ref.read(scrollPositionServiceProvider);
    _scrollController.addListener(_onScroll);
    _restoreScrollPosition();
  }

  @override
  void dispose() {
    // Save position immediately on dispose (using cached reference)
    if (_scrollController.hasClients) {
      _scrollService.savePositionImmediate(
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
    final l10n = AppLocalizations.of(context)!;

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
              label: l10n.share,
              icon: '↗',
              color: theme.accentColor,
              onTriggered: () {
                if (item.url.isNotEmpty) {
                  Share.share(item.url);
                }
              },
            ),
            SwipeAction(
              id: 'toggle_star',
              label: item.isStarred ? l10n.unstar : l10n.star,
              icon: item.isStarred ? '★' : '☆',
              color: const Color(0xFFFFCC00),
              onTriggered: () => _toggleStarred(item.id, item.isStarred),
            ),
          ],
          rightSwipeActions: [
            SwipeAction(
              id: 'later',
              label: l10n.later,
              icon: '🕐',
              color: const Color(0xFFFF9500),
              onTriggered: () => _toggleLater(item.id),
            ),
            SwipeAction(
              id: 'toggle_read',
              label: item.isRead ? l10n.markUnread : l10n.markRead,
              icon: item.isRead ? '●' : '○',
              color: const Color(0xFF007AFF),
              onTriggered: () => _toggleReadState(item.id, item.isRead),
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

  /// Toggles the read/unread state of an article (with remote sync).
  Future<void> _toggleReadState(int itemId, bool isCurrentlyRead) async {
    final syncBridge = ref.read(syncBridgeProvider);
    if (isCurrentlyRead) {
      await syncBridge.markAsUnreadWithSync([itemId]);
    } else {
      await syncBridge.markAsReadWithSync([itemId]);
    }
    // Reload list to reflect changes
    ref.read(articleListControllerProvider(widget.timelineId).notifier).refresh();
  }

  /// Toggles the starred state of an article (with remote sync).
  Future<void> _toggleStarred(int itemId, bool isCurrentlyStarred) async {
    final syncBridge = ref.read(syncBridgeProvider);
    if (isCurrentlyStarred) {
      await syncBridge.markAsUnstarredWithSync([itemId]);
    } else {
      await syncBridge.markAsStarredWithSync([itemId]);
    }
    // Reload list to reflect changes
    ref.read(articleListControllerProvider(widget.timelineId).notifier).refresh();
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
