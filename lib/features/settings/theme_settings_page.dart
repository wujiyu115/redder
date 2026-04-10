import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_settings_helpers.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/providers/settings_provider.dart';

/// Theme settings page.
///
/// Allows users to select from available themes:
/// - Light
/// - Dark
/// - OLED Black
/// - Dark Light (hybrid)
/// - System (follow OS setting)
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentMode = settingsState.whenOrNull(
      data: (s) => s.themeMode,
    );

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.theme,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: AppDimensions.spacingS),
          ReederSectionHeader(title: l10n.theme),

          _ThemeOption(
            title: l10n.themeLight,
            subtitle: l10n.themeLightDesc,
            mode: ReederThemeMode.light,
            isSelected: currentMode == ReederThemeMode.light,
            previewColors: const [
              Color(0xFFFFFFFF),
              Color(0xFF1C1C1E),
              Color(0xFF007AFF),
            ],
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ReederThemeMode.light),
          ),

          _ThemeOption(
            title: l10n.themeDark,
            subtitle: l10n.themeDarkDesc,
            mode: ReederThemeMode.dark,
            isSelected: currentMode == ReederThemeMode.dark,
            previewColors: const [
              Color(0xFF1C1C1E),
              Color(0xFFFFFFFF),
              Color(0xFF0A84FF),
            ],
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ReederThemeMode.dark),
          ),

          _ThemeOption(
            title: l10n.themeOled,
            subtitle: l10n.themeOledDesc,
            mode: ReederThemeMode.oled,
            isSelected: currentMode == ReederThemeMode.oled,
            previewColors: const [
              Color(0xFF000000),
              Color(0xFFFFFFFF),
              Color(0xFF0A84FF),
            ],
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ReederThemeMode.oled),
          ),

          _ThemeOption(
            title: l10n.themeDarkLight,
            subtitle: l10n.themeDarkLightDesc,
            mode: ReederThemeMode.darkLight,
            isSelected: currentMode == ReederThemeMode.darkLight,
            previewColors: const [
              Color(0xFF1C1C1E),
              Color(0xFFFFFFFF),
              Color(0xFF007AFF),
            ],
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ReederThemeMode.darkLight),
          ),

          ReederSectionHeader(title: l10n.automatic),

          _ThemeOption(
            title: l10n.themeSystem,
            subtitle: l10n.themeSystemDesc,
            mode: ReederThemeMode.system,
            isSelected: currentMode == ReederThemeMode.system,
            previewColors: const [
              Color(0xFFF2F2F7),
              Color(0xFF1C1C1E),
              Color(0xFF007AFF),
            ],
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ReederThemeMode.system),
          ),

          const SizedBox(height: AppDimensions.spacingXXL),
        ],
      ),
    );
  }
}

/// A single theme option row with color preview.
class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final ReederThemeMode mode;
  final bool isSelected;
  final List<Color> previewColors;
  final VoidCallback? onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.isSelected,
    required this.previewColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return ReederListTile(
      title: title,
      subtitle: subtitle,
      leading: _buildPreview(),
      trailing: isSelected
          ? Text(
              '✓',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.accentColor,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildPreview() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: previewColors.isNotEmpty ? previewColors[0] : const Color(0xFFCCCCCC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(
          color: const Color(0x33000000),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          'A',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: previewColors.length > 1
                ? previewColors[1]
                : const Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}
