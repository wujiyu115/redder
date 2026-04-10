import 'package:flutter/widgets.dart';

import '../../../core/constants/app_durations.dart';

/// Configuration for a single swipe action.
class SwipeAction {
  /// Unique identifier for this action.
  final String id;

  /// Display label.
  final String label;

  /// Icon text (emoji or symbol).
  final String icon;

  /// Background color of the action area.
  final Color color;

  /// Callback when the action is triggered.
  final VoidCallback? onTriggered;

  const SwipeAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.onTriggered,
  });
}

/// A widget that wraps a child with swipe-to-reveal actions.
///
/// Supports:
/// - Left swipe to reveal right-side actions (e.g., Share)
/// - Right swipe to reveal left-side actions (e.g., Later)
/// - Snap-to-action when swiped past threshold
/// - Smooth spring animation on release
class SwipeActionWidget extends StatefulWidget {
  /// The main content widget.
  final Widget child;

  /// Actions revealed on left swipe (shown on the right side).
  final List<SwipeAction> leftSwipeActions;

  /// Actions revealed on right swipe (shown on the left side).
  final List<SwipeAction> rightSwipeActions;

  /// Width of each action button.
  final double actionWidth;

  /// Threshold ratio (0-1) to trigger the action automatically.
  final double triggerThreshold;

  /// Whether swipe actions are enabled.
  final bool enabled;

  const SwipeActionWidget({
    super.key,
    required this.child,
    this.leftSwipeActions = const [],
    this.rightSwipeActions = const [],
    this.actionWidth = 80.0,
    this.triggerThreshold = 0.4,
    this.enabled = true,
  });

  @override
  State<SwipeActionWidget> createState() => _SwipeActionWidgetState();
}

class _SwipeActionWidgetState extends State<SwipeActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double _dragExtent = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.standard,
      vsync: this,
    );
    _animation = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _isDragging = true;
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragExtent += details.primaryDelta ?? 0;

      // Limit drag extent based on available actions
      final maxLeftSwipe = widget.leftSwipeActions.isEmpty
          ? 0.0
          : widget.actionWidth * widget.leftSwipeActions.length;
      final maxRightSwipe = widget.rightSwipeActions.isEmpty
          ? 0.0
          : widget.actionWidth * widget.rightSwipeActions.length;

      // Apply rubber-band effect beyond limits
      if (_dragExtent < -maxLeftSwipe) {
        final overflow = -_dragExtent - maxLeftSwipe;
        _dragExtent = -(maxLeftSwipe + overflow * 0.3);
      }
      if (_dragExtent > maxRightSwipe) {
        final overflow = _dragExtent - maxRightSwipe;
        _dragExtent = maxRightSwipe + overflow * 0.3;
      }

      // Prevent swiping in direction with no actions
      if (widget.leftSwipeActions.isEmpty && _dragExtent < 0) {
        _dragExtent = 0;
      }
      if (widget.rightSwipeActions.isEmpty && _dragExtent > 0) {
        _dragExtent = 0;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * widget.triggerThreshold;

    // Check if we should trigger an action
    if (_dragExtent.abs() > threshold) {
      if (_dragExtent < 0 && widget.leftSwipeActions.isNotEmpty) {
        // Triggered left swipe action
        widget.leftSwipeActions.first.onTriggered?.call();
      } else if (_dragExtent > 0 && widget.rightSwipeActions.isNotEmpty) {
        // Triggered right swipe action
        widget.rightSwipeActions.first.onTriggered?.call();
      }
    }

    // Animate back to center
    _animateBack();
  }

  void _animateBack() {
    _animation = Tween<double>(
      begin: _dragExtent,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _animation.addListener(() {
      setState(() {
        _dragExtent = _animation.value;
      });
    });

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          // Left-side actions (revealed on right swipe)
          if (_dragExtent > 0 && widget.rightSwipeActions.isNotEmpty)
            Positioned.fill(
              child: Row(
                children: [
                  for (final action in widget.rightSwipeActions)
                    Container(
                      width: _dragExtent / widget.rightSwipeActions.length,
                      color: action.color,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              action.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              action.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),

          // Right-side actions (revealed on left swipe)
          if (_dragExtent < 0 && widget.leftSwipeActions.isNotEmpty)
            Positioned.fill(
              child: Row(
                children: [
                  const Spacer(),
                  for (final action in widget.leftSwipeActions)
                    Container(
                      width: -_dragExtent / widget.leftSwipeActions.length,
                      color: action.color,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              action.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              action.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Main content
          GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
