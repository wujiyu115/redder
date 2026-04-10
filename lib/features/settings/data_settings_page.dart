import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/widgets/reeder_switch.dart';
import '../../shared/widgets/reeder_dialog.dart';
import '../../core/database/app_database.dart';
import '../../shared/providers/settings_provider.dart';

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
        loading: () => Center(child: Text(l10n.loading)),
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
              // Toggle cache images setting
            },
          ),
        ),

        // ─── IMPORT / EXPORT ────────────────────────────────
        ReederSectionHeader(title: l10n.importExport),

        ReederListTile(
          title: l10n.importOpml,
          subtitle: l10n.importOpmlDesc,
          showDisclosure: true,
          onTap: () {
            // Will be implemented in W3 subscription management
          },
        ),

        ReederListTile(
          title: l10n.exportOpml,
          subtitle: l10n.exportOpmlDesc,
          showDisclosure: true,
          onTap: () {
            // Will be implemented in W3 subscription management
          },
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
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
            },
          ),
        ],
      ),
    );
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
