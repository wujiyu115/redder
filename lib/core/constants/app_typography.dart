import 'package:flutter/widgets.dart';

/// Defines all typography constants for the Reeder app.
///
/// Uses system default fonts (SF Pro on iOS, Roboto on Android).
/// All sizes are in logical pixels (pt).
class AppTypography {
  AppTypography._();

  /// Large title: 28pt Bold
  /// Used for page titles and prominent headings.
  static const TextStyle largeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.21, // ~34pt line height
  );

  /// Article title: 20pt Semibold
  /// Used for article titles in detail view.
  static const TextStyle articleTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.25, // ~25pt line height
  );

  /// List title: 17pt Semibold
  /// Used for article titles in list view.
  static const TextStyle listTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29, // ~22pt line height
  );

  /// Body: 16pt Regular
  /// Used for article body text.
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.5, // ~24pt line height
  );

  /// Summary: 14pt Regular
  /// Used for article summaries and descriptions.
  static const TextStyle summary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.15,
    height: 1.43, // ~20pt line height
  );

  /// Caption: 12pt Regular
  /// Used for auxiliary information like dates, counts.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33, // ~16pt line height
  );

  /// Section header: 13pt Semibold, uppercase
  /// Used for section headers in source list.
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    height: 1.38, // ~18pt line height
  );

  /// Nav bar title: 17pt Semibold
  static const TextStyle navBarTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Button text: 17pt Regular
  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Small button text: 15pt Regular
  static const TextStyle smallButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
  );
}
