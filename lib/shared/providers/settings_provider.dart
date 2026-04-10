import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_settings_helpers.dart';
import '../../data/repositories/settings_repository.dart';
import 'theme_provider.dart';

/// Provider for the [SettingsRepository] singleton.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Provider for the current [AppSettingsTableData].
///
/// Loads settings from the database on first access and
/// provides methods to update individual settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettingsTableData>>(
  (ref) => SettingsNotifier(ref),
);

/// Notifier that manages application settings state.
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettingsTableData>> {
  final Ref _ref;
  late final SettingsRepository _repository;

  SettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _repository = _ref.read(settingsRepositoryProvider);
    _loadSettings();
  }

  /// Loads settings from the database.
  Future<void> _loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);

      // Sync theme mode with theme provider
      _ref.read(themeModeProvider.notifier).setThemeMode(settings.themeMode);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reloads settings from the database.
  Future<void> reload() => _loadSettings();

  /// Updates the theme mode.
  Future<void> setThemeMode(ReederThemeMode mode) async {
    await _repository.setThemeMode(mode);
    _ref.read(themeModeProvider.notifier).setThemeMode(mode);
    await _loadSettings();
  }

  /// Updates the font size level.
  Future<void> setFontSizeLevel(int level) async {
    await _repository.setFontSizeLevel(level);
    await _loadSettings();
  }

  /// Updates the line height level.
  Future<void> setLineHeightLevel(int level) async {
    await _repository.setLineHeightLevel(level);
    await _loadSettings();
  }

  /// Toggles Bionic Reading mode.
  Future<void> toggleBionicReading() async {
    await _repository.toggleBionicReading();
    await _loadSettings();
  }

  /// Toggles compact mode.
  Future<void> toggleCompactMode() async {
    await _repository.toggleCompactMode();
    await _loadSettings();
  }

  /// Toggles thumbnail display.
  Future<void> toggleShowThumbnails() async {
    await _repository.toggleShowThumbnails();
    await _loadSettings();
  }

  /// Toggles avatar display.
  Future<void> toggleShowAvatars() async {
    await _repository.toggleShowAvatars();
    await _loadSettings();
  }

  /// Sets the sort order.
  Future<void> setSortOrder(String order) async {
    await _repository.setSortOrder(order);
    await _loadSettings();
  }

  /// Toggles group-by-feed in timeline.
  Future<void> toggleGroupByFeed() async {
    await _repository.toggleGroupByFeed();
    await _loadSettings();
  }

  /// Toggles mark-as-read on scroll.
  Future<void> toggleMarkReadOnScroll() async {
    await _repository.toggleMarkReadOnScroll();
    await _loadSettings();
  }

  /// Sets content expiry days.
  Future<void> setContentExpiryDays(int days) async {
    await _repository.setContentExpiryDays(days);
    await _loadSettings();
  }

  /// Sets auto-refresh interval.
  Future<void> setAutoRefreshInterval(int minutes) async {
    await _repository.setAutoRefreshInterval(minutes);
    await _loadSettings();
  }

  /// Sets playback speed.
  Future<void> setPlaybackSpeed(double speed) async {
    await _repository.setPlaybackSpeed(speed);
    await _loadSettings();
  }

  /// Resets all settings to defaults.
  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    await _loadSettings();
  }
}

/// Convenience provider for specific settings values.

/// Whether compact mode is enabled.
final compactModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.compactMode) ??
      false;
});

/// Whether thumbnails should be shown.
final showThumbnailsProvider = Provider<bool>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.showThumbnails) ??
      true;
});

/// Whether avatars should be shown.
final showAvatarsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.showAvatars) ??
      true;
});

/// Current font size in logical pixels.
final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.fontSize) ??
      16.0;
});

/// Current line height multiplier.
final lineHeightProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.lineHeight) ??
      1.5;
});
