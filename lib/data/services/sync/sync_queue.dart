import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../datasources/local/sync_local_ds.dart';
import 'sync_service.dart';

/// 离线操作类型枚举
enum SyncQueueAction {
  markRead,
  markUnread,
  star,
  unstar,
  addFeed,
  removeFeed,
}

/// 离线操作队列管理器
/// 用于在网络不可用时暂存用户的操作，待网络恢复后同步到远程服务
class SyncQueue {
  final SyncLocalDataSource _localDataSource;
  static const int _maxRetries = 3;

  SyncQueue(this._localDataSource);

  /// 将操作加入队列
  /// [accountId] 账户ID
  /// [action] 操作类型
  /// [itemIds] 操作项ID列表
  Future<void> enqueue(
    int accountId,
    SyncQueueAction action,
    List<String> itemIds,
  ) async {
    final itemIdsJson = jsonEncode(itemIds);
    final now = DateTime.now();

    await _localDataSource.enqueueAction(
      SyncQueueItemsCompanion.insert(
        accountId: accountId,
        action: action.name,
        itemIds: itemIdsJson,
        createdAt: now,
        retryCount: const Value(0),
      ),
    );
  }

  /// 处理队列中的所有操作
  /// [accountId] 账户ID
  /// [syncService] 同步服务实例
  /// 按创建时间顺序处理，成功后删除，失败时增加重试次数，超过最大重试次数则丢弃
  Future<void> processQueue(int accountId, SyncService syncService) async {
    while (true) {
      final queueItem = await _localDataSource.dequeueAction(accountId);
      if (queueItem == null) {
        break;
      }

      try {
        final action = SyncQueueAction.values.firstWhere(
          (e) => e.name == queueItem.action,
        );
        final itemIds = List<String>.from(jsonDecode(queueItem.itemIds));

        await _executeAction(syncService, action, itemIds);

        // 成功后删除队列项
        await _localDataSource.deleteQueueItem(queueItem.id);
      } catch (e) {
        // 失败时增加重试次数
        final newRetryCount = queueItem.retryCount + 1;
        if (newRetryCount >= _maxRetries) {
          // 超过最大重试次数，丢弃该队列项
          await _localDataSource.deleteQueueItem(queueItem.id);
        } else {
          // 增加重试次数
          await _localDataSource.incrementRetryCount(queueItem.id);
        }
      }
    }
  }

  /// 执行单个操作
  Future<void> _executeAction(
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
        // 添加 Feed 的逻辑由 syncEngine 处理
        break;
      case SyncQueueAction.removeFeed:
        for (final feedId in itemIds) {
          await syncService.markFeedAsRead(feedId);
        }
        break;
    }
  }

  /// 获取队列大小
  /// [accountId] 账户ID
  /// 返回队列中的操作数量
  Future<int> getQueueSize(int accountId) async {
    final queueItems = await _localDataSource.getAllQueueItems(accountId);
    return queueItems.length;
  }

  /// 清空队列
  /// [accountId] 账户ID
  Future<void> clearQueue(int accountId) async {
    await _localDataSource.deleteQueueItemsByAccountId(accountId);
  }
}
