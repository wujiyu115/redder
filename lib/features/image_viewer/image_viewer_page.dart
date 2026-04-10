import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';

/// Full-screen image viewer with pinch-to-zoom and swipe navigation.
///
/// Features:
/// - Hero animation transition (300ms)
/// - Pinch-to-zoom with InteractiveViewer
/// - Left/right swipe to navigate between images
/// - Tap to toggle UI visibility
/// - Swipe down to dismiss
class ImageViewerPage extends StatefulWidget {
  /// List of image URLs to display.
  final List<String> imageUrls;

  /// Index of the initially displayed image.
  final int initialIndex;

  /// Optional hero tag for transition animation.
  final String? heroTag;

  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;
  late AnimationController _uiAnimController;
  late Animation<double> _uiOpacity;

  // For swipe-to-dismiss
  double _dragOffset = 0;
  double _dragScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _uiAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
    _uiOpacity = CurvedAnimation(
      parent: _uiAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiAnimController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
      if (_showUI) {
        _uiAnimController.forward();
      } else {
        _uiAnimController.reverse();
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ColoredBox(
      color: const Color(0xFF000000),
      child: Stack(
        children: [
          // Image page view with swipe-to-dismiss
          GestureDetector(
            onTap: _toggleUI,
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.delta.dy;
                _dragScale = (1 - (_dragOffset.abs() / 500)).clamp(0.5, 1.0);
              });
            },
            onVerticalDragEnd: (details) {
              if (_dragOffset.abs() > 100) {
                // Dismiss
                if (context.canPop()) {
                  context.pop();
                }
              } else {
                setState(() {
                  _dragOffset = 0;
                  _dragScale = 1.0;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.scale(
                scale: _dragScale,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return _ZoomableImage(
                      imageUrl: widget.imageUrls[index],
                      heroTag: index == widget.initialIndex
                          ? widget.heroTag
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),

          // Top bar (close button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _uiOpacity,
              child: Container(
                padding: EdgeInsets.only(
                  top: mediaQuery.padding.top + AppDimensions.spacingS,
                  left: AppDimensions.spacing,
                  right: AppDimensions.spacing,
                  bottom: AppDimensions.spacingS,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x80000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close button
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) context.pop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingS),
                        child: Text(
                          '✕',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),

                    // Page indicator
                    if (widget.imageUrls.length > 1)
                      Text(
                        '${_currentIndex + 1} / ${widget.imageUrls.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),

                    // Spacer for symmetry
                    const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
          ),

          // Bottom page dots
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: mediaQuery.padding.bottom + AppDimensions.spacing,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _uiOpacity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == _currentIndex ? 8 : 6,
                      height: index == _currentIndex ? 8 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? const Color(0xFFFFFFFF)
                            : const Color(0x80FFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single zoomable image with InteractiveViewer.
class _ZoomableImage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const _ZoomableImage({
    required this.imageUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) => const Center(
            child: Text(
              '⏳',
              style: TextStyle(fontSize: 32),
            ),
          ),
          errorWidget: (_, __, ___) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('❌', style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Wrap with Hero if tag is provided
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        flightShuttleBuilder: (_, animation, __, ___, ____) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) => imageWidget,
          );
        },
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
