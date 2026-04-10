# Reeder

一款极简风格的 RSS 阅读器，使用 Flutter 构建，灵感来源于 [Reeder 5](https://reederapp.com/)。支持 iOS 和 Android 双平台，采用完全自定义 UI 组件（不依赖 Material/Cupertino），提供纯净的阅读体验。

## 功能概览

### 核心阅读
- **统一时间线** — 所有订阅源内容按时间倒序展示
- **分类浏览** — 按文章 / 音频 / 视频分类，独立滚动位置
- **文章详情** — HTML 富文本渲染（图片、链接、代码块、引用块）
- **Reader View** — 去杂阅读模式，提取正文内容
- **Bionic Reading** — 加粗单词前几个字母，提升阅读速度
- **应用内浏览器** — 前进 / 后退 / 刷新 / 分享 / 外部打开

### 订阅管理
- **Feed 发现** — 输入 URL 自动搜索可用的 RSS / Atom / JSON Feed
- **OPML 导入导出** — 支持 OPML 2.0 格式，含文件夹结构
- **自动分组** — 按内容类型归入 Blogs / Podcasts / Videos
- **自定义文件夹** — 创建、重命名、删除、拖拽排序

### 内容组织
- **标签系统** — 内置 Later / Bookmarks / Favorites + 自定义标签
- **智能过滤器** — 基于关键词、媒体类型、Feed 类型的自定义时间线
- **全文搜索** — Isar 全文索引，关键词高亮
- **滚动位置记忆** — 每个时间线独立保存和恢复滚动位置

### 多媒体支持
- **图片查看器** — 全屏查看、双指缩放、左右滑动切换多图
- **播客播放器** — 播放 / 暂停 / 进度控制 / 倍速 / 章节标记 / 迷你播放器
- **视频播放器** — 内嵌播放，YouTube 等平台 WebView 回退

### 手势交互
- **滑动操作** — 列表项左滑分享、右滑稍后阅读
- **边缘手势** — 文章详情页左边缘右滑返回、右边缘左滑下一篇
- **长按菜单** — 源列表项长按弹出上下文菜单
- **手势驱动返回** — 页面转场支持拖拽驱动的返回动画

### 主题与个性化
- **5 种主题** — Light / Dark / OLED Black / Dark Light（混合） / System
- **Dark Light 混合** — 暗色列表 + 亮色内容查看器
- **字号调节** — 7 档字号选择，实时预览
- **行高调节** — 5 档行高选择，实时预览
- **主题切换动画** — 300ms 全局交叉淡入淡出

### 平板适配
- **三栏布局** — 横屏：源列表 240pt + 文章列表 320pt + 详情 Flexible
- **两栏布局** — 竖屏：文章列表 + 详情，源列表侧滑呼出
- **列宽拖拽** — 支持鼠标 / 触摸拖拽调整列宽

### 其他
- **后台刷新** — 定时自动刷新订阅源（默认 30 分钟）
- **标签导出** — 将标签文章导出为 JSON Feed 1.1 格式
- **无障碍支持** — VoiceOver / TalkBack Semantics 标注
- **动态字体** — 支持系统字体大小设置（0.8x - 1.5x）
- **隐私优先** — 所有数据本地存储，无追踪、无账号、无广告

## 技术栈

| 类别 | 技术 |
|------|------|
| **框架** | Flutter 3.x |
| **状态管理** | Riverpod 2.x (StateNotifier) |
| **数据库** | Isar 3.x (嵌入式 NoSQL) |
| **路由** | go_router |
| **网络** | Dio |
| **RSS 解析** | webfeed_plus |
| **HTML 渲染** | flutter_widget_from_html |
| **音频** | just_audio |
| **视频** | video_player + chewie |
| **WebView** | flutter_inappwebview |
| **UI 基础** | WidgetsApp (完全自定义) |

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # App 根组件 (WidgetsApp)
├── core/
│   ├── constants/                     # 颜色、字体、间距、动画时长常量
│   ├── database/                      # Isar 数据库初始化
│   ├── extensions/                    # String、DateTime 扩展方法
│   ├── network/                       # Dio 客户端、拦截器
│   ├── router/                        # go_router 路由配置
│   ├── theme/                         # 主题系统 (Light/Dark/OLED)
│   └── utils/                         # 工具类 (日期、HTML、OPML、Bionic Reading)
├── data/
│   ├── datasources/
│   │   ├── local/                     # Isar 本地数据源
│   │   └── remote/                    # RSS 远程数据源
│   ├── models/                        # 数据模型 (Feed, FeedItem, Tag, Filter...)
│   ├── repositories/                  # Repository 抽象层
│   └── services/                      # 业务服务 (刷新、发现、播客、后台刷新)
├── features/
│   ├── article_detail/                # 文章详情页
│   ├── article_list/                  # 文章列表页
│   ├── browser/                       # 应用内浏览器
│   ├── filter/                        # 过滤器编辑
│   ├── image_viewer/                  # 图片查看器
│   ├── podcast_player/                # 播客播放器 (迷你 + 全屏)
│   ├── search/                        # 搜索页
│   ├── settings/                      # 设置页 (主题/阅读/数据/时间线/隐私)
│   ├── source_list/                   # 源列表页 (主导航)
│   └── video_player/                  # 视频播放器
└── shared/
    ├── providers/                     # 全局 Provider (主题/设置/网络)
    └── widgets/                       # 自定义 UI 组件库
        ├── reeder_scaffold.dart       # 页面脚手架
        ├── reeder_nav_bar.dart        # 导航栏
        ├── reeder_button.dart         # 按钮
        ├── reeder_switch.dart         # 开关
        ├── reeder_slider.dart         # 滑块
        ├── reeder_dialog.dart         # 对话框
        ├── reeder_list_tile.dart      # 列表项
        ├── adaptive_scaffold.dart     # 自适应布局
        ├── pull_to_refresh.dart       # 下拉刷新
        └── ...                        # 更多组件
```

## 开发指南

### 环境要求

- **Flutter**: 3.x (stable channel)
- **Dart**: >= 3.0.0
- **iOS**: 15.0+
- **Android**: API 26+ (Android 8.0+)
- **IDE**: VS Code 或 Android Studio

### 快速开始

```bash
# 1. 克隆项目
git clone <repo-url>
cd reeder

# 2. 安装依赖
flutter pub get

# 3. 生成 Isar Schema 代码
dart run build_runner build --delete-conflicting-outputs

# 4. 运行应用
flutter run
```

### 常用命令

```bash
# 代码生成（Isar Schema + Riverpod）
dart run build_runner build --delete-conflicting-outputs

# 监听模式（开发时自动重新生成）
dart run build_runner watch --delete-conflicting-outputs

# 代码分析
flutter analyze

# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test/

# 构建 iOS Release
flutter build ios --release

# 构建 Android APK
flutter build apk --release

# 构建 Android App Bundle
flutter build appbundle --release

# mumu模拟器连接 问题诊断中查看adb端口
adb connect 127.0.0.1:16384
```

### 开发规范

- **UI 组件**：所有 UI 组件基于 `WidgetsApp` 自定义实现，位于 `lib/shared/widgets/`，不使用 Material/Cupertino
- **主题系统**：通过 `ReederTheme` InheritedWidget 传递主题数据，使用 `ReederTheme.of(context)` 获取
- **状态管理**：使用 Riverpod `StateNotifier` 模式，Provider 定义在各 feature 的 controller 文件中
- **数据层**：遵循 Repository 模式，`DataSource → Repository → Provider → UI`
- **路由**：使用 go_router 声明式路由，配置在 `lib/core/router/app_router.dart`
- **动画**：所有动画时长定义在 `lib/core/constants/app_durations.dart`，目标 60fps
- **无障碍**：关键交互组件需添加 `Semantics` 包装

### 测试

```
test/
├── data/repositories/                 # 数据层单元测试
│   └── article_repository_test.dart   # DateFormatter/HtmlParser/BionicReading/OpmlParser
└── widgets/
    └── reeder_widgets_test.dart        # 核心 Widget 测试

integration_test/
└── app_flow_test.dart                 # 端到端集成测试
```

### 验证清单

完整的验证和测试清单请参考 [`docs/verification_checklist.md`](docs/verification_checklist.md)，包含：
- 编译验证
- MVP 集成测试
- 平台兼容性
- 平板适配
- 无障碍支持
- 动态字体
- 性能指标
- 最终回归测试

## 平台要求

| 平台 | 最低版本 |
|------|---------|
| iOS | 15.0+ |
| Android | API 26 (Android 8.0+) |

## 许可证

Private - All rights reserved.
