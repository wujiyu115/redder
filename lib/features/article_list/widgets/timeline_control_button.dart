import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sync_provider.dart';
import '../../../shared/widgets/reeder_popup_menu.dart';
import '../article_list_controller.dart';

/// Timeline control button displayed in the article list nav bar.
///
/// Shows a new content count badge and provides a popup menu with:
/// - Timeline Position (scroll to saved position)
/// - Today (scroll to today's articles)
/// - Top (scroll to top)
/// - Refresh
/// - Mark All as Read
class TimelineControlButton extends ConsumerWidget {
  /// The timeline identifier.
  final String timelineId;

  /// Callback to trigger a refresh.
  final VoidCallback? onRefresh;

  /// Callback to scroll the list back to the top.
  final VoidCallback? onScrollToTop;

  const TimelineControlButton({
    super.key,
    required this.timelineId,
    this.onRefresh,
    this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);

    return GestureDetector(
      onTap: () => _showMenu(context, ref, theme),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Text(
            '⋯',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.accentColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref, ReederThemeData theme) async {
    // Get the button's position for the popup menu
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(
      Offset(box.size.width, box.size.height),
    );

    final hideRead = ref.read(hideReadArticlesProvider);
    final l10n = AppLocalizations.of(context)!;

    final selected = await ReederPopupMenu.show(
      context: context,
      position: position,
      items: [
        ReederPopupMenuItem(
          id: 'sync',
          label: l10n.sync,
        ),
        ReederPopupMenuItem(
          id: 'refresh',
          label: l10n.refresh,
        ),
        ReederPopupMenuItem(
          id: 'toggle_hide_read',
          label: hideRead ? l10n.showReadArticles : l10n.hideReadArticles,
        ),
        ReederPopupMenuItem(
          id: 'scroll_top',
          label: l10n.scrollToTop,
        ),
        ReederPopupMenuItem(
          id: 'mark_all_read',
          label: l10n.markAllAsRead,
          isDestructive: true,
        ),
      ],
    );

    if (selected == null) return;

    switch (selected) {
      case 'toggle_hide_read':
        ref
            .read(articleListControllerProvider(timelineId).notifier)
            .toggleHideRead();
        break;
      case 'refresh':
        onRefresh?.call();
        break;
      case 'scroll_top':
        onScrollToTop?.call();
        break;
      case 'mark_all_read':
        // markAllAsRead now goes through SyncBridge for remote sync
        ref
            .read(articleListControllerProvider(timelineId).notifier)
            .markAllAsRead();
        break;
      case 'sync':
        // Trigger incremental sync via SyncBridge
        final syncBridge = ref.read(syncBridgeProvider);
        await syncBridge.triggerIncrementalSync();
        onRefresh?.call();
        break;
    }
  }
}
