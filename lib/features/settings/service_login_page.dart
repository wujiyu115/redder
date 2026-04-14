import 'package:flutter/scheduler.dart';
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
import '../source_list/source_list_controller.dart';

/// Login page for a specific sync service.
class ServiceLoginPage extends ConsumerStatefulWidget {
  final String serviceType;

  const ServiceLoginPage({
    super.key,
    required this.serviceType,
  });

  @override
  ConsumerState<ServiceLoginPage> createState() => _ServiceLoginPageState();
}

class _ServiceLoginPageState extends ConsumerState<ServiceLoginPage> {
  late final SyncServiceType _serviceType;
  late final TextEditingController _serverUrlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _serverUrlError;
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _serviceType = SyncServiceType.values.firstWhere(
      (type) => type.name == widget.serviceType,
      orElse: () => SyncServiceType.feedbin,
    );
    _serverUrlController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates all input fields. Returns true if valid.
  bool _validate(AppLocalizations l10n) {
    bool isValid = true;

    setState(() {
      _serverUrlError = null;
      _usernameError = null;
      _passwordError = null;
    });

    if (_serviceType.requiresServerUrl) {
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

    if (!_serviceType.usesOAuth) {
      if (_usernameController.text.trim().isEmpty) {
        _usernameError = l10n.fieldRequired;
        isValid = false;
      }
      if (_passwordController.text.trim().isEmpty) {
        _passwordError = l10n.fieldRequired;
        isValid = false;
      }
    }

    if (!isValid) {
      setState(() {});
    }
    return isValid;
  }

  Future<void> _handleLogin(AppLocalizations l10n) async {
    if (!_serviceType.usesOAuth && !_validate(l10n)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final credentials = SyncCredentials(
        serviceType: _serviceType,
        serverUrl: _serviceType.requiresServerUrl
            ? _serverUrlController.text.trim()
            : null,
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await ref.read(syncAccountsProvider.notifier).addAccount(
        _serviceType,
        credentials,
        serverUrl: _serviceType.requiresServerUrl
            ? _serverUrlController.text.trim()
            : null,
        username: _usernameController.text.trim(),
      );

      // Authentication succeeded — show success and refresh subscriptions
      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = l10n.loginSuccess;
        });

        // Defer navigation to after the current frame to avoid
        // calling setState/markNeedsBuild during build.
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          // Reload the source list so newly synced feeds appear
          await ref.read(sourceListControllerProvider.notifier).reload();

          // Delay so the user can clearly see the success message
          await Future<void>.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            context.pop();
          }
        });
      }
      return; // Skip the finally block's _isLoading reset
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.loginFailed(e.toString());
        });
      }
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
    final usesOAuth = _serviceType.usesOAuth;
    final requiresServerUrl = _serviceType.requiresServerUrl;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: _serviceType.displayName,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing),
        children: [
          const SizedBox(height: AppDimensions.spacingS),

          if (usesOAuth) ...[
            // OAuth services — not yet configured
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Text(
                l10n.oauthNotConfigured(_serviceType.displayName),
                style: theme.typography.body.copyWith(
                  color: theme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            Opacity(
              opacity: 0.4,
              child: ReederButton.filled(
                label: l10n.signInWith(_serviceType.displayName),
                onPressed: null,
                disabled: true,
              ),
            ),
          ] else if (requiresServerUrl) ...[
            // Self-hosted services
            _buildFieldLabel(l10n.serverUrl, theme),
            ReederTextField(
              controller: _serverUrlController,
              placeholder: l10n.serverUrlHint,
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() => _serverUrlError = null),
            ),
            if (_serverUrlError != null)
              _buildFieldError(_serverUrlError!, theme),
            const SizedBox(height: AppDimensions.spacingM),

            _buildFieldLabel(l10n.username, theme),
            ReederTextField(
              controller: _usernameController,
              placeholder: l10n.username,
              onChanged: (_) => setState(() => _usernameError = null),
            ),
            if (_usernameError != null)
              _buildFieldError(_usernameError!, theme),
            const SizedBox(height: AppDimensions.spacingM),

            _buildFieldLabel(l10n.password, theme),
            ReederTextField(
              controller: _passwordController,
              placeholder: l10n.password,
              onChanged: (_) => setState(() => _passwordError = null),
            ),
            if (_passwordError != null)
              _buildFieldError(_passwordError!, theme),
            const SizedBox(height: AppDimensions.spacingXL),

            if (_successMessage != null) ...[
              _buildSuccessMessage(_successMessage!, theme),
              const SizedBox(height: AppDimensions.spacingM),
            ],
            if (_errorMessage != null) ...[
              _buildFieldError(_errorMessage!, theme),
              const SizedBox(height: AppDimensions.spacingM),
            ],
            ReederButton.filled(
              label: _isLoading ? l10n.verifyingCredentials : l10n.signIn,
              onPressed: _isLoading ? null : () => _handleLogin(l10n),
              disabled: _isLoading,
            ),
          ] else ...[
            // Email/password services (Feedbin)
            _buildFieldLabel(l10n.email, theme),
            ReederTextField(
              controller: _usernameController,
              placeholder: l10n.email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() => _usernameError = null),
            ),
            if (_usernameError != null)
              _buildFieldError(_usernameError!, theme),
            const SizedBox(height: AppDimensions.spacingM),

            _buildFieldLabel(l10n.password, theme),
            ReederTextField(
              controller: _passwordController,
              placeholder: l10n.password,
              onChanged: (_) => setState(() => _passwordError = null),
            ),
            if (_passwordError != null)
              _buildFieldError(_passwordError!, theme),
            const SizedBox(height: AppDimensions.spacingXL),

            if (_successMessage != null) ...[
              _buildSuccessMessage(_successMessage!, theme),
              const SizedBox(height: AppDimensions.spacingM),
            ],
            if (_errorMessage != null) ...[
              _buildFieldError(_errorMessage!, theme),
              const SizedBox(height: AppDimensions.spacingM),
            ],
            ReederButton.filled(
              label: _isLoading ? l10n.verifyingCredentials : l10n.signIn,
              onPressed: _isLoading ? null : () => _handleLogin(l10n),
              disabled: _isLoading,
            ),
          ],

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

  Widget _buildSuccessMessage(String message, ReederThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingXS),
      child: Text(
        message,
        style: theme.typography.caption.copyWith(
          color: theme.accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
