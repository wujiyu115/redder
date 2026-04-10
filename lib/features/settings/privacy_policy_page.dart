import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';

/// Privacy Policy page.
///
/// Displays the app's privacy policy, explaining data collection,
/// storage, and usage practices. Since Reeder is a local-first app
/// with no cloud sync, the privacy policy is straightforward.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return ReederScaffold(
      navBar: ReederNavBar(
        title: 'Privacy Policy',
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacingL),

            // Title
            Text(
              'Privacy Policy',
              style: theme.typography.largeTitle.copyWith(
                color: theme.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              'Last updated: April 2026',
              style: theme.typography.caption.copyWith(
                color: theme.tertiaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),

            // Introduction
            _buildSection(
              theme,
              'Introduction',
              'Reeder is a local-first RSS reader application. We are committed '
                  'to protecting your privacy. This policy explains what data we '
                  'collect, how we use it, and your rights regarding your data.',
            ),

            // Data Collection
            _buildSection(
              theme,
              'Data Collection',
              'Reeder collects and stores the following data locally on your device:\n\n'
                  '• RSS/Atom/JSON Feed URLs you subscribe to\n'
                  '• Feed content (articles, podcasts, videos) fetched from your subscriptions\n'
                  '• Your reading preferences (theme, font size, line height)\n'
                  '• Tags, bookmarks, and reading history\n'
                  '• Scroll positions and app settings\n\n'
                  'All data is stored locally on your device using an embedded database. '
                  'No data is transmitted to our servers.',
            ),

            // Network Requests
            _buildSection(
              theme,
              'Network Requests',
              'Reeder makes network requests only to:\n\n'
                  '• Fetch RSS/Atom/JSON Feed content from the URLs you subscribe to\n'
                  '• Load images embedded in feed content\n'
                  '• Open web pages in the in-app browser when you choose to\n\n'
                  'These requests are made directly to the feed providers and '
                  'content hosts. Reeder does not proxy, log, or analyze these requests.',
            ),

            // Data Storage
            _buildSection(
              theme,
              'Data Storage',
              'All your data is stored locally on your device. Reeder does not '
                  'use cloud storage, remote databases, or any third-party analytics '
                  'or tracking services. Your data remains entirely under your control.',
            ),

            // Data Sharing
            _buildSection(
              theme,
              'Data Sharing',
              'Reeder does not share your data with any third parties. The only '
                  'data that leaves your device is:\n\n'
                  '• Feed URLs when fetching content updates\n'
                  '• Article URLs when you choose to share or open in browser\n'
                  '• OPML export files when you explicitly export your subscriptions',
            ),

            // Data Deletion
            _buildSection(
              theme,
              'Data Deletion',
              'You can delete all your data at any time by:\n\n'
                  '• Removing individual subscriptions\n'
                  '• Clearing all data from Settings → Data → Clear All Data\n'
                  '• Uninstalling the application\n\n'
                  'When you delete data or uninstall the app, all locally stored '
                  'data is permanently removed.',
            ),

            // Children's Privacy
            _buildSection(
              theme,
              "Children's Privacy",
              'Reeder does not knowingly collect data from children under 13. '
                  'The app does not require account creation or personal information.',
            ),

            // Changes to Policy
            _buildSection(
              theme,
              'Changes to This Policy',
              'We may update this privacy policy from time to time. Any changes '
                  'will be reflected in the app with an updated "Last updated" date.',
            ),

            // Contact
            _buildSection(
              theme,
              'Contact',
              'If you have questions about this privacy policy, please contact '
                  'us through the app\'s support channel.',
            ),

            const SizedBox(height: AppDimensions.spacingXXL * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    ReederThemeData theme,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.articleTitle.copyWith(
              color: theme.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            content,
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
