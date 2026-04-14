import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/app_logger.dart';
import '../../datasources/local/sync_local_ds.dart';
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
  })  : _registry = registry,
        _localDataSource = localDataSource,
        _syncQueue = syncQueue,
        _connectivity = connectivity ?? Connectivity();

  /// 同步状态流
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  /// 当前同步状态
  SyncStatus get currentStatus => _currentStatus;

  /// 更新同步状态
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// 执行同步操作
  /// 1. 检查是否有活跃的同步服务
  /// 2. 获取活跃账户
  /// 3. 处理离线队列
  /// 4. 根据上次同步时间决定执行全量同步还是增量同步
  /// 5. 更新账户的同步时间
  Future<SyncResult> sync() async {
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
    _log.info('sync: starting for account $accountId (${activeService.serviceName})');

    _updateStatus(SyncStatus.syncing);

    try {
      // 处理离线队列
      _log.info('sync: processing offline queue for account $accountId');
      await _syncQueue.processQueue(accountId, activeService);

      final lastSyncAt = account.lastSyncAt;
      SyncResult result;

      if (lastSyncAt == null) {
        // 首次同步，执行全量同步
        _log.info('sync: performing full sync (first time) for account $accountId');
        result = await activeService.fullSync();
      } else {
        // 增量同步
        _log.info('sync: performing incremental sync since $lastSyncAt for account $accountId');
        result = await activeService.incrementalSync(since: lastSyncAt);
      }

      // 更新账户的同步时间
      await _localDataSource.upsertAccount(
        SyncAccountsCompanion(
          id: Value(accountId),
          lastSyncAt: Value(DateTime.now()),
        ),
      );

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

    _log.info('syncFeed: starting incremental sync for feed $feedId (account ${account.id})');
    _updateStatus(SyncStatus.syncing);

    try {
      // SyncService 没有按 feed 同步的 API，调用增量同步
      final result = await activeService.incrementalSync();
      
      // 更新账户的同步时间
      await _localDataSource.upsertAccount(
        SyncAccountsCompanion(
          id: Value(account.id),
          lastSyncAt: Value(DateTime.now()),
        ),
      );

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
  Future<void> pushStateChange(
    SyncQueueAction action,
    List<String> itemIds,
  ) async {
    final activeService = _registry.activeService;
    if (activeService == null) {
      _log.warning('pushStateChange: no active service, ignoring $action');
      return;
    }

    // 获取活跃账户
    final account = await _localDataSource.getActiveAccount();
    if (account == null) {
      _log.warning('pushStateChange: no active account, ignoring $action');
      return;
    }

    final accountId = account.id;

    // 检查网络状态
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      // 在线，直接调用远程服务
      _log.info('pushStateChange: executing $action for ${itemIds.length} items (online)');
      await _executeRemoteAction(activeService, action, itemIds);
      _log.info('pushStateChange: $action completed');
    } else {
      // 离线，加入队列
      _log.info('pushStateChange: offline, enqueuing $action for ${itemIds.length} items (account $accountId)');
      await _syncQueue.enqueue(accountId, action, itemIds);
      _updateStatus(SyncStatus.waitingForNetwork);
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
        // 添加 Feed 的逻辑由调用方处理
        break;
      case SyncQueueAction.removeFeed:
        for (final feedId in itemIds) {
          await syncService.markFeedAsRead(feedId);
        }
        break;
    }
  }

  /// 释放资源
  void dispose() {
    _statusController.close();
  }
}
