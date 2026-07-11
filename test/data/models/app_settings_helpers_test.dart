import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/data/models/app_settings_helpers.dart';

AppSettingsTableData _settings({
  int themeModeIndex = 4,
  int fontSizeLevel = 3,
  int lineHeightLevel = 2,
}) {
  return AppSettingsTableData(
    id: 0,
    themeModeIndex: themeModeIndex,
    fontSizeLevel: fontSizeLevel,
    lineHeightLevel: lineHeightLevel,
    maxContentWidth: 680.0,
    bionicReading: false,
    defaultFullscreenReading: false,
    showAvatars: true,
    avatarStyle: 'rounded',
    showFolderIcons: true,
    showThumbnails: true,
    compactMode: false,
    sortOrder: 'newest',
    groupByFeed: false,
    hideReadFeeds: false,
    hideReadArticles: true,
    markReadOnScroll: false,
    contentExpiryDays: 0,
    notificationsEnabled: false,
    cacheImages: true,
    maxCacheSizeMB: 500,
    autoRefreshIntervalMinutes: 30,
    playbackSpeed: 1.0,
    skipForwardSeconds: 30,
    skipBackwardSeconds: 15,
  );
}

void main() {
  group('themeMode', () {
    test('valid index maps to enum', () {
      expect(_settings(themeModeIndex: 0).themeMode,
          ReederThemeMode.values[0]);
    });

    test('out-of-range index falls back to system', () {
      expect(_settings(themeModeIndex: 999).themeMode, ReederThemeMode.system);
      expect(_settings(themeModeIndex: -1).themeMode, ReederThemeMode.system);
    });
  });

  group('fontSize', () {
    test('maps level to px', () {
      expect(_settings(fontSizeLevel: 0).fontSize, 12.0);
      expect(_settings(fontSizeLevel: 3).fontSize, 16.0);
      expect(_settings(fontSizeLevel: 6).fontSize, 22.0);
    });

    test('clamps out-of-range level', () {
      expect(_settings(fontSizeLevel: 99).fontSize, 22.0);
      expect(_settings(fontSizeLevel: -5).fontSize, 12.0);
    });
  });

  group('lineHeight', () {
    test('maps level to multiplier', () {
      expect(_settings(lineHeightLevel: 0).lineHeight, 1.2);
      expect(_settings(lineHeightLevel: 2).lineHeight, 1.5);
      expect(_settings(lineHeightLevel: 4).lineHeight, 1.8);
    });

    test('clamps out-of-range level', () {
      expect(_settings(lineHeightLevel: 99).lineHeight, 1.8);
      expect(_settings(lineHeightLevel: -1).lineHeight, 1.2);
    });
  });
}
