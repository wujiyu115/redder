import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_text_field.dart';
import '../../shared/widgets/reeder_button.dart';
import '../../shared/providers/sync_provider.dart';
import '../../data/services/sync/sync_models.dart';

/// Page for editing an existing sync account's credentials.
class EditAccountPage extends ConsumerStatefulWidget {
  final int accountId;

  const EditAccountPage({
    super.key,
    required this.accountId,
  });

  @override
  ConsumerState<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends ConsumerState<EditAccountPage> {
  late final TextEditingController _serverUrlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _serverUrlError;
  String? _usernameError;
  String? _passwordError;
  SyncAccountInfo? _account;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _loadAccountData();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    final accounts = ref.read(syncAccountsProvider).valueOrNull ?? [];
    final account = accounts.where((a) => a.id == widget.accountId).firstOrNull;

    if (account == null) {
      if (mounted) context.pop();
      return;
    }

    setState(() {
      _account = account;
      _serverUrlController.text = account.serverUrl ?? '';
      _usernameController.text = account.username ?? '';
      _isInitialized = true;
    });
  }

  bool _validate(AppLocalizations l10n) {
    bool isValid = true;

    setState(() {
      _serverUrlError = null;
      _usernameError = null;
      _passwordError = null;
    });

    final account = _account;
    if (account == null) return false;

    final serviceType = account.serviceType;

    if (serviceType.requiresServerUrl) {
      final serverUrl = _serverUrlController.text.trim();
      if (serverUrl.isEmpty) {
        _serverUrlError = l10n.fieldRequired;
        isValid = false;
      } else if (!serverUrl.startsWith('http://') &&
          !serverUrl.startsWith('https://')) {
        _serverUrlError = l10n.invalidServerUrl;
        isValid = false;
      }
    }

    if (_usernameController.text.trim().isEmpty) {
      _usernameError = l10n.fieldRequired;
      isValid = false;
    }

    // Password is optional when editing — keep existing if empty

    if (!isValid) {
      setState(() {});
    }
    return isValid;
  }

  Future<void> _handleSave(AppLocalizations l10n) async {
    if (!_validate(l10n)) return;

    final account = _account;
    if (account == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final password = _passwordController.text.trim();
      final credentials = SyncCredentials(
        serviceType: account.serviceType,
        serverUrl: account.serviceType.requiresServerUrl
            ? _serverUrlController.text.trim()
            : null,
        username: _usernameController.text.trim(),
        password: password.isNotEmpty ? password : null,
      );

      await ref.read(syncAccountsProvider.notifier).updateAccount(
        widget.accountId,
        credentials,
        serverUrl: account.serviceType.requiresServerUrl
            ? _serverUrlController.text.trim()
            : null,
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = l10n.loginFailed(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final account = _account;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.editAccount,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: !_isInitialized || account == null
          ? Center(
              child: Text(
                l10n.loading,
                style: theme.typography.body.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.spacing),
              children: [
                const SizedBox(height: AppDimensions.spacingS),

                // Service name header
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingM,
                  ),
                  child: Text(
                    account.serviceType.displayName,
                    style: theme.typography.listTitle.copyWith(
                      color: theme.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                if (account.serviceType.requiresServerUrl) ...[
                  _buildFieldLabel(l10n.serverUrl, theme),
                  ReederTextField(
                    controller: _serverUrlController,
                    placeholder: l10n.serverUrlHint,
                    keyboardType: TextInputType.url,
                    onChanged: (_) =>
                        setState(() => _serverUrlError = null),
                  ),
                  if (_serverUrlError != null)
                    _buildFieldError(_serverUrlError!, theme),
                  const SizedBox(height: AppDimensions.spacingM),
                ],

                // Username / Email
                _buildFieldLabel(
                  account.serviceType == SyncServiceType.feedbin
                      ? l10n.email
                      : l10n.username,
                  theme,
                ),
                ReederTextField(
                  controller: _usernameController,
                  placeholder: account.serviceType == SyncServiceType.feedbin
                      ? l10n.email
                      : l10n.username,
                  keyboardType:
                      account.serviceType == SyncServiceType.feedbin
                          ? TextInputType.emailAddress
                          : null,
                  onChanged: (_) =>
                      setState(() => _usernameError = null),
                ),
                if (_usernameError != null)
                  _buildFieldError(_usernameError!, theme),
                const SizedBox(height: AppDimensions.spacingM),

                // Password (optional when editing)
                _buildFieldLabel(l10n.password, theme),
                ReederTextField(
                  controller: _passwordController,
                  placeholder: l10n.password,
                  onChanged: (_) =>
                      setState(() => _passwordError = null),
                ),
                if (_passwordError != null)
                  _buildFieldError(_passwordError!, theme),
                const SizedBox(height: AppDimensions.spacingXL),

                if (_errorMessage != null) ...[
                  _buildFieldError(_errorMessage!, theme),
                  const SizedBox(height: AppDimensions.spacingM),
                ],

                ReederButton.filled(
                  label: l10n.saveChanges,
                  onPressed:
                      _isLoading ? null : () => _handleSave(l10n),
                  disabled: _isLoading,
                ),

                const SizedBox(height: AppDimensions.spacingXXL),
              ],
            ),
    );
  }

  Widget _buildFieldLabel(String label, ReederThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
      child: Text(
        label,
        style: theme.typography.caption.copyWith(
          color: theme.secondaryTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFieldError(String error, ReederThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingXS),
      child: Text(
        error,
        style: theme.typography.caption.copyWith(
          color: theme.destructiveColor,
        ),
      ),
    );
  }
}
