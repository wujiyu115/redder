import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_slider.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/providers/settings_provider.dart';
import '../../core/database/app_database.dart';
import '../../data/models/app_settings_helpers.dart';

/// Reading settings page.
///
/// Allows users to configure:
/// - Font size (7 levels: 12-22pt)
/// - Line height (5 levels: 1.2-1.8x)
/// - Live preview of text with current settings
class ReadingSettingsPage extends ConsumerWidget {
  const ReadingSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);
    final settingsState = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.reading,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: settingsState.when(
        data: (settings) =>
            _buildContent(context, ref, settings, theme, l10n),
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

        // ─── FONT SIZE ──────────────────────────────────────
        ReederSectionHeader(title: l10n.fontSize),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.spacingS,
          ),
          child: Column(
            children: [
              ReederSlider(
                value: settings.fontSizeLevel.toDouble(),
                min: 0,
                max: 6,
                divisions: 6,
                startLabel: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.secondaryTextColor,
                  ),
                ),
                endLabel: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryTextColor,
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setFontSizeLevel(value.round());
                },
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                '${settings.fontSize.toStringAsFixed(0)}pt',
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),

        // ─── LINE HEIGHT ────────────────────────────────────
        ReederSectionHeader(title: l10n.lineHeight),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.spacingS,
          ),
          child: Column(
            children: [
              ReederSlider(
                value: settings.lineHeightLevel.toDouble(),
                min: 0,
                max: 4,
                divisions: 4,
                startLabel: Text(
                  '≡',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.secondaryTextColor,
                  ),
                ),
                endLabel: Text(
                  '≡',
                  style: TextStyle(
                    fontSize: 22,
                    color: theme.secondaryTextColor,
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setLineHeightLevel(value.round());
                },
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                '${settings.lineHeight.toStringAsFixed(2)}x',
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),

        // ─── PREVIEW ────────────────────────────────────────
        ReederSectionHeader(title: l10n.preview),

        Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacing),
            decoration: BoxDecoration(
              color: theme.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              l10n.previewText,
              style: TextStyle(
                fontSize: settings.fontSize,
                height: settings.lineHeight,
                color: theme.primaryTextColor,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingXXL),
      ],
    );
  }
}
