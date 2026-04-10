import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../datasources/local/settings_local_ds.dart';
import '../models/app_settings_helpers.dart';

/// Repository for application settings.
///
/// Provides a clean API for reading and writing user preferences.
/// Wraps [SettingsLocalDataSource] with convenience methods.
///
/// Note: Drift data classes are immutable. The [updateSettings] callback
/// in [SettingsLocalDataSource] receives the current [AppSettingsTableData]
/// and must return an [AppSettingsTableCompanion] with the fields to update.
class SettingsRepository {
  final SettingsLocalDataSource _localDs;

  SettingsRepository({SettingsLocalDataSource? localDs})
      : _localDs = localDs ?? SettingsLocalDataSource();

  /// Gets the current settings.
  Future<AppSettingsTableData> getSettings() {
    return _localDs.getSettings();
  }

  /// Saves the full settings object.
  Future<void> saveSettings(AppSettingsTableCompanion settings) {
    return _localDs.saveSettings(settings);
  }

  /// Resets all settings to defaults.
  Future<AppSettingsTableData> resetToDefaults() {
    return _localDs.resetToDefaults();
  }

  /// Watches settings for changes.
  Stream<AppSettingsTableData> watchSettings() {
    return _localDs.watchSettings();
  }

  // ─── Theme Settings ───────────────────────────────────────

  /// Gets the current theme mode.
  Future<ReederThemeMode> getThemeMode() async {
    final settings = await _localDs.getSettings();
    return settings.themeMode;
  }

  /// Sets the theme mode.
  Future<void> setThemeMode(ReederThemeMode mode) async {
    await _localDs.updateSettings(
      (s) => const AppSettingsTableCompanion(
        themeModeIndex: Value(0),
      ).copyWith(themeModeIndex: Value(mode.index)),
    );
  }

  // ─── Reading Settings ─────────────────────────────────────

  /// Gets the font size level.
  Future<int> getFontSizeLevel() async {
    final settings = await _localDs.getSettings();
    return settings.fontSizeLevel;
  }

  /// Sets the font size level (0-6).
  Future<void> setFontSizeLevel(int level) async {
    await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        fontSizeLevel: Value(level.clamp(0, 6)),
      ),
    );
  }

  /// Gets the line height level.
  Future<int> getLineHeightLevel() async {
    final settings = await _localDs.getSettings();
    return settings.lineHeightLevel;
  }

  /// Sets the line height level (0-4).
  Future<void> setLineHeightLevel(int level) async {
    await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        lineHeightLevel: Value(level.clamp(0, 4)),
      ),
    );
  }

  /// Toggles Bionic Reading mode.
  Future<bool> toggleBionicReading() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        bionicReading: Value(!s.bionicReading),
      ),
    );
    return settings.bionicReading;
  }

  // ─── Display Settings ─────────────────────────────────────

  /// Toggles compact mode.
  Future<bool> toggleCompactMode() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        compactMode: Value(!s.compactMode),
      ),
    );
    return settings.compactMode;
  }

  /// Toggles thumbnail display.
  Future<bool> toggleShowThumbnails() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        showThumbnails: Value(!s.showThumbnails),
      ),
    );
    return settings.showThumbnails;
  }

  /// Toggles avatar display.
  Future<bool> toggleShowAvatars() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        showAvatars: Value(!s.showAvatars),
      ),
    );
    return settings.showAvatars;
  }

  // ─── Timeline Settings ────────────────────────────────────

  /// Sets the sort order ('newest' or 'oldest').
  Future<void> setSortOrder(String order) async {
    await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        sortOrder: Value(order),
      ),
    );
  }

  /// Toggles group-by-feed in timeline.
  Future<bool> toggleGroupByFeed() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        groupByFeed: Value(!s.groupByFeed),
      ),
    );
    return settings.groupByFeed;
  }

  /// Toggles mark-as-read on scroll.
  Future<bool> toggleMarkReadOnScroll() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        markReadOnScroll: Value(!s.markReadOnScroll),
      ),
    );
    return settings.markReadOnScroll;
  }

  /// Sets content expiry days (0 = never).
  Future<void> setContentExpiryDays(int days) async {
    await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        contentExpiryDays: Value(days.clamp(0, 365)),
      ),
    );
  }

  // ─── Data Settings ────────────────────────────────────────

  /// Sets the auto-refresh interval in minutes (0 = manual only).
  Future<void> setAutoRefreshInterval(int minutes) async {
    await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        autoRefreshIntervalMinutes: Value(minutes),
      ),
    );
  }

  /// Toggles image caching.
  Future<bool> toggleCacheImages() async {
    final settings = await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        cacheImages: Value(!s.cacheImages),
      ),
    );
    return settings.cacheImages;
  }

  // ─── Podcast Settings ─────────────────────────────────────

  /// Sets the playback speed.
  Future<void> setPlaybackSpeed(double speed) async {
    await _localDs.updateSettings(
      (s) => AppSettingsTableCompanion(
        playbackSpeed: Value(speed.clamp(0.5, 3.0)),
      ),
    );
  }
}
