### reeder-service-integration ###
集成 mockito 和 build_runner 代码生成，为 SyncEngine、SyncQueue、SyncRepository、AuthService 编写基于 mock 的单元测试，替换现有的纯逻辑测试。

# 集成 Mockito 测试

## 背景

当前项目的单元测试存在明显不足：大部分测试只验证纯逻辑（字符串拼接、枚举值、DateTime 计算等），没有通过 mock 依赖来测试核心业务逻辑。集成 `mockito` + `build_runner` 代码生成后，可以为以下核心组件编写真正有效的单元测试：

- **SyncEngine** - 同步引擎（依赖 SyncServiceRegistry、SyncLocalDataSource、SyncQueue、Connectivity）
- **SyncQueue** - 离线操作队列（依赖 SyncLocalDataSource、SyncService）
- **SyncRepository** - 同步仓库（依赖 SyncLocalDataSource、AuthService）
- **AuthService** - 认证服务（依赖 FlutterSecureStorage）

## Proposed Changes

### 依赖配置

#### [MODIFY] [pubspec.yaml](file:///Users/yitouxiaomaolv/git/redder/pubspec.yaml)
在 `dev_dependencies` 中添加 `mockito` 和 `build_runner`（已有）依赖：
```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.8  # 已存在
```

---

### SyncEngine 测试（重写）

#### [MODIFY] [sync_engine_test.dart](file:///Users/yitouxiaomaolv/git/redder/test/data/services/sync/sync_engine_test.dart)
使用 mockito 重写，mock 以下依赖：
- `MockSyncServiceRegistry` - mock `activeService` 返回
- `MockSyncLocalDataSource` - mock `getActiveAccount()`、`upsertAccount()`
- `MockSyncQueue` - mock `processQueue()`
- `MockSyncService` - mock `fullSync()`、`incrementalSync()`
- `MockConnectivity` - mock `checkConnectivity()`

测试场景：
1. `sync()` - 无活跃服务时返回 empty
2. `sync()` - 无活跃账户时返回 empty
3. `sync()` - 首次同步（lastSyncAt 为 null）调用 fullSync
4. `sync()` - 增量同步调用 incrementalSync
5. `sync()` - 同步成功后更新 lastSyncAt
6. `sync()` - 同步失败时状态变为 error
7. `syncFeed()` - 调用 incrementalSync
8. `pushStateChange()` - 在线时直接调用远程服务
9. `pushStateChange()` - 离线时加入队列
10. 状态流正确发射 syncing → idle / error

---

### SyncQueue 测试（重写）

#### [NEW] [sync_queue_test.dart](file:///Users/yitouxiaomaolv/git/redder/test/data/services/sync/sync_queue_test.dart)
使用 mockito mock `SyncLocalDataSource` 和 `SyncService`：

测试场景：
1. `enqueue()` - 正确调用 `_localDataSource.enqueueAction()`
2. `processQueue()` - 按顺序处理队列项
3. `processQueue()` - 成功后删除队列项
4. `processQueue()` - 失败时增加重试次数
5. `processQueue()` - 超过最大重试次数后丢弃
6. `processQueue()` - 空队列时直接返回
7. `processQueue()` - markRead 调用 `syncService.markAsRead()`
8. `processQueue()` - star 调用 `syncService.markAsStarred()`
9. `getQueueSize()` - 返回正确数量
10. `clearQueue()` - 调用 `deleteQueueItemsByAccountId()`

---

### AuthService 测试（重写）

#### [MODIFY] [auth_service_test.dart](file:///Users/yitouxiaomaolv/git/redder/test/data/services/auth/auth_service_test.dart)
使用 mockito mock `FlutterSecureStorage`：

测试场景：
1. `saveCredentials()` - 正确序列化并写入 secure storage
2. `getCredentials()` - 正确读取并反序列化
3. `getCredentials()` - key 不存在时返回 null
4. `getCredentials()` - JSON 解析失败时返回 null
5. `deleteCredentials()` - 调用 secure storage delete
6. `updateTokens()` - 更新 OAuth token
7. `updateTokens()` - 无已有凭据时抛出 StateError
8. `hasCredentials()` - 存在时返回 true
9. `hasCredentials()` - 不存在时返回 false
10. `deleteAllCredentials()` - 只删除 reeder_sync_ 前缀的 key

---

### SyncRepository 测试（新建）

#### [NEW] [sync_repository_test.dart](file:///Users/yitouxiaomaolv/git/redder/test/data/repositories/sync_repository_test.dart)
使用 mockito mock `SyncLocalDataSource` 和 `AuthService`：

测试场景：
1. `getAccounts()` - 正确转换 SyncAccount → SyncAccountInfo
2. `getActiveAccount()` - 有活跃账户时返回 SyncAccountInfo
3. `getActiveAccount()` - 无活跃账户时返回 null
4. `addAccount()` - 正确构造 SyncAccountsCompanion 并调用 upsertAccount
5. `removeAccount()` - 先删除凭据再删除账户
6. `setActiveAccount()` - 调用 localDs.setActiveAccount
7. `updateLastSyncAt()` - 更新同步时间
8. `getAccountById()` - 存在时返回 SyncAccountInfo
9. `getAccountById()` - 不存在时返回 null

---

### Mock 生成文件

#### [NEW] [test_mocks.dart](file:///Users/yitouxiaomaolv/git/redder/test/test_mocks.dart)
集中定义所有 `@GenerateMocks` 注解，供 build_runner 生成 mock 类：

```dart
@GenerateMocks([
  SyncServiceRegistry,
  SyncLocalDataSource,
  SyncQueue,
  SyncService,
  AuthService,
  FlutterSecureStorage,
  Connectivity,
])
```

运行 `dart run build_runner build --delete-conflicting-outputs` 生成 `test_mocks.mocks.dart`。

## Verification Plan

### Automated Tests
```bash
# 生成 mock 代码
dart run build_runner build --delete-conflicting-outputs

# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/data/services/sync/sync_engine_test.dart
flutter test test/data/services/sync/sync_queue_test.dart
flutter test test/data/services/auth/auth_service_test.dart
flutter test test/data/repositories/sync_repository_test.dart
```

### Manual Verification
- 用户手动执行 `flutter test` 确认所有测试通过
- 用户手动执行 `dart analyze` 确认无编译错误


updateAtTime: 2026/4/11 22:07:45

planId: 3b0aad0c-ad1c-4f09-bcc3-9f6dee070b12