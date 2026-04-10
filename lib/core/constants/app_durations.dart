/// Defines all animation duration constants for the Reeder app.
///
/// All durations are specified in milliseconds and correspond to
/// the animation specification in the PRD.
class AppDurations {
  AppDurations._();

  /// Page push/pop transition: 350ms
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// List item appear animation: 200ms
  static const Duration listItemAppear = Duration(milliseconds: 200);

  /// Theme switch crossfade: 300ms
  static const Duration themeSwitch = Duration(milliseconds: 300);

  /// Pull-to-refresh elastic bounce: 500ms
  static const Duration pullToRefresh = Duration(milliseconds: 500);

  /// Image zoom hero animation: 300ms
  static const Duration imageZoom = Duration(milliseconds: 300);

  /// Mini player expand/collapse: 400ms
  static const Duration miniPlayerExpand = Duration(milliseconds: 400);

  /// Swipe action reveal: 200ms
  static const Duration swipeAction = Duration(milliseconds: 200);

  /// Dialog appear: 250ms
  static const Duration dialogAppear = Duration(milliseconds: 250);

  /// Bottom sheet slide: 300ms
  static const Duration bottomSheet = Duration(milliseconds: 300);

  /// Popup menu appear: 200ms
  static const Duration popupMenu = Duration(milliseconds: 200);

  /// Switch toggle: 200ms
  static const Duration switchToggle = Duration(milliseconds: 200);

  /// Nav bar hide/show: 200ms
  static const Duration navBarToggle = Duration(milliseconds: 200);

  /// Scroll position save debounce: 500ms
  static const Duration scrollPositionDebounce = Duration(milliseconds: 500);

  /// Feed refresh timeout: 30s
  static const Duration feedRefreshTimeout = Duration(seconds: 30);

  /// Short delay for micro-interactions: 100ms
  static const Duration micro = Duration(milliseconds: 100);

  /// Standard animation: 250ms
  static const Duration standard = Duration(milliseconds: 250);
}
