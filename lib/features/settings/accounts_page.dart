import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';
import '../../shared/widgets/reeder_button.dart';
import '../../shared/widgets/reeder_dialog.dart';
import '../../shared/providers/sync_provider.dart';
import '../../data/services/sync/sync_models.dart';

/// Account management page for sync services.
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(syncAccountsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = ReederTheme.of(context);

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.syncAccounts,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: accounts.when(
        data: (accountList) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: AppDimensions.spacingS),
              if (accountList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  child: Center(
                    child: Text(
                      l10n.noSyncAccounts,
                      style: theme.typography.body.copyWith(
                            color: theme.secondaryTextColor,
                          ),
                    ),
                  ),
                )
              else
                ...accountList.map((account) => _AccountTile(
                      account: account,
                      theme: theme,
                      l10n: l10n,
                      onTap: () => ref
                          .read(syncAccountsProvider.notifier)
                          .setActiveAccount(account.id),
                      onEdit: () => context.push(
                        '/settings/accounts/edit/${account.id}',
                      ),
                      onDelete: () => _showDeleteConfirmation(
                        context, ref, account, theme, l10n,
                      ),
                    )),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing),
                child: ReederButton.filled(
                  label: l10n.addAccount,
                  onPressed: () => context.push('/settings/accounts/add'),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXXL),
            ],
          );
        },
        loading: () => Center(
          child: Text(
            l10n.loading,
            style: theme.typography.body.copyWith(
                  color: theme.secondaryTextColor,
                ),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            l10n.errorWithMessage(e.toString()),
            style: theme.typography.body.copyWith(
                  color: theme.destructiveColor,
                ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    SyncAccountInfo account,
    ReederThemeData theme,
    AppLocalizations l10n,
  ) {
    final detail = account.username ?? account.serverUrl ?? 'ID: ${account.id}';
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.deleteAccount,
        message: l10n.deleteAccountConfirm(
          account.serviceType.displayName,
          detail,
        ),
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.delete,
            isDestructive: true,
            onPressed: () {
              ref.read(syncAccountsProvider.notifier).removeAccount(account.id);
            },
          ),
        ],
      ),
    );
  }
}

/// A tile that displays detailed account information.
class _AccountTile extends StatelessWidget {
  final SyncAccountInfo account;
  final ReederThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.account,
    required this.theme,
    required this.l10n,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final identityText = _buildIdentityText();
    final syncStatusText = _buildSyncStatusText();

    return ReederListTile(
      title: account.serviceType.displayName,
      subtitle: identityText + (syncStatusText.isNotEmpty ? '\n$syncStatusText' : ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (account.isActive)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.spacingS),
              child: Text(
                l10n.active,
                style: theme.typography.caption.copyWith(
                  color: theme.accentColor,
                ),
              ),
            ),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Text(
                  '✎',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.accentColor,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Text(
                  '✕',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.destructiveColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _buildIdentityText() {
    final parts = <String>[];
    if (account.username != null && account.username!.isNotEmpty) {
      parts.add(account.username!);
    }
    if (account.serverUrl != null && account.serverUrl!.isNotEmpty) {
      parts.add(account.serverUrl!);
    }
    if (parts.isEmpty) {
      return account.serviceType.displayName;
    }
    return parts.join(' · ');
  }

  String _buildSyncStatusText() {
    if (account.lastSyncAt != null) {
      return l10n.lastSynced(DateFormatter.relativeTime(account.lastSyncAt!));
    }
    return l10n.neverSynced;
  }
}
