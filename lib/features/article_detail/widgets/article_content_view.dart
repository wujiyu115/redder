import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/bionic_reading.dart';

/// Widget that renders HTML article content.
///
/// Uses `flutter_widget_from_html` to render rich HTML content
/// including images, links, code blocks, blockquotes, tables, etc.
///
/// Supports configurable font size, line height, and Bionic Reading mode.
class ArticleContentView extends StatelessWidget {
  /// The HTML content to render.
  final String content;

  /// Font size in logical pixels.
  final double fontSize;

  /// Line height multiplier.
  final double lineHeight;

  /// Maximum content width for readability.
  final double maxWidth;

  /// Whether Bionic Reading mode is enabled.
  final bool bionicReading;

  /// Callback when an image in the content is tapped.
  final void Function(String imageUrl)? onImageTap;

  const ArticleContentView({
    super.key,
    required this.content,
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.maxWidth = AppDimensions.maxContentWidth,
    this.bionicReading = false,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    if (content.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingXL,
        ),
        child: Center(
          child: Text(
            'No content available',
            style: theme.typography.body.copyWith(
              color: theme.tertiaryTextColor,
            ),
          ),
        ),
      );
    }

    // Apply Bionic Reading transformation if enabled
    final displayContent =
        bionicReading ? BionicReading.applyToHtml(content) : content;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: HtmlWidget(
        displayContent,
        textStyle: TextStyle(
          fontSize: fontSize,
          height: lineHeight,
          color: theme.primaryTextColor,
        ),
        customStylesBuilder: (element) {
          return _buildCustomStyles(element, theme);
        },
        onTapUrl: (url) {
          _handleUrlTap(url);
          return true;
        },
        onTapImage: (imageMetadata) {
          final src = imageMetadata.sources.firstOrNull?.url;
          if (src != null && onImageTap != null) {
            onImageTap!(src);
          }
        },
      ),
    );
  }

  /// Builds custom CSS-like styles for HTML elements.
  Map<String, String>? _buildCustomStyles(
    dynamic element,
    ReederThemeData theme,
  ) {
    final tag = element.localName;

    switch (tag) {
      case 'a':
        return {
          'color': _colorToHex(theme.accentColor),
          'text-decoration': 'none',
        };
      case 'blockquote':
        return {
          'border-left': '3px solid ${_colorToHex(theme.separatorColor)}',
          'padding-left': '${AppDimensions.spacing}px',
          'margin-left': '0',
          'color': _colorToHex(theme.secondaryTextColor),
          'font-style': 'italic',
        };
      case 'code':
        return {
          'background-color': _colorToHex(theme.secondaryBackgroundColor),
          'padding': '2px 6px',
          'border-radius': '4px',
          'font-size': '${fontSize * 0.9}px',
        };
      case 'pre':
        return {
          'background-color': _colorToHex(theme.secondaryBackgroundColor),
          'padding': '${AppDimensions.spacingM}px',
          'border-radius': '${AppDimensions.radiusM}px',
          'overflow-x': 'auto',
          'font-size': '${fontSize * 0.85}px',
        };
      case 'img':
        return {
          'max-width': '100%',
          'border-radius': '${AppDimensions.radiusM}px',
          'margin': '${AppDimensions.spacingS}px 0',
        };
      case 'h1':
        return {
          'font-size': '${fontSize * 1.5}px',
          'font-weight': '700',
          'margin-top': '${AppDimensions.spacingXL}px',
          'margin-bottom': '${AppDimensions.spacingS}px',
        };
      case 'h2':
        return {
          'font-size': '${fontSize * 1.3}px',
          'font-weight': '600',
          'margin-top': '${AppDimensions.spacingXL}px',
          'margin-bottom': '${AppDimensions.spacingS}px',
        };
      case 'h3':
        return {
          'font-size': '${fontSize * 1.15}px',
          'font-weight': '600',
          'margin-top': '${AppDimensions.spacing}px',
          'margin-bottom': '${AppDimensions.spacingXS}px',
        };
      case 'figure':
        return {
          'margin': '${AppDimensions.spacing}px 0',
          'text-align': 'center',
        };
      case 'figcaption':
        return {
          'font-size': '${fontSize * 0.85}px',
          'color': _colorToHex(theme.tertiaryTextColor),
          'text-align': 'center',
          'margin-top': '${AppDimensions.spacingXS}px',
        };
      case 'table':
        return {
          'border-collapse': 'collapse',
          'width': '100%',
          'margin': '${AppDimensions.spacing}px 0',
        };
      case 'th':
        return {
          'border': '1px solid ${_colorToHex(theme.separatorColor)}',
          'padding': '${AppDimensions.spacingS}px',
          'font-weight': '600',
          'background-color': _colorToHex(theme.secondaryBackgroundColor),
        };
      case 'td':
        return {
          'border': '1px solid ${_colorToHex(theme.separatorColor)}',
          'padding': '${AppDimensions.spacingS}px',
        };
      case 'hr':
        return {
          'border': 'none',
          'border-top': '1px solid ${_colorToHex(theme.separatorColor)}',
          'margin': '${AppDimensions.spacingXL}px 0',
        };
      default:
        return null;
    }
  }

  /// Converts a Color to a hex string for CSS.
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// Handles URL taps by launching the URL.
  Future<void> _handleUrlTap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
