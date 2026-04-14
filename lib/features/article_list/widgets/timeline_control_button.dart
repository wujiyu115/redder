import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/theme/app_theme.dart';
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

  const TimelineControlButton({
    super.key,
    required this.timelineId,
    this.onRefresh,
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

    final selected = await ReederPopupMenu.show(
      context: context,
      position: position,
      items: [
        const ReederPopupMenuItem(
          id: 'sync',
          label: 'Sync',
        ),
        const ReederPopupMenuItem(
          id: 'refresh',
          label: 'Refresh',
        ),
        const ReederPopupMenuItem(
          id: 'scroll_top',
          label: 'Scroll to Top',
        ),
        const ReederPopupMenuItem(
          id: 'mark_all_read',
          label: 'Mark All as Read',
          isDestructive: true,
        ),
      ],
    );

    if (selected == null) return;

    switch (selected) {
      case 'refresh':
        onRefresh?.call();
        break;
      case 'scroll_top':
        final scrollable = Scrollable.maybeOf(context);
        scrollable?.position.animateTo(
          0,
          duration: AppDurations.standard,
          curve: Curves.easeInOut,
        );
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
