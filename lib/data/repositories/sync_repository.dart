import 'package:drift/drift.dart';

import '../datasources/local/sync_local_ds.dart';
import '../services/auth/auth_service.dart';
import '../services/sync/sync_models.dart';
import '../../core/database/app_database.dart';

/// Repository for managing sync accounts and sync state.
///
/// Provides a clean API for the presentation layer to interact with
/// sync account data. Coordinates between local data source and
/// secure credential storage.
class SyncRepository {
  final SyncLocalDataSource _localDs;
  final AuthService _authService;

  SyncRepository({
    SyncLocalDataSource? localDs,
    AuthService? authService,
  })  : _localDs = localDs ?? SyncLocalDataSource(),
        _authService = authService ?? AuthService();

  /// Gets all sync accounts.
  ///
  /// Returns a list of [SyncAccountInfo] DTOs representing all accounts.
  Future<List<SyncAccountInfo>> getAccounts() async {
    final accounts = await _localDs.getAllAccounts();
    return accounts.map((account) => _toSyncAccountInfo(account)).toList();
  }

  /// Gets the currently active sync account.
  ///
  /// Returns `null` if no active account exists.
  Future<SyncAccountInfo?> getActiveAccount() async {
    final account = await _localDs.getActiveAccount();
    return account != null ? _toSyncAccountInfo(account) : null;
  }

  /// Adds a new sync account.
  ///
  /// Creates a new account entry in the database with the specified service type.
  /// Returns the assigned [accountId].
  ///
  /// Note: Credentials must be saved separately using [AuthService].
  Future<int> addAccount(
    SyncServiceType serviceType, {
    String? serverUrl,
    String? username,
  }) async {
    final companion = SyncAccountsCompanion.insert(
      serviceType: serviceType.index,
      serverUrl: Value(serverUrl),
      username: Value(username),
      isActive: const Value(false),
      createdAt: DateTime.now(),
    );
    return await _localDs.upsertAccount(companion);
  }

  /// Removes a sync account, its credentials, and all associated data.
  ///
  /// Deletes the account from the database, securely removes stored credentials,
  /// and clears all associated feeds, articles, folders, tags, etc.
  Future<void> removeAccount(int accountId) async {
    // Clear all associated data first
    await _localDs.clearAccountData(accountId);
    // Delete credentials
    await _authService.deleteCredentials(accountId);
    // Then delete account from database
    await _localDs.deleteAccount(accountId);
  }

  /// Sets an account as the active account.
  ///
  /// Deactivates all other accounts and activates the specified account.
  Future<void> setActiveAccount(int accountId) async {
    await _localDs.setActiveAccount(accountId);
  }

  /// Updates the last sync timestamp for an account.
  ///
  /// Called after a successful sync operation.
  Future<void> updateLastSyncAt(int accountId) async {
    final account = await _localDs.getAccountById(accountId);
    if (account != null) {
      await _localDs.upsertAccount(SyncAccountsCompanion(
        id: Value(account.id),
        serviceType: Value(account.serviceType),
        serverUrl: Value(account.serverUrl),
        username: Value(account.username),
        isActive: Value(account.isActive),
        lastSyncAt: Value(DateTime.now()),
        createdAt: Value(account.createdAt),
      ));
    }
  }

  /// Updates an existing sync account's details.
  ///
  /// Updates the server URL and username for the specified account.
  /// Credentials must be updated separately using [AuthService].
  Future<void> updateAccount(
    int accountId, {
    String? serverUrl,
    String? username,
  }) async {
    final existing = await _localDs.getAccountById(accountId);
    if (existing == null) {
      throw StateError('Account $accountId not found');
    }
    await _localDs.upsertAccount(SyncAccountsCompanion(
      id: Value(existing.id),
      serviceType: Value(existing.serviceType),
      serverUrl: Value(serverUrl),
      username: Value(username),
      isActive: Value(existing.isActive),
      lastSyncAt: Value(existing.lastSyncAt),
      createdAt: Value(existing.createdAt),
    ));
  }

  /// Gets a sync account by its ID.
  ///
  /// Returns `null` if no account exists with the given ID.
  Future<SyncAccountInfo?> getAccountById(int accountId) async {
    final account = await _localDs.getAccountById(accountId);
    return account != null ? _toSyncAccountInfo(account) : null;
  }

  /// Converts a database [SyncAccount] to a [SyncAccountInfo] DTO.
  SyncAccountInfo _toSyncAccountInfo(SyncAccount account) {
    return SyncAccountInfo(
      id: account.id,
      serviceType: SyncServiceType.values[account.serviceType],
      serverUrl: account.serverUrl,
      username: account.username,
      isActive: account.isActive,
      lastSyncAt: account.lastSyncAt,
      createdAt: account.createdAt,
    );
  }
}