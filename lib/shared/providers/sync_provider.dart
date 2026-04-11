import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/sync_repository.dart';
import '../../data/services/auth/auth_service.dart';
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
final syncServiceRegistryProvider = Provider<SyncServiceRegistry>((ref) {
  return SyncServiceRegistry();
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
  Future<void> addAccount(
    SyncServiceType serviceType,
    SyncCredentials credentials, {
    String? serverUrl,
    String? username,
  }) async {
    try {
      final accountId = await _repository.addAccount(
        serviceType,
        serverUrl: serverUrl,
        username: username,
      );
      await _authService.saveCredentials(accountId, credentials);
      await _repository.setActiveAccount(accountId);
      await _loadAccounts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates an existing sync account's credentials and details.
  Future<void> updateAccount(
    int accountId,
    SyncCredentials credentials, {
    String? serverUrl,
    String? username,
  }) async {
    try {
      await _repository.updateAccount(
        accountId,
        serverUrl: serverUrl,
        username: username,
      );
      await _authService.saveCredentials(accountId, credentials);
      await _loadAccounts();
    } catch (e, st) {
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
