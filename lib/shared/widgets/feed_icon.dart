import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// A widget that displays a feed's icon/favicon.
///
/// Shows the feed icon from a URL with fallback to a
/// colored placeholder with the first letter of the feed title.
///
/// Supports two sizes:
/// - Default (20px) for list items
/// - Large (32px) for detail views
class FeedIcon extends StatelessWidget {
  /// URL of the feed icon.
  final String? iconUrl;

  /// Feed title (used for fallback letter).
  final String title;

  /// Size of the icon (default: [AppDimensions.feedIconSize]).
  final double size;

  /// Border radius of the icon.
  final double borderRadius;

  const FeedIcon({
    super.key,
    this.iconUrl,
    required this.title,
    this.size = AppDimensions.feedIconSize,
    this.borderRadius = AppDimensions.radiusS,
  });

  /// Creates a large feed icon (32px).
  const FeedIcon.large({
    super.key,
    this.iconUrl,
    required this.title,
    this.size = AppDimensions.feedIconSizeLarge,
    this.borderRadius = AppDimensions.radiusM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    if (iconUrl != null && iconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: iconUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          errorWidget: (_, __, ___) => _FallbackIcon(
            title: title,
            size: size,
            borderRadius: borderRadius,
            theme: theme,
          ),
          placeholder: (_, __) => _FallbackIcon(
            title: title,
            size: size,
            borderRadius: borderRadius,
            theme: theme,
          ),
        ),
      );
    }

    return _FallbackIcon(
      title: title,
      size: size,
      borderRadius: borderRadius,
      theme: theme,
    );
  }
}

/// Fallback icon showing the first letter of the feed title
/// on a colored background.
class _FallbackIcon extends StatelessWidget {
  final String title;
  final double size;
  final double borderRadius;
  final ReederThemeData theme;

  const _FallbackIcon({
    required this.title,
    required this.size,
    required this.borderRadius,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a consistent color based on the title
    final colorIndex = title.isEmpty ? 0 : title.codeUnitAt(0) % _colors.length;
    final bgColor = _colors[colorIndex];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }

  /// A set of pleasant colors for fallback icons.
  static const List<Color> _colors = [
    Color(0xFF007AFF), // Blue
    Color(0xFF34C759), // Green
    Color(0xFFFF9500), // Orange
    Color(0xFFFF3B30), // Red
    Color(0xFFAF52DE), // Purple
    Color(0xFF5856D6), // Indigo
    Color(0xFFFF2D55), // Pink
    Color(0xFF00C7BE), // Teal
    Color(0xFF5AC8FA), // Light Blue
    Color(0xFFFFCC00), // Yellow
  ];
}
