### reeder-service-integration ###
# 集成 Mockito 测试 - 任务清单

## 依赖配置
- [x] 1. 在 pubspec.yaml 中添加 mockito 依赖

## Mock 定义与代码生成
- [x] 2. 创建 test/test_mocks.dart，定义 @GenerateMocks 注解
- [ ] 3. 运行 build_runner 生成 mock 代码（需用户手动执行：`dart run build_runner build --delete-conflicting-outputs`）

## 测试文件编写
- [x] 4. 重写 test/data/services/sync/sync_engine_test.dart（使用 mockito mock SyncServiceRegistry、SyncLocalDataSource、SyncQueue、SyncService、Connectivity）
- [x] 5. 新建 test/data/services/sync/sync_queue_test.dart（使用 mockito mock SyncLocalDataSource、SyncService）
- [x] 6. 重写 test/data/services/auth/auth_service_test.dart（使用 mockito mock FlutterSecureStorage）
- [x] 7. 新建 test/data/repositories/sync_repository_test.dart（使用 mockito mock SyncLocalDataSource、AuthService）

## 验证
- [ ] 8. 运行 flutter test 确认所有测试通过（用户手动执行）
- [ ] 9. 运行 dart analyze 确认无编译错误（用户手动执行）


updateAtTime: 2026/4/11 22:07:45

planId: 3b0aad0c-ad1c-4f09-bcc3-9f6dee070b12