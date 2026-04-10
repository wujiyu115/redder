import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

/// Extension on the generated AppSettingsTableData to provide
/// computed properties matching the original Isar model.
///
/// Separated from app_settings.dart to avoid circular dependency:
/// app_settings.dart is imported by app_database.dart, so it cannot import
/// app_database.dart back. This file can safely import app_database.dart.
extension AppSettingsHelpers on AppSettingsTableData {
  /// Helper to get the ReederThemeMode from stored index.
  ReederThemeMode get themeMode {
    if (themeModeIndex >= 0 && themeModeIndex < ReederThemeMode.values.length) {
      return ReederThemeMode.values[themeModeIndex];
    }
    return ReederThemeMode.system;
  }

  /// Font size in logical pixels based on level.
  double get fontSize {
    const sizes = [12.0, 13.0, 14.0, 16.0, 18.0, 20.0, 22.0];
    return sizes[fontSizeLevel.clamp(0, sizes.length - 1)];
  }

  /// Line height multiplier based on level.
  double get lineHeight {
    const heights = [1.2, 1.35, 1.5, 1.65, 1.8];
    return heights[lineHeightLevel.clamp(0, heights.length - 1)];
  }
}