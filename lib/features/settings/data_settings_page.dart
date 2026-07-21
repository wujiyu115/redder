import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/widgets/reeder_switch.dart';
import '../../shared/widgets/reeder_dialog.dart';
import '../../shared/widgets/reeder_toast.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../core/database/app_database.dart';
import '../../shared/providers/settings_provider.dart';
import '../source_list/source_list_controller.dart';

/// Data & storage settings page.
///
/// Allows users to configure:
/// - Auto-refresh interval
/// - Content expiry
/// - Cache settings
/// - OPML import/export
class DataSettingsPage extends ConsumerWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);
    final settingsState = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.dataAndStorage,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: settingsState.when(
        data: (settings) =>
            _buildContent(context, ref, settings, theme),
        loading: () => const ShimmerLoading(),
        error: (e, _) => Center(child: Text(l10n.errorWithMessage(e.toString()))),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppSettingsTableData settings,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: AppDimensions.spacingS),

        // ─── REFRESH ────────────────────────────────────────
        ReederSectionHeader(title: l10n.refresh),

        ReederListTile(
          title: l10n.autoRefresh,
          trailing: Text(
            _refreshIntervalLabel(settings.autoRefreshIntervalMinutes, l10n),
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
          onTap: () => _showRefreshIntervalPicker(context, ref, settings),
        ),

        // ─── CONTENT ────────────────────────────────────────
        ReederSectionHeader(title: l10n.content),

        ReederListTile(
          title: l10n.contentExpiry,
          subtitle: l10n.contentExpiryDesc,
          trailing: Text(
            _expiryLabel(settings.contentExpiryDays, l10n),
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
          onTap: () => _showExpiryPicker(context, ref, settings),
        ),

        ReederListTile(
          title: l10n.cacheImages,
          subtitle: l10n.cacheImagesDesc,
          trailing: ReederSwitch(
            value: settings.cacheImages,
            onChanged: (_) {
              ref.read(settingsProvider.notifier).toggleCacheImages();
            },
          ),
        ),

        // ─── IMPORT / EXPORT ────────────────────────────────
        ReederSectionHeader(title: l10n.importExport),

        ReederListTile(
          title: l10n.importOpml,
          subtitle: l10n.importOpmlDesc,
          showDisclosure: true,
          onTap: () => _importOpml(context, ref),
        ),

        ReederListTile(
          title: l10n.exportOpml,
          subtitle: l10n.exportOpmlDesc,
          showDisclosure: true,
          onTap: () => _exportOpml(context, ref),
        ),

        // ─── DANGER ZONE ────────────────────────────────────
        ReederSectionHeader(title: l10n.dangerZone),

        ReederListTile(
          title: l10n.clearAllData,
          subtitle: l10n.clearAllDataDesc,
          trailing: Text(
            l10n.clear,
            style: theme.typography.body.copyWith(
              color: theme.destructiveColor,
            ),
          ),
          onTap: () => _showClearDataConfirmation(context, ref, theme),
          showSeparator: false,
        ),

        const SizedBox(height: AppDimensions.spacingXXL),
      ],
    );
  }

  /// Picks an OPML file and imports its subscriptions.
  Future<void> _importOpml(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      String? content;
      if (picked.bytes != null) {
        content = utf8.decode(picked.bytes!);
      } else if (picked.path != null) {
        content = await File(picked.path!).readAsString();
      }
      if (content == null) return;

      final count = await ref
          .read(sourceListControllerProvider.notifier)
          .importOpml(content);
      if (context.mounted) {
        ReederToast.show(context, l10n.opmlImportSuccess(count));
      }
    } catch (_) {
      if (context.mounted) {
        ReederToast.show(context, l10n.opmlImportFailed, isError: true);
      }
    }
  }

  /// Exports all subscriptions as an OPML file and opens the share sheet.
  Future<void> _exportOpml(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final opml = await ref
          .read(sourceListControllerProvider.notifier)
          .exportOpml();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/reeder_subscriptions.opml');
      await file.writeAsString(opml);
      await Share.shareXFiles([XFile(file.path)], subject: l10n.exportOpml);
    } catch (_) {
      if (context.mounted) {
        ReederToast.show(context, l10n.opmlExportFailed, isError: true);
      }
    }
  }

  String _refreshIntervalLabel(int minutes, AppLocalizations l10n) {
    if (minutes == 0) return l10n.manual;
    if (minutes < 60) return l10n.refreshIntervalMin(minutes);
    return l10n.refreshIntervalHour(minutes ~/ 60);
  }

  String _expiryLabel(int days, AppLocalizations l10n) {
    if (days == 0) return l10n.never;
    if (days == 1) return l10n.dayCount(1);
    if (days < 30) return l10n.dayCount(days);
    if (days == 30) return l10n.monthCount(1);
    if (days == 90) return l10n.monthCount(3);
    if (days == 365) return l10n.yearCount(1);
    return l10n.dayCount(days);
  }

  void _showRefreshIntervalPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettingsTableData settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final options = [0, 15, 30, 60, 120, 360];
    ReederDialog.show(
      context: context,
      builder: (context) => ReederDialog(
        title: l10n.autoRefreshInterval,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in options)
              _OptionTile(
                label: _refreshIntervalLabel(minutes, l10n),
                isSelected: settings.autoRefreshIntervalMinutes == minutes,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setAutoRefreshInterval(minutes);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showExpiryPicker(
    BuildContext context,
    WidgetRef ref,
    AppSettingsTableData settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final options = [0, 7, 14, 30, 90, 365];
    ReederDialog.show(
      context: context,
      builder: (context) => ReederDialog(
        title: l10n.contentExpiry,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final days in options)
              _OptionTile(
                label: _expiryLabel(days, l10n),
                isSelected: settings.contentExpiryDays == days,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setContentExpiryDays(days);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDataConfirmation(
    BuildContext context,
    WidgetRef ref,
    ReederThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (context) => ReederDialog(
        title: l10n.clearAllDataConfirmTitle,
        message: l10n.clearAllDataConfirmMessage,
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.clearAll,
            isDestructive: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(context, ref);
            },
          ),
        ],
      ),
    );
  }

  /// Deletes all articles/feeds/folders/tags/filters, resets settings to
  /// defaults, and refreshes the source list.
  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // clearAll() wipes every table including appSettingsTable; reset it
      // to defaults so the app is left in a usable first-run state.
      await AppDatabase.instance.clearAll();
      await ref.read(settingsProvider.notifier).resetToDefaults();
      ref.invalidate(sourceListControllerProvider);
      if (context.mounted) {
        // Reuse the confirm label as the success toast; a dedicated
        // `clearAllDataSuccess` l10n key doesn't exist (l10n files are
        // owned by another agent).
        ReederToast.show(context, l10n.clearAllData);
      }
    } catch (e) {
      if (context.mounted) {
        ReederToast.show(
          context,
          l10n.errorWithMessage(e.toString()),
          isError: true,
        );
      }
    }
  }
}

/// A selectable option tile used in picker dialogs.
class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _OptionTile({
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
