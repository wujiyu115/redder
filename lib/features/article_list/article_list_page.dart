import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/pull_to_refresh.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/sync_icon_button.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/providers/sync_provider.dart';
import '../../data/services/scroll_position_service.dart';
import '../../data/services/sync/sync_models.dart';
import '../media/media_launcher.dart';
import '../source_list/source_list_controller.dart';
import 'article_list_controller.dart';
import 'widgets/article_list_item.dart';
import 'widgets/article_list_item_compact.dart';
import 'widgets/timeline_control_button.dart';
import 'widgets/scroll_past_probe.dart';
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

  /// Item ids that have already played their entrance animation, so
  /// scroll-recycling doesn't replay it.
  final Set<int> _animatedItemIds = {};

  /// Maximum index that plays the entrance animation (roughly one screen of
  /// items). Everything below the fold appears instantly — animating an item
  /// that enters the viewport *during* a scroll just adds frames to draw
  /// while the list is already moving.
  static const int _animatedItemLimit = 12;

  /// Cached reference to avoid using ref after dispose.
  late final ScrollPositionService _scrollService;

  /// Cached notifier: `_onScroll` runs on every scroll tick, and each
  /// `ref.read` rebuilds the provider handle.
  late final ArticleListController _listController;

  /// Rows that scrolled past the viewport, for "mark as read on scroll".
  final ScrollPastReporter _scrollPast = ScrollPastReporter();

  /// Previous scroll offset, to tell down-scrolls from up-scrolls.
  double _lastScrollOffset = 0;

  /// Set while the list is programmatically positioned (e.g. restoring a saved
  /// scroll position) so rows above the viewport aren't marked read.
  bool _suppressScrollRead = false;

  /// Coalesces scrolled-past checks to one per frame.
  bool _scrollReadCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollService = ref.read(scrollPositionServiceProvider);
    _listController =
        ref.read(articleListControllerProvider(widget.timelineId).notifier);
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
          _suppressScrollRead = true;
          _scrollController.jumpTo(savedPosition.scrollOffset);
          _lastScrollOffset = savedPosition.scrollOffset;
          // Rows above a restored position were never actually read now.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _suppressScrollRead = false;
          });
        }
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final scrollingDown = position.pixels > _lastScrollOffset;
    _lastScrollOffset = position.pixels;

    // Infinite scroll: load more when near bottom.
    // `loadMore` guards itself, so this is cheap once a page is in flight.
    if (position.pixels >= position.maxScrollExtent - 200) {
      _listController.loadMore();
    }

    // Mark as read on scroll: only on the way down, so scrolling back up never
    // consumes unread articles the user is heading towards.
    if (scrollingDown && !_suppressScrollRead) {
      _scheduleScrollReadCheck();
    }

    // Save scroll position with debouncing (500ms).
    _scrollService.savePositionDebounced(
      timelineId: widget.timelineId,
      scrollOffset: position.pixels,
    );
  }

  /// Runs the scrolled-past check off the scroll notification.
  ///
  /// The check reads live render geometry and then updates provider state;
  /// both are safer after the current frame's layout finishes, and a frame of
  /// latency is invisible here (a row stays above the top for several frames).
  void _scheduleScrollReadCheck() {
    if (_scrollReadCheckScheduled) return;
    _scrollReadCheckScheduled = true;
    scheduleMicrotask(() {
      _scrollReadCheckScheduled = false;
      if (!mounted || _suppressScrollRead) return;
      if (!ref.read(markReadOnScrollProvider)) return;

      final scrolledPast = _scrollPast.collectScrolledPast();
      if (scrolledPast.isNotEmpty) {
        _listController.markReadOnScroll(scrolledPast);
      }
    });
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
    final l10n = AppLocalizations.of(context)!;
    final listState = ref.watch(articleListControllerProvider(widget.timelineId));
    final isCompact = ref.watch(compactModeProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final markReadOnScroll = ref.watch(markReadOnScrollProvider);

    return ReederScaffold(
      navBar: ReederNavBar(
        title: _resolveTitle(widget.timelineId, l10n),
        showBackButton: true,
        onBack: () => context.pop(),
        actions: [
          // Sync button (spins while syncing/refreshing)
          SyncIconButton(
            externalActive: syncStatus.valueOrNull == SyncStatus.syncing,
            successMessage: l10n.refreshComplete,
            errorMessage: l10n.refreshFailed,
            onSync: () async {
              await ref
                  .read(sourceListControllerProvider.notifier)
                  .triggerSync();
              if (mounted) {
                ref
                    .read(articleListControllerProvider(widget.timelineId)
                        .notifier)
                    .reload();
              }
            },
          ),
          TimelineControlButton(
            timelineId: widget.timelineId,
            onRefresh: _onRefresh,
            onScrollToTop: _scrollToTop,
          ),
        ],
      ),
      body: listState.when(
        data: (state) => PullToRefresh(
          onRefresh: _onRefresh,
          child: _buildList(context, state, theme, isCompact, markReadOnScroll),
        ),
        loading: () => ShimmerLoading(compact: isCompact),
        error: (e, _) => ErrorState(
          message: AppLocalizations.of(context)!.failedToLoadArticles,
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
    bool markReadOnScroll,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (state.items.isEmpty) {
      return EmptyState.articles(
        onAction: () => context.push('/search'),
      );
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
                l10n.loadingMore,
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            ),
          );
        }

        final item = state.items[index];

        // Wrap list items with swipe actions
        void openItem() => launchMedia(
              context,
              ref,
              item,
              timelineId: widget.timelineId,
              feedTitle: state.feedTitles[item.feedId],
              openArticle: () async {
                await context.push(
                  '/timeline/${widget.timelineId}/article/${item.id}',
                );
                // Article was marked read while open; reload so hide-read
                // removes it from the list immediately.
                if (mounted) {
                  ref
                      .read(articleListControllerProvider(widget.timelineId)
                          .notifier)
                      .reload();
                }
              },
            );

        // Set.add returns true only the first time this id is seen, so each
        // item animates once and stays put through scroll-recycling. Items
        // that first appear below the fold skip the animation entirely.
        final animate = index < _animatedItemLimit &&
            _animatedItemIds.add(item.id);

        final listItemWidget = isCompact
            ? ArticleListItemCompact(
                item: item,
                feedTitle: state.feedTitles[item.feedId],
                onTap: openItem,
              )
            : ArticleListItem(
                item: item,
                feedTitle: state.feedTitles[item.feedId],
                feedIconUrl: state.feedIcons[item.feedId],
                onTap: openItem,
                index: index,
                animate: animate,
              );

        final row = SwipeActionWidget(
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
              // ponytail: no per-semantic warning token; using theme.warningColor.
              color: theme.warningColor,
              onTriggered: () => _toggleStarred(item.id, item.isStarred),
            ),
          ],
          rightSwipeActions: [
            SwipeAction(
              id: 'later',
              label: l10n.later,
              icon: '🕐',
              // ponytail: no per-semantic "later" token; using accentColor.
              color: theme.accentColor,
              onTriggered: () => _toggleLater(item.id),
            ),
            SwipeAction(
              id: 'toggle_read',
              label: item.isRead ? l10n.markUnread : l10n.markRead,
              icon: item.isRead ? '●' : '○',
              color: theme.accentColor,
              onTriggered: () => _toggleReadState(item.id, item.isRead),
            ),
          ],
          child: listItemWidget,
        );

        // Report the row's position so "mark as read on scroll" knows when it
        // has left the viewport. Only wrapped when the setting is on, so the
        // default path costs nothing.
        return markReadOnScroll
            ? ScrollPastProbe(
                itemId: item.id,
                reporter: _scrollPast,
                child: row,
              )
            : row;
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
    if (mounted) {
      ref.read(articleListControllerProvider(widget.timelineId).notifier).reload();
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
    if (mounted) {
      ref.read(articleListControllerProvider(widget.timelineId).notifier).reload();
      // Badge refresh only — coalesced so rapid toggles don't reload the whole
      // source list each time.
      ref.read(sourceListControllerProvider.notifier).scheduleReload();
    }
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
    if (mounted) {
      ref.read(articleListControllerProvider(widget.timelineId).notifier).reload();
    }
  }

  String _resolveTitle(String timelineId, AppLocalizations l10n) {
    if (timelineId == 'all') return l10n.timelineAll;
    if (timelineId == 'articles') return l10n.timelineArticles;
    if (timelineId == 'podcasts') return l10n.podcasts;
    if (timelineId == 'videos') return l10n.videos;
    if (timelineId.startsWith('feed_')) return l10n.timelineFeed;
    if (timelineId.startsWith('folder_')) return l10n.timelineFolder;
    if (timelineId.startsWith('tag_')) return l10n.timelineTag;
    if (timelineId.startsWith('filter_')) return l10n.timelineFilter;
    return l10n.timeline;
  }
}
