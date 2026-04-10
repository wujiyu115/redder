import 'package:flutter/widgets.dart';

/// Defines all color constants for the four theme variants:
/// Light, Dark, OLED Black, and Dark Light (hybrid).
///
/// Color values are derived from the Reeder design specification.
class AppColors {
  AppColors._();

  // ─── Light Theme ───────────────────────────────────────────

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSecondaryBackground = Color(0xFFF2F2F7);
  static const Color lightPrimaryText = Color(0xFF1C1C1E);
  static const Color lightSecondaryText = Color(0xFF8E8E93);
  static const Color lightTertiaryText = Color(0xFFC7C7CC);
  static const Color lightAccent = Color(0xFF007AFF);
  static const Color lightSeparator = Color(0xFFE5E5EA);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightIcon = Color(0xFF8E8E93);
  static const Color lightActiveIcon = Color(0xFF007AFF);
  static const Color lightDestructive = Color(0xFFFF3B30);
  static const Color lightSuccess = Color(0xFF34C759);
  static const Color lightWarning = Color(0xFFFF9500);

  // ─── Dark Theme ────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkSecondaryBackground = Color(0xFF2C2C2E);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF8E8E93);
  static const Color darkTertiaryText = Color(0xFF48484A);
  static const Color darkAccent = Color(0xFF0A84FF);
  static const Color darkSeparator = Color(0xFF38383A);
  static const Color darkCardBackground = Color(0xFF2C2C2E);
  static const Color darkIcon = Color(0xFF8E8E93);
  static const Color darkActiveIcon = Color(0xFF0A84FF);
  static const Color darkDestructive = Color(0xFFFF453A);
  static const Color darkSuccess = Color(0xFF30D158);
  static const Color darkWarning = Color(0xFFFF9F0A);

  // ─── OLED Black Theme ─────────────────────────────────────

  static const Color oledBackground = Color(0xFF000000);
  static const Color oledSecondaryBackground = Color(0xFF1C1C1E);
  static const Color oledPrimaryText = Color(0xFFFFFFFF);
  static const Color oledSecondaryText = Color(0xFF8E8E93);
  static const Color oledTertiaryText = Color(0xFF48484A);
  static const Color oledAccent = Color(0xFF0A84FF);
  static const Color oledSeparator = Color(0xFF2C2C2E);
  static const Color oledCardBackground = Color(0xFF1C1C1E);
  static const Color oledIcon = Color(0xFF8E8E93);
  static const Color oledActiveIcon = Color(0xFF0A84FF);

  // ─── Shared / Semantic Colors ─────────────────────────────

  /// Later tag color
  static const Color tagLater = Color(0xFFFF9500);

  /// Bookmark tag color
  static const Color tagBookmark = Color(0xFF007AFF);

  /// Favorite tag color
  static const Color tagFavorite = Color(0xFFFF2D55);

  /// Transparent
  static const Color transparent = Color(0x00000000);
}
