import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/light_theme.dart';
import '../../core/theme/dark_theme.dart';
import '../../core/theme/oled_theme.dart';

/// Provider for the current theme mode selection.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ReederThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Provider for the resolved [ReederThemeData] based on current mode.
final currentThemeProvider = Provider<ReederThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  return _resolveTheme(mode);
});

/// Notifier that manages theme mode state.
class ThemeModeNotifier extends StateNotifier<ReederThemeMode> {
  ThemeModeNotifier() : super(ReederThemeMode.system);

  /// Sets the theme mode.
  void setThemeMode(ReederThemeMode mode) {
    state = mode;
  }

  /// Cycles through available themes: light → dark → oled → system → light.
  void cycleTheme() {
    switch (state) {
      case ReederThemeMode.light:
        state = ReederThemeMode.dark;
        break;
      case ReederThemeMode.dark:
        state = ReederThemeMode.oled;
        break;
      case ReederThemeMode.oled:
        state = ReederThemeMode.system;
        break;
      case ReederThemeMode.system:
        state = ReederThemeMode.light;
        break;
      case ReederThemeMode.darkLight:
        state = ReederThemeMode.light;
        break;
    }
  }
}

/// Resolves the theme mode to a concrete [ReederThemeData].
ReederThemeData _resolveTheme(ReederThemeMode mode) {
  switch (mode) {
    case ReederThemeMode.light:
      return lightTheme;
    case ReederThemeMode.dark:
      return darkTheme;
    case ReederThemeMode.oled:
      return oledTheme;
    case ReederThemeMode.darkLight:
      // Dark Light hybrid: uses dark theme as base
      // (detail view override handled at page level)
      return darkTheme.copyWith(mode: ReederThemeMode.darkLight);
    case ReederThemeMode.system:
      // Determine system brightness
      final brightness =
          PlatformDispatcher.instance.platformBrightness;
      return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}
