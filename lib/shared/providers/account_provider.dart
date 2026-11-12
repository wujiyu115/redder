import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../data/datasources/local/sync_local_ds.dart';
import '../../data/services/sync/sync_models.dart';
import '../../features/source_list/source_list_controller.dart';
import 'sync_provider.dart';

/// Provider for the currently active account ID.
///
/// Returns `null` if no account is active (local-only mode).
/// This is the primary way for UI components to get the current account context.
final activeAccountIdProvider = FutureProvider<int?>((ref) async {
  // Watch syncAccountsProvider to auto-refresh when accounts change
  ref.watch(syncAccountsProvider);
  final repo = ref.watch(syncRepositoryProvider);
  final activeAccount = await repo.getActiveAccount();
  return activeAccount?.id;
});

/// Provider for the active account info (full details).
///
/// Returns `null` if no account is active.
final activeAccountInfoProvider = FutureProvider<SyncAccountInfo?>((ref) async {
  ref.watch(syncAccountsProvider);
  final repo = ref.watch(syncRepositoryProvider);
  return await repo.getActiveAccount();
});

/// Notifier for managing account switching.
///
/// When an account is switched, this invalidates all data providers
/// to force a reload with the new account's data.
class AccountSwitchNotifier extends StateNotifier<int?> {
  static const _log = AppLogger('AccountSwitch');

  final Ref _ref;

  AccountSwitchNotifier(this._ref) : super(null) {
    _initActiveAccount();
  }

  Future<void> _initActiveAccount() async {
    try {
      final repo = _ref.read(syncRepositoryProvider);
      final activeAccount = await repo.getActiveAccount();
      state = activeAccount?.id;
      _log.info('init: active account id=${state ?? 'none'}');
    } catch (e, st) {
      // Never leave the app in an unscoped state: a throw here used to keep
      // state at null forever (nothing retried), which made every timeline
      // show *all* accounts' articles.
      _log.error('init: failed to resolve active account',
          error: e, stackTrace: st);
    }
  }

  /// Resolves the active account id, falling back to the database.
  ///
  /// `accountSwitchProvider` starts as null and only flips once its first
  /// database read completes, so a read issued right after a cold start (or the
  /// read that *constructs* the notifier) returns null. Callers that scope a
  /// query by account used to consume that null and silently load every
  /// account's rows — the first page of a timeline was unscoped while later
  /// pages were scoped. Always resolve through here instead.
  Future<int?> resolve() async {
    final cached = state;
    if (cached != null) return cached;
    try {
      final active = await _ref.read(syncRepositoryProvider).getActiveAccount();
      if (active?.id != null && state == null) state = active!.id;
      return active?.id;
    } catch (e, st) {
      _log.error('resolve: failed to read active account',
          error: e, stackTrace: st);
      return null;
    }
  }

  /// Switches to a different account.
  ///
  /// Updates the active account in the database, then invalidates
  /// all data-dependent providers to trigger a full UI refresh.
  Future<void> switchAccount(int accountId) async {
    final repo = _ref.read(syncRepositoryProvider);
    await repo.setActiveAccount(accountId);
    state = accountId;

    // Invalidate all data providers to force reload with new account data
    _ref.invalidate(activeAccountIdProvider);
    _ref.invalidate(activeAccountInfoProvider);
    _ref.invalidate(activeSyncAccountProvider);
    _ref.invalidate(sourceListControllerProvider);
  }

  /// Clears the active account (switches to local-only mode).
  Future<void> clearActiveAccount() async {
    final syncLocalDs = SyncLocalDataSource();
    // Deactivate all accounts
    final accounts = await syncLocalDs.getAllAccounts();
    for (final account in accounts) {
      if (account.isActive) {
        await syncLocalDs.setActiveAccount(-1); // Deactivate all
        break;
      }
    }
    state = null;

    _ref.invalidate(activeAccountIdProvider);
    _ref.invalidate(activeAccountInfoProvider);
    _ref.invalidate(activeSyncAccountProvider);
    _ref.invalidate(sourceListControllerProvider);
  }
}

/// Provider for the account switch notifier.
final accountSwitchProvider =
    StateNotifierProvider<AccountSwitchNotifier, int?>((ref) {
  return AccountSwitchNotifier(ref);
});
