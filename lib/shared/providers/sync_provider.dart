import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../data/repositories/sync_repository.dart';
import '../../data/services/auth/auth_service.dart';
import '../../data/services/sync/feedbin_sync_service.dart';
import '../../data/services/sync/feedly_sync_service.dart';
import '../../data/services/sync/freshrss_sync_service.dart';
import '../../data/services/sync/inoreader_sync_service.dart';
import '../../data/services/sync/reader_sync_service.dart';
import '../../data/services/sync/sync_models.dart';
import '../../data/services/sync/sync_service_registry.dart';

/// Provider for the [SyncRepository] singleton.
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository();
});

/// Provider for the [AuthService] singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for the [SyncServiceRegistry] singleton.
///
/// Registers all available sync service factories so that
/// [SyncAccountsNotifier] can authenticate against them.
final syncServiceRegistryProvider = Provider<SyncServiceRegistry>((ref) {
  final registry = SyncServiceRegistry();
  registry.registerFactory(SyncServiceType.feedbin, FeedbinSyncService.new);
  registry.registerFactory(SyncServiceType.feedly, FeedlySyncService.new);
  registry.registerFactory(SyncServiceType.inoreader, InoreaderSyncService.new);
  registry.registerFactory(SyncServiceType.freshRss, FreshRssSyncService.new);
  registry.registerFactory(SyncServiceType.reader, ReaderSyncService.new);
  return registry;
});

/// Provider for all sync accounts.
final syncAccountsProvider = StateNotifierProvider<SyncAccountsNotifier, AsyncValue<List<SyncAccountInfo>>>(
  (ref) => SyncAccountsNotifier(ref),
);

/// Provider for the currently active sync account.
final activeSyncAccountProvider = FutureProvider<SyncAccountInfo?>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  return repo.getActiveAccount();
});

/// Provider for available sync services metadata.
final availableSyncServicesProvider = Provider<List<SyncServiceInfo>>((ref) {
  final registry = ref.watch(syncServiceRegistryProvider);
  return registry.availableServices;
});

/// Provider for sync status stream.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  // Returns idle status until sync engine is initialized
  return Stream.value(SyncStatus.idle);
});

/// Notifier that manages sync accounts state.
class SyncAccountsNotifier extends StateNotifier<AsyncValue<List<SyncAccountInfo>>> {
  static const _log = AppLogger('Sync');

  final Ref _ref;
  late final SyncRepository _repository;
  late final AuthService _authService;

  SyncAccountsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _repository = _ref.read(syncRepositoryProvider);
    _authService = _ref.read(authServiceProvider);
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _repository.getAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Adds a new sync account with credentials.
  ///
  /// Validates credentials by calling [SyncService.authenticate] before
  /// persisting. If authentication fails, the account and credentials
  /// are cleaned up and an exception is thrown.
  Future<void> addAccount(
    SyncServiceType serviceType,
    SyncCredentials credentials, {
    String? serverUrl,
    String? username,
  }) async {
    _log.info('addAccount: starting for ${serviceType.displayName} (user: $username)');
    int? accountId;
    bool accountCleaned = false;
    try {
      accountId = await _repository.addAccount(
        serviceType,
        serverUrl: serverUrl,
        username: username,
      );
      _log.info('addAccount: account created with id=$accountId');

      await _authService.saveCredentials(accountId, credentials);
      _log.info('addAccount: credentials saved for account $accountId');

      // Verify credentials against the remote service
      final registry = _ref.read(syncServiceRegistryProvider);
      final syncService = registry.getService(serviceType);
      if (syncService != null) {
        _log.info('addAccount: authenticating with ${serviceType.displayName}…');
        final authenticated = await syncService.authenticate(credentials);
        if (!authenticated) {
          _log.warning('addAccount: authentication failed for account $accountId, cleaning up');
          await _repository.removeAccount(accountId);
          accountCleaned = true;
          throw Exception('Authentication failed. Please check your credentials.');
        }
        _log.info('addAccount: authentication succeeded for account $accountId');
      } else {
        _log.warning('addAccount: no SyncService registered for ${serviceType.displayName}, skipping verification');
      }

      await _repository.setActiveAccount(accountId);
      _log.info('addAccount: account $accountId set as active');
      await _loadAccounts();
    } catch (e, st) {
      _log.error('addAccount: failed for ${serviceType.displayName}', error: e, stackTrace: st);
      if (accountId != null && !accountCleaned) {
        try {
          await _repository.removeAccount(accountId);
          _log.info('addAccount: cleaned up partial account $accountId');
        } catch (cleanupError) {
          _log.error('addAccount: cleanup failed for account $accountId', error: cleanupError);
        }
      }
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates an existing sync account's credentials and details.
  ///
  /// Validates the new credentials by calling [SyncService.authenticate]
  /// before persisting. If authentication fails, the previous credentials
  /// are restored and an exception is thrown.
  Future<void> updateAccount(
    int accountId,
    SyncCredentials credentials, {
    String? serverUrl,
    String? username,
  }) async {
    _log.info('updateAccount: starting for account $accountId (user: $username)');

    // Backup existing credentials for rollback on failure
    final previousCredentials = await _authService.getCredentials(accountId);
    final previousAccount = await _repository.getAccountById(accountId);
    _log.info('updateAccount: backed up previous credentials for account $accountId');

    try {
      await _repository.updateAccount(
        accountId,
        serverUrl: serverUrl,
        username: username,
      );
      _log.info('updateAccount: account details updated for account $accountId');

      await _authService.saveCredentials(accountId, credentials);
      _log.info('updateAccount: new credentials saved for account $accountId');

      // Verify new credentials against the remote service
      final registry = _ref.read(syncServiceRegistryProvider);
      final syncService = registry.getService(credentials.serviceType);
      if (syncService != null) {
        _log.info('updateAccount: authenticating with ${credentials.serviceType.displayName}…');
        final authenticated = await syncService.authenticate(credentials);
        if (!authenticated) {
          _log.warning('updateAccount: authentication failed for account $accountId, rolling back');
          // Rollback to previous credentials
          if (previousCredentials != null) {
            await _authService.saveCredentials(accountId, previousCredentials);
          }
          if (previousAccount != null) {
            await _repository.updateAccount(
              accountId,
              serverUrl: previousAccount.serverUrl,
              username: previousAccount.username,
            );
          }
          _log.info('updateAccount: rollback completed for account $accountId');
          throw Exception('Authentication failed. Please check your credentials.');
        }
        _log.info('updateAccount: authentication succeeded for account $accountId');
      } else {
        _log.warning('updateAccount: no SyncService registered for ${credentials.serviceType.displayName}, skipping verification');
      }

      await _loadAccounts();
      _log.info('updateAccount: completed successfully for account $accountId');
    } catch (e, st) {
      _log.error('updateAccount: failed for account $accountId', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Removes a sync account.
  Future<void> removeAccount(int accountId) async {
    try {
      await _repository.removeAccount(accountId);
      await _loadAccounts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sets an account as active.
  Future<void> setActiveAccount(int accountId) async {
    try {
      await _repository.setActiveAccount(accountId);
      await _loadAccounts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refreshes the accounts list.
  Future<void> refreshAccounts() => _loadAccounts();
}
