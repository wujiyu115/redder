### multi-account-data-isolation ###
# 多账户数据隔离与 SyncService API 全面集成 - 任务清单

## Phase 1: 数据库 Schema 升级（添加 accountId）

- [x] 1.1 修改 `lib/data/models/feed.dart`：Feeds 表添加 `accountId` 可空整型字段
- [x] 1.2 修改 `lib/data/models/feed_item.dart`：FeedItems 表添加 `accountId` 可空整型字段
- [x] 1.3 修改 `lib/data/models/folder.dart`：Folders 表添加 `accountId` 可空整型字段，移除 name 的 unique 约束
- [x] 1.4 修改 `lib/data/models/tag.dart`：Tags 表添加 `accountId`，TaggedItems 表添加 `accountId`，移除 name 的 unique 约束
- [x] 1.5 修改 `lib/data/models/filter.dart`：Filters 表添加 `accountId`，移除 name 的 unique 约束
- [x] 1.6 修改 `lib/data/models/scroll_position.dart`：ScrollPositions 表添加 `accountId`，移除 timelineId 的 unique 约束
- [x] 1.7 修改 `lib/core/database/app_database.dart`：schemaVersion 升到 3，添加迁移逻辑
- [x] 1.8 运行 `dart run build_runner build` 重新生成 Drift 代码

## Phase 2: 数据源层 - 按账户过滤

- [x] 2.1 修改 `lib/data/datasources/local/feed_local_ds.dart`：所有查询/写入方法添加 accountId 支持
- [x] 2.2 修改 `lib/data/datasources/local/article_local_ds.dart`：所有查询/写入方法添加 accountId 支持
- [x] 2.3 修改 `lib/data/datasources/local/sync_local_ds.dart`：添加 clearAccountData 方法

## Phase 3: Repository 层 - 传递账户上下文

- [x] 3.1 修改 `lib/data/repositories/feed_repository.dart`：所有方法添加可选 accountId 参数
- [x] 3.2 修改 `lib/data/repositories/article_repository.dart`：添加 accountId 参数 + markAsUnread 方法
- [x] 3.3 修改 `lib/data/repositories/tag_repository.dart`：所有方法添加可选 accountId 参数
- [x] 3.4 修改 `lib/data/repositories/sync_repository.dart`：removeAccount 中调用 clearAccountData

## Phase 4: 同步桥接层 - 本地操作双向同步

- [x] 4.1 创建 `lib/data/services/sync/sync_bridge.dart`：封装所有"本地操作 + 远程推送"的统一逻辑
  - addFeedWithSync, removeFeedWithSync, renameFeedWithSync, moveFeedWithSync
  - createFolderWithSync, deleteFolderWithSync, renameFolderWithSync
  - markAsReadWithSync, markAsUnreadWithSync, markAsStarredWithSync, markAsUnstarredWithSync
  - markFeedAsReadWithSync

## Phase 5: 同步服务层 - 远程数据落库

- [x] 5.1 修改 `lib/data/services/sync/reader_sync_service.dart`：fullSync/incrementalSync 将远程数据写入本地数据库
  - 同步 feeds/folders/articles 并关联 accountId
  - 调用 getUnreadArticleIds/getStarredArticleIds 更新本地状态
- [x] 5.2 修改 `lib/data/services/sync/sync_engine.dart`：sync 完成后触发 UI 刷新通知

## Phase 6: Provider 层 - 账户切换与刷新

- [x] 6.1 创建 `lib/shared/providers/account_provider.dart`：activeAccountIdProvider + 账户切换通知
- [x] 6.2 修改 `lib/shared/providers/sync_provider.dart`：
  - setActiveAccount 后触发全局刷新
  - _syncRemoteFeeds 携带 accountId
  - 添加 syncBridgeProvider
  - addAccount 成功后触发 fullSync

## Phase 7: UI 层 - SourceList 集成远程同步

- [x] 7.1 修改 `lib/features/source_list/source_list_controller.dart`：
  - _loadData 按 accountId 过滤
  - 所有操作通过 SyncBridge 执行
  - 添加 renameFeed 方法
  - 添加 triggerSync 方法
- [x] 7.2 修改 `lib/features/source_list/source_list_page.dart`：
  - 顶部显示当前账户信息 + 快速切换
  - Feed 右键菜单添加"重命名"
  - 添加手动同步按钮
  - 添加"重命名 Feed"对话框

## Phase 8: UI 层 - ArticleList 集成远程同步

- [x] 8.1 修改 `lib/features/article_list/article_list_controller.dart`：
  - _loadItems 按 accountId 过滤
  - markAllAsRead 通过 SyncBridge 执行
  - refresh 触发 incrementalSync
- [x] 8.2 修改 `lib/features/article_list/article_list_page.dart`：
  - 滑动操作添加"标记未读"和"加星/取消加星"
- [x] 8.3 修改 `lib/features/article_list/widgets/timeline_control_button.dart`：
  - Mark All as Read 通过 SyncBridge 同步远程
  - Refresh 触发 incrementalSync

## Phase 9: UI 层 - ArticleDetail 集成远程同步

- [x] 9.1 修改 `lib/features/article_detail/article_detail_controller.dart`：
  - markAsRead/toggleStarred 通过 SyncBridge 执行
  - 添加 markAsUnread 方法
- [x] 9.2 修改 `lib/features/article_detail/article_detail_page.dart`：
  - 导航栏添加"标记未读"按钮
- [x] 9.3 修改 `lib/features/article_detail/widgets/article_action_bar.dart`：
  - 添加"标记未读"操作按钮

## Phase 10: UI 层 - 账户管理页面增强

- [x] 10.1 修改 `lib/features/settings/accounts_page.dart`：
  - 添加"登出"按钮（区别于删除）
  - 添加"立即同步"按钮
  - 切换账户后导航回源列表并刷新
  - 显示同步状态
- [x] 10.2 修改 `lib/features/settings/service_login_page.dart`：
  - 登录成功后触发 fullSync
  - 登录成功后触发全局数据刷新

## Phase 11: 验证

- [x] 11.1 运行 `dart run build_runner build` 确保 Drift 代码生成成功
- [x] 11.2 运行 `flutter analyze` 确保无编译错误（0 error，仅 info/warning）
- [x] 11.3 运行 `flutter test` 确保现有测试通过（152/152 全部通过）
- [ ] 11.4 手动验证：远程数据同步落库、本地操作推送远程
- [ ] 11.5 手动验证：多账户数据隔离、切换刷新
- [ ] 11.6 手动验证：所有 SyncService 方法在 UI 中可触发


updateAtTime: 2026/4/14 12:27:28

planId: ab030d66-e38a-4783-820b-3fc214aac0c7