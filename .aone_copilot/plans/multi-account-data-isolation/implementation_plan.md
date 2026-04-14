### multi-account-data-isolation ###
为 Reeder 应用实现完整的多账户数据隔离、账户切换、以及将 SyncService 定义的所有远程 API 方法完整集成到 UI 界面中：包括数据库添加 accountId 实现数据隔离、远程同步数据落库、所有本地操作双向同步到远程、UI 补齐缺失的交互功能（重命名 Feed、标记未读、手动同步等）、账户切换后数据重新加载和 UI 刷新。

# 多账户数据隔离与 SyncService API 全面集成

## 背景

当前项目存在三大核心问题：

1. **数据未隔离**：`Feeds`、`FeedItems`、`Folders`、`Tags`、`TaggedItems`、`ScrollPositions`、`Filters` 等核心表没有 `accountId` 字段，所有账户共享同一份数据
2. **远程同步未落库**：`ReaderSyncService` 的 `fullSync`/`incrementalSync` 只获取远程数据但未写入本地数据库；本地操作（添加/删除/重命名 Feed、标记已读/加星等）未同步到远程
3. **UI 功能缺失**：`SyncService` 接口定义了 25+ 个方法，但大量方法未在 UI 中体现

### SyncService 方法 UI 集成现状

| 方法类别 | 方法 | UI 状态 |
|---------|------|---------|
| 认证 | `authenticate` | 已有登录页面 |
| 认证 | `logout` | 仅通过删除账户实现，缺独立登出 |
| 认证 | `validateCredentials` | 未使用 |
| 订阅管理 | `addFeed` | 仅本地，未同步远程 |
| 订阅管理 | `removeFeed` | 仅本地，未同步远程 |
| 订阅管理 | `renameFeed` | UI 完全缺失 |
| 订阅管理 | `moveFeed` | 仅本地，未同步远程 |
| 文件夹 | `createFolder` | 仅本地，未同步远程 |
| 文件夹 | `deleteFolder` | 仅本地，未同步远程 |
| 文件夹 | `renameFolder` | 仅本地，未同步远程 |
| 文章 | `getArticles` | 获取但未落库 |
| 文章 | `getUnreadArticleIds` | 未使用 |
| 文章 | `getStarredArticleIds` | 未使用 |
| 状态 | `markAsRead` | 仅本地，未同步远程 |
| 状态 | `markAsUnread` | UI 完全缺失 |
| 状态 | `markAsStarred` | 仅本地，未同步远程 |
| 状态 | `markAsUnstarred` | 仅本地，未同步远程 |
| 状态 | `markFeedAsRead` | 仅本地，未同步远程 |
| 同步 | `fullSync` | UI 完全缺失 |
| 同步 | `incrementalSync` | UI 完全缺失 |

## User Review Required

> [!IMPORTANT]
> 本方案采用"accountId 字段 + 查询过滤"策略实现数据隔离，而非"每个账户一个独立数据库文件"。这样可以保持单一数据库连接，减少复杂度，同时通过 accountId 过滤实现完全隔离。

> [!WARNING]
> 数据库 schema 升级（schemaVersion 2 -> 3）会为现有表添加 `accountId` 列。已有数据的 `accountId` 将设为 NULL（表示本地/未关联账户的数据）。

> [!IMPORTANT]
> 所有本地操作（添加/删除/重命名 Feed、创建/删除/重命名文件夹、标记已读/未读/加星/取消加星、全部标记已读）在有活跃同步账户时，都会同时推送到远程服务。采用"本地优先 + 异步推送"策略：先更新本地数据库保证 UI 响应速度，然后异步推送到远程（失败时加入离线队列）。

---

## Proposed Changes

### 数据库 Schema 升级

为核心表添加 `accountId` 字段，建立与 `SyncAccounts` 的关联。

#### [MODIFY] [feed.dart](file:///D:/git/reeder/lib/data/models/feed.dart)
- 在 `Feeds` 表中添加 `accountId` 可空整型字段

#### [MODIFY] [feed_item.dart](file:///D:/git/reeder/lib/data/models/feed_item.dart)
- 在 `FeedItems` 表中添加 `accountId` 可空整型字段

#### [MODIFY] [folder.dart](file:///D:/git/reeder/lib/data/models/folder.dart)
- 在 `Folders` 表中添加 `accountId` 可空整型字段
- 移除 `name` 字段的 `unique()` 约束（不同账户可以有同名文件夹）

#### [MODIFY] [tag.dart](file:///D:/git/reeder/lib/data/models/tag.dart)
- 在 `Tags` 表中添加 `accountId` 可空整型字段
- 在 `TaggedItems` 表中添加 `accountId` 可空整型字段
- 移除 `name` 字段的 `unique()` 约束

#### [MODIFY] [filter.dart](file:///D:/git/reeder/lib/data/models/filter.dart)
- 在 `Filters` 表中添加 `accountId` 可空整型字段
- 移除 `name` 字段的 `unique()` 约束

#### [MODIFY] [scroll_position.dart](file:///D:/git/reeder/lib/data/models/scroll_position.dart)
- 在 `ScrollPositions` 表中添加 `accountId` 可空整型字段
- 移除 `timelineId` 字段的 `unique()` 约束

#### [MODIFY] [app_database.dart](file:///D:/git/reeder/lib/core/database/app_database.dart)
- 将 `schemaVersion` 从 2 升级到 3
- 在 `onUpgrade` 中添加迁移逻辑：为所有核心表添加 `accountId` 列

---

### 数据源层 - 按账户过滤查询

#### [MODIFY] [feed_local_ds.dart](file:///D:/git/reeder/lib/data/datasources/local/feed_local_ds.dart)
- 所有查询方法添加可选 `accountId` 参数并按其过滤
- `upsert()`/`upsertAll()` 写入时携带 accountId
- `getByUrl()` 按 accountId 过滤（不同账户可订阅相同 URL）

#### [MODIFY] [article_local_ds.dart](file:///D:/git/reeder/lib/data/datasources/local/article_local_ds.dart)
- 所有查询方法添加可选 `accountId` 参数并按其过滤

#### [MODIFY] [sync_local_ds.dart](file:///D:/git/reeder/lib/data/datasources/local/sync_local_ds.dart)
- 添加 `clearAccountData(int accountId)` 方法：删除账户时清理所有关联的 feeds、feedItems、folders、tags、taggedItems、scrollPositions、filters

---

### Repository 层 - 传递账户上下文

#### [MODIFY] [feed_repository.dart](file:///D:/git/reeder/lib/data/repositories/feed_repository.dart)
- 所有方法添加可选 `accountId` 参数，透传给数据源层

#### [MODIFY] [article_repository.dart](file:///D:/git/reeder/lib/data/repositories/article_repository.dart)
- 所有方法添加可选 `accountId` 参数
- 添加 `markAsUnread(int articleId)` 方法（对应 SyncService.markAsUnread）

#### [MODIFY] [tag_repository.dart](file:///D:/git/reeder/lib/data/repositories/tag_repository.dart)
- 所有方法添加可选 `accountId` 参数
- `initializeBuiltInTags()` 按账户初始化

#### [MODIFY] [sync_repository.dart](file:///D:/git/reeder/lib/data/repositories/sync_repository.dart)
- `removeAccount` 中调用 `clearAccountData` 清理所有关联数据

---

### 同步服务层 - 远程同步数据落库 + 本地操作推送远程

#### [MODIFY] [reader_sync_service.dart](file:///D:/git/reeder/lib/data/services/sync/reader_sync_service.dart)
- 添加 `accountId` 属性，在 `authenticate` 时设置
- `fullSync()` 将远程 feeds/folders/articles 写入本地数据库并关联 accountId
- `incrementalSync()` 增量获取变更并更新本地数据库
- 同步时调用 `getUnreadArticleIds()` 和 `getStarredArticleIds()` 更新本地已读/加星状态

#### [MODIFY] [sync_engine.dart](file:///D:/git/reeder/lib/data/services/sync/sync_engine.dart)
- `sync()` 完成后触发 UI 刷新通知
- 添加 `syncAndNotify()` 方法，同步后通知 Provider 刷新

#### [NEW] [sync_bridge.dart](file:///D:/git/reeder/lib/data/services/sync/sync_bridge.dart)
- 创建同步桥接层：封装"本地操作 + 远程推送"的统一逻辑
- 方法包括：
  - `addFeedWithSync(feedUrl, accountId)` — 本地添加 + 远程 `addFeed`
  - `removeFeedWithSync(feedId, accountId)` — 本地删除 + 远程 `removeFeed`
  - `renameFeedWithSync(feedId, newTitle, accountId)` — 本地重命名 + 远程 `renameFeed`
  - `moveFeedWithSync(feedId, folderId, accountId)` — 本地移动 + 远程 `moveFeed`
  - `createFolderWithSync(name, accountId)` — 本地创建 + 远程 `createFolder`
  - `deleteFolderWithSync(folderId, accountId)` — 本地删除 + 远程 `deleteFolder`
  - `renameFolderWithSync(folderId, newName, accountId)` — 本地重命名 + 远程 `renameFolder`
  - `markAsReadWithSync(articleIds, accountId)` — 本地标记 + 远程 `markAsRead`
  - `markAsUnreadWithSync(articleIds, accountId)` — 本地标记 + 远程 `markAsUnread`
  - `markAsStarredWithSync(articleIds, accountId)` — 本地标记 + 远程 `markAsStarred`
  - `markAsUnstarredWithSync(articleIds, accountId)` — 本地标记 + 远程 `markAsUnstarred`
  - `markFeedAsReadWithSync(feedId, accountId)` — 本地标记 + 远程 `markFeedAsRead`
- 所有方法采用"本地优先"策略：先更新本地，再异步推送远程（失败加入离线队列）

---

### Provider 层 - 账户切换与数据刷新

#### [NEW] [account_provider.dart](file:///D:/git/reeder/lib/shared/providers/account_provider.dart)
- `activeAccountIdProvider`：提供当前活跃账户 ID
- `accountSwitchProvider`：账户切换状态，切换时使所有数据 Provider 失效并重新加载

#### [MODIFY] [sync_provider.dart](file:///D:/git/reeder/lib/shared/providers/sync_provider.dart)
- `setActiveAccount()` 切换后使 `sourceListControllerProvider`、`articleListControllerProvider` 等失效并触发重新加载
- `_syncRemoteFeeds()` 写入数据时携带 accountId
- 添加 `syncBridgeProvider` 提供 `SyncBridge` 实例
- `addAccount` 成功后触发 `fullSync` 将远程数据完整落库

---

### UI 层 - 补齐缺失功能 + 账户切换刷新

#### [MODIFY] [source_list_controller.dart](file:///D:/git/reeder/lib/features/source_list/source_list_controller.dart)
- `_loadData()` 按当前活跃账户 accountId 过滤数据
- 所有操作（addFeed/deleteFeed/moveFeedToFolder/createFolder/deleteFolder/renameFolder）通过 `SyncBridge` 执行，实现本地+远程双向同步
- 添加 `renameFeed(feedId, newTitle)` 方法（对应 SyncService.renameFeed）
- 添加 `triggerSync()` 方法：手动触发全量/增量同步
- 监听账户切换事件，自动重新加载数据

#### [MODIFY] [source_list_page.dart](file:///D:/git/reeder/lib/features/source_list/source_list_page.dart)
- 顶部导航栏显示当前账户信息（服务类型 + 用户名），点击可快速切换账户
- Feed 右键菜单添加"重命名"选项（对应 SyncService.renameFeed）
- 添加手动同步按钮（对应 SyncService.fullSync/incrementalSync）
- 下拉刷新时，如有活跃同步账户则触发 `incrementalSync`
- 添加"重命名 Feed"对话框

#### [MODIFY] [article_list_controller.dart](file:///D:/git/reeder/lib/features/article_list/article_list_controller.dart)
- `_loadItems()` 按当前活跃账户 accountId 过滤数据
- `markAllAsRead()` 通过 `SyncBridge` 执行，同步到远程
- `refresh()` 如有活跃同步账户则触发 `incrementalSync`
- 监听账户切换事件，自动重新加载数据

#### [MODIFY] [article_list_page.dart](file:///D:/git/reeder/lib/features/article_list/article_list_page.dart)
- 文章列表项滑动操作添加"标记未读"（对应 SyncService.markAsUnread）
- 文章列表项滑动操作添加"加星/取消加星"（对应 SyncService.markAsStarred/markAsUnstarred）

#### [MODIFY] [article_detail_controller.dart](file:///D:/git/reeder/lib/features/article_detail/article_detail_controller.dart)
- `markAsRead()` 通过 `SyncBridge` 执行，同步到远程
- `toggleStarred()` 通过 `SyncBridge` 执行，同步到远程
- 添加 `markAsUnread()` 方法，通过 `SyncBridge` 执行
- 添加 `validateAndRefreshAuth()` 在加载文章前校验凭据（对应 SyncService.validateCredentials）

#### [MODIFY] [article_detail_page.dart](file:///D:/git/reeder/lib/features/article_detail/article_detail_page.dart)
- 导航栏添加"标记未读"按钮（对应 SyncService.markAsUnread）

#### [MODIFY] [article_action_bar.dart](file:///D:/git/reeder/lib/features/article_detail/widgets/article_action_bar.dart)
- 添加"标记未读"操作按钮（对应 SyncService.markAsUnread）

#### [MODIFY] [timeline_control_button.dart](file:///D:/git/reeder/lib/features/article_list/widgets/timeline_control_button.dart)
- "Mark All as Read" 通过 `SyncBridge` 执行，同步到远程（对应 SyncService.markFeedAsRead）
- "Refresh" 如有活跃同步账户则触发 `incrementalSync`

#### [MODIFY] [accounts_page.dart](file:///D:/git/reeder/lib/features/settings/accounts_page.dart)
- 账户列表项添加"登出"按钮（对应 SyncService.logout，区别于删除账户）
- 账户列表项添加"立即同步"按钮（对应 SyncService.fullSync）
- 切换账户后显示加载状态，导航回源列表页面确保 UI 完全刷新
- 显示同步状态（idle/syncing/error）和上次同步时间

#### [MODIFY] [service_login_page.dart](file:///D:/git/reeder/lib/features/settings/service_login_page.dart)
- 登录成功后触发 `fullSync` 完整同步远程数据到本地
- 登录成功后触发全局数据刷新

---

### 代码生成

#### [REGENERATE] app_database.g.dart
- 运行 `dart run build_runner build` 重新生成 Drift 代码

---

## Verification Plan

### Automated Tests
- 运行 `dart run build_runner build` 确保 Drift 代码生成成功
- 运行 `flutter analyze` 确保无编译错误
- 运行 `flutter test` 确保现有测试通过

### Manual Verification
- 添加 Reader 账户后，验证远程 feeds/folders/articles 完整同步到本地并显示
- 在 UI 中添加/删除/重命名 Feed，验证操作同步到远程服务
- 在 UI 中创建/删除/重命名文件夹，验证操作同步到远程服务
- 在 UI 中标记已读/未读/加星/取消加星，验证状态同步到远程服务
- 在 UI 中全部标记已读，验证操作同步到远程服务
- 手动触发同步按钮，验证增量/全量同步正常工作
- 添加两个不同账户，验证数据完全隔离
- 切换账户后，验证源列表和文章列表立即刷新为新账户数据
- 删除账户后，验证关联数据被清理，其他账户数据不受影响
- 离线状态下操作，验证操作加入离线队列，恢复网络后自动同步


updateAtTime: 2026/4/14 12:27:28

planId: ab030d66-e38a-4783-820b-3fc214aac0c7