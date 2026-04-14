### 补全mocks测试用例 ###
补全 test_mocks.dart 中缺失的 mock 类定义，并为项目核心模块（Repository、Service、SyncBridge）编写全面的单元测试用例，提升测试覆盖率。


# 补全 Mocks 与测试用例

## 背景

当前项目 `test_mocks.dart` 仅注册了 7 个 mock 类（SyncServiceRegistry、SyncLocalDataSource、SyncQueue、SyncService、AuthService、FlutterSecureStorage、Connectivity），而项目中有大量核心类缺少 mock 和测试覆盖。

现有测试文件 9 个，共 152 个测试用例，主要覆盖：
- 工具类（DateFormatter、HtmlParser、BionicReading、OpmlParser）
- SyncRepository、AuthService、SyncEngine、SyncQueue
- SyncModels、SyncServiceRegistry、LocalSyncService
- UI 组件（ReederButton、ReederSwitch 等）
- App 烟雾测试

## User Review Required

> [!IMPORTANT]
> 部分 DataSource 类（ArticleLocalDataSource、FeedLocalDataSource、SettingsLocalDataSource）和 TagRepository 使用单例模式（依赖 `AppDatabase.instance`），无法直接被 `@GenerateMocks` 生成 mock。需要为这些类添加可选的构造函数参数以支持依赖注入，才能进行 mock 测试。

> [!WARNING]
> 本计划涉及修改 4 个生产代码文件的构造函数（添加可选参数，完全向后兼容），以及创建 8 个新测试文件。请确认是否同意对生产代码进行这些最小化的重构。

---

## Proposed Changes

### Phase 1: 重构单例类以支持依赖注入

为无法被 mock 的单例类添加可选的 `AppDatabase` 构造函数参数，使其在测试中可以注入内存数据库。这是完全向后兼容的修改。

#### [MODIFY] [article_local_ds.dart](file:///D:/git/reeder/lib/data/datasources/local/article_local_ds.dart)
- 添加可选构造函数参数 `AppDatabase? db`
- 内部使用 `_db = db ?? AppDatabase.instance` 替代直接访问 `AppDatabase.instance`

#### [MODIFY] [feed_local_ds.dart](file:///D:/git/reeder/lib/data/datasources/local/feed_local_ds.dart)
- 同上，添加可选 `AppDatabase? db` 参数

#### [MODIFY] [settings_local_ds.dart](file:///D:/git/reeder/lib/data/datasources/local/settings_local_ds.dart)
- 同上，添加可选 `AppDatabase? db` 参数

#### [MODIFY] [tag_repository.dart](file:///D:/git/reeder/lib/data/repositories/tag_repository.dart)
- 同上，添加可选 `AppDatabase? db` 参数

---

### Phase 2: 补全 test_mocks.dart

#### [MODIFY] [test_mocks.dart](file:///D:/git/reeder/test/test_mocks.dart)
新增以下 mock 类注册：

**Repository 层：**
- `FeedRepository`
- `ArticleRepository`
- `SettingsRepository`
- `TagRepository`（Phase 1 重构后可 mock）

**DataSource 层：**
- `ArticleLocalDataSource`（Phase 1 重构后可 mock）
- `FeedLocalDataSource`（Phase 1 重构后可 mock）
- `SettingsLocalDataSource`（Phase 1 重构后可 mock）
- `RssRemoteDataSource`

**Service 层：**
- `SyncBridge`
- `SyncEngine`
- `FeedRefreshService`
- `FeedDiscoveryService`
- `ScrollPositionService`
- `ReaderViewService`
- `PodcastService`

**网络层：**
- `DioClient`

运行 `dart run build_runner build` 重新生成 mock 代码。

---

### Phase 3: 补全 Repository 层测试

#### [NEW] [feed_repository_test.dart](file:///D:/git/reeder/test/data/repositories/feed_repository_test.dart)
测试 FeedRepository 的核心方法：
- `addFeed()` - 添加 Feed（成功、重复 URL）
- `getAllFeeds()` - 获取所有 Feed（带/不带 accountId）
- `getFeedById()` / `getFeedByUrl()` - 按 ID/URL 查询
- `getFeedsByFolder()` / `getRootFeeds()` - 按文件夹查询
- `renameFeed()` / `moveFeedToFolder()` - 修改操作
- `deleteFeed()` / `deleteFeeds()` - 删除操作
- `isSubscribed()` - 订阅检查
- `syncFeeds()` / `syncSingleFeed()` - 同步操作

#### [NEW] [tag_repository_test.dart](file:///D:/git/reeder/test/data/repositories/tag_repository_test.dart)
测试 TagRepository 的核心方法：
- `createTag()` / `deleteTag()` - 标签 CRUD
- `tagItem()` / `untagItem()` / `toggleTag()` - 标签关联
- `getItemIdsByTag()` / `getTagIdsForItem()` - 查询关联
- `getLaterTag()` / `getBookmarksTag()` / `getFavoritesTag()` - 内置标签

#### [NEW] [settings_repository_test.dart](file:///D:/git/reeder/test/data/repositories/settings_repository_test.dart)
测试 SettingsRepository 的核心方法：
- `getSettings()` / `saveSettings()` - 设置读写
- `getThemeMode()` / `setThemeMode()` - 主题设置
- `toggleBionicReading()` / `toggleCompactMode()` 等 toggle 方法
- `resetToDefaults()` - 重置默认

---

### Phase 4: 补全 Service 层测试

#### [NEW] [sync_bridge_test.dart](file:///D:/git/reeder/test/data/services/sync/sync_bridge_test.dart)
测试 SyncBridge 的核心方法：
- `addFeedWithSync()` - 添加 Feed + 远程同步
- `removeFeedWithSync()` - 删除 Feed + 远程同步
- `markAsReadWithSync()` / `markAsUnreadWithSync()` - 标记已读/未读 + 远程推送
- `markAsStarredWithSync()` / `markAsUnstarredWithSync()` - 加星/取消加星 + 远程推送
- `markFeedAsReadWithSync()` / `markAllAsReadWithSync()` - 批量标记 + 远程推送
- `triggerFullSync()` / `triggerIncrementalSync()` - 触发同步
- 无活跃账户时的降级行为
- 无活跃同步服务时的降级行为

#### [NEW] [feed_refresh_service_test.dart](file:///D:/git/reeder/test/data/services/feed_refresh_service_test.dart)
测试 FeedRefreshService 的核心方法：
- `refreshAll()` - 刷新所有 Feed
- `refreshFeed()` - 刷新单个 Feed
- `refreshFeeds()` - 批量刷新

#### [NEW] [feed_discovery_service_test.dart](file:///D:/git/reeder/test/data/services/feed_discovery_service_test.dart)
测试 FeedDiscoveryService 的核心方法：
- `discover()` - 发现 Feed（直接 Feed URL、HTML 页面中的 Feed 链接、无 Feed 的 URL）

---

### Phase 5: 补全 DataSource 层测试（集成测试，使用内存数据库）

#### [NEW] [article_local_ds_test.dart](file:///D:/git/reeder/test/data/datasources/local/article_local_ds_test.dart)
使用 `AppDatabase.forTesting()` 内存数据库测试：
- `upsert()` / `upsertAll()` - 插入/更新文章
- `getById()` / `getByUrl()` / `getByFeedId()` - 查询
- `markAsRead()` / `markAsUnread()` / `markAsStarred()` - 状态变更
- `markAllAsRead()` / `markAllAsReadForFeed()` - 批量标记
- `delete()` / `deleteByFeedId()` - 删除
- `search()` - 搜索
- accountId 过滤验证

#### [NEW] [feed_local_ds_test.dart](file:///D:/git/reeder/test/data/datasources/local/feed_local_ds_test.dart)
使用 `AppDatabase.forTesting()` 内存数据库测试：
- `upsert()` / `upsertAll()` - 插入/更新 Feed
- `getById()` / `getByUrl()` / `getAll()` - 查询
- `getByType()` / `getByFolderId()` / `getRootFeeds()` - 分类查询
- `delete()` / `deleteAll()` - 删除
- `exists()` - 存在性检查
- accountId 过滤验证

---

### Phase 6: 验证

运行完整测试套件确保所有测试通过。

---

## Verification Plan

### Automated Tests
```bash
# 重新生成 mock 代码
dart run build_runner build --delete-conflicting-outputs

# 静态分析
flutter analyze

# 运行所有测试
flutter test

# 运行特定测试文件验证
flutter test test/data/repositories/feed_repository_test.dart
flutter test test/data/repositories/tag_repository_test.dart
flutter test test/data/repositories/settings_repository_test.dart
flutter test test/data/services/sync/sync_bridge_test.dart
flutter test test/data/services/feed_refresh_service_test.dart
flutter test test/data/services/feed_discovery_service_test.dart
flutter test test/data/datasources/local/article_local_ds_test.dart
flutter test test/data/datasources/local/feed_local_ds_test.dart
```

### Manual Verification
- 确认生产代码的构造函数修改完全向后兼容
- 确认现有 152 个测试仍然全部通过


updateAtTime: 2026/4/14 14:54:30

planId: 002648e8-6a1a-440b-8bcd-ca6e176a7ffc