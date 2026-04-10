### isar-to-drift-migration ###
# 修复 flutter analyze 剩余 errors 和 warnings（第三轮）

## Phase N: rss_remote_ds.dart

- [x] N.1 rss_remote_ds.dart: `atomFeed.entries` → `atomFeed.items`

## Phase O: app.dart

- [x] O.1 app.dart: 移除行 156 不必要的 `!` 非空断言

## Phase P: unused imports/variables 清理

- [x] P.1 html_parser.dart: 移除 unused import `html/dom.dart`
- [x] P.2 settings_repository.dart: 移除 unused import `app_settings.dart`
- [x] P.3 background_refresh_service.dart: 移除 3 个 unused imports
- [x] P.4 reader_view_service.dart: 移除 unused import `html_parser.dart`
- [x] P.5 article_list_page.dart: 移除 unused import `tag_repository.dart`
- [x] P.6 swipe_action_widget.dart: 移除 unused import + unused variable
- [x] P.7 timeline_control_button.dart: 移除 unused import `app_dimensions.dart`
- [x] P.8 filter_controller.dart: 移除 unused field `_ref`
- [x] P.9 filter_editor_page.dart: 移除 unused variable `theme`
- [x] P.10 image_viewer_page.dart: 移除 unused import + unused variable
- [x] P.11 full_player_page.dart: 移除 unused import `app_durations.dart`
- [x] P.12 mini_player.dart: 移除 2 个 unused imports
- [x] P.13 source_list_page.dart: 移除 unused variable `folderItems`
- [x] P.14 video_player_page.dart: 移除 unused import `app_durations.dart`
- [x] P.15 adaptive_scaffold.dart: 移除 2 个 unused variables `detailWidth`
- [x] P.16 pull_to_refresh.dart: 移除 unused import `app_dimensions.dart`
- [x] P.17 reeder_dialog.dart: 移除 unused import `reeder_button.dart`
- [x] P.18 reeder_page_transition.dart: 移除 unused field `_popThreshold`

## Phase Q: 测试文件修复

- [x] Q.1 article_repository_test.dart: 修复 DateFormatter API 调用
- [x] Q.2 article_repository_test.dart: 修复 OpmlParser API 调用
- [x] Q.3 widget_test.dart: 重写为 ReederApp 冒烟测试

## Phase R: 验证

- [x] R.1 IDE linter 确认 0 errors, 0 warnings

updateAtTime: 2026/4/10 15:58:31

planId: 2c8b1925-60e0-45c8-9e93-aa9f0667e57e