### 补全mocks测试用例 ###

# 补全 Mocks 与测试用例 - 任务清单

## Phase 1: 重构单例类以支持依赖注入

- [x] 1.1 修改 `lib/data/datasources/local/article_local_ds.dart`：添加可选 `AppDatabase? db` 构造函数参数
- [x] 1.2 修改 `lib/data/datasources/local/feed_local_ds.dart`：添加可选 `AppDatabase? db` 构造函数参数
- [x] 1.3 修改 `lib/data/datasources/local/settings_local_ds.dart`：添加可选 `AppDatabase? db` 构造函数参数
- [x] 1.4 修改 `lib/data/repositories/tag_repository.dart`：添加可选 `AppDatabase? db` 构造函数参数

## Phase 2: 补全 test_mocks.dart

- [x] 2.1 修改 `test/test_mocks.dart`：添加 FeedRepository、ArticleRepository、SettingsRepository、TagRepository
- [x] 2.2 修改 `test/test_mocks.dart`：添加 ArticleLocalDataSource、FeedLocalDataSource、SettingsLocalDataSource、RssRemoteDataSource
- [x] 2.3 修改 `test/test_mocks.dart`：添加 SyncBridge、SyncEngine、FeedRefreshService、FeedDiscoveryService、ScrollPositionService、ReaderViewService、PodcastService、DioClient
- [x] 2.4 运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 mock 代码
- [x] 2.5 运行 `flutter analyze` 确认无编译错误

## Phase 3: 补全 Repository 层测试

- [x] 3.1 创建 `test/data/repositories/feed_repository_test.dart`：FeedRepository 核心方法测试
- [x] 3.2 创建 `test/data/repositories/tag_repository_test.dart`：TagRepository 核心方法测试
- [x] 3.3 创建 `test/data/repositories/settings_repository_test.dart`：SettingsRepository 核心方法测试

## Phase 4: 补全 Service 层测试

- [x] 4.1 创建 `test/data/services/sync/sync_bridge_test.dart`：SyncBridge 核心方法测试
- [x] 4.2 创建 `test/data/services/feed_refresh_service_test.dart`：FeedRefreshService 核心方法测试
- [x] 4.3 创建 `test/data/services/feed_discovery_service_test.dart`：FeedDiscoveryService 核心方法测试

## Phase 5: 补全 DataSource 层测试（内存数据库集成测试）

- [x] 5.1 创建 `test/data/datasources/local/article_local_ds_test.dart`：ArticleLocalDataSource 核心方法测试
- [x] 5.2 创建 `test/data/datasources/local/feed_local_ds_test.dart`：FeedLocalDataSource 核心方法测试

## Phase 6: 验证

- [x] 6.1 运行 `flutter analyze` 确认无编译错误
- [x] 6.2 运行 `flutter test` 确认所有测试通过（384 个测试全部通过）


updateAtTime: 2026/4/14 14:54:30

planId: 002648e8-6a1a-440b-8bcd-ca6e176a7ffc