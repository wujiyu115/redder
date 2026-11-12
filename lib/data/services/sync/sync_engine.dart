import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/utils/app_logger.dart';
import '../../datasources/local/sync_local_ds.dart';
import '../auth/auth_service.dart';
import 'sync_models.dart';
import 'sync_queue.dart';
import 'sync_service.dart';
import 'sync_service_registry.dart';

/// 同步引擎
/// 协调本地数据库和远程服务之间的数据同步
class SyncEngine {
  static const _log = AppLogger('SyncEngine');

  final SyncServiceRegistry _registry;
  final SyncLocalDataSource _localDataSource;
  final SyncQueue _syncQueue;
  final Connectivity _connectivity;
  final AuthService _authService;

  /// Guards [ensureActiveService] against concurrent restores (startup sync and
  /// a pull-to-refresh can land at the same moment).
  Future<bool>? _ensuringActiveService;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;

  /// Callback invoked after a successful sync to notify the UI to refresh.
  /// Set by the Provider layer to trigger data reload.
  void Function()? onSyncCompleted;

  SyncEngine({
    required SyncServiceRegistry registry,
    required SyncLocalDataSource localDataSource,
    required SyncQueue syncQueue,
    Connectivity? connectivity,
    AuthService? authService,
  })  : _registry = registry,
        _localDataSource = localDataSource,
        _syncQueue = syncQueue,
        _connectivity = connectivity ?? Connectivity(),
        _authService = authService ?? AuthService();

  /// 同步状态流
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  /// 当前同步状态
  SyncStatus get currentStatus => _currentStatus;

  /// 更新同步状态
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Makes sure the active account's remote service is instantiated,
  /// bound to that account and authenticated.
  ///
  /// The registry only lives in memory, so after a cold start it is empty: the
  /// active account is loaded from the database on every launch, but the
  /// service backing it has to be restored here. Without this, every sync /
  /// remote push was a silent no-op after restarting the app.
  ///
  /// Returns `true` when a usable remote service is ready.
  Future<bool> ensureActiveService() {
    if (_registry.activeService != null) return Future.value(true);
    return _ensuringActiveService ??= _restoreActiveService()
        .whenComplete(() => _ensuringActiveService = null);
  }

  Future<bool> _restoreActiveService() async {
    try {
      final account = await _localDataSource.getActiveAccount();
      if (account == null) {
        _log.info('ensureActiveService: no active account (local-only mode)');
        return false;
      }

      if (account.serviceType < 0 ||
          account.serviceType >= SyncServiceType.values.length) {
        _log.warning(
            'ensureActiveService: unknown serviceType ${account.serviceType}');
        return false;
      }

      final type = SyncServiceType.values[account.serviceType];
      final service = _registry.getService(type);
      if (service == null) {
        _log.warning(
            'ensureActiveService: no service registered for ${type.displayName}');
        return false;
      }

      if (service case final AccountScopedSyncService bound) {
        bound.bindAccount(account.id);
      }

      if (!service.isAuthenticated) {
        final credentials = await _authService.getCredentials(account.id);
        if (credentials == null) {
          _log.warning(
              'ensureActiveService: no stored credentials for account ${account.id}');
          return false;
        }
        final authenticated = await service.authenticate(credentials);
        if (!authenticated) {
          _log.warning(
              'ensureActiveService: authentication failed for account ${account.id}');
          return false;
        }
      }

      _registry.setActiveService(type);
      _log.info(
          'ensureActiveService: restored ${type.displayName} for account ${account.id}');
      return true;
    } catch (e) {
      _log.error('ensureActiveService: failed', error: e);
      return false;
    }
  }

  /// 执行同步操作
  /// 1. 检查是否有活跃的同步服务
  /// 2. 获取活跃账户
  /// 3. 处理离线队列
  /// 4. 根据上次同步时间决定执行全量同步还是增量同步
  /// 5. 更新账户的同步时间
  Future<SyncResult> sync() async {
    // Restore the active account's service on demand (cold start).
    if (!await ensureActiveService()) {
      _log.warning('sync: no active service, skipping');
      return SyncResult.empty();
    }

    final activeService = _registry.activeService;
    if (activeService == null) {
      _log.warning('sync: no active service, skipping');
      return SyncResult.empty();
    }

    // 获取活跃账户
    final account = await _localDataSource.getActiveAccount();
    if (account == null) {
      _log.warning('sync: no active account, skipping');
      return SyncResult.empty();
    }

    final accountId = account.id;
    _log.info(
        'sync: starting for account $accountId (${activeService.serviceName})');

    _updateStatus(SyncStatus.syncing);

    try {
      // 处理离线队列
      _log.info('sync: processing offline queue for account $accountId');
      await _syncQueue.processQueue(accountId, activeService);

      final lastSyncAt = account.lastSyncAt;
      SyncResult result;

      if (lastSyncAt == null) {
        // 首次同步，执行全量同步
        _log.info(
            'sync: performing full sync (first time) for account $accountId');
        result = await activeService.fullSync();
      } else {
        // Overlap the window a little: the server's fetch/crawl time can trail
        // the client clock, and an item published earlier can be pulled by the
        // server after our last sync. Re-fetched items are deduped by URL.
        final since = lastSyncAt.subtract(const Duration(minutes: 10));
        _log.info(
            'sync: performing incremental sync since $since for account $accountId');
        result = await activeService.incrementalSync(since: since);
      }

      // Only advance the sync watermark when nothing failed: a failed run must
      // re-cover the same window on the next attempt instead of silently
      // skipping it.
      if (!result.hasErrors) {
        await _localDataSource.updateLastSyncAt(accountId, DateTime.now());
      } else {
        _log.warning(
          'sync: completed with errors for account $accountId, keeping lastSyncAt',
        );
      }

      _log.info('sync: completed for account $accountId — $result');
      _updateStatus(SyncStatus.idle);

      // Notify UI to refresh after successful sync
      if (result.hasChanges) {
        onSyncCompleted?.call();
      }

      return result;
    } catch (e) {
      _log.error('sync: failed for account $accountId', error: e);
      _updateStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// 同步单个 Feed
  /// [feedId] Feed ID
  Future<SyncResult> syncFeed(int feedId) async {
    if (!await ensureActiveService()) {
      _log.warning('syncFeed: no active service, skipping feed $feedId');
      return SyncResult.empty();
    }

    final activeService = _registry.activeService;
    if (activeService == null) {
      _log.warning('syncFeed: no active service, skipping feed $feedId');
      return SyncResult.empty();
    }

    // 获取活跃账户
    final account = await _localDataSource.getActiveAccount();
    if (account == null) {
      _log.warning('syncFeed: no active account, skipping feed $feedId');
      return SyncResult.empty();
    }

    _log.info(
        'syncFeed: starting incremental sync for feed $feedId (account ${account.id})');
    _updateStatus(SyncStatus.syncing);

    try {
      // SyncService 没有按 feed 同步的 API，调用增量同步
      final result = await activeService.incrementalSync();

      // 更新账户的同步时间（有错误时不推进，下次重新覆盖同一窗口）
      if (!result.hasErrors) {
        await _localDataSource.updateLastSyncAt(account.id, DateTime.now());
      }

      _log.info('syncFeed: completed for feed $feedId — $result');
      _updateStatus(SyncStatus.idle);

      // Notify UI to refresh after successful sync
      if (result.hasChanges) {
        onSyncCompleted?.call();
      }

      return result;
    } catch (e) {
      _log.error('syncFeed: failed for feed $feedId', error: e);
      _updateStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// 推送状态变更到远程服务
  /// [action] 操作类型
  /// [itemIds] 操作项 ID 列表
  ///
  /// 用户操作永不丢弃：离线、服务实例未恢复（冷启动 / 无网络导致登录失败）
  /// 或远程调用失败时，一律写入本地队列，等下次同步时补推。
  Future<void> pushStateChange(
    SyncQueueAction action,
    List<String> itemIds,
  ) async {
    if (itemIds.isEmpty) return;

    // 活跃账户是持久化的，服务实例只活在内存 —— 先取账户，取不到说明是
    // 纯本地模式，没有远端可推。
    final account = await _localDataSource.getActiveAccount();
    if (account == null) {
      _log.info(
          'pushStateChange: no active account (local mode), ignoring $action');
      return;
    }
    final accountId = account.id;

    Future<void> enqueue() async {
      _log.info(
        'pushStateChange: enqueuing $action for ${itemIds.length} items '
        '(account $accountId)',
      );
      await _syncQueue.enqueue(accountId, action, itemIds);
    }

    // 先判网络：离线时不要尝试重建服务（否则白等一次 HTTP 超时）
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);
    if (!isOnline) {
      await enqueue();
      _updateStatus(SyncStatus.waitingForNetwork);
      return;
    }

    // 在线但服务实例可能还没恢复（冷启动）：恢复失败也入队，绝不丢掉操作
    if (!await ensureActiveService()) {
      await enqueue();
      return;
    }

    final activeService = _registry.activeService;
    if (activeService == null) {
      await enqueue();
      return;
    }

    _log.info(
        'pushStateChange: executing $action for ${itemIds.length} items (online)');
    try {
      await _executeRemoteAction(activeService, action, itemIds);
      _log.info('pushStateChange: $action completed');
    } catch (e) {
      _log.warning(
          'pushStateChange: $action failed, enqueuing for retry (account $accountId)');
      await enqueue();
    }
  }

  /// 执行远程操作
  Future<void> _executeRemoteAction(
    SyncService syncService,
    SyncQueueAction action,
    List<String> itemIds,
  ) async {
    switch (action) {
      case SyncQueueAction.markRead:
        await syncService.markAsRead(itemIds);
        break;
      case SyncQueueAction.markUnread:
        await syncService.markAsUnread(itemIds);
        break;
      case SyncQueueAction.star:
        await syncService.markAsStarred(itemIds);
        break;
      case SyncQueueAction.unstar:
        await syncService.markAsUnstarred(itemIds);
        break;
      case SyncQueueAction.addFeed:
        for (final feedUrl in itemIds) {
          await syncService.addFeed(feedUrl);
        }
        break;
      case SyncQueueAction.removeFeed:
        for (final feedRemoteId in itemIds) {
          await syncService.removeFeed(feedRemoteId);
        }
        break;
      case SyncQueueAction.markFeedRead:
        for (final feedRemoteId in itemIds) {
          await syncService.markFeedAsRead(feedRemoteId);
        }
        break;
    }
  }

  /// 释放资源
  void dispose() {
    _statusController.close();
  }
}
