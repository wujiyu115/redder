import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
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

    return ReederScaffold(
      navBar: ReederNavBar(
        title: 'Timeline',
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings, theme),
        loading: () => const Center(
          child: Text('⏳', style: TextStyle(fontSize: 32)),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load settings',
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
    dynamic settings,
    ReederThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Sort Order ─────────────────────────────────
          const ReederSectionHeader(title: 'SORT ORDER'),
          const SizedBox(height: AppDimensions.spacingS),

          ReederListTile(
            title: 'Newest First',
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
            title: 'Oldest First',
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
          const ReederSectionHeader(title: 'BEHAVIOR'),
          const SizedBox(height: AppDimensions.spacingS),

          ReederListTile(
            title: 'Group by Feed',
            subtitle: 'Group articles by their source feed',
            trailing: ReederSwitch(
              value: settings.groupByFeed,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleGroupByFeed();
              },
            ),
          ),
          ReederListTile(
            title: 'Mark Read on Scroll',
            subtitle: 'Automatically mark articles as read when scrolled past',
            trailing: ReederSwitch(
              value: settings.markReadOnScroll,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleMarkReadOnScroll();
              },
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Content Expiry ─────────────────────────────
          const ReederSectionHeader(title: 'CONTENT EXPIRY'),
          const SizedBox(height: AppDimensions.spacingS),

          _ExpiryOption(
            title: 'Never',
            isSelected: settings.contentExpiryDays == 0,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(0);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: '1 Week',
            isSelected: settings.contentExpiryDays == 7,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(7);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: '2 Weeks',
            isSelected: settings.contentExpiryDays == 14,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(14);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: '1 Month',
            isSelected: settings.contentExpiryDays == 30,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(30);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: '3 Months',
            isSelected: settings.contentExpiryDays == 90,
            onTap: () {
              ref.read(settingsProvider.notifier).setContentExpiryDays(90);
            },
            theme: theme,
          ),
          _ExpiryOption(
            title: '6 Months',
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
              'Articles older than the selected period will be hidden from timelines. '
              'They can still be found via search.',
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
