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
import '../../core/database/app_database.dart';
import '../../data/models/app_settings_helpers.dart';
import '../../shared/providers/settings_provider.dart';

/// The main settings page of the Reeder app.
///
/// Organized into sections:
/// - Appearance: Theme, Display options
/// - Reading: Font size, Line height, Bionic Reading
/// - Data: Cache, Refresh, Export
/// - About: Version, Credits
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);
    final settingsState = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.settings,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: settingsState.when(
        data: (settings) => _buildContent(context, ref, settings, theme, l10n),
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
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: AppDimensions.spacingS),

        // ─── APPEARANCE ─────────────────────────────────────
        ReederSectionHeader(title: l10n.appearance),

        ReederListTile(
          title: l10n.theme,
          trailing: Text(
            _themeModeName(settings.themeMode, l10n),
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
          showDisclosure: true,
          onTap: () => context.push('/settings/theme'),
        ),

        ReederListTile(
          title: l10n.compactMode,
          subtitle: l10n.compactModeDesc,
          trailing: ReederSwitch(
            value: settings.compactMode,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleCompactMode(),
          ),
        ),

        ReederListTile(
          title: l10n.showThumbnails,
          trailing: ReederSwitch(
            value: settings.showThumbnails,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleShowThumbnails(),
          ),
        ),

        ReederListTile(
          title: l10n.showFeedIcons,
          trailing: ReederSwitch(
            value: settings.showAvatars,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleShowAvatars(),
          ),
        ),

        // ─── READING ────────────────────────────────────────
        ReederSectionHeader(title: l10n.reading),

        ReederListTile(
          title: l10n.fontSizeAndLineHeight,
          subtitle: l10n.fontSizeAndLineHeightDesc,
          showDisclosure: true,
          onTap: () => context.push('/settings/reading'),
        ),

        ReederListTile(
          title: l10n.bionicReading,
          subtitle: l10n.bionicReadingDesc,
          trailing: ReederSwitch(
            value: settings.bionicReading,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleBionicReading(),
          ),
        ),

        ReederListTile(
          title: l10n.markAsReadOnScroll,
          subtitle: l10n.markAsReadOnScrollDesc,
          trailing: ReederSwitch(
            value: settings.markReadOnScroll,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleMarkReadOnScroll(),
          ),
        ),

        ReederListTile(
          title: l10n.sortOrder,
          trailing: Text(
            settings.sortOrder == 'newest' ? l10n.newestFirst : l10n.oldestFirst,
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
          onTap: () {
            final newOrder =
                settings.sortOrder == 'newest' ? 'oldest' : 'newest';
            ref.read(settingsProvider.notifier).setSortOrder(newOrder);
          },
        ),

        ReederListTile(
          title: l10n.timeline,
          subtitle: l10n.timelineDesc,
          showDisclosure: true,
          onTap: () => context.push('/settings/timeline'),
        ),

        // ─── DATA ───────────────────────────────────────────
        ReederSectionHeader(title: l10n.data),

        ReederListTile(
          title: l10n.dataAndStorage,
          subtitle: l10n.dataAndStorageDesc,
          showDisclosure: true,
          onTap: () => context.push('/settings/data'),
        ),

        // ─── ABOUT ──────────────────────────────────────────
        ReederSectionHeader(title: l10n.about),

        ReederListTile(
          title: l10n.aboutReeder,
          showDisclosure: true,
          onTap: () => context.push('/settings/about'),
        ),

        ReederListTile(
          title: l10n.resetAllSettings,
          trailing: Text(
            l10n.reset,
            style: theme.typography.body.copyWith(
              color: theme.destructiveColor,
            ),
          ),
          onTap: () {
            ref.read(settingsProvider.notifier).resetToDefaults();
          },
          showSeparator: false,
        ),

        const SizedBox(height: AppDimensions.spacingXXL),
      ],
    );
  }

  String _themeModeName(ReederThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ReederThemeMode.light:
        return l10n.themeLight;
      case ReederThemeMode.dark:
        return l10n.themeDark;
      case ReederThemeMode.oled:
        return l10n.themeOled;
      case ReederThemeMode.darkLight:
        return l10n.themeDarkLight;
      case ReederThemeMode.system:
        return l10n.themeSystem;
      default:
        return l10n.themeSystem;
    }
  }
}
