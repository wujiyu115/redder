import 'package:flutter/cupertino.dart';

import '../../core/constants/app_durations.dart';

/// iOS-style page transition for the app.
///
/// Right-to-left slide with a parallax + shadow on the outgoing page, plus the
/// interactive edge-swipe back gesture: dragging from the left edge makes the
/// page follow the finger and either snap back or pop.
///
/// This is Flutter's own [CupertinoRouteTransitionMixin] rather than a
/// hand-rolled transition, for two reasons the hand-rolled version got wrong:
///
/// 1. the drag target has to sit *above* the page content so a gesture starting
///    at the screen edge wins the gesture arena before any horizontal
///    recognizer inside the page (list row swipe actions, article swipe
///    navigation) — otherwise edge swipes are swallowed by the page;
/// 2. driving the transition during the drag requires the route's own
///    `AnimationController`, which is `@protected` and only reachable from a
///    route subclass.
///
/// The app's own timing ([AppDurations.pageTransition]) is kept.
class ReederPage<T> extends Page<T> {
  const ReederPage({
    required this.child,
    this.title,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The page content.
  final Widget child;

  /// Title used by Cupertino navigation bars.
  final String? title;

  /// Whether the page keeps its state while covered by another route.
  final bool maintainState;

  /// Whether the page is presented as a fullscreen dialog (slides up, no
  /// edge-swipe back).
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) => _ReederPageRoute<T>(this);
}

class _ReederPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _ReederPageRoute(this.page) : super(settings: page);

  final ReederPage<T> page;

  @override
  Widget buildContent(BuildContext context) => page.child;

  @override
  String? get title => page.title;

  @override
  bool get maintainState => page.maintainState;

  @override
  bool get fullscreenDialog => page.fullscreenDialog;

  @override
  String get debugLabel => 'ReederPage';

  // Keep the app's timing instead of Cupertino's 500ms default.
  @override
  Duration get transitionDuration => AppDurations.pageTransition;

  @override
  Duration get reverseTransitionDuration => AppDurations.pageTransition;
}