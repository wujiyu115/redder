import 'package:flutter/widgets.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Custom pull-to-refresh widget with elastic bounce animation.
///
/// Wraps a scrollable child and provides a pull-down gesture
/// to trigger a refresh callback. Uses a custom indicator
/// instead of Material/Cupertino refresh indicators.
class PullToRefresh extends StatefulWidget {
  /// The scrollable child widget.
  final Widget child;

  /// Callback triggered when the user pulls to refresh.
  /// Should return a Future that completes when refresh is done.
  final Future<void> Function() onRefresh;

  /// The distance the user must pull to trigger a refresh.
  final double triggerDistance;

  /// Maximum distance the indicator can be pulled.
  final double maxDragDistance;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.triggerDistance = 80.0,
    this.maxDragDistance = 140.0,
  });

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: AppDurations.pullToRefresh,
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        // Pulling down past the top
        setState(() {
          _dragOffset = (_dragOffset - notification.overscroll * 0.5)
              .clamp(0.0, widget.maxDragDistance);
        });
      }
    }

    if (notification is ScrollEndNotification) {
      if (_dragOffset >= widget.triggerDistance && !_isRefreshing) {
        _startRefresh();
      } else if (_dragOffset > 0) {
        _resetDrag();
      }
    }

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels <= 0 && _dragOffset > 0) {
        // User is scrolling back up while dragging
        if (notification.scrollDelta != null && notification.scrollDelta! > 0) {
          setState(() {
            _dragOffset = (_dragOffset - notification.scrollDelta!)
                .clamp(0.0, widget.maxDragDistance);
          });
        }
      }
    }

    return false;
  }

  Future<void> _startRefresh() async {
    setState(() => _isRefreshing = true);

    // Animate to a fixed position while refreshing
    _bounceAnimation = Tween<double>(
      begin: _dragOffset,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
    _bounceController.forward(from: 0.0);

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _resetDrag();
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _resetDrag() {
    // Use elasticOut with a slightly dampened period for natural bounce
    _bounceAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: const ElasticOutCurve(0.6),
    ));
    _bounceController.forward(from: 0.0);

    _bounceController.addListener(_onBounceUpdate);
  }

  void _onBounceUpdate() {
    if (mounted) {
      setState(() {
        _dragOffset = _bounceAnimation.value;
      });
    }
    if (_bounceController.isCompleted) {
      _bounceController.removeListener(_onBounceUpdate);
      if (mounted) {
        setState(() => _dragOffset = 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final progress = (_dragOffset / widget.triggerDistance).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          // Refresh indicator
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _dragOffset,
              child: Center(
                child: Opacity(
                  opacity: progress,
                  child: _buildIndicator(theme, progress),
                ),
              ),
            ),

          // Content with offset
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(ReederThemeData theme, double progress) {
    if (_isRefreshing) {
      return _RefreshingIndicator(color: theme.accentColor);
    }

    return Transform.rotate(
      angle: progress * 3.14159 * 2,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.accentColor,
            width: 2.0,
          ),
        ),
        child: progress >= 1.0
            ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// A simple rotating indicator shown during refresh.
class _RefreshingIndicator extends StatefulWidget {
  final Color color;

  const _RefreshingIndicator({required this.color});

  @override
  State<_RefreshingIndicator> createState() => _RefreshingIndicatorState();
}

class _RefreshingIndicatorState extends State<_RefreshingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 3.14159 * 2,
          child: child,
        );
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color,
            width: 2.0,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
