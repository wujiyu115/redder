### reeder-flutter ###
基于 PRD 文档，创建 Reeder Flutter 复刻版的完整开发计划。去除云端同步和键盘快捷键功能，UI 采用完全自定义组件（不依赖 Cupertino 或 Material）。技术栈：Flutter 3.x + Riverpod 2.x + Isar + go_router。

# Reeder Flutter 复刻版 - 完整开发计划

基于 PRD 文档的完整产品开发计划。已调整：去除云端同步/第三方服务集成/键盘快捷键，UI 采用完全自定义组件（不依赖 Cupertino 或 Material）。

## User Review Required

> [!IMPORTANT]
> **Isar 维护状态风险**：Isar 目前维护状态不确定（isar v4 长期未发布稳定版），如果开发过程中遇到严重兼容性问题，可能需要回退到 Drift (SQLite) 方案。建议在数据层设计时做好 Repository 抽象，降低后续切换成本。

> [!IMPORTANT]
> **完全自定义 UI**：不使用 CupertinoApp 或 MaterialApp，而是基于 WidgetsApp 构建，所有 UI 组件（按钮、导航栏、列表、对话框、开关、滑块等）均需自行实现。这会增加 Phase 1 的工作量，但能获得完全的设计控制权。

> [!WARNING]
> **已移除的功能**：云端同步（W14）、自建服务集成（W15）、第三方服务集成（W16）、键盘快捷键。Phase 4 原有的 4 周缩减为 1 周（仅保留高级功能），总工期从 19 周缩减为约 16 周。

---

## Proposed Changes

### Phase 1：MVP 核心阅读体验（W1-W6）

---

#### W1-W2：项目搭建 + 数据层

##### 项目初始化与基础架构

###### [NEW] [main.dart](file:///home/ejoy/git/reeder/lib/main.dart)
- 应用入口，初始化 Isar 数据库、ProviderScope、主题系统

###### [NEW] [app.dart](file:///home/ejoy/git/reeder/lib/app.dart)
- App 根组件，基于 `WidgetsApp`（非 MaterialApp/CupertinoApp）构建
- 配置 go_router、自定义主题系统、全局手势处理

###### [NEW] [pubspec.yaml](file:///home/ejoy/git/reeder/pubspec.yaml)
- Flutter 项目配置，声明所有依赖：
  - `flutter_riverpod` / `riverpod_annotation` / `riverpod_generator`
  - `go_router`
  - `isar` / `isar_flutter_libs`
  - `dio`
  - `webfeed_plus`（RSS 解析）
  - `flutter_widget_from_html`
  - `flutter_inappwebview`
  - `just_audio`
  - `video_player` / `chewie`
  - `cached_network_image`
  - `flutter_local_notifications`
  - `share_plus`
  - `url_launcher`
  - `path_provider`
  - `intl`

##### 自定义 UI 基础组件库

> [!NOTE]
> 由于不依赖 Material/Cupertino，需要先构建一套完整的基础 UI 组件库，作为整个应用的 UI 基石。

###### [NEW] [app_colors.dart](file:///home/ejoy/git/reeder/lib/core/constants/app_colors.dart)
- 定义 Light/Dark/OLED/DarkLight 四套配色方案的所有色值

###### [NEW] [app_typography.dart](file:///home/ejoy/git/reeder/lib/core/constants/app_typography.dart)
- 定义字体规范：大标题 28pt Bold、文章标题 20pt Semibold、列表标题 17pt Semibold、正文 16pt Regular、摘要 14pt Regular、辅助信息 12pt Regular、Section Header 13pt Semibold 大写

###### [NEW] [app_dimensions.dart](file:///home/ejoy/git/reeder/lib/core/constants/app_dimensions.dart)
- 定义间距、圆角、图标尺寸等布局常量

###### [NEW] [app_durations.dart](file:///home/ejoy/git/reeder/lib/core/constants/app_durations.dart)
- 定义动画时长常量：页面推入 350ms、列表项出现 200ms、主题切换 300ms、下拉刷新 500ms、图片放大 300ms、迷你播放器展开 400ms

###### [NEW] [app_theme.dart](file:///home/ejoy/git/reeder/lib/core/theme/app_theme.dart)
- 自定义主题数据类（非 ThemeData），包含所有颜色、字体、间距定义
- 提供 `ReederTheme` InheritedWidget 供子组件访问

###### [NEW] [light_theme.dart](file:///home/ejoy/git/reeder/lib/core/theme/light_theme.dart)
- 亮色主题实例：背景 #FFFFFF、主文字 #1C1C1E、强调色 #007AFF

###### [NEW] [dark_theme.dart](file:///home/ejoy/git/reeder/lib/core/theme/dark_theme.dart)
- 暗色主题实例：背景 #1C1C1E、主文字 #FFFFFF、强调色 #0A84FF

###### [NEW] [oled_theme.dart](file:///home/ejoy/git/reeder/lib/core/theme/oled_theme.dart)
- OLED 黑色主题实例：背景 #000000

##### 自定义基础 Widget

###### [NEW] [reeder_scaffold.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_scaffold.dart)
- 自定义页面脚手架：导航栏 + 内容区 + 可选底部栏

###### [NEW] [reeder_nav_bar.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_nav_bar.dart)
- 自定义导航栏：返回按钮 + 标题 + 右侧操作按钮，支持滚动时隐藏

###### [NEW] [reeder_button.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_button.dart)
- 自定义按钮组件：文字按钮、图标按钮、带背景按钮

###### [NEW] [reeder_text_field.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_text_field.dart)
- 自定义文本输入框

###### [NEW] [reeder_switch.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_switch.dart)
- 自定义开关组件

###### [NEW] [reeder_slider.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_slider.dart)
- 自定义滑块组件（用于字号、行高、音量等设置）

###### [NEW] [reeder_dialog.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_dialog.dart)
- 自定义对话框组件

###### [NEW] [reeder_bottom_sheet.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_bottom_sheet.dart)
- 自定义底部弹出面板

###### [NEW] [reeder_popup_menu.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_popup_menu.dart)
- 自定义弹出菜单

###### [NEW] [reeder_list_tile.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_list_tile.dart)
- 自定义列表项组件（用于设置页等）

###### [NEW] [reeder_section_header.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_section_header.dart)
- 自定义 Section Header（大写灰色小字样式）

###### [NEW] [reeder_page_transition.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/reeder_page_transition.dart)
- 自定义页面转场动画（右滑入 350ms easeInOut，支持手势驱动返回）

##### 路由配置

###### [NEW] [app_router.dart](file:///home/ejoy/git/reeder/lib/core/router/app_router.dart)
- go_router 路由配置，使用自定义 `reeder_page_transition` 作为转场动画
- 定义所有页面路由
- 支持 `reed://` URL Scheme 深度链接

##### 网络层

###### [NEW] [dio_client.dart](file:///home/ejoy/git/reeder/lib/core/network/dio_client.dart)
- Dio HTTP 客户端封装，配置超时、重试、HTTPS 强制

###### [NEW] [api_interceptor.dart](file:///home/ejoy/git/reeder/lib/core/network/api_interceptor.dart)
- 请求/响应拦截器，日志记录、错误处理

##### 数据库层

###### [NEW] [app_database.dart](file:///home/ejoy/git/reeder/lib/core/database/app_database.dart)
- Isar 数据库初始化、Schema 注册、迁移管理

##### 数据模型（Isar Collection）

###### [NEW] [feed.dart](file:///home/ejoy/git/reeder/lib/data/models/feed.dart)
- Feed 订阅源模型：id, title, description, feedUrl, siteUrl, iconUrl, type(FeedType), folderId, groupId, lastFetched, fetchDurationMs, defaultViewer(ViewerType), autoReaderView, createdAt

###### [NEW] [feed_item.dart](file:///home/ejoy/git/reeder/lib/data/models/feed_item.dart)
- FeedItem 内容项模型：id, feedId, title, summary, content, url, imageUrl, imageUrls, audioUrl, videoUrl, audioDuration, author, publishedAt, fetchedAt, contentType(ContentType), metadata

###### [NEW] [folder.dart](file:///home/ejoy/git/reeder/lib/data/models/folder.dart)
- Folder 文件夹模型：id, name, iconName, sortOrder, createdAt

###### [NEW] [tag.dart](file:///home/ejoy/git/reeder/lib/data/models/tag.dart)
- Tag 标签模型：id, name, iconName, isBuiltIn, isShared, sharedFeedUrl, itemCount, createdAt
- TaggedItem 标签关联模型：tagId, itemId, taggedAt

###### [NEW] [filter.dart](file:///home/ejoy/git/reeder/lib/data/models/filter.dart)
- Filter 过滤器模型：id, name, includeKeywords, excludeKeywords, mediaTypes, feedTypes, matchWholeWord, createdAt

###### [NEW] [scroll_position.dart](file:///home/ejoy/git/reeder/lib/data/models/scroll_position.dart)
- ScrollPosition 滚动位置模型：timelineId, lastItemId, scrollOffset, savedAt

###### [NEW] [app_settings.dart](file:///home/ejoy/git/reeder/lib/data/models/app_settings.dart)
- AppSettings 应用设置模型：themeMode, fontSize, lineHeight, maxContentWidth, bionicReading, showAvatars, avatarStyle, showFolderIcons 等

##### 数据仓库（Repository 抽象层）

###### [NEW] [feed_repository.dart](file:///home/ejoy/git/reeder/lib/data/repositories/feed_repository.dart)
- Feed CRUD 操作、按类型/文件夹查询、批量操作

###### [NEW] [article_repository.dart](file:///home/ejoy/git/reeder/lib/data/repositories/article_repository.dart)
- FeedItem CRUD、按 feed/时间/类型查询、全文搜索、分页加载

###### [NEW] [tag_repository.dart](file:///home/ejoy/git/reeder/lib/data/repositories/tag_repository.dart)
- Tag 和 TaggedItem 管理、内置标签初始化

###### [NEW] [settings_repository.dart](file:///home/ejoy/git/reeder/lib/data/repositories/settings_repository.dart)
- 应用设置读写

##### 本地数据源

###### [NEW] [feed_local_ds.dart](file:///home/ejoy/git/reeder/lib/data/datasources/local/feed_local_ds.dart)
- Isar 操作封装：Feed 表的增删改查

###### [NEW] [article_local_ds.dart](file:///home/ejoy/git/reeder/lib/data/datasources/local/article_local_ds.dart)
- Isar 操作封装：FeedItem 表的增删改查、全文索引

###### [NEW] [settings_local_ds.dart](file:///home/ejoy/git/reeder/lib/data/datasources/local/settings_local_ds.dart)
- Isar 操作封装：AppSettings 读写

##### 远程数据源

###### [NEW] [rss_remote_ds.dart](file:///home/ejoy/git/reeder/lib/data/datasources/remote/rss_remote_ds.dart)
- RSS/Atom/JSON Feed 远程获取与解析

##### 业务服务

###### [NEW] [feed_refresh_service.dart](file:///home/ejoy/git/reeder/lib/data/services/feed_refresh_service.dart)
- 订阅源刷新服务：并发控制（限制 10 并发）、增量刷新、去重、刷新耗时记录

###### [NEW] [feed_discovery_service.dart](file:///home/ejoy/git/reeder/lib/data/services/feed_discovery_service.dart)
- Feed 发现服务：输入 URL 自动搜索可用的 RSS/Atom/JSON Feed

##### 工具类

###### [NEW] [date_formatter.dart](file:///home/ejoy/git/reeder/lib/core/utils/date_formatter.dart)
- 日期格式化：相对时间（2h ago）、绝对时间、预估阅读时间

###### [NEW] [html_parser.dart](file:///home/ejoy/git/reeder/lib/core/utils/html_parser.dart)
- HTML 内容解析、摘要提取、图片 URL 提取

###### [NEW] [opml_parser.dart](file:///home/ejoy/git/reeder/lib/core/utils/opml_parser.dart)
- OPML 2.0 格式导入/导出

###### [NEW] [feed_discoverer.dart](file:///home/ejoy/git/reeder/lib/core/utils/feed_discoverer.dart)
- 网页 Feed 自动发现（解析 HTML link 标签）

##### 扩展方法

###### [NEW] [string_ext.dart](file:///home/ejoy/git/reeder/lib/core/extensions/string_ext.dart)
- String 扩展方法

###### [NEW] [datetime_ext.dart](file:///home/ejoy/git/reeder/lib/core/extensions/datetime_ext.dart)
- DateTime 扩展方法

##### 全局 Provider

###### [NEW] [theme_provider.dart](file:///home/ejoy/git/reeder/lib/shared/providers/theme_provider.dart)
- 主题状态管理 Provider

###### [NEW] [settings_provider.dart](file:///home/ejoy/git/reeder/lib/shared/providers/settings_provider.dart)
- 全局设置 Provider

###### [NEW] [connectivity_provider.dart](file:///home/ejoy/git/reeder/lib/shared/providers/connectivity_provider.dart)
- 网络连接状态 Provider

---

#### W3：订阅管理

##### 源列表页面

###### [NEW] [source_list_page.dart](file:///home/ejoy/git/reeder/lib/features/source_list/source_list_page.dart)
- 应用主导航页面，使用自定义 `ReederScaffold`
- 展示 HOME / FEEDS / TAGS / SAVED 四个 Section
- 顶部显示 "Reeder" + 添加按钮 + 设置按钮

###### [NEW] [source_list_controller.dart](file:///home/ejoy/git/reeder/lib/features/source_list/source_list_controller.dart)
- Riverpod Controller：管理源列表数据、分组逻辑、计数

###### [NEW] [source_section.dart](file:///home/ejoy/git/reeder/lib/features/source_list/widgets/source_section.dart)
- Section 组件：使用自定义 `ReederSectionHeader`

###### [NEW] [source_item.dart](file:///home/ejoy/git/reeder/lib/features/source_list/widgets/source_item.dart)
- 源列表项组件：图标 + 名称 + 可选计数
- 长按弹出自定义 `ReederPopupMenu`

###### [NEW] [add_feed_dialog.dart](file:///home/ejoy/git/reeder/lib/features/source_list/widgets/add_feed_dialog.dart)
- 添加订阅对话框：使用自定义 `ReederDialog` + `ReederTextField`
- URL 输入 → Feed 发现 → 预览 → 确认添加

---

#### W4：文章列表 + 时间线

##### 文章列表页面

###### [NEW] [article_list_page.dart](file:///home/ejoy/git/reeder/lib/features/article_list/article_list_page.dart)
- 使用自定义 `ReederScaffold` + `ReederNavBar`
- 支持统一时间线、分类时间线、文件夹时间线、单源时间线

###### [NEW] [article_list_controller.dart](file:///home/ejoy/git/reeder/lib/features/article_list/article_list_controller.dart)
- Riverpod Controller：管理文章列表数据、分页加载、刷新逻辑

###### [NEW] [article_list_item.dart](file:///home/ejoy/git/reeder/lib/features/article_list/widgets/article_list_item.dart)
- 标准列表项：来源图标 + 名称 + 相对时间 + 标题 + 摘要 + 缩略图 + 标签状态

###### [NEW] [article_list_item_compact.dart](file:///home/ejoy/git/reeder/lib/features/article_list/widgets/article_list_item_compact.dart)
- 紧凑列表项（无图模式）

###### [NEW] [timeline_control_button.dart](file:///home/ejoy/git/reeder/lib/features/article_list/widgets/timeline_control_button.dart)
- 时间线控制按钮：新内容计数 + 弹出菜单（Timeline Position / Today / Top）

##### 通用组件

###### [NEW] [pull_to_refresh.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/pull_to_refresh.dart)
- 自定义下拉刷新组件，弹性回弹动画

###### [NEW] [feed_icon.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/feed_icon.dart)
- 订阅源图标组件

###### [NEW] [shimmer_loading.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/shimmer_loading.dart)
- 骨架屏加载组件

###### [NEW] [empty_state.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/empty_state.dart)
- 空状态组件

###### [NEW] [error_state.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/error_state.dart)
- 错误状态组件

---

#### W5：文章详情 + 阅读

###### [NEW] [article_detail_page.dart](file:///home/ejoy/git/reeder/lib/features/article_detail/article_detail_page.dart)
- 使用自定义 `ReederScaffold`，导航栏滚动时可隐藏
- 支持左滑加载下一篇、右滑返回

###### [NEW] [article_detail_controller.dart](file:///home/ejoy/git/reeder/lib/features/article_detail/article_detail_controller.dart)
- Riverpod Controller

###### [NEW] [article_header.dart](file:///home/ejoy/git/reeder/lib/features/article_detail/widgets/article_header.dart)
- 文章头部：Hero Image + 标题 + 来源 + 日期 + 预估阅读时间

###### [NEW] [article_content_view.dart](file:///home/ejoy/git/reeder/lib/features/article_detail/widgets/article_content_view.dart)
- HTML 富文本渲染

###### [NEW] [article_action_bar.dart](file:///home/ejoy/git/reeder/lib/features/article_detail/widgets/article_action_bar.dart)
- 底部操作栏：Later / Bookmark / Favorite / Share / Open in Browser

###### [NEW] [reader_view.dart](file:///home/ejoy/git/reeder/lib/features/article_detail/widgets/reader_view.dart)
- Reader View 去杂阅读模式

###### [NEW] [reader_view_service.dart](file:///home/ejoy/git/reeder/lib/data/services/reader_view_service.dart)
- Reader View 正文提取服务

###### [NEW] [in_app_browser_page.dart](file:///home/ejoy/git/reeder/lib/features/browser/in_app_browser_page.dart)
- 应用内浏览器

---

#### W6：主题 + 基础设置

###### [NEW] [settings_page.dart](file:///home/ejoy/git/reeder/lib/features/settings/settings_page.dart)
- 设置主页面，使用自定义 `ReederListTile`、`ReederSwitch` 等组件

###### [NEW] [theme_settings_page.dart](file:///home/ejoy/git/reeder/lib/features/settings/theme_settings_page.dart)
- 主题设置

###### [NEW] [reading_settings_page.dart](file:///home/ejoy/git/reeder/lib/features/settings/reading_settings_page.dart)
- 阅读设置，使用自定义 `ReederSlider`

###### [NEW] [data_settings_page.dart](file:///home/ejoy/git/reeder/lib/features/settings/data_settings_page.dart)
- 数据设置

###### [NEW] [about_page.dart](file:///home/ejoy/git/reeder/lib/features/settings/about_page.dart)
- 关于页面

---

### Phase 2：内容组织（W7-W10）

#### W7：标签系统
- 内置标签（Later / Bookmarks / Favorites）+ 自定义标签
- 标签关联、快捷操作、计数展示

#### W8：滑动操作 + 手势

###### [NEW] [swipe_action_widget.dart](file:///home/ejoy/git/reeder/lib/features/article_list/widgets/swipe_action_widget.dart)
- 列表项滑动操作

###### [NEW] [context_menu.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/context_menu.dart)
- 自定义上下文菜单（替代系统菜单）

#### W9：过滤器 + 文件夹

###### [NEW] [filter_editor_page.dart](file:///home/ejoy/git/reeder/lib/features/filter/filter_editor_page.dart)
###### [NEW] [filter_controller.dart](file:///home/ejoy/git/reeder/lib/features/filter/filter_controller.dart)

#### W10：搜索 + 滚动位置

###### [NEW] [search_page.dart](file:///home/ejoy/git/reeder/lib/features/search/search_page.dart)
###### [NEW] [search_controller.dart](file:///home/ejoy/git/reeder/lib/features/search/search_controller.dart)
- 全文搜索 + 滚动位置防抖保存与恢复

---

### Phase 3：多媒体支持（W11-W13）

#### W11：图片查看器
###### [NEW] [image_viewer_page.dart](file:///home/ejoy/git/reeder/lib/features/image_viewer/image_viewer_page.dart)

#### W12：播客播放器
###### [NEW] [mini_player.dart](file:///home/ejoy/git/reeder/lib/features/podcast_player/mini_player.dart)
###### [NEW] [full_player_page.dart](file:///home/ejoy/git/reeder/lib/features/podcast_player/full_player_page.dart)
###### [NEW] [podcast_controller.dart](file:///home/ejoy/git/reeder/lib/features/podcast_player/podcast_controller.dart)
###### [NEW] [podcast_service.dart](file:///home/ejoy/git/reeder/lib/data/services/podcast_service.dart)

#### W13：视频播放器
###### [NEW] [video_player_page.dart](file:///home/ejoy/git/reeder/lib/features/video_player/video_player_page.dart)

---

### Phase 4：高级功能（W14）

> [!NOTE]
> 原 Phase 4 的云端同步（W14）、自建服务集成（W15）、第三方服务集成（W16）已移除。仅保留 W17 的高级功能，合并为 1 周。

#### W14：高级功能

###### [NEW] [bionic_reading.dart](file:///home/ejoy/git/reeder/lib/core/utils/bionic_reading.dart)
- Bionic Reading 算法

###### [NEW] [adaptive_scaffold.dart](file:///home/ejoy/git/reeder/lib/shared/widgets/adaptive_scaffold.dart)
- 自适应布局组件（手机单栏 / 平板横屏三栏 / 平板竖屏两栏）

###### [NEW] [timeline_settings_page.dart](file:///home/ejoy/git/reeder/lib/features/settings/timeline_settings_page.dart)
- 时间线设置

- 标签导出为 JSON Feed（共享订阅源）
- Dark Light 混合主题
- 内容过期隐藏设置

---

### Phase 5：打磨与发布（W15-W16）

#### W15：动画打磨 + 性能优化
- 所有动画达到 60fps
- 冷启动 < 2s、列表滚动 60fps、内存 < 200MB
- 后台刷新（平台后台任务 API）

#### W16：测试 + 发布准备
- 单元测试、Widget 测试、集成测试
- iOS 15.0+ / Android 8.0+ 兼容性验证
- 无障碍支持、动态字体
- 应用商店素材

---

## Verification Plan

### Automated Tests
- `flutter test` 运行所有单元测试和 Widget 测试
- `flutter test integration_test/` 运行集成测试
- 每个 Phase 完成后运行完整测试套件

### Manual Verification
- **Phase 1 MVP 验收**：可添加 RSS 订阅并浏览内容、统一时间线、文章详情富文本渲染、Reader View、亮色/暗色主题切换、OPML 导入/导出
- **Phase 2 验收**：标签系统、滑动操作、过滤器和文件夹、搜索和滚动位置同步
- **Phase 3 验收**：图片查看器缩放流畅、播客播放器完整可用、视频播放正常
- **Phase 4 验收**：Bionic Reading、平板自适应布局、Dark Light 混合主题
- **Phase 5 验收**：所有动画 60fps、性能指标达标、无障碍支持、应用商店审核通过

updateAtTime: 2026/4/10 10:06:09

planId: 1a1e5083-2fcc-4c7d-abf0-8e3b6ef87be8