import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/dio_client.dart';
import '../sync/sync_models.dart';

/// OAuth 2.0 authorization flow handler.
///
/// Manages the OAuth Authorization Code Grant flow for services
/// that require it (Feedly, Inoreader). Handles:
/// - Authorization URL generation
/// - Token exchange (authorization code → access token)
/// - Token refresh (refresh token → new access token)
///
/// Each service provides its own OAuth configuration via [OAuthConfig].
class OAuthHandler {
  final DioClient _client;

  OAuthHandler({DioClient? client}) : _client = client ?? DioClient.instance;

  /// Initiates the OAuth authorization flow by opening the authorization
  /// URL in the system browser.
  ///
  /// Returns the authorization URL that was opened.
  Future<Uri> startAuthorization(OAuthConfig config) async {
    final uri = Uri.parse(config.authorizationEndpoint).replace(
      queryParameters: {
        'client_id': config.clientId,
        'redirect_uri': config.redirectUri,
        'response_type': 'code',
        'scope': config.scopes.join(' '),
        if (config.additionalParams != null) ...config.additionalParams!,
      },
    );

    developer.log(
      'Starting OAuth flow for ${config.serviceName}',
      name: 'Reeder.OAuth',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch authorization URL: $uri');
    }

    return uri;
  }

  /// Exchanges an authorization code for access and refresh tokens.
  ///
  /// Called after the user completes authorization in the browser
  /// and is redirected back to the app with an authorization code.
  Future<OAuthTokenResult> exchangeCode(
    OAuthConfig config,
    String authorizationCode,
  ) async {
    developer.log(
      'Exchanging authorization code for ${config.serviceName}',
      name: 'Reeder.OAuth',
    );

    try {
      final response = await _client.post<Map<String, dynamic>>(
        config.tokenEndpoint,
        data: {
          'grant_type': 'authorization_code',
          'code': authorizationCode,
          'client_id': config.clientId,
          'client_secret': config.clientSecret,
          'redirect_uri': config.redirectUri,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      return _parseTokenResponse(response.data!);
    } on DioException catch (e) {
      developer.log(
        'Token exchange failed for ${config.serviceName}: ${e.message}',
        name: 'Reeder.OAuth',
        level: 1000,
      );
      throw OAuthException(
        'Failed to exchange authorization code: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Refreshes an expired access token using a refresh token.
  ///
  /// Returns new tokens. The refresh token may or may not be rotated
  /// depending on the service.
  Future<OAuthTokenResult> refreshToken(
    OAuthConfig config,
    String refreshToken,
  ) async {
    developer.log(
      'Refreshing token for ${config.serviceName}',
      name: 'Reeder.OAuth',
    );

    try {
      final response = await _client.post<Map<String, dynamic>>(
        config.tokenEndpoint,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': config.clientId,
          'client_secret': config.clientSecret,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final result = _parseTokenResponse(response.data!);

      // If the service doesn't return a new refresh token, keep the old one
      return OAuthTokenResult(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken ?? refreshToken,
        expiresAt: result.expiresAt,
        tokenType: result.tokenType,
      );
    } on DioException catch (e) {
      developer.log(
        'Token refresh failed for ${config.serviceName}: ${e.message}',
        name: 'Reeder.OAuth',
        level: 1000,
      );
      throw OAuthException(
        'Failed to refresh token: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Parses a token response from the OAuth server.
  OAuthTokenResult _parseTokenResponse(Map<String, dynamic> data) {
    final accessToken = data['access_token'] as String?;
    if (accessToken == null) {
      throw OAuthException('No access_token in response');
    }

    final expiresIn = data['expires_in'] as int?;
    final expiresAt = expiresIn != null
        ? DateTime.now().add(Duration(seconds: expiresIn))
        : null;

    return OAuthTokenResult(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String?,
      expiresAt: expiresAt,
      tokenType: data['token_type'] as String? ?? 'Bearer',
    );
  }
}

/// OAuth 2.0 configuration for a specific service.
class OAuthConfig {
  /// Service name for logging.
  final String serviceName;

  /// OAuth client ID.
  final String clientId;

  /// OAuth client secret.
  final String clientSecret;

  /// Authorization endpoint URL.
  final String authorizationEndpoint;

  /// Token endpoint URL.
  final String tokenEndpoint;

  /// Redirect URI registered with the service.
  final String redirectUri;

  /// OAuth scopes to request.
  final List<String> scopes;

  /// Additional query parameters for the authorization request.
  final Map<String, String>? additionalParams;

  const OAuthConfig({
    required this.serviceName,
    required this.clientId,
    required this.clientSecret,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.redirectUri,
    this.scopes = const [],
    this.additionalParams,
  });

  /// Feedly OAuth configuration.
  static OAuthConfig feedly({
    required String clientId,
    required String clientSecret,
  }) {
    return OAuthConfig(
      serviceName: 'Feedly',
      clientId: clientId,
      clientSecret: clientSecret,
      authorizationEndpoint: 'https://cloud.feedly.com/v3/auth/auth',
      tokenEndpoint: 'https://cloud.feedly.com/v3/auth/token',
      redirectUri: 'reeder://oauth/feedly',
      scopes: ['https://cloud.feedly.com/subscriptions'],
    );
  }

  /// Inoreader OAuth configuration.
  static OAuthConfig inoreader({
    required String clientId,
    required String clientSecret,
  }) {
    return OAuthConfig(
      serviceName: 'Inoreader',
      clientId: clientId,
      clientSecret: clientSecret,
      authorizationEndpoint: 'https://www.inoreader.com/oauth2/auth',
      tokenEndpoint: 'https://www.inoreader.com/oauth2/token',
      redirectUri: 'reeder://oauth/inoreader',
      scopes: ['read', 'write'],
    );
  }
}

/// Result of an OAuth token exchange or refresh.
class OAuthTokenResult {
  /// The access token.
  final String accessToken;

  /// The refresh token (may be null if not provided).
  final String? refreshToken;

  /// When the access token expires.
  final DateTime? expiresAt;

  /// Token type (usually "Bearer").
  final String tokenType;

  const OAuthTokenResult({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// Converts to [SyncCredentials] for storage.
  SyncCredentials toCredentials(SyncServiceType serviceType) {
    return SyncCredentials(
      serviceType: serviceType,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenExpiresAt: expiresAt,
    );
  }
}

/// Exception thrown during OAuth operations.
class OAuthException implements Exception {
  final String message;
  final int? statusCode;

  const OAuthException(this.message, {this.statusCode});

  @override
  String toString() => 'OAuthException: $message (status: $statusCode)';
}
