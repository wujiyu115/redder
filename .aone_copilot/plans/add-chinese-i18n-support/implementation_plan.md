### add-chinese-i18n-support ###
为 Reeder RSS 阅读器项目添加完整的中文国际化支持，包括配置 Flutter 国际化框架、创建英文和中文 ARB 资源文件、以及将所有页面和组件中的硬编码字符串替换为国际化引用。


# 为 Reeder 项目添加中文国际化支持

## 背景

Reeder 是一个使用 Flutter 构建的极简 RSS 阅读器应用。当前项目中所有用户可见的文本都是硬编码的英文字符串，分布在 15 个页面和多个共享组件中。项目已引入 `intl` 依赖但尚未配置国际化框架。本计划将为项目添加完整的中英文国际化支持。

## Proposed Changes

### 1. 国际化基础配置

配置 Flutter 官方国际化框架，添加必要的依赖和配置文件。

#### [MODIFY] [pubspec.yaml](file:///D:/git/reeder/pubspec.yaml)
- 在 `dependencies` 中添加 `flutter_localizations` SDK 依赖
- 确认 `intl` 依赖已存在
- 在 `flutter` 配置中添加 `generate: true` 以启用代码生成

#### [NEW] [l10n.yaml](file:///D:/git/reeder/l10n.yaml)
- 创建国际化配置文件
- 配置 ARB 文件目录为 `lib/l10n`
- 配置模板 ARB 文件为 `app_en.arb`
- 配置输出类名为 `AppLocalizations`

---

### 2. ARB 资源文件

创建英文和中文的 ARB 资源文件，包含所有需要翻译的字符串。

#### [NEW] [app_en.arb](file:///D:/git/reeder/lib/l10n/app_en.arb)
- 英文模板文件，包含所有国际化键值对
- 包含约 150+ 条翻译条目
- 按模块分组：app、settings、source_list、article、search、player、filter、error、empty 等

#### [NEW] [app_zh.arb](file:///D:/git/reeder/lib/l10n/app_zh.arb)
- 中文翻译文件，与英文模板一一对应
- 所有条目翻译为简体中文

---

### 3. 应用入口配置

#### [MODIFY] [app.dart](file:///D:/git/reeder/lib/app.dart)
- 导入 `flutter_localizations` 和生成的 `AppLocalizations`
- 在 `MaterialApp` / `MaterialApp.router` 中添加 `localizationsDelegates`
- 添加 `supportedLocales` 配置（英文、中文）
- 添加 `locale` 配置（可选，跟随系统）

---

### 4. 设置模块字符串替换

#### [MODIFY] [settings_page.dart](file:///D:/git/reeder/lib/features/settings/settings_page.dart)
- 替换所有硬编码字符串为 `AppLocalizations.of(context)!.xxx` 引用
- 涉及字符串：Settings、Loading...、Error、Appearance、Theme、Compact Mode、Show Thumbnails、Show Feed Icons、Reading 等

#### [MODIFY] [theme_settings_page.dart](file:///D:/git/reeder/lib/features/settings/theme_settings_page.dart)
- 替换：Theme、Light、Dark、OLED Black、Dark Light 及其描述文本

#### [MODIFY] [reading_settings_page.dart](file:///D:/git/reeder/lib/features/settings/reading_settings_page.dart)
- 替换：Reading、Loading...、Error、Font Size、Line Height

#### [MODIFY] [data_settings_page.dart](file:///D:/git/reeder/lib/features/settings/data_settings_page.dart)
- 替换：Data & Storage、Refresh、Auto-Refresh、Content、Content Expiry、Cache Images、Import/Export OPML、Danger Zone、Clear All Data 及其描述文本
- 替换时间单位：Manual、min、h、day、month、year 等

#### [MODIFY] [about_page.dart](file:///D:/git/reeder/lib/features/settings/about_page.dart)
- 替换：About、Version、应用描述、Links、Privacy Policy、Terms of Service、Source Code、Acknowledgments 及其描述文本

---

### 5. 源列表模块字符串替换

#### [MODIFY] [source_list_page.dart](file:///D:/git/reeder/lib/features/source_list/source_list_page.dart)
- 替换：Reeder、Loading...、Error、Home、All、Articles、Podcasts、Videos、Feeds

#### [MODIFY] [add_feed_dialog.dart](file:///D:/git/reeder/lib/features/source_list/widgets/add_feed_dialog.dart)
- 替换：Add Feed、Enter feed or website URL、Searching...、Found feeds、Please enter a URL、No feeds found 等

---

### 6. 文章详情模块字符串替换

#### [MODIFY] [article_action_bar.dart](file:///D:/git/reeder/lib/features/article_detail/widgets/article_action_bar.dart)
- 替换：Later、Bookmark、Favorite、Share、Browser

---

### 7. 搜索模块字符串替换

#### [MODIFY] [search_page.dart](file:///D:/git/reeder/lib/features/search/search_page.dart)
- 替换：Search、Search articles...

---

### 8. 播放器模块字符串替换

#### [MODIFY] [mini_player.dart](file:///D:/git/reeder/lib/features/podcast_player/mini_player.dart)
- 替换：Unknown Episode

#### [MODIFY] [full_player_page.dart](file:///D:/git/reeder/lib/features/podcast_player/full_player_page.dart)
- 替换：Now Playing、No episode playing、Unknown Episode

---

### 9. 视频播放器模块字符串替换

#### [MODIFY] [video_player_page.dart](file:///D:/git/reeder/lib/features/video_player/video_player_page.dart)
- 替换：Failed to play video

---

### 10. 过滤器模块字符串替换

#### [MODIFY] [filter_editor_page.dart](file:///D:/git/reeder/lib/features/filter/filter_editor_page.dart)
- 替换：Edit Filter、New Filter、Save、Loading...、Name、Filter name、Include Keywords、Exclude Keywords、Content Types 及其描述文本
- 替换内容类型标签：Article、Audio、Video、Image

---

### 11. 共享组件字符串替换

#### [MODIFY] [error_state.dart](file:///D:/git/reeder/lib/shared/widgets/error_state.dart)
- 替换：Something went wrong、Try Again、No internet connection、Check your connection、Failed to load feed、Failed to parse content、Retry 等

#### [MODIFY] [empty_state.dart](file:///D:/git/reeder/lib/shared/widgets/empty_state.dart)
- 替换：No articles yet、Pull down to refresh、No results found、Try a different search term、No feeds yet、Add Feed、No tagged items 等

---

## Verification Plan

### Automated Tests
- 运行 `flutter pub get` 确保依赖安装成功
- 运行 `flutter gen-l10n` 确保国际化代码生成成功
- 运行 `flutter analyze` 确保无编译错误
- 运行 `flutter test` 确保现有测试通过

### Manual Verification
- 将设备/模拟器语言切换为中文，验证所有页面文本正确显示中文
- 将设备/模拟器语言切换为英文，验证所有页面文本正确显示英文
- 检查所有带参数的翻译字符串（如时间单位、数量等）是否正确插值


updateAtTime: 2026/4/10 17:42:15

planId: 28e4666c-3f4a-497d-9f2e-1252ece6b043