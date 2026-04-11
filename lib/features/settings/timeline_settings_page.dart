import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_switch.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/providers/settings_provider.dart';

/// Timeline settings page.
///
/// Allows users to configure:
/// - Sort order (newest/oldest first)
/// - Group by feed
/// - Mark as read on scroll
/// - Content expiry (hide old articles)
class TimelineSettingsPage extends ConsumerWidget {
  const TimelineSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.timelineSettingsTitle,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings, theme, l10n),
        loading: () => Center(child: Text(l10n.loading)),
        error: (e, _) => Center(
          child: Text(
            l10n.failedToLoadSettings,
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Sort Order ─────────────────────────────────
          ReederSectionHeader(title: l10n.sortOrderSection),
          const SizedBox(height: AppDimensions.spacingS),

          ReederListTile(
            title: l10n.newestFirst,
            trailing: settings.sortOrder == 'newest'
                ? Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.accentColor,
                    ),
                  )
                : null,
            onTap: () {
              ref.read(settingsProvider.notifier).setSortOrder('newest');
            },
          ),
          ReederListTile(
            title: l10n.oldestFirst,
            trailing: settings.sortOrder == 'oldest'
                ? Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.accentColor,
                    ),
                  )
                : null,
            onTap: () {
              ref.read(settingsProvider.notifier).setSortOrder('oldest');
            },
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Behavior ───────────────────────────────────
          ReederSectionHeader(title: l10n.behaviorSection),
          const SizedBox(height: AppDimensions.spacingS),

          ReederListTile(
            title: l10n.groupByFeed,
            subtitle: l10n.groupByFeedDesc,
            trailing: ReederSwitch(
              value: settings.groupByFeed,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleGroupByFeed();
              },
            ),
          ),
          ReederListTile(
            title: l10n.markAsReadOnScroll,
            subtitle: l10n.markAsReadOnScrollDesc,
            trailing: ReederSwitch(
              value: settings.markReadOnScroll,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleMarkReadOnScroll();
              },
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Content Expiry ─────────────────────────────
          ReederSectionHeader(title: l10n.contentExpirySection),
          const SizedBox(height: AppDimensions.spacingS),

          _ExpiryOption(
            title: l10n.never,
            isSelected: settings.contentExpiryDays == 0,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(0);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: l10n.oneWeek,
            isSelected: settings.contentExpiryDays == 7,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(7);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: l10n.twoWeeks,
            isSelected: settings.contentExpiryDays == 14,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(14);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: l10n.oneMonth,
            isSelected: settings.contentExpiryDays == 30,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(30);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: l10n.threeMonths,
            isSelected: settings.contentExpiryDays == 90,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(90);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: l10n.sixMonths,
            isSelected: settings.contentExpiryDays == 180,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(180);
            },
            theme: theme,
          ),

          const SizedBox(height: AppDimensions.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
            ),
            child: Text(
              l10n.contentExpiryHint,
              style: theme.typography.caption.copyWith(
                color: theme.tertiaryTextColor,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXXL),
        ],
      ),
    );
  }
}

/// Content expiry option item.
class _ExpiryOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final ReederThemeData theme;

  const _ExpiryOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ReederListTile(
      title: title,
      trailing: isSelected
          ? Text(
              '✓',
              style: TextStyle(
                fontSize: 16,
                color: theme.accentColor,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
