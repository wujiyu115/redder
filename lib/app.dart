import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_durations.dart';
import 'core/router/app_router.dart';
import 'shared/providers/theme_provider.dart';
import 'features/podcast_player/mini_player.dart';
import 'features/podcast_player/full_player_page.dart';
import 'features/podcast_player/podcast_controller.dart';

/// Reeder App root widget.
///
/// Built on [WidgetsApp] instead of MaterialApp/CupertinoApp
/// for full design control over all UI components.
///
/// Includes a global mini player overlay that appears when
/// a podcast episode is playing.
class ReederApp extends ConsumerWidget {
  const ReederApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final theme = ref.watch(currentThemeProvider);
    final playerState = ref.watch(podcastControllerProvider);

    return _AnimatedThemeSwitcher(
      theme: theme,
      duration: AppDurations.themeSwitch,
      child: WidgetsApp.router(
        title: 'Reeder',
        color: theme.accentColor,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: ref.watch(appRouterProvider),
        textStyle: TextStyle(
          fontSize: theme.typography.body.fontSize,
          fontWeight: theme.typography.body.fontWeight,
          color: theme.primaryTextColor,
          decoration: TextDecoration.none,
        ),
        builder: (context, child) {
          // Clamp text scale factor to prevent layout overflow
          // while still supporting dynamic font sizes
          final mediaQuery = MediaQuery.of(context);
          final clampedTextScaler = mediaQuery.textScaler.clamp(
            minScaleFactor: 0.8,
            maxScaleFactor: 1.5,
          );

          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedTextScaler),
            child: _AppShell(
              showMiniPlayer: playerState.isActive,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

/// Animated theme switcher that crossfades between themes.
///
/// When the [theme] changes, the old theme fades out and the new
/// theme fades in over [duration] (default 300ms), providing a
/// smooth visual transition.
class _AnimatedThemeSwitcher extends StatefulWidget {
  final ReederThemeData theme;
  final Duration duration;
  final Widget child;

  const _AnimatedThemeSwitcher({
    required this.theme,
    required this.duration,
    required this.child,
  });

  @override
  State<_AnimatedThemeSwitcher> createState() => _AnimatedThemeSwitcherState();
}

class _AnimatedThemeSwitcherState extends State<_AnimatedThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ReederThemeData? _oldTheme;
  ReederThemeData? _newTheme;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTransitioning = false;
          _oldTheme = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_AnimatedThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _oldTheme = oldWidget.theme;
      _newTheme = widget.theme;
      _isTransitioning = true;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTransitioning && _oldTheme != null && _newTheme != null) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              // Old theme (fading out)
              Opacity(
                opacity: 1.0 - _animation.value,
                child: ReederTheme(
                  data: _oldTheme!,
                  child: ColoredBox(
                    color: _oldTheme!.backgroundColor,
                    child: child!,
                  ),
                ),
              ),
              // New theme (fading in)
              Opacity(
                opacity: _animation.value,
                child: ReederTheme(
                  data: _newTheme!,
                  child: ColoredBox(
                    color: _newTheme!.backgroundColor,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
        child: widget.child,
      );
    }

    return ReederTheme(
      data: widget.theme,
      child: widget.child,
    );
  }
}

/// App shell that wraps the router content with a global mini player.
///
/// The mini player slides up from the bottom with a 400ms animation
/// when a podcast episode is playing.
class _AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final bool showMiniPlayer;

  const _AppShell({
    required this.child,
    required this.showMiniPlayer,
  });

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _miniPlayerAnimController;
  late Animation<Offset> _miniPlayerSlide;

  @override
  void initState() {
    super.initState();
    _miniPlayerAnimController = AnimationController(
      duration: AppDurations.miniPlayerExpand,
      vsync: this,
      value: widget.showMiniPlayer ? 1.0 : 0.0,
    );
    _miniPlayerSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _miniPlayerAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showMiniPlayer != oldWidget.showMiniPlayer) {
      if (widget.showMiniPlayer) {
        _miniPlayerAnimController.forward();
      } else {
        _miniPlayerAnimController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _miniPlayerAnimController.dispose();
    super.dispose();
  }

  void _openFullPlayer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: const FullPlayerPage(),
          );
        },
        transitionDuration: AppDurations.miniPlayerExpand,
        reverseTransitionDuration: AppDurations.miniPlayerExpand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main content
        Expanded(child: widget.child),

        // Mini player (slides up from bottom)
        SlideTransition(
          position: _miniPlayerSlide,
          child: MiniPlayer(
            onTap: _openFullPlayer,
          ),
        ),
      ],
    );
  }
}
