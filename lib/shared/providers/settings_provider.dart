import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_settings_helpers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/background_refresh_service.dart';
import '../../data/services/image_cache_manager.dart';
import 'theme_provider.dart';

/// Sort order for timelines.
///
/// Stored in settings as a lowercase string ('newest' / 'oldest');
/// exposed to consumers as a typed enum via [sortOrderProvider].
enum SortOrder { newest, oldest }

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

  /// Toggles default fullscreen reading mode.
  Future<void> toggleDefaultFullscreenReading() async {
    await _repository.toggleDefaultFullscreenReading();
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

  /// Toggles hiding fully-read feeds in the source list.
  Future<void> toggleHideReadFeeds() async {
    await _repository.toggleHideReadFeeds();
    await _loadSettings();
  }

  /// Toggles hiding read articles in timelines.
  Future<void> toggleHideReadArticles() async {
    await _repository.toggleHideReadArticles();
    await _loadSettings();
  }

  /// Toggles caching of article images for offline reading.
  Future<void> toggleCacheImages() async {
    await _repository.toggleCacheImages();
    await _loadSettings();
  }

  /// Enables/disables the app-level master notifications toggle.
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _repository.setNotificationsEnabled(enabled);
    await _loadSettings();
  }

  /// Sets content expiry days.
  Future<void> setContentExpiryDays(int days) async {
    await _repository.setContentExpiryDays(days);
    await _loadSettings();
  }

  /// Sets auto-refresh interval.
  ///
  /// Persists the value and applies it to the live background timer so
  /// runtime changes take effect without an app restart.
  Future<void> setAutoRefreshInterval(int minutes) async {
    await _repository.setAutoRefreshInterval(minutes);
    await _loadSettings();
    if (minutes > 0) {
      BackgroundRefreshService.updateInterval(Duration(minutes: minutes));
    } else {
      // 0 = manual only: pause the periodic timer.
      BackgroundRefreshService.pause();
    }
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

/// Whether read articles are hidden in timelines.
final hideReadArticlesProvider = Provider<bool>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.hideReadArticles) ??
      true;
});

/// Whether articles open in fullscreen reading mode by default.
final defaultFullscreenReadingProvider = Provider<bool>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.defaultFullscreenReading) ??
      false;
});

/// Typed timeline sort order. Consumer (article list controller) should read
/// this instead of hardcoding `OrderingTerm.desc(t.publishedAt)`.
final sortOrderProvider = Provider<SortOrder>((ref) {
  final raw = ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.sortOrder) ??
      'newest';
  return raw == 'oldest' ? SortOrder.oldest : SortOrder.newest;
});

/// Max content width (px) for reading columns.
final maxContentWidthProvider = Provider<double>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.maxContentWidth) ??
      680.0;
});

/// Default podcast playback speed.
final playbackSpeedProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.playbackSpeed) ??
      1.0;
});

/// Seconds skipped forward in podcast playback.
final skipForwardSecondsProvider = Provider<int>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.skipForwardSeconds) ??
      30;
});

/// Seconds skipped backward in podcast playback.
final skipBackwardSecondsProvider = Provider<int>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.skipBackwardSeconds) ??
      15;
});

/// Auto-refresh interval in minutes (0 = manual only).
final autoRefreshIntervalMinutesProvider = Provider<int>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.autoRefreshIntervalMinutes) ??
      30;
});

/// Content expiry in days (0 = never expire).
final contentExpiryDaysProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.contentExpiryDays) ??
      0;
});

/// Whether article images should be cached for offline reading.
///
/// `CachedNetworkImage` call sites gate on this: when false they fall back
/// to `Image.network` (no disk cache); when true they use `CachedNetworkImage`
/// with [ReederImageCacheManager].
final cacheImagesProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.cacheImages) ??
      true;
});

/// Max on-disk image cache size in MB.
///
/// Enforced best-effort by [imageCacheSizeCapEnforcerProvider], which walks
/// the cache directory and deletes oldest files until under the cap.
final maxCacheSizeMBProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).whenOrNull(data: (s) => s.maxCacheSizeMB) ??
      500;
});

/// Triggers image cache byte-cap enforcement whenever the cap changes.
///
/// Watched by the app root so it re-runs on settings reload and at startup.
/// ponytail: fire-and-forget — [ReederImageCacheManager.enforceSizeCap] is
/// best-effort and never throws up to here.
final imageCacheSizeCapEnforcerProvider = Provider<void>((ref) {
  final mb = ref.watch(maxCacheSizeMBProvider);
  Future.microtask(
    () => ref
        .read(reederImageCacheManagerProvider)
        .enforceSizeCap(mb * 1024 * 1024),
  );
});

// ─── Notifications ─────────────────────────────────────────

/// Whether the app-level master notifications toggle is on.
///
/// Surfaced as a switch on the Data & Storage settings page. Per-feed
/// notifications (feed.notificationsEnabled) are gated on this AND the feed's
/// own flag inside [FeedRefreshService]; see [NotificationService].
final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref
          .watch(settingsProvider)
          .whenOrNull(data: (s) => s.notificationsEnabled) ??
      false;
});

