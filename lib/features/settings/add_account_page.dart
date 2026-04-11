import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_section_header.dart';

/// Page for selecting a sync service to add an account.
class AddAccountPage extends StatelessWidget {
  const AddAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.addAccount,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: AppDimensions.spacingS),

          // ─── Third-Party Services ─────────────────────────────
          ReederSectionHeader(title: l10n.thirdPartyServices),

          ReederListTile(
            title: 'Feedbin',
            subtitle: l10n.feedbinDesc,
            showDisclosure: true,
            onTap: () => context.push('/settings/accounts/login/feedbin'),
          ),

          ReederListTile(
            title: 'Feedly',
            subtitle: l10n.comingSoon,
            showDisclosure: true,
            onTap: () => context.push('/settings/accounts/login/feedly'),
          ),

          ReederListTile(
            title: 'Inoreader',
            subtitle: l10n.comingSoon,
            showDisclosure: true,
            onTap: () => context.push('/settings/accounts/login/inoreader'),
          ),

          // ─── Self-Hosted Services ────────────────────────────
          ReederSectionHeader(title: l10n.selfHostedServices),

          ReederListTile(
            title: 'FreshRSS',
            subtitle: l10n.freshRssDesc,
            showDisclosure: true,
            onTap: () => context.push('/settings/accounts/login/freshRss'),
          ),

          ReederListTile(
            title: 'Reader',
            subtitle: l10n.readerDesc,
            showDisclosure: true,
            onTap: () => context.push('/settings/accounts/login/reader'),
            showSeparator: false,
          ),

          const SizedBox(height: AppDimensions.spacingXXL),
        ],
      ),
    );
  }
}
