import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/feed.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_button.dart';
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

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.appTitle,
        leading: const SizedBox.shrink(),
        actions: [
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
        loading: () => Center(child: Text(l10n.loading)),
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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ─── HOME Section ─────────────────────────────────
        ReederSectionHeader(title: l10n.home),
        SourceItem(
          icon: const Text('📰', style: TextStyle(fontSize: 18)),
          title: l10n.all,
          count: state.totalUnreadCount,
          onTap: () => context.push('/timeline/all'),
        ),
        SourceItem(
          icon: const Text('📝', style: TextStyle(fontSize: 18)),
          title: l10n.articles,
          onTap: () => context.push('/timeline/articles'),
        ),
        SourceItem(
          icon: const Text('🎙', style: TextStyle(fontSize: 18)),
          title: l10n.podcasts,
          onTap: () => context.push('/timeline/podcasts'),
        ),
        SourceItem(
          icon: const Text('🎬', style: TextStyle(fontSize: 18)),
          title: l10n.videos,
          onTap: () => context.push('/timeline/videos'),
        ),

        // ─── FEEDS Section ────────────────────────────────
        ReederSectionHeader(
          title: l10n.feeds,
          trailing: ReederButton.icon(
            icon: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
            onPressed: () => _showAddFeedDialog(context),
          ),
        ),

        // Folders with long-press context menu
        for (final folder in state.folders)
          SourceSection(
            title: folder.name,
            iconName: folder.iconName,
            isExpanded: folder.isExpanded,
            unreadCount: folder.unreadCount,
            onTap: () => context.push('/timeline/folder_${folder.id}'),
            onLongPress: () => _showFolderContextMenu(
              context, ref, folder, theme,
            ),
            children: [
              for (final feed in state.feedsByFolder[folder.id] ?? [])
                SourceItem(
                  title: feed.title,
                  iconUrl: feed.iconUrl,
                  count: feed.unreadCount,
                  onTap: () => context.push('/timeline/feed_${feed.id}'),
                  onLongPress: () => _showFeedContextMenu(
                    context, ref, feed, state.folders, theme,
                  ),
                ),
            ],
          ),

        // Root feeds (not in any folder) with long-press context menu
        for (final feed in state.rootFeeds)
          SourceItem(
            title: feed.title,
            iconUrl: feed.iconUrl,
            count: feed.unreadCount,
            onTap: () => context.push('/timeline/feed_${feed.id}'),
            onLongPress: () => _showFeedContextMenu(
              context, ref, feed, state.folders, theme,
            ),
          ),

        // New Folder button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
            vertical: AppDimensions.spacingS,
          ),
          child: GestureDetector(
            onTap: () => _showCreateFolderDialog(context, ref, theme),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  '📁',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  l10n.newFolder,
                  style: theme.typography.body.copyWith(
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── TAGS Section ─────────────────────────────────
        ReederSectionHeader(title: l10n.tags),
        for (final tag in state.tags)
          SourceItem(
            icon: Text(
              _tagIcon(tag.iconName),
              style: const TextStyle(fontSize: 18),
            ),
            title: tag.name,
            count: tag.itemCount,
            onTap: () => context.push('/timeline/tag_${tag.id}'),
            onLongPress: tag.isBuiltIn
                ? null
                : () => _showTagContextMenu(context, ref, tag, theme),
          ),

        // New Tag button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
            vertical: AppDimensions.spacingS,
          ),
          child: GestureDetector(
            onTap: () => _showCreateTagDialog(context, ref, theme),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  '🏷',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  l10n.newTag,
                  style: theme.typography.body.copyWith(
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── FILTERS Section ──────────────────────────────
        if (state.filters.isNotEmpty) ...[
          ReederSectionHeader(title: l10n.filters),
          for (final filter in state.filters)
            SourceItem(
              icon: const Text('⚡', style: TextStyle(fontSize: 18)),
              title: filter.name,
              onTap: () => context.push('/timeline/filter_${filter.id}'),
              onLongPress: () => _showFilterContextMenu(
                context, ref, filter, theme,
              ),
            ),
        ],

        // New Filter button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
            vertical: AppDimensions.spacingS,
          ),
          child: GestureDetector(
            onTap: () => context.push('/filter/new'),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Text(
                  '⚡',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  l10n.newFilter,
                  style: theme.typography.body.copyWith(
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom padding
        const SizedBox(height: AppDimensions.spacingXXL),
      ],
    );
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
      case 'move':
        _showMoveFeedDialog(context, ref, feed, folders, theme);
        break;
      case 'refresh':
        ref.read(sourceListControllerProvider.notifier).refreshFeed(feed.id);
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
            onPressed: () {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .deleteFeed(feed.id);
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
    final controller = TextEditingController();

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.newFolder,
        content: ReederTextField(
          controller: controller,
          placeholder: l10n.folderName,
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .createFolder(value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.create,
            isDefault: true,
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(sourceListControllerProvider.notifier)
                    .createFolder(name);
              }
            },
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
    final controller = TextEditingController(text: folder.name);

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.renameFolder,
        content: ReederTextField(
          controller: controller,
          placeholder: l10n.folderName,
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .renameFolder(folder.id, value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.rename,
            isDefault: true,
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(sourceListControllerProvider.notifier)
                    .renameFolder(folder.id, name);
              }
            },
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
            onPressed: () {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .deleteFolder(folder.id);
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
    final controller = TextEditingController();

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.newTag,
        content: ReederTextField(
          controller: controller,
          placeholder: l10n.tagName,
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .createTag(value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.create,
            isDefault: true,
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(sourceListControllerProvider.notifier)
                    .createTag(name);
              }
            },
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
    final controller = TextEditingController(text: tag.name);

    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.renameTag,
        content: ReederTextField(
          controller: controller,
          placeholder: l10n.tagName,
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .renameTag(tag.id, value.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          ReederDialogAction(label: l10n.cancel),
          ReederDialogAction(
            label: l10n.rename,
            isDefault: true,
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(sourceListControllerProvider.notifier)
                    .renameTag(tag.id, name);
              }
            },
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
            onPressed: () {
              ref
                  .read(sourceListControllerProvider.notifier)
                  .deleteTag(tag.id);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    _selectedViewer = widget.feed.defaultViewer;
    _autoReaderView = widget.feed.autoReaderView;
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
