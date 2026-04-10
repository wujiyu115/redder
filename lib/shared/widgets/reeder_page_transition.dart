import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_durations.dart';

/// Custom page transition for the Reeder app.
///
/// Implements iOS-style right-to-left slide transition with:
/// - 350ms easeInOut curve
/// - Previous page slides left (parallax effect)
/// - New page slides in from right
/// - Supports gesture-driven back navigation via edge swipe
class ReederPage extends CustomTransitionPage<void> {
  ReederPage({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppDurations.pageTransition,
          reverseTransitionDuration: AppDurations.pageTransition,
          transitionsBuilder: _buildTransition,
        );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Incoming page: slide from right
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    // Outgoing page: slight slide to left (parallax)
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    ));

    // Shadow overlay on outgoing page
    final shadowOpacity = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(secondaryAnimation);

    // Wrap with gesture-driven back navigation
    return SlideTransition(
      position: slideOut,
      child: _GestureDrivenBack(
        animation: animation,
        child: SlideTransition(
          position: slideIn,
          child: Stack(
            children: [
              child,
              // Shadow overlay (only visible during secondary animation)
              if (secondaryAnimation.value > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color.fromRGBO(0, 0, 0, shadowOpacity.value),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enables gesture-driven back navigation by swiping from the left edge.
///
/// Detects horizontal drag from the left 20px edge and drives the
/// route's animation controller in reverse, providing a smooth
/// interactive pop transition.
class _GestureDrivenBack extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;

  const _GestureDrivenBack({
    required this.animation,
    required this.child,
  });

  @override
  State<_GestureDrivenBack> createState() => _GestureDrivenBackState();
}

class _GestureDrivenBackState extends State<_GestureDrivenBack> {
  bool _isDragging = false;
  double _dragStartX = 0.0;

  /// Edge zone width for initiating back gesture.
  static const double _edgeWidth = 20.0;

  /// Minimum velocity to trigger pop.
  static const double _popVelocity = 300.0;

  @override
  Widget build(BuildContext context) {
    // Only enable gesture when the page is fully visible (not animating in)
    if (widget.animation.status != AnimationStatus.completed) {
      return widget.child;
    }

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: widget.child,
    );
  }

  void _onDragStart(DragStartDetails details) {
    if (details.globalPosition.dx <= _edgeWidth) {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final dragDistance = details.globalPosition.dx - _dragStartX;
    final progress = (dragDistance / screenWidth).clamp(0.0, 1.0);

    // Drive the animation controller if available
    final controller = widget.animation;
    if (controller is AnimationController) {
      controller.value = 1.0 - progress;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    final controller = widget.animation;

    if (controller is AnimationController) {
      if (velocity > _popVelocity || controller.value < 0.5) {
        // Pop the route
        Navigator.of(context).pop();
      } else {
        // Snap back
        controller.animateTo(
          1.0,
          duration: AppDurations.pageTransition,
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Fallback: check velocity only
      if (velocity > _popVelocity) {
        Navigator.of(context).pop();
      }
    }
  }
}
