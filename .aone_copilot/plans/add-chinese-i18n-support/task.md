### add-chinese-i18n-support ###

# 国际化支持任务清单

## 基础配置
- [x] 修改 `pubspec.yaml`，添加 `flutter_localizations` 依赖和 `generate: true` 配置
- [x] 创建 `l10n.yaml` 国际化配置文件
- [x] 创建 `lib/l10n/app_en.arb` 英文模板资源文件（包含所有国际化键值对）
- [x] 创建 `lib/l10n/app_zh.arb` 中文翻译资源文件
- [x] 运行 `flutter pub get` 安装依赖
- [/] 运行 `flutter gen-l10n` 生成国际化代码

## 应用入口配置
- [x] 修改 `lib/app.dart`，添加 localizationsDelegates 和 supportedLocales 配置

## 设置模块字符串替换
- [x] 替换 `lib/features/settings/settings_page.dart` 中的硬编码字符串
- [x] 替换 `lib/features/settings/theme_settings_page.dart` 中的硬编码字符串
- [x] 替换 `lib/features/settings/reading_settings_page.dart` 中的硬编码字符串
- [x] 替换 `lib/features/settings/data_settings_page.dart` 中的硬编码字符串
- [x] 替换 `lib/features/settings/about_page.dart` 中的硬编码字符串

## 源列表模块字符串替换
- [x] 替换 `lib/features/source_list/source_list_page.dart` 中的硬编码字符串
- [x] 替换 `lib/features/source_list/widgets/add_feed_dialog.dart` 中的硬编码字符串

## 文章模块字符串替换
- [x] 替换 `lib/features/article_detail/widgets/article_action_bar.dart` 中的硬编码字符串

## 搜索模块字符串替换
- [x] 替换 `lib/features/search/search_page.dart` 中的硬编码字符串

## 播放器模块字符串替换
- [x] 替换 `lib/features/podcast_player/mini_player.dart` 中的硬编码字符串
- [x] 替换 `lib/features/podcast_player/full_player_page.dart` 中的硬编码字符串

## 视频播放器模块字符串替换
- [x] 替换 `lib/features/video_player/video_player_page.dart` 中的硬编码字符串

## 过滤器模块字符串替换
- [x] 替换 `lib/features/filter/filter_editor_page.dart` 中的硬编码字符串

## 共享组件字符串替换
- [x] 替换 `lib/shared/widgets/error_state.dart` 中的硬编码字符串
- [x] 替换 `lib/shared/widgets/empty_state.dart` 中的硬编码字符串

## 验证
- [ ] 运行 `flutter pub get` 确保依赖安装成功
- [ ] 运行 `flutter gen-l10n` 确保国际化代码生成成功
- [ ] 运行 `flutter analyze` 确保无编译错误
- [ ] 运行 `flutter test` 确保现有测试通过


updateAtTime: 2026/4/10 17:42:15

planId: 28e4666c-3f4a-497d-9f2e-1252ece6b043