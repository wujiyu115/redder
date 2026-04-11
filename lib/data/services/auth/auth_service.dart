import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../sync/sync_models.dart';

/// Unified authentication service for managing sync service credentials.
///
/// Handles secure storage and retrieval of credentials for all supported
/// sync services. Uses platform Keychain (iOS) / Keystore (Android) via
/// [FlutterSecureStorage] for secure credential persistence.
///
/// Supports:
/// - Basic Auth (Feedbin, FreshRSS, Reader)
/// - OAuth 2.0 (Feedly, Inoreader)
class AuthService {
  static const String _keyPrefix = 'reeder_sync_';
  static const String _credentialsKeySuffix = '_credentials';

  final FlutterSecureStorage _secureStorage;

  AuthService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// Stores credentials for a sync service account.
  ///
  /// [accountId] is the local database ID of the sync account.
  Future<void> saveCredentials(int accountId, SyncCredentials credentials) async {
    final key = _credentialsKey(accountId);
    final json = _credentialsToJson(credentials);
    await _secureStorage.write(key: key, value: jsonEncode(json));
    developer.log(
      'Saved credentials for account $accountId (${credentials.serviceType.displayName})',
      name: 'Reeder.Auth',
    );
  }

  /// Retrieves credentials for a sync service account.
  ///
  /// Returns `null` if no credentials are stored for the given account.
  Future<SyncCredentials?> getCredentials(int accountId) async {
    final key = _credentialsKey(accountId);
    final value = await _secureStorage.read(key: key);
    if (value == null) return null;

    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return _credentialsFromJson(json);
    } catch (e) {
      developer.log(
        'Failed to parse credentials for account $accountId: $e',
        name: 'Reeder.Auth',
        level: 900,
      );
      return null;
    }
  }

  /// Deletes credentials for a sync service account.
  Future<void> deleteCredentials(int accountId) async {
    final key = _credentialsKey(accountId);
    await _secureStorage.delete(key: key);
    developer.log(
      'Deleted credentials for account $accountId',
      name: 'Reeder.Auth',
    );
  }

  /// Updates OAuth tokens for an existing account.
  ///
  /// This is used when refreshing expired OAuth tokens.
  Future<void> updateTokens(
    int accountId, {
    required String accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) async {
    final existing = await getCredentials(accountId);
    if (existing == null) {
      throw StateError('No credentials found for account $accountId');
    }

    final updated = existing.copyWithTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenExpiresAt: tokenExpiresAt,
    );

    await saveCredentials(accountId, updated);
    developer.log(
      'Updated tokens for account $accountId',
      name: 'Reeder.Auth',
    );
  }

  /// Checks if credentials exist for a given account.
  Future<bool> hasCredentials(int accountId) async {
    final key = _credentialsKey(accountId);
    final value = await _secureStorage.read(key: key);
    return value != null;
  }

  /// Deletes all stored credentials (used during app reset).
  Future<void> deleteAllCredentials() async {
    final allKeys = await _secureStorage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith(_keyPrefix)) {
        await _secureStorage.delete(key: key);
      }
    }
    developer.log(
      'Deleted all sync credentials',
      name: 'Reeder.Auth',
    );
  }

  // ─── Private Helpers ────────────────────────────────────────────────

  String _credentialsKey(int accountId) =>
      '$_keyPrefix$accountId$_credentialsKeySuffix';

  Map<String, dynamic> _credentialsToJson(SyncCredentials credentials) {
    return {
      'serviceType': credentials.serviceType.index,
      'serverUrl': credentials.serverUrl,
      'username': credentials.username,
      'password': credentials.password,
      'accessToken': credentials.accessToken,
      'refreshToken': credentials.refreshToken,
      'tokenExpiresAt': credentials.tokenExpiresAt?.toIso8601String(),
    };
  }

  SyncCredentials _credentialsFromJson(Map<String, dynamic> json) {
    return SyncCredentials(
      serviceType: SyncServiceType.values[json['serviceType'] as int],
      serverUrl: json['serverUrl'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.parse(json['tokenExpiresAt'] as String)
          : null,
    );
  }
}
