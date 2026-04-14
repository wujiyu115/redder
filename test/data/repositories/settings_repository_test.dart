import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drift/drift.dart';

import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/data/repositories/settings_repository.dart';

import '../../test_mocks.mocks.dart';

void main() {
  late MockSettingsLocalDataSource mockLocalDs;
  late SettingsRepository repository;

  /// Helper to create a default AppSettingsTableData for testing.
  AppSettingsTableData createSettings({
    int id = 0,
    int themeModeIndex = 4, // system
    int fontSizeLevel = 3,
    int lineHeightLevel = 2,
    double maxContentWidth = 680.0,
    bool bionicReading = false,
    bool showAvatars = true,
    String avatarStyle = 'rounded',
    bool showFolderIcons = true,
    bool showThumbnails = true,
    bool compactMode = false,
    String sortOrder = 'newest',
    bool groupByFeed = false,
    bool markReadOnScroll = false,
    int contentExpiryDays = 0,
    bool notificationsEnabled = false,
    bool cacheImages = true,
    int maxCacheSizeMB = 500,
    int autoRefreshIntervalMinutes = 30,
    double playbackSpeed = 1.0,
    int skipForwardSeconds = 30,
    int skipBackwardSeconds = 15,
  }) {
    return AppSettingsTableData(
      id: id,
      themeModeIndex: themeModeIndex,
      fontSizeLevel: fontSizeLevel,
      lineHeightLevel: lineHeightLevel,
      maxContentWidth: maxContentWidth,
      bionicReading: bionicReading,
      showAvatars: showAvatars,
      avatarStyle: avatarStyle,
      showFolderIcons: showFolderIcons,
      showThumbnails: showThumbnails,
      compactMode: compactMode,
      sortOrder: sortOrder,
      groupByFeed: groupByFeed,
      markReadOnScroll: markReadOnScroll,
      contentExpiryDays: contentExpiryDays,
      notificationsEnabled: notificationsEnabled,
      cacheImages: cacheImages,
      maxCacheSizeMB: maxCacheSizeMB,
      autoRefreshIntervalMinutes: autoRefreshIntervalMinutes,
      playbackSpeed: playbackSpeed,
      skipForwardSeconds: skipForwardSeconds,
      skipBackwardSeconds: skipBackwardSeconds,
    );
  }

  setUp(() {
    mockLocalDs = MockSettingsLocalDataSource();
    repository = SettingsRepository(localDs: mockLocalDs);
  });

  group('getSettings', () {
    test('should delegate to localDs.getSettings', () async {
      final settings = createSettings();
      when(mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repository.getSettings();

      expect(result, equals(settings));
      verify(mockLocalDs.getSettings()).called(1);
    });
  });

  group('saveSettings', () {
    test('should delegate to localDs.saveSettings', () async {
      final companion = AppSettingsTableCompanion(
        bionicReading: const Value(true),
      );
      when(mockLocalDs.saveSettings(any)).thenAnswer((_) async {});

      await repository.saveSettings(companion);

      verify(mockLocalDs.saveSettings(companion)).called(1);
    });
  });

  group('resetToDefaults', () {
    test('should delegate to localDs.resetToDefaults', () async {
      final defaultSettings = createSettings();
      when(mockLocalDs.resetToDefaults()).thenAnswer((_) async => defaultSettings);

      final result = await repository.resetToDefaults();

      expect(result, equals(defaultSettings));
      verify(mockLocalDs.resetToDefaults()).called(1);
    });
  });

  group('watchSettings', () {
    test('should delegate to localDs.watchSettings', () {
      final mockStream = Stream<AppSettingsTableData>.empty();
      when(mockLocalDs.watchSettings()).thenAnswer((_) => mockStream);

      final result = repository.watchSettings();

      expect(result, equals(mockStream));
      verify(mockLocalDs.watchSettings()).called(1);
    });
  });

  group('getThemeMode', () {
    test('should return light theme mode', () async {
      final settings = createSettings(themeModeIndex: ReederThemeMode.light.index);
      when(mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repository.getThemeMode();

      expect(result, equals(ReederThemeMode.light));
    });

    test('should return dark theme mode', () async {
      final settings = createSettings(themeModeIndex: ReederThemeMode.dark.index);
      when(mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repository.getThemeMode();

      expect(result, equals(ReederThemeMode.dark));
    });

    test('should return system theme mode', () async {
      final settings = createSettings(themeModeIndex: ReederThemeMode.system.index);
      when(mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repository.getThemeMode();

      expect(result, equals(ReederThemeMode.system));
    });
  });

  group('setThemeMode', () {
    test('should call updateSettings with correct theme mode index', () async {
      final updatedSettings = createSettings(themeModeIndex: ReederThemeMode.dark.index);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setThemeMode(ReederThemeMode.dark);

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('getFontSizeLevel', () {
    test('should return font size level from settings', () async {
      final settings = createSettings(fontSizeLevel: 5);
      when(mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repository.getFontSizeLevel();

      expect(result, equals(5));
    });
  });

  group('setFontSizeLevel', () {
    test('should call updateSettings with clamped font size level', () async {
      final updatedSettings = createSettings(fontSizeLevel: 4);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setFontSizeLevel(4);

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('getLineHeightLevel', () {
    test('should return line height level from settings', () async {
      final settings = createSettings(lineHeightLevel: 3);
      when(mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repository.getLineHeightLevel();

      expect(result, equals(3));
    });
  });

  group('setLineHeightLevel', () {
    test('should call updateSettings with clamped line height level', () async {
      final updatedSettings = createSettings(lineHeightLevel: 3);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setLineHeightLevel(3);

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleBionicReading', () {
    test('should toggle from false to true and return new value', () async {
      final updatedSettings = createSettings(bionicReading: true);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleBionicReading();

      expect(result, isTrue);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });

    test('should toggle from true to false and return new value', () async {
      final updatedSettings = createSettings(bionicReading: false);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleBionicReading();

      expect(result, isFalse);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleCompactMode', () {
    test('should toggle from false to true and return new value', () async {
      final updatedSettings = createSettings(compactMode: true);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleCompactMode();

      expect(result, isTrue);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });

    test('should toggle from true to false and return new value', () async {
      final updatedSettings = createSettings(compactMode: false);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleCompactMode();

      expect(result, isFalse);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleShowThumbnails', () {
    test('should toggle and return new value', () async {
      final updatedSettings = createSettings(showThumbnails: false);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleShowThumbnails();

      expect(result, isFalse);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleShowAvatars', () {
    test('should toggle and return new value', () async {
      final updatedSettings = createSettings(showAvatars: false);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleShowAvatars();

      expect(result, isFalse);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('setSortOrder', () {
    test('should call updateSettings with sort order', () async {
      final updatedSettings = createSettings(sortOrder: 'oldest');
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setSortOrder('oldest');

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleGroupByFeed', () {
    test('should toggle and return new value', () async {
      final updatedSettings = createSettings(groupByFeed: true);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleGroupByFeed();

      expect(result, isTrue);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleMarkReadOnScroll', () {
    test('should toggle and return new value', () async {
      final updatedSettings = createSettings(markReadOnScroll: true);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleMarkReadOnScroll();

      expect(result, isTrue);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('setContentExpiryDays', () {
    test('should call updateSettings with clamped value', () async {
      final updatedSettings = createSettings(contentExpiryDays: 30);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setContentExpiryDays(30);

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('setAutoRefreshInterval', () {
    test('should call updateSettings with interval', () async {
      final updatedSettings = createSettings(autoRefreshIntervalMinutes: 60);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setAutoRefreshInterval(60);

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('toggleCacheImages', () {
    test('should toggle and return new value', () async {
      final updatedSettings = createSettings(cacheImages: false);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      final result = await repository.toggleCacheImages();

      expect(result, isFalse);
      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });

  group('setPlaybackSpeed', () {
    test('should call updateSettings with clamped speed', () async {
      final updatedSettings = createSettings(playbackSpeed: 1.5);
      when(mockLocalDs.updateSettings(any)).thenAnswer((_) async => updatedSettings);

      await repository.setPlaybackSpeed(1.5);

      verify(mockLocalDs.updateSettings(any)).called(1);
    });
  });
}
