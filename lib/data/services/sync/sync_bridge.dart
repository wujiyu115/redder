import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/app_logger.dart';
import '../../datasources/local/sync_local_ds.dart';
import '../../repositories/feed_repository.dart';
import '../../repositories/article_repository.dart';
import 'sync_engine.dart';
import 'sync_models.dart';
import 'sync_queue.dart';
import 'sync_service.dart';
import 'sync_service_registry.dart';

/// Bridge layer that coordinates local database operations with remote sync.
///
/// All methods follow a "local-first + async remote push" strategy:
/// 1. Update local database immediately (for fast UI response)
/// 2. Asynchronously push the change to the remote service
/// 3. On failure, enqueue the operation for later retry
///
/// This ensures the UI is always responsive while maintaining eventual
/// consistency with the remote service.
class SyncBridge {
  static const _log = AppLogger('SyncBridge');

  final FeedRepository _feedRepo;
  final ArticleRepository _articleRepo;
  final SyncLocalDataSource _syncLocalDs;
  final SyncEngine _syncEngine;
  final SyncServiceRegistry _registry;
  final SyncQueue _syncQueue;

  SyncBridge({
    required FeedRepository feedRepo,
    required ArticleRepository articleRepo,
    required SyncLocalDataSource syncLocalDs,
    required SyncEngine syncEngine,
    required SyncServiceRegistry registry,
    required SyncQueue syncQueue,
  })  : _feedRepo = feedRepo,
        _articleRepo = articleRepo,
        _syncLocalDs = syncLocalDs,
        _syncEngine = syncEngine,
        _registry = registry,
        _syncQueue = syncQueue;

  /// Gets the active sync service, or null if none is active.
  SyncService? get _activeService => _registry.activeService;

  /// Gets the active account ID, or null if none is active.
  Future<int?> _getActiveAccountId() async {
    final account = await _syncLocalDs.getActiveAccount();
    return account?.id;
  }

  /// Gets the remote ID for a local entity.
  Future<String?> _getRemoteId(int accountId, String localType, int localId) {
    return _syncLocalDs.getRemoteId(accountId, localType, localId);
  }

  // ─── Feed Operations ──────────────────────────────────────

  /// Adds a feed locally and syncs to remote service.
  ///
  /// Returns the locally saved [Feed].
  Future<Feed> addFeedWithSync(String feedUrl, {int? accountId}) async {
    // 1. Add feed locally
    final feed = await _feedRepo.addFeed(feedUrl, accountId: accountId);

    // 2. Push to remote if active service exists
    final service = _activeService;
    final activeAccountId = accountId ?? await _getActiveAccountId();
    if (service != null && activeAccountId != null) {
      _pushRemoteAsync(() async {
        try {
          final syncFeed = await service.addFeed(feedUrl, title: feed.title);
          // Save remote ID mapping
          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: activeAccountId,
            localType: 'feed',
            localId: feed.id,
            remoteId: syncFeed.remoteId,
          ));
_log.info('addFeedWithSync: remote push succeeded for feed ${feed.id}');
        } catch (e) {
_log.warning('addFeedWithSync: remote push failed, enqueuing');
          await _syncQueue.enqueue(activeAccountId, SyncQueueAction.addFeed, [feedUrl]);
        }
      });
    }

    return feed;
  }

  /// Removes a feed locally and syncs to remote service.
  Future<void> removeFeedWithSync(int feedId, {int? accountId}) async {
    final service = _activeService;
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // Get remote ID before deleting locally
    String? remoteId;
    if (service != null && activeAccountId != null) {
      remoteId = await _getRemoteId(activeAccountId, 'feed', feedId);
    }

    // 1. Delete locally
    await _feedRepo.deleteFeed(feedId);

    // 2. Push to remote
    if (service != null && remoteId != null && activeAccountId != null) {
      _pushRemoteAsync(() async {
        try {
          await service.removeFeed(remoteId!);
_log.info('removeFeedWithSync: remote push succeeded for feed $feedId');
        } catch (e) {
          _log.warning('removeFeedWithSync: remote push failed, enqueuing');
          await _syncQueue.enqueue(activeAccountId, SyncQueueAction.removeFeed, [remoteId!]);
        }
      });
    }
  }

  /// Renames a feed locally and syncs to remote service.
  Future<void> renameFeedWithSync(int feedId, String newTitle, {int? accountId}) async {
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Rename locally
    await _feedRepo.renameFeed(feedId, newTitle, accountId: activeAccountId);

    // 2. Push to remote
    final service = _activeService;
    if (service != null && activeAccountId != null) {
      final remoteId = await _getRemoteId(activeAccountId, 'feed', feedId);
      if (remoteId != null) {
        _pushRemoteAsync(() async {
          try {
            await service.renameFeed(remoteId, newTitle);
            _log.info('renameFeedWithSync: remote push succeeded for feed $feedId');
          } catch (e) {
            _log.error('renameFeedWithSync: remote push failed', error: e);
          }
        });
      }
    }
  }

  /// Moves a feed to a folder locally and syncs to remote service.
  Future<void> moveFeedWithSync(int feedId, int? folderId, {int? accountId}) async {
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Move locally
    await _feedRepo.moveFeedToFolder(feedId, folderId, accountId: activeAccountId);

    // 2. Push to remote
    final service = _activeService;
    if (service != null && activeAccountId != null) {
      final feedRemoteId = await _getRemoteId(activeAccountId, 'feed', feedId);
      String? folderRemoteId;
      if (folderId != null) {
        folderRemoteId = await _getRemoteId(activeAccountId, 'folder', folderId);
      }
      if (feedRemoteId != null) {
        _pushRemoteAsync(() async {
          try {
            await service.moveFeed(feedRemoteId, folderRemoteId);
            _log.info('moveFeedWithSync: remote push succeeded for feed $feedId');
          } catch (e) {
            _log.error('moveFeedWithSync: remote push failed', error: e);
          }
        });
      }
    }
  }

  // ─── Folder Operations ────────────────────────────────────

  /// Creates a folder locally and syncs to remote service.
  ///
  /// Returns the locally created [Folder].
  Future<Folder> createFolderWithSync(String name, {int? accountId}) async {
    final db = AppDatabase.instance;
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Create locally
    final folderId = await db.into(db.folders).insert(
      FoldersCompanion.insert(
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).copyWith(accountId: Value(activeAccountId)),
    );
    final folder = await (db.select(db.folders)..where((t) => t.id.equals(folderId))).getSingle();

    // 2. Push to remote
    final service = _activeService;
    if (service != null && activeAccountId != null) {
      _pushRemoteAsync(() async {
        try {
          final syncFolder = await service.createFolder(name);
          await _syncLocalDs.upsertMapping(RemoteIdMappingsCompanion.insert(
            accountId: activeAccountId,
            localType: 'folder',
            localId: folderId,
            remoteId: syncFolder.remoteId,
          ));
_log.info('createFolderWithSync: remote push succeeded for folder $folderId');
        } catch (e) {
          _log.error('createFolderWithSync: remote push failed', error: e);
        }
      });
    }

    return folder;
  }

  /// Deletes a folder locally and syncs to remote service.
  Future<void> deleteFolderWithSync(int folderId, {int? accountId}) async {
    final db = AppDatabase.instance;
    final service = _activeService;
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // Get remote ID before deleting
    String? remoteId;
    if (service != null && activeAccountId != null) {
      remoteId = await _getRemoteId(activeAccountId, 'folder', folderId);
    }

    // 1. Delete locally
    await (db.delete(db.folders)..where((t) => t.id.equals(folderId))).go();

    // 2. Push to remote
    if (service != null && remoteId != null) {
      _pushRemoteAsync(() async {
        try {
          await service.deleteFolder(remoteId!);
_log.info('deleteFolderWithSync: remote push succeeded for folder $folderId');
        } catch (e) {
          _log.error('deleteFolderWithSync: remote push failed', error: e);
        }
      });
    }
  }

  /// Renames a folder locally and syncs to remote service.
  Future<void> renameFolderWithSync(int folderId, String newName, {int? accountId}) async {
    final db = AppDatabase.instance;
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Rename locally
    await (db.update(db.folders)..where((t) => t.id.equals(folderId))).write(
      FoldersCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // 2. Push to remote
    final service = _activeService;
    if (service != null && activeAccountId != null) {
      final remoteId = await _getRemoteId(activeAccountId, 'folder', folderId);
      if (remoteId != null) {
        _pushRemoteAsync(() async {
          try {
            await service.renameFolder(remoteId, newName);
            _log.info('renameFolderWithSync: remote push succeeded for folder $folderId');
          } catch (e) {
            _log.error('renameFolderWithSync: remote push failed', error: e);
          }
        });
      }
    }
  }

  // ─── Article State Operations ─────────────────────────────

  /// Marks articles as read locally and syncs to remote service.
  Future<void> markAsReadWithSync(List<int> articleIds, {int? accountId}) async {
    _log.info('markAsReadWithSync: marking ${articleIds.length} articles as read');
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Mark as read locally
    await _articleRepo.markMultipleAsRead(articleIds);

    // 2. Push to remote
    if (_activeService != null && activeAccountId != null) {
      final remoteIds = await _resolveRemoteIds(activeAccountId, 'article', articleIds);
      if (remoteIds.isNotEmpty) {
        await _syncEngine.pushStateChange(SyncQueueAction.markRead, remoteIds);
      }
    }
  }

  /// Marks articles as unread locally and syncs to remote service.
  Future<void> markAsUnreadWithSync(List<int> articleIds, {int? accountId}) async {
    _log.info('markAsUnreadWithSync: marking ${articleIds.length} articles as unread');
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Mark as unread locally
    await _articleRepo.markMultipleAsUnread(articleIds);

    // 2. Push to remote
    if (_activeService != null && activeAccountId != null) {
      final remoteIds = await _resolveRemoteIds(activeAccountId, 'article', articleIds);
      if (remoteIds.isNotEmpty) {
        await _syncEngine.pushStateChange(SyncQueueAction.markUnread, remoteIds);
      }
    }
  }

  /// Marks articles as starred locally and syncs to remote service.
  Future<void> markAsStarredWithSync(List<int> articleIds, {int? accountId}) async {
    _log.info('markAsStarredWithSync: marking ${articleIds.length} articles as starred');
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Mark as starred locally
    for (final id in articleIds) {
      await _articleRepo.markAsStarred(id);
    }

    // 2. Push to remote
    if (_activeService != null && activeAccountId != null) {
      final remoteIds = await _resolveRemoteIds(activeAccountId, 'article', articleIds);
      if (remoteIds.isNotEmpty) {
        await _syncEngine.pushStateChange(SyncQueueAction.star, remoteIds);
      }
    }
  }

  /// Marks articles as unstarred locally and syncs to remote service.
  Future<void> markAsUnstarredWithSync(List<int> articleIds, {int? accountId}) async {
    _log.info('markAsUnstarredWithSync: marking ${articleIds.length} articles as unstarred');
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Mark as unstarred locally
    for (final id in articleIds) {
      await _articleRepo.markAsUnstarred(id);
    }

    // 2. Push to remote
    if (_activeService != null && activeAccountId != null) {
      final remoteIds = await _resolveRemoteIds(activeAccountId, 'article', articleIds);
      if (remoteIds.isNotEmpty) {
        await _syncEngine.pushStateChange(SyncQueueAction.unstar, remoteIds);
      }
    }
  }

  /// Marks all articles in a feed as read locally and syncs to remote service.
  Future<void> markFeedAsReadWithSync(int feedId, {int? accountId}) async {
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Mark all as read locally
    await _articleRepo.markAllAsReadForFeed(feedId, accountId: activeAccountId);

    // 2. Push to remote
    final service = _activeService;
    if (service != null && activeAccountId != null) {
      final remoteId = await _getRemoteId(activeAccountId, 'feed', feedId);
      if (remoteId != null) {
        _pushRemoteAsync(() async {
          try {
            await service.markFeedAsRead(remoteId);
            _log.info('markFeedAsReadWithSync: remote push succeeded for feed $feedId');
          } catch (e) {
            _log.error('markFeedAsReadWithSync: remote push failed', error: e);
          }
        });
      }
    }
  }

  /// Marks all articles as read locally and syncs to remote service.
  Future<void> markAllAsReadWithSync({int? accountId}) async {
    final activeAccountId = accountId ?? await _getActiveAccountId();

    // 1. Mark all as read locally
    await _articleRepo.markAllAsRead(accountId: activeAccountId);

    // 2. For remote, we need to mark each feed as read
    // This is a best-effort operation
    final service = _activeService;
    if (service != null && activeAccountId != null) {
      _pushRemoteAsync(() async {
        try {
          final feeds = await _feedRepo.getAllFeeds(accountId: activeAccountId);
          for (final feed in feeds) {
            final remoteId = await _getRemoteId(activeAccountId, 'feed', feed.id);
            if (remoteId != null) {
              await service.markFeedAsRead(remoteId);
            }
          }
_log.info('markAllAsReadWithSync: remote push succeeded');
        } catch (e) {
          _log.error('markAllAsReadWithSync: remote push failed', error: e);
        }
      });
    }
  }

  // ─── Sync Trigger Operations ──────────────────────────────

  /// Triggers a full sync with the remote service.
  Future<SyncResult> triggerFullSync() async {
    _log.info('triggerFullSync: starting full sync');
    return await _syncEngine.sync();
  }

  /// Triggers an incremental sync with the remote service.
  ///
  /// Delegates to [SyncEngine.sync] which correctly handles authentication,
  /// accountId setup, offline queue processing, and sync timestamp updates.
  /// SyncEngine automatically chooses full vs incremental sync based on
  /// whether a previous sync timestamp exists.
  Future<SyncResult> triggerIncrementalSync() async {
    _log.info('triggerIncrementalSync: starting incremental sync');
    return await _syncEngine.sync();
  }

  // ─── Helper Methods ───────────────────────────────────────

  /// Resolves local IDs to remote IDs for a given entity type.
  Future<List<String>> _resolveRemoteIds(int accountId, String localType, List<int> localIds) async {
    final remoteIds = <String>[];
    for (final localId in localIds) {
      final remoteId = await _getRemoteId(accountId, localType, localId);
      if (remoteId != null) {
        remoteIds.add(remoteId);
      }
    }
    return remoteIds;
  }

  /// Executes a remote operation asynchronously without blocking the caller.
  ///
  /// Errors are logged but not propagated to the caller, since the local
  /// operation has already succeeded.
  void _pushRemoteAsync(Future<void> Function() operation) {
    Future.microtask(() async {
      try {
        await operation();
      } catch (e) {
_log.error('_pushRemoteAsync: unhandled error', error: e);
      }
    });
  }
}
