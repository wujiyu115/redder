import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/feed.dart';
import '../../data/models/tag.dart';
import '../../data/services/sync/sync_models.dart';
import '../../shared/providers/account_provider.dart';
import '../../shared/providers/sync_provider.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_button.dart';
import '../../shared/widgets/reeder_toast.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/sync_icon_button.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/widgets/reeder_popup_menu.dart';
import '../../shared/widgets/reeder_dialog.dart';
import '../../shared/widgets/reeder_text_field.dart';
import '../../shared/widgets/reeder_switch.dart';
import '../filter/filter_controller.dart';
import 'source_list_controller.dart';
import 'widgets/source_section.dart';
import 'widgets/source_item.dart';
import 'widgets/add_feed_dialog.dart';

/// The main navigation page of the Reeder app.
///
/// Displays the source list organized into sections:
/// - HOME: Unified timeline, category timelines
/// - FEEDS: Subscribed feeds grouped by type/folder
/// - TAGS: Built-in and custom tags
///
/// Supports long-press context menus for feed and folder management.
class SourceListPage extends ConsumerWidget {
  const SourceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);
    final sourceListState = ref.watch(sourceListControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    // Watch active account info for display
    final activeAccountAsync = ref.watch(activeAccountInfoProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return ReederScaffold(
      navBar: ReederNavBar(
        title: activeAccountAsync.when(
          data: (account) => account != null
              ? '${account.serviceType.displayName} · ${account.username ?? l10n.appTitle}'
              : l10n.appTitle,
          loading: () => l10n.appTitle,
          error: (_, __) => l10n.appTitle,
        ),
        leading: const SizedBox.shrink(),
        actions: [
          ReederButton.icon(
            icon: const Text('🔍', style: TextStyle(fontSize: 18)),
            onPressed: () => context.push('/search'),
          ),
          // Sync button (spins while syncing/refreshing)
          SyncIconButton(
            externalActive:
                syncStatus.valueOrNull == SyncStatus.syncing,
            successMessage: l10n.refreshComplete,
            errorMessage: l10n.refreshFailed,
            onSync: () =>
                ref.read(sourceListControllerProvider.notifier).triggerSync(),
          ),
          ReederButton.icon(
            icon: const Text('+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
            onPressed: () => _showAddFeedDialog(context),
          ),
          ReederButton.icon(
            icon: const Text('⚙', style: TextStyle(fontSize: 20)),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: sourceListState.when(
        data: (state) => _buildContent(context, ref, state, theme),
        loading: () => const ShimmerLoading(compact: false),
        error: (e, _) => Center(child: Text(l10n.errorWithMessage(e.toString()))),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SourceListState state,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Build a flat, data-driven row list so the ListView.builder constructs
    // row widgets lazily — off-screen rows are not built/mounted — instead of
    // eagerly assembling the whole widget tree up front. Folder children stay
    // eager (SourceSection owns its children list), but every top-level row,
    // including off-screen folders, is now constructed on demand.
    final rows = <_SourceRow>[
      // ─── HOME Section ─────────────────────────────────
      _SourceRow.header(title: l10n.home),
      _SourceRow.home(
        icon: const Text('📰', style: TextStyle(fontSize: 18)),
        title: l10n.all,
        count: state.totalUnreadCount,
        onTap: () => context.push('/timeline/all'),
      ),
      _SourceRow.home(
        icon: const Text('📝', style: TextStyle(fontSize: 18)),
        title: l10n.articles,
        onTap: () => context.push('/timeline/articles'),
      ),
      _SourceRow.home(
        icon: const Text('🎙', style: TextStyle(fontSize: 18)),
        title: l10n.podcasts,
        onTap: () => context.push('/timeline/podcasts'),
      ),
      _SourceRow.home(
        icon: const Text('🎬', style: TextStyle(fontSize: 18)),
        title: l10n.videos,
        onTap: () => context.push('/timeline/videos'),
      ),

      // ─── FEEDS Section ────────────────────────────────
      const _SourceRow.feedsHeader(),

      // Folders with long-press context menu
      for (final folder in state.folders)
        if (!state.hideRead || folder.unreadCount > 0)
          _SourceRow.folder(
            folder: folder,
            feeds: state.feedsByFolder[folder.id] ?? const [],
            hideRead: state.hideRead,
          ),

      // Root feeds (not in any folder) with long-press context menu
      for (final feed in state.rootFeeds)
        if (!state.hideRead || feed.unreadCount > 0)
          _SourceRow.rootFeed(feed: feed),

      // New Folder button
      _SourceRow.newFolderButton(
        onTap: () => _showCreateFolderDialog(context, ref, theme),
      ),

      // ─── TAGS Section ─────────────────────────────────
      _SourceRow.header(title: l10n.tags),
      for (final tag in state.tags)
        _SourceRow.tag(
          tag: tag,
          title: _localizedTagName(tag, l10n),
          tagIcon: _tagIcon(tag.iconName),
          isBuiltIn: tag.isBuiltIn,
          onTap: () => context.push('/timeline/tag_${tag.id}'),
          onLongPress: tag.isBuiltIn
              ? null
              : () => _showTagContextMenu(context, ref, tag, theme),
        ),

      // New Tag button
      _SourceRow.newTagButton(
        onTap: () => _showCreateTagDialog(context, ref, theme),
      ),

      // ─── FILTERS Section ──────────────────────────────
      if (state.filters.isNotEmpty) ...[
        _SourceRow.header(title: l10n.filters),
        for (final filter in state.filters)
          _SourceRow.filter(
            filter: filter,
            onTap: () => context.push('/timeline/filter_${filter.id}'),
            onLongPress: () => _showFilterContextMenu(context, ref, filter, theme),
          ),
      ],

      // New Filter button
      _SourceRow.newFilterButton(onTap: () => context.push('/filter/new')),

      // Bottom padding
      const _SourceRow.bottomPadding(),
    ];

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      itemBuilder: (context, index) =>
          _buildRow(context, ref, rows[index], state, theme, l10n),
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    _SourceRow row,
    SourceListState state,
    ReederThemeData theme,
    AppLocalizations l10n,
  ) {
    switch (row.type) {
      case _SourceRowType.header:
        if (row.isFeedsHeader) {
          // Feeds header carries the unread-only toggle + add-feed button.
          return ReederSectionHeader(
            title: l10n.feeds,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReederButton.icon(
                  icon: Text(
                    state.hideRead ? '◉' : '◎',
                    style: TextStyle(
                      fontSize: 18,
                      color: state.hideRead
                          ? theme.accentColor
                          : theme.secondaryTextColor,
                    ),
                  ),
                  onPressed: () => ref
                      .read(sourceListControllerProvider.notifier)
                      .toggleHideRead(),
                ),
                ReederButton.icon(
                  icon: const Text('+',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                  onPressed: () => _showAddFeedDialog(context),
                ),
              ],
            ),
          );
        }
        return ReederSectionHeader(title: row.title!);

      case _SourceRowType.home:
        return SourceItem(
          icon: row.icon,
          title: row.title!,
          count: row.count,
          onTap: row.onTap,
        );

      case _SourceRowType.folder:
        return SourceSection(
          title: row.folder!.name,
          iconName: row.folder!.iconName,
          isExpanded: row.folder!.isExpanded,
          unreadCount: row.folder!.unreadCount,
          onTap: () => context.push('/timeline/folder_${row.folder!.id}'),
          onLongPress: () => _showFolderContextMenu(
            context, ref, row.folder!, theme,
          ),
          children: [
            for (final feed in row.feeds)
              if (!row.hideRead || feed.unreadCount > 0)
                SourceItem(
                  title: feed.title,
                  iconUrl: feed.iconUrl,
                  count: feed.unreadCount,
                  dimWhenRead: true,
                  onTap: () => context.push('/timeline/feed_${feed.id}'),
                  onLongPress: () => _showFeedContextMenu(
                    context, ref, feed, state.folders, theme,
                  ),
                ),
          ],
        );

      case _SourceRowType.rootFeed:
        final feed = row.feed!;
        return SourceItem(
          title: feed.title,
          iconUrl: feed.iconUrl,
          count: feed.unreadCount,
          dimWhenRead: true,
          onTap: () => context.push('/timeline/feed_${feed.id}'),
          onLongPress: () => _showFeedContextMenu(
            context, ref, feed, state.folders, theme,
          ),
        );

      case _SourceRowType.newFolderButton:
        return _buildNewButton(
          theme: theme,
          l10n: l10n,
          emoji: '📁',
          label: l10n.newFolder,
          onTap: row.onTap,
        );

      case _SourceRowType.tag:
        return SourceItem(
          icon: Text(row.tagIcon!, style: const TextStyle(fontSize: 18)),
          title: row.title!,
          count: row.tag!.itemCount,
          onTap: row.onTap,
          onLongPress: row.onLongPress,
        );

      case _SourceRowType.newTagButton:
        return _buildNewButton(
          theme: theme,
          l10n: l10n,
          emoji: '🏷',
          label: l10n.newTag,
          onTap: row.onTap,
        );

      case _SourceRowType.filter:
        final filter = row.filter!;
        return SourceItem(
          icon: const Text('⚡', style: TextStyle(fontSize: 18)),
          title: filter.name,
          onTap: row.onTap,
          onLongPress: row.onLongPress,
        );

      case _SourceRowType.newFilterButton:
        return _buildNewButton(
          theme: theme,
          l10n: l10n,
          emoji: '⚡',
          label: l10n.newFilter,
          onTap: row.onTap,
        );

      case _SourceRowType.bottomPadding:
        return const SizedBox(height: AppDimensions.spacingXXL);
    }
  }

  /// Builds the "New X" accent-colored tappable row used for new
  /// folder / tag / filter buttons.
  Widget _buildNewButton({
    required ReederThemeData theme,
    required AppLocalizations l10n,
    required String emoji,
    required String label,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.listItemPaddingH,
        vertical: AppDimensions.spacingS,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              label,
              style: theme.typography.body.copyWith(
                color: theme.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the localized display name for a tag.
  /// Built-in tags (Later, Bookmarks, Favorites) are mapped to l10n strings;
  /// custom tags use their stored name as-is.
  String _localizedTagName(Tag tag, AppLocalizations l10n) {
    if (!tag.isBuiltIn) return tag.name;
    switch (tag.name) {
      case TagNames.laterName:
        return l10n.later;
      case TagNames.bookmarksName:
        return l10n.bookmark;
      case TagNames.favoritesName:
        return l10n.favorite;
      default:
        return tag.name;
    }
  }

  String _tagIcon(String? iconName) {
    switch (iconName) {
      case 'clock':
        return '🕐';
      case 'bookmark':
        return '🔖';
      case 'heart':
        return '❤';
      default:
        return '🏷';
    }
  }

  void _showAddFeedDialog(BuildContext context) {
    showAddFeedDialog(context);
  }

  // ─── Filter Context Menu ────────────────────────────────

  void _showFilterContextMenu(
    BuildContext context,
    WidgetRef ref,
    Filter filter,
    ReederThemeData theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await ReederPopupMenu.show(
      context: context,
      position: const Offset(100, 400),
      items: [
        ReederPopupMenuItem(
          id: 'edit',
          label: l10n.editFilter,
        ),
        ReederPopupMenuItem(
          id: 'delete',
          label: l10n.deleteFilter,
          isDestructive: true,
        ),
      ],
    );

    if (selected == null || !context.mounted) return;

    switch (selected) {
      case 'edit':
        context.push('/filter/${filter.id}');
        break;
      case 'delete':
        _showDeleteFilterConfirmation(context, ref, filter, theme);
        break;
    }
  }

  // ─── Delete Filter Confirmation ─────────────────────────

  void _showDeleteFilterConfirmation(
    BuildContext context,
    WidgetRef ref,
    Filter filter,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.deleteFilter,
        message: l10n.deleteFilterConfirm(filter.name),
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.delete,
            isDestructive: true,
            onPressed: () {
              ref
                  .read(filtersProvider.notifier)
                  .deleteFilter(filter.id);
              ref
                  .read(sourceListControllerProvider.notifier)
                  .reload();
            },
          ),
        ],
      ),
    );
  }

  // ─── Feed Context Menu ──────────────────────────────────

  void _showFeedContextMenu(
    BuildContext context,
    WidgetRef ref,
    Feed feed,
    List<Folder> folders,
    ReederThemeData theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await ReederPopupMenu.show(
      context: context,
      position: const Offset(100, 300), // Approximate position
      items: [
        ReederPopupMenuItem(
          id: 'settings',
          label: l10n.feedSettings,
        ),
        ReederPopupMenuItem(
          id: 'rename',
          label: l10n.rename,
        ),
        ReederPopupMenuItem(
          id: 'move',
          label: l10n.moveTo,
          showSeparatorAfter: true,
        ),
        ReederPopupMenuItem(
          id: 'refresh',
          label: l10n.refreshFeed,
        ),
        ReederPopupMenuItem(
          id: 'unsubscribe',
          label: l10n.unsubscribe,
          isDestructive: true,
        ),
      ],
    );

    if (selected == null || !context.mounted) return;

    switch (selected) {
      case 'settings':
        _showFeedSettingsDialog(context, ref, feed, theme);
        break;
      case 'rename':
        _showRenameFeedDialog(context, ref, feed, theme);
        break;
      case 'move':
        _showMoveFeedDialog(context, ref, feed, folders, theme);
        break;
      case 'refresh':
        await _runDestructive(
          context, ref, l10n,
          () => ref.read(sourceListControllerProvider.notifier).refreshFeed(feed.id),
        );
        break;
      case 'unsubscribe':
        _showUnsubscribeConfirmation(context, ref, feed, theme);
        break;
    }
  }

  // ─── Unsubscribe Confirmation ─────────────────────────────

  void _showUnsubscribeConfirmation(
    BuildContext context,
    WidgetRef ref,
    Feed feed,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.unsubscribe,
        message: l10n.unsubscribeConfirm(feed.title),
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.unsubscribe,
            isDestructive: true,
            onPressed: () async {
              await _runDestructive(
                context, ref, l10n,
                () => ref
                    .read(sourceListControllerProvider.notifier)
                    .deleteFeed(feed.id),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Move Feed to Folder ──────────────────────────────────

  void _showMoveFeedDialog(
    BuildContext context,
    WidgetRef ref,
    Feed feed,
    List<Folder> folders,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.moveTo,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Root option
            _FolderOptionTile(
              label: l10n.noFolder,
              isSelected: feed.folderId == null,
              onTap: () {
                ref
                    .read(sourceListControllerProvider.notifier)
                    .moveFeedToFolder(feed.id, null);
                Navigator.of(ctx).pop();
              },
            ),
            // Folder options
            for (final folder in folders)
              _FolderOptionTile(
                label: folder.name,
                isSelected: feed.folderId == folder.id,
                onTap: () {
                  ref
                      .read(sourceListControllerProvider.notifier)
                      .moveFeedToFolder(feed.id, folder.id);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  // ─── Rename Feed Dialog ───────────────────────────────────

  void _showRenameFeedDialog(
    BuildContext context,
    WidgetRef ref,
    Feed feed,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final key = GlobalKey<_TextInputDialogContentState>();

    void submit(String name) {
      if (name.isEmpty) return;
      ref.read(sourceListControllerProvider.notifier).renameFeed(feed.id, name);
      Navigator.of(context).pop();
    }

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.rename,
        content: _TextInputDialogContent(
          key: key,
          initialText: feed.title,
          placeholder: l10n.rename,
          onSubmit: submit,
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.save,
            isDefault: true,
            dismissOnTap: false,
            onPressed: () => submit(key.currentState?.value ?? ''),
          ),
        ],
      ),
    );
  }

  // ─── Feed Settings Dialog ─────────────────────────────────

  void _showFeedSettingsDialog(
    BuildContext context,
    WidgetRef ref,
    Feed feed,
    ReederThemeData theme,
  ) {
    ReederDialog.show(
      context: context,
      builder: (ctx) => _FeedSettingsDialog(feed: feed, ref: ref),
    );
  }

  // ─── Folder Context Menu ──────────────────────────────────

  void _showFolderContextMenu(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
    ReederThemeData theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await ReederPopupMenu.show(
      context: context,
      position: const Offset(100, 300),
      items: [
        ReederPopupMenuItem(
          id: 'rename',
          label: l10n.rename,
        ),
        ReederPopupMenuItem(
          id: 'delete',
          label: l10n.deleteFolder,
          isDestructive: true,
        ),
      ],
    );

    if (selected == null || !context.mounted) return;

    switch (selected) {
      case 'rename':
        _showRenameFolderDialog(context, ref, folder, theme);
        break;
      case 'delete':
        _showDeleteFolderConfirmation(context, ref, folder, theme);
        break;
    }
  }

  // ─── Create Folder Dialog ─────────────────────────────────

  void _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final key = GlobalKey<_TextInputDialogContentState>();

    void submit(String name) {
      if (name.isEmpty) return;
      ref.read(sourceListControllerProvider.notifier).createFolder(name);
      Navigator.of(context).pop();
    }

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.newFolder,
        content: _TextInputDialogContent(
          key: key,
          placeholder: l10n.folderName,
          onSubmit: submit,
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.create,
            isDefault: true,
            dismissOnTap: false,
            onPressed: () => submit(key.currentState?.value ?? ''),
          ),
        ],
      ),
    );
  }

  // ─── Rename Folder Dialog ─────────────────────────────────

  void _showRenameFolderDialog(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final key = GlobalKey<_TextInputDialogContentState>();

    void submit(String name) {
      if (name.isEmpty) return;
      ref.read(sourceListControllerProvider.notifier).renameFolder(folder.id, name);
      Navigator.of(context).pop();
    }

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.renameFolder,
        content: _TextInputDialogContent(
          key: key,
          initialText: folder.name,
          placeholder: l10n.folderName,
          onSubmit: submit,
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.rename,
            isDefault: true,
            dismissOnTap: false,
            onPressed: () => submit(key.currentState?.value ?? ''),
          ),
        ],
      ),
    );
  }

  // ─── Delete Folder Confirmation ───────────────────────────

  void _showDeleteFolderConfirmation(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.deleteFolder,
        message: l10n.deleteFolderConfirm(folder.name),
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.delete,
            isDestructive: true,
            onPressed: () async {
              await _runDestructive(
                context, ref, l10n,
                () => ref
                    .read(sourceListControllerProvider.notifier)
                    .deleteFolder(folder.id),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Tag Context Menu ─────────────────────────────────────

  void _showTagContextMenu(
    BuildContext context,
    WidgetRef ref,
    dynamic tag,
    ReederThemeData theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await ReederPopupMenu.show(
      context: context,
      position: const Offset(100, 400),
      items: [
        ReederPopupMenuItem(
          id: 'rename',
          label: l10n.rename,
        ),
        ReederPopupMenuItem(
          id: 'delete',
          label: l10n.deleteTag,
          isDestructive: true,
        ),
      ],
    );

    if (selected == null || !context.mounted) return;

    switch (selected) {
      case 'rename':
        _showRenameTagDialog(context, ref, tag, theme);
        break;
      case 'delete':
        _showDeleteTagConfirmation(context, ref, tag, theme);
        break;
    }
  }

  // ─── Create Tag Dialog ────────────────────────────────────

  void _showCreateTagDialog(
    BuildContext context,
    WidgetRef ref,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final key = GlobalKey<_TextInputDialogContentState>();

    void submit(String name) {
      if (name.isEmpty) return;
      ref.read(sourceListControllerProvider.notifier).createTag(name);
      Navigator.of(context).pop();
    }

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.newTag,
        content: _TextInputDialogContent(
          key: key,
          placeholder: l10n.tagName,
          onSubmit: submit,
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.create,
            isDefault: true,
            dismissOnTap: false,
            onPressed: () => submit(key.currentState?.value ?? ''),
          ),
        ],
      ),
    );
  }

  // ─── Rename Tag Dialog ────────────────────────────────────

  void _showRenameTagDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic tag,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final key = GlobalKey<_TextInputDialogContentState>();

    void submit(String name) {
      if (name.isEmpty) return;
      ref.read(sourceListControllerProvider.notifier).renameTag(tag.id, name);
      Navigator.of(context).pop();
    }

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.renameTag,
        content: _TextInputDialogContent(
          key: key,
          initialText: tag.name as String,
          placeholder: l10n.tagName,
          onSubmit: submit,
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.rename,
            isDefault: true,
            dismissOnTap: false,
            onPressed: () => submit(key.currentState?.value ?? ''),
          ),
        ],
      ),
    );
  }

  // ─── Delete Tag Confirmation ──────────────────────────────

  void _showDeleteTagConfirmation(
    BuildContext context,
    WidgetRef ref,
    dynamic tag,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.deleteTag,
        message: l10n.deleteTagConfirm(tag.name),
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.delete,
            isDestructive: true,
            onPressed: () async {
              await _runDestructive(
                context, ref, l10n,
                () => ref
                    .read(sourceListControllerProvider.notifier)
                    .deleteTag(tag.id),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Runs a destructive controller operation, surfacing a toast on
  /// success or failure. The page [context] stays valid after the
  /// confirm dialog auto-dismisses.
  ///
  // ponytail: no per-op success l10n key exists, so success reuses
  // refreshComplete. Add a dedicated "deleted" key when i18n grows it.
  Future<void> _runDestructive(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Future<void> Function() op,
  ) async {
    try {
      await op();
      if (!context.mounted) return;
      ReederToast.show(context, l10n.refreshComplete);
    } catch (e) {
      if (!context.mounted) return;
      ReederToast.show(context, l10n.refreshFailed, isError: true);
    }
  }
}

// ─── Helper Widgets ─────────────────────────────────────────

/// A single flat row of data for the source list, used by the lazy
/// `ListView.builder` so row widgets are constructed on demand.
class _SourceRow {
  final _SourceRowType type;
  final String? title;
  final Widget? icon;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Folder? folder;
  final List<Feed> feeds;
  final bool hideRead;
  final Feed? feed;
  final Tag? tag;
  final String? tagIcon;
  final bool isBuiltIn;
  final Filter? filter;
  final bool isFeedsHeader;

  const _SourceRow._({
    required this.type,
    this.title,
    this.icon,
    this.count = 0,
    this.onTap,
    this.onLongPress,
    this.folder,
    this.feeds = const [],
    this.hideRead = false,
    this.feed,
    this.tag,
    this.tagIcon,
    this.isBuiltIn = false,
    this.filter,
    this.isFeedsHeader = false,
  });

  const _SourceRow.header({required String? title})
      : this._(type: _SourceRowType.header, title: title);
  const _SourceRow.feedsHeader()
      : this._(type: _SourceRowType.header, isFeedsHeader: true);
  const _SourceRow.home({
    required Widget icon,
    required String title,
    int count = 0,
    VoidCallback? onTap,
  }) : this._(
          type: _SourceRowType.home,
          icon: icon,
          title: title,
          count: count,
          onTap: onTap,
        );
  const _SourceRow.folder({
    required Folder folder,
    required List<Feed> feeds,
    required bool hideRead,
  }) : this._(
          type: _SourceRowType.folder,
          folder: folder,
          feeds: feeds,
          hideRead: hideRead,
        );
  const _SourceRow.rootFeed({required Feed feed})
      : this._(type: _SourceRowType.rootFeed, feed: feed);
  const _SourceRow.newFolderButton({VoidCallback? onTap})
      : this._(type: _SourceRowType.newFolderButton, onTap: onTap);
  const _SourceRow.tag({
    required Tag tag,
    required String title,
    required String tagIcon,
    required bool isBuiltIn,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : this._(
          type: _SourceRowType.tag,
          tag: tag,
          title: title,
          tagIcon: tagIcon,
          isBuiltIn: isBuiltIn,
          onTap: onTap,
          onLongPress: onLongPress,
        );
  const _SourceRow.newTagButton({VoidCallback? onTap})
      : this._(type: _SourceRowType.newTagButton, onTap: onTap);
  const _SourceRow.filter({
    required Filter filter,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : this._(
          type: _SourceRowType.filter,
          filter: filter,
          onTap: onTap,
          onLongPress: onLongPress,
        );
  const _SourceRow.newFilterButton({VoidCallback? onTap})
      : this._(type: _SourceRowType.newFilterButton, onTap: onTap);
  const _SourceRow.bottomPadding()
      : this._(type: _SourceRowType.bottomPadding);
}

enum _SourceRowType {
  header,
  home,
  folder,
  rootFeed,
  newFolderButton,
  tag,
  newTagButton,
  filter,
  newFilterButton,
  bottomPadding,
}

/// A dialog content widget that owns and disposes its own
/// [TextEditingController], fixing the controller leak that came from
/// creating the controller in a dialog-show helper method.
///
/// The parent dialog reads the current trimmed value via a
/// `GlobalKey<_TextInputDialogContentState>` for its Save action, and
/// wires [onSubmit] so the keyboard's "enter" path shares that same save.
class _TextInputDialogContent extends StatefulWidget {
  final String initialText;
  final String placeholder;
  final ValueChanged<String>? onSubmit;

  const _TextInputDialogContent({
    super.key,
    this.initialText = '',
    required this.placeholder,
    this.onSubmit,
  });

  @override
  State<_TextInputDialogContent> createState() =>
      _TextInputDialogContentState();
}

class _TextInputDialogContentState extends State<_TextInputDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Current trimmed text, read by the dialog's Save action.
  String get value => _controller.text.trim();

  @override
  Widget build(BuildContext context) {
    return ReederTextField(
      controller: _controller,
      placeholder: widget.placeholder,
      autofocus: true,
      onSubmitted: (v) {
        final name = v.trim();
        if (name.isNotEmpty) widget.onSubmit?.call(name);
      },
    );
  }
}


/// A selectable folder option tile used in the move-to-folder dialog.
class _FolderOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FolderOptionTile({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingS,
          horizontal: AppDimensions.spacing,
        ),
        child: Row(
          children: [
            Text('📁', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                label,
                style: theme.typography.body.copyWith(
                  color: theme.primaryTextColor,
                ),
              ),
            ),
            if (isSelected)
              Text(
                '✓',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for configuring individual feed settings.
///
/// Allows setting:
/// - Default viewer (Article / Reader / Browser)
/// - Auto Reader View toggle
class _FeedSettingsDialog extends ConsumerStatefulWidget {
  final Feed feed;
  final WidgetRef ref;

  const _FeedSettingsDialog({
    required this.feed,
    required this.ref,
  });

  @override
  ConsumerState<_FeedSettingsDialog> createState() =>
      _FeedSettingsDialogState();
}

class _FeedSettingsDialogState extends ConsumerState<_FeedSettingsDialog> {
  late ViewerType _selectedViewer;
  late bool _autoReaderView;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _selectedViewer = widget.feed.defaultViewer;
    _autoReaderView = widget.feed.autoReaderView;
    _notificationsEnabled = widget.feed.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    final l10n = AppLocalizations.of(context)!;

    return ReederDialog(
      title: l10n.feedSettings,
      width: 320,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feed info
          Text(
            widget.feed.title,
            style: theme.typography.listTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            widget.feed.feedUrl,
            style: theme.typography.caption.copyWith(
              color: theme.tertiaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacing),

          // Default Viewer
          Text(
            l10n.defaultViewer,
            style: theme.typography.sectionHeader.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),

          _ViewerOption(
            label: l10n.articleViewer,
            isSelected: _selectedViewer == ViewerType.article,
            onTap: () => setState(() => _selectedViewer = ViewerType.article),
          ),
          _ViewerOption(
            label: l10n.readerView,
            isSelected: _selectedViewer == ViewerType.reader,
            onTap: () => setState(() => _selectedViewer = ViewerType.reader),
          ),
          _ViewerOption(
            label: l10n.browser,
            isSelected: _selectedViewer == ViewerType.browser,
            onTap: () => setState(() => _selectedViewer = ViewerType.browser),
          ),

          const SizedBox(height: AppDimensions.spacing),

          // Auto Reader View
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.autoReaderView,
                  style: theme.typography.body,
                ),
              ),
              ReederSwitch(
                value: _autoReaderView,
                onChanged: (value) =>
                    setState(() => _autoReaderView = value),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing),

          // Per-feed notifications
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.notifications,
                  style: theme.typography.body,
                ),
              ),
              ReederSwitch(
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ReederDialogAction(label: l10n.cancel),
        ReederDialogAction(
          label: l10n.save,
          isDefault: true,
          onPressed: () {
            final controller =
                widget.ref.read(sourceListControllerProvider.notifier);
            controller.setFeedDefaultViewer(
              widget.feed.id,
              _selectedViewer,
            );
            if (_autoReaderView != widget.feed.autoReaderView) {
              controller.toggleFeedAutoReaderView(widget.feed.id);
            }
            if (_notificationsEnabled != widget.feed.notificationsEnabled) {
              controller.setFeedNotificationsEnabled(
                widget.feed.id,
                _notificationsEnabled,
              );
            }
          },
        ),
      ],
    );
  }
}

/// A selectable viewer option row.
class _ViewerOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ViewerOption({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXS),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.typography.body.copyWith(
                  color: theme.primaryTextColor,
                ),
              ),
            ),
            if (isSelected)
              Text(
                '✓',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
