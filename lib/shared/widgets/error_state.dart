import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import 'reeder_button.dart';

/// A widget displayed when an error occurs loading content.
///
/// Shows an error icon, message, and a retry button.
class ErrorState extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Optional detailed error information.
  final String? details;

  /// Callback when the retry button is pressed.
  final VoidCallback? onRetry;

  /// The icon/emoji displayed above the message.
  final String icon;

  /// Label for the retry button.
  final String retryLabel;

  const ErrorState({
    super.key,
    this.message = 'Something went wrong',
    this.details,
    this.onRetry,
    this.icon = '⚠️',
    this.retryLabel = 'Try Again',
  });

  /// Creates an error state for network errors.
  const ErrorState.network({
    super.key,
    this.message = 'No internet connection',
    this.details = 'Check your connection and try again',
    this.onRetry,
    this.icon = '📡',
    this.retryLabel = 'Retry',
  });

  /// Creates an error state for feed loading errors.
  const ErrorState.feedLoad({
    super.key,
    this.message = 'Failed to load feed',
    this.details,
    this.onRetry,
    this.icon = '❌',
    this.retryLabel = 'Retry',
  });

  /// Creates an error state for parsing errors.
  const ErrorState.parse({
    super.key,
    this.message = 'Failed to parse content',
    this.details = 'The feed format may not be supported',
    this.onRetry,
    this.icon = '📄',
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Translate default English values to localized strings
    final displayMessage = message == 'Something went wrong' ? l10n.somethingWentWrong
        : message == 'No internet connection' ? l10n.noInternetConnection
        : message == 'Failed to load feed' ? l10n.failedToLoadFeed
        : message == 'Failed to parse content' ? l10n.failedToParseContent
        : message;

    final displayDetails = details == 'Check your connection and try again' ? l10n.checkYourConnection
        : details == 'The feed format may not be supported' ? l10n.feedFormatNotSupported
        : details;

    final displayRetryLabel = retryLabel == 'Try Again' ? l10n.tryAgain
        : retryLabel == 'Retry' ? l10n.retry
        : retryLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: AppDimensions.spacing),

            // Error message
            Text(
              displayMessage,
              style: theme.typography.listTitle.copyWith(
                color: theme.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Error details
            if (displayDetails != null) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                displayDetails,
                style: theme.typography.summary.copyWith(
                  color: theme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXL),
              ReederButton.filled(
                label: displayRetryLabel,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
