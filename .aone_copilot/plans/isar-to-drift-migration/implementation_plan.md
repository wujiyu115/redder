### isar-to-drift-migration ###
修复 flutter analyze 发现的所有剩余 errors 和 warnings（第三轮），包括 rss_remote_ds.dart 的 AtomFeed API、测试文件的旧 API 引用、以及全项目范围的 unused imports/variables 清理。

# 修复 flutter analyze 剩余 errors 和 warnings（第三轮）

## 背景

第二轮修复完成后，`flutter analyze` 仍发现 11 个 errors 和大量 warnings。本轮将全部修复。

> [!IMPORTANT]
> 测试文件 `article_repository_test.dart` 使用了大量旧 API，需要根据当前实际的类定义进行全面修正。
> `widget_test.dart` 是 Flutter 默认模板，与项目不匹配，需要重写。

## Proposed Changes

### Phase N: 修复 rss_remote_ds.dart 残留 error

#### [MODIFY] [rss_remote_ds.dart](file:///D:/git/reeder/lib/data/datasources/remote/rss_remote_ds.dart)
- `atomFeed.entries` → `atomFeed.items`（webfeed_plus 的 AtomFeed 使用 `items` 属性）

---

### Phase O: 修复 app.dart 残留 warning

#### [MODIFY] [app.dart](file:///D:/git/reeder/lib/app.dart)
- 行 156: 移除不必要的 `!` 非空断言

---

### Phase P: 修复 unused imports/variables（lib 目录）

#### [MODIFY] [html_parser.dart](file:///D:/git/reeder/lib/core/utils/html_parser.dart)
- 移除 unused import `package:html/dom.dart`

#### [MODIFY] [settings_repository.dart](file:///D:/git/reeder/lib/data/repositories/settings_repository.dart)
- 移除 unused import `../models/app_settings.dart`

#### [MODIFY] [background_refresh_service.dart](file:///D:/git/reeder/lib/data/services/background_refresh_service.dart)
- 移除 unused imports: `dart:isolate`, `dart:ui`, `app_database.dart`

#### [MODIFY] [reader_view_service.dart](file:///D:/git/reeder/lib/data/services/reader_view_service.dart)
- 移除 unused import `html_parser.dart`

#### [MODIFY] [article_list_page.dart](file:///D:/git/reeder/lib/features/article_list/article_list_page.dart)
- 移除 unused import `tag_repository.dart`

#### [MODIFY] [swipe_action_widget.dart](file:///D:/git/reeder/lib/features/article_list/widgets/swipe_action_widget.dart)
- 移除 unused import `app_dimensions.dart`
- 移除 unused variable `theme`（行 181）

#### [MODIFY] [timeline_control_button.dart](file:///D:/git/reeder/lib/features/article_list/widgets/timeline_control_button.dart)
- 移除 unused import `app_dimensions.dart`

#### [MODIFY] [filter_controller.dart](file:///D:/git/reeder/lib/features/filter/filter_controller.dart)
- 移除 unused field `_ref`（行 32）

#### [MODIFY] [filter_editor_page.dart](file:///D:/git/reeder/lib/features/filter/filter_editor_page.dart)
- 移除 unused variable `theme`（行 440，`_confirmDelete` 方法中）

#### [MODIFY] [image_viewer_page.dart](file:///D:/git/reeder/lib/features/image_viewer/image_viewer_page.dart)
- 移除 unused import `app_durations.dart`
- 移除 unused variable `theme`（行 91）

#### [MODIFY] [full_player_page.dart](file:///D:/git/reeder/lib/features/podcast_player/full_player_page.dart)
- 移除 unused import `app_durations.dart`

#### [MODIFY] [mini_player.dart](file:///D:/git/reeder/lib/features/podcast_player/mini_player.dart)
- 移除 unused imports: `app_durations.dart`, `podcast_service.dart`

#### [MODIFY] [source_list_page.dart](file:///D:/git/reeder/lib/features/source_list/source_list_page.dart)
- 移除 unused variable `folderItems`（行 357）

#### [MODIFY] [video_player_page.dart](file:///D:/git/reeder/lib/features/video_player/video_player_page.dart)
- 移除 unused import `app_durations.dart`

#### [MODIFY] [adaptive_scaffold.dart](file:///D:/git/reeder/lib/shared/widgets/adaptive_scaffold.dart)
- 移除 unused variable `detailWidth`（行 151 和 220）

#### [MODIFY] [pull_to_refresh.dart](file:///D:/git/reeder/lib/shared/widgets/pull_to_refresh.dart)
- 移除 unused import `app_dimensions.dart`

#### [MODIFY] [reeder_dialog.dart](file:///D:/git/reeder/lib/shared/widgets/reeder_dialog.dart)
- 移除 unused import `reeder_button.dart`

#### [MODIFY] [reeder_page_transition.dart](file:///D:/git/reeder/lib/shared/widgets/reeder_page_transition.dart)
- 移除 unused field `_popThreshold`（行 106）

---

### Phase Q: 修复测试文件 errors

#### [MODIFY] [article_repository_test.dart](file:///D:/git/reeder/test/data/repositories/article_repository_test.dart)
- `DateFormatter.formatRelative()` → `DateFormatter.relativeTime()`
- `DateFormatter.estimateReadingTime()` → 使用 `DateFormatter.readingTime()` 或 `readingTimeFromContent()`
- `result.feeds` → 直接使用 `result`（`OpmlParser.parse()` 返回 `List<OpmlOutline>`）
- `OpmlFeed(...)` → `OpmlOutline(...)` 或 `FlatOpmlFeed(...)`
- `OpmlParser.export(...)` → `OpmlParser.generate(...)`

#### [MODIFY] [widget_test.dart](file:///D:/git/reeder/test/widget_test.dart)
- 重写为使用 `ReederApp` 的基本冒烟测试，或删除默认模板内容

---

### Phase R: 验证

- 运行 `flutter analyze` 确认 0 errors

## Verification Plan

### Automated Tests
- `flutter analyze`（目标：0 errors, 0 warnings）

### Manual Verification
- `flutter run` 在 Android 设备上验证构建和启动

updateAtTime: 2026/4/10 15:58:31

planId: 2c8b1925-60e0-45c8-9e93-aa9f0667e57e