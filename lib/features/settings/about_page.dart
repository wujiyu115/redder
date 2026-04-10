import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_section_header.dart';

/// About page displaying app information.
///
/// Shows:
/// - App name and version
/// - Credits and acknowledgments
/// - Links to privacy policy, terms, etc.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.about,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // App header
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingXXL,
            ),
            child: Column(
              children: [
                // App icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusL,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing),

                // App name
                Text(
                  l10n.appTitle,
                  style: theme.typography.articleTitle.copyWith(
                    color: theme.primaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),

                // Version
                Text(
                  l10n.version('1.0.0'),
                  style: theme.typography.caption.copyWith(
                    color: theme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXXL,
                  ),
                  child: Text(
                    l10n.appDescription,
                    style: theme.typography.summary.copyWith(
                      color: theme.tertiaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // ─── LINKS ────────────────────────────────────────
          ReederSectionHeader(title: l10n.links),

          ReederListTile(
            title: l10n.privacyPolicy,
            showDisclosure: true,
            onTap: () => _openUrl('https://example.com/privacy'),
          ),

          ReederListTile(
            title: l10n.termsOfService,
            showDisclosure: true,
            onTap: () => _openUrl('https://example.com/terms'),
          ),

          ReederListTile(
            title: l10n.sourceCode,
            subtitle: l10n.viewOnGithub,
            showDisclosure: true,
            onTap: () => _openUrl('https://github.com/example/reeder'),
          ),

          // ─── ACKNOWLEDGMENTS ──────────────────────────────
          ReederSectionHeader(title: l10n.acknowledgments),

          ReederListTile(
            title: l10n.flutter,
            subtitle: l10n.flutterDesc,
            showDisclosure: true,
            onTap: () => _openUrl('https://flutter.dev'),
          ),

          ReederListTile(
            title: l10n.riverpod,
            subtitle: l10n.riverpodDesc,
            showDisclosure: true,
            onTap: () => _openUrl('https://riverpod.dev'),
          ),

          ReederListTile(
            title: l10n.isar,
            subtitle: l10n.isarDesc,
            showDisclosure: true,
            onTap: () => _openUrl('https://isar.dev'),
          ),

          ReederListTile(
            title: l10n.openSourceLicenses,
            showDisclosure: true,
            onTap: () {
              // Show licenses page
            },
            showSeparator: false,
          ),

          const SizedBox(height: AppDimensions.spacingXXL),

          // Footer
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.spacingXXL,
            ),
            child: Text(
              l10n.madeWithFlutter,
              style: theme.typography.caption.copyWith(
                color: theme.tertiaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
