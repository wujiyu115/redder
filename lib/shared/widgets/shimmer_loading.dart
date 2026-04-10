import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';

/// A shimmer/skeleton loading placeholder widget.
///
/// Displays animated placeholder shapes that indicate
/// content is loading. Used as a loading state for
/// article lists and other content areas.
class ShimmerLoading extends StatefulWidget {
  /// Number of placeholder items to show.
  final int itemCount;

  /// Whether to show in compact mode (no thumbnails).
  final bool compact;

  const ShimmerLoading({
    super.key,
    this.itemCount = 5,
    this.compact = false,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final shimmerColor = theme.separatorColor.withOpacity(_animation.value);

        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            if (widget.compact) {
              return _buildCompactItem(shimmerColor);
            }
            return _buildStandardItem(shimmerColor);
          },
        );
      },
    );
  }

  Widget _buildStandardItem(Color shimmerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.listItemPaddingH,
        vertical: AppDimensions.listItemPaddingV,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feed info row placeholder
                Row(
                  children: [
                    _ShimmerBox(
                      width: 14,
                      height: 14,
                      color: shimmerColor,
                      borderRadius: 3,
                    ),
                    const SizedBox(width: AppDimensions.spacingXS),
                    _ShimmerBox(
                      width: 80,
                      height: 12,
                      color: shimmerColor,
                    ),
                    const SizedBox(width: AppDimensions.spacingXS),
                    _ShimmerBox(
                      width: 30,
                      height: 12,
                      color: shimmerColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Title placeholder
                _ShimmerBox(
                  width: double.infinity,
                  height: 17,
                  color: shimmerColor,
                ),
                const SizedBox(height: 4),
                _ShimmerBox(
                  width: 200,
                  height: 17,
                  color: shimmerColor,
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Summary placeholder
                _ShimmerBox(
                  width: double.infinity,
                  height: 14,
                  color: shimmerColor,
                ),
                const SizedBox(height: 3),
                _ShimmerBox(
                  width: double.infinity,
                  height: 14,
                  color: shimmerColor,
                ),
                const SizedBox(height: 3),
                _ShimmerBox(
                  width: 150,
                  height: 14,
                  color: shimmerColor,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.spacingM),

          // Thumbnail placeholder
          _ShimmerBox(
            width: AppDimensions.thumbnailWidth,
            height: AppDimensions.thumbnailHeight,
            color: shimmerColor,
            borderRadius: AppDimensions.radiusM,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactItem(Color shimmerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.listItemPaddingH,
        vertical: AppDimensions.spacingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title placeholder
          _ShimmerBox(
            width: double.infinity,
            height: 16,
            color: shimmerColor,
          ),
          const SizedBox(height: 4),

          // Feed name + time placeholder
          Row(
            children: [
              _ShimmerBox(
                width: 80,
                height: 12,
                color: shimmerColor,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              _ShimmerBox(
                width: 30,
                height: 12,
                color: shimmerColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single shimmer placeholder box.
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
