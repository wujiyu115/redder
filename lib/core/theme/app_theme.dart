import 'package:flutter/widgets.dart';

import '../constants/app_typography.dart';

/// Theme mode enumeration for the Reeder app.
enum ReederThemeMode {
  light,
  dark,
  oled,
  darkLight,
  system,
}

/// Typography data class holding all text styles with applied colors.
class ReederTypography {
  final TextStyle largeTitle;
  final TextStyle articleTitle;
  final TextStyle listTitle;
  final TextStyle body;
  final TextStyle summary;
  final TextStyle caption;
  final TextStyle sectionHeader;
  final TextStyle navBarTitle;
  final TextStyle button;
  final TextStyle smallButton;

  const ReederTypography({
    required this.largeTitle,
    required this.articleTitle,
    required this.listTitle,
    required this.body,
    required this.summary,
    required this.caption,
    required this.sectionHeader,
    required this.navBarTitle,
    required this.button,
    required this.smallButton,
  });

  /// Creates typography with colors applied from the theme.
  factory ReederTypography.fromColors({
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
  }) {
    return ReederTypography(
      largeTitle: AppTypography.largeTitle.copyWith(color: primaryText),
      articleTitle: AppTypography.articleTitle.copyWith(color: primaryText),
      listTitle: AppTypography.listTitle.copyWith(color: primaryText),
      body: AppTypography.body.copyWith(color: primaryText),
      summary: AppTypography.summary.copyWith(color: secondaryText),
      caption: AppTypography.caption.copyWith(color: secondaryText),
      sectionHeader: AppTypography.sectionHeader.copyWith(color: secondaryText),
      navBarTitle: AppTypography.navBarTitle.copyWith(color: primaryText),
      button: AppTypography.button.copyWith(color: accentColor),
      smallButton: AppTypography.smallButton.copyWith(color: accentColor),
    );
  }
}

/// Custom theme data class for the Reeder app.
///
/// This replaces Flutter's [ThemeData] to provide full control
/// over all visual properties without Material/Cupertino dependencies.
class ReederThemeData {
  /// Primary background color.
  final Color backgroundColor;

  /// Secondary background color (for grouped sections, cards).
  final Color secondaryBackgroundColor;

  /// Primary text color.
  final Color primaryTextColor;

  /// Secondary text color (for captions, metadata).
  final Color secondaryTextColor;

  /// Tertiary text color (for placeholders, disabled).
  final Color tertiaryTextColor;

  /// Accent/tint color (for interactive elements).
  final Color accentColor;

  /// Separator/divider color.
  final Color separatorColor;

  /// Card background color.
  final Color cardBackgroundColor;

  /// Default icon color.
  final Color iconColor;

  /// Active/selected icon color.
  final Color activeIconColor;

  /// Destructive action color (delete, remove).
  final Color destructiveColor;

  /// Success color.
  final Color successColor;

  /// Warning color.
  final Color warningColor;

  /// Typography with colors applied.
  final ReederTypography typography;

  /// Whether this is a dark theme.
  final bool isDark;

  /// The theme mode.
  final ReederThemeMode mode;

  const ReederThemeData({
    required this.backgroundColor,
    required this.secondaryBackgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
    required this.accentColor,
    required this.separatorColor,
    required this.cardBackgroundColor,
    required this.iconColor,
    required this.activeIconColor,
    required this.destructiveColor,
    required this.successColor,
    required this.warningColor,
    required this.typography,
    required this.isDark,
    required this.mode,
  });

  /// Creates a copy with optional overrides.
  ReederThemeData copyWith({
    Color? backgroundColor,
    Color? secondaryBackgroundColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? tertiaryTextColor,
    Color? accentColor,
    Color? separatorColor,
    Color? cardBackgroundColor,
    Color? iconColor,
    Color? activeIconColor,
    Color? destructiveColor,
    Color? successColor,
    Color? warningColor,
    ReederTypography? typography,
    bool? isDark,
    ReederThemeMode? mode,
  }) {
    return ReederThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? this.secondaryBackgroundColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      tertiaryTextColor: tertiaryTextColor ?? this.tertiaryTextColor,
      accentColor: accentColor ?? this.accentColor,
      separatorColor: separatorColor ?? this.separatorColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      typography: typography ?? this.typography,
      isDark: isDark ?? this.isDark,
      mode: mode ?? this.mode,
    );
  }
}

/// InheritedWidget that provides [ReederThemeData] to the widget tree.
///
/// Usage:
/// ```dart
/// final theme = ReederTheme.of(context);
/// ```
class ReederTheme extends InheritedWidget {
  final ReederThemeData data;

  const ReederTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieves the nearest [ReederThemeData] from the widget tree.
  static ReederThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ReederTheme>();
    assert(widget != null, 'No ReederTheme found in context');
    return widget!.data;
  }

  /// Retrieves the nearest [ReederThemeData] without registering a dependency.
  static ReederThemeData? maybeOf(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ReederTheme>();
    return widget?.data;
  }

  @override
  bool updateShouldNotify(ReederTheme oldWidget) {
    return data != oldWidget.data;
  }
}
