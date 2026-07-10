import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/theme/app_theme.dart';
import 'package:reeder/core/theme/light_theme.dart';
import 'package:reeder/data/services/podcast_service.dart';
import 'package:reeder/features/podcast_player/mini_player.dart';
import 'package:reeder/features/podcast_player/podcast_controller.dart';
import 'package:reeder/l10n/app_localizations.dart';

/// Fake that bypasses the real [PodcastController] constructor (which would
/// create a platform [AudioPlayer]). Uses `implements` + noSuchMethod so no
/// platform dependency is touched.
class _FakeController extends StateNotifier<PodcastPlayerState>
    implements PodcastController {
  _FakeController(super.state);

  int toggleCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> togglePlayPause() async => toggleCalls++;

  @override
  Future<void> stop() async => stopCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrap(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReederTheme(
        data: lightTheme,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  ProviderContainer containerWith(_FakeController fake) {
    return ProviderContainer(
      overrides: [podcastControllerProvider.overrideWith((ref) => fake)],
    );
  }

  testWidgets('renders episode and feed title when active', (tester) async {
    final fake = _FakeController(const PodcastPlayerState(
      status: PlaybackStatus.playing,
      episodeTitle: 'Episode One',
      feedTitle: 'My Feed',
    ));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, const MiniPlayer()));

    expect(find.text('Episode One'), findsOneWidget);
    expect(find.text('My Feed'), findsOneWidget);
  });

  testWidgets('hidden (shrinks) when idle', (tester) async {
    final fake = _FakeController(const PodcastPlayerState());
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, const MiniPlayer()));

    expect(find.text('Episode One'), findsNothing);
    // Pause/play glyphs absent when not active.
    expect(find.text('⏸'), findsNothing);
    expect(find.text('▶'), findsNothing);
  });

  testWidgets('shows pause glyph while playing', (tester) async {
    final fake = _FakeController(const PodcastPlayerState(
      status: PlaybackStatus.playing,
      episodeTitle: 'E',
    ));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, const MiniPlayer()));
    expect(find.text('⏸'), findsOneWidget);
  });

  testWidgets('shows play glyph while paused', (tester) async {
    final fake = _FakeController(const PodcastPlayerState(
      status: PlaybackStatus.paused,
      episodeTitle: 'E',
    ));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, const MiniPlayer()));
    expect(find.text('▶'), findsOneWidget);
  });

  testWidgets('tap play/pause calls controller', (tester) async {
    final fake = _FakeController(const PodcastPlayerState(
      status: PlaybackStatus.playing,
      episodeTitle: 'E',
    ));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, const MiniPlayer()));
    await tester.tap(find.text('⏸'));
    await tester.pump();

    expect(fake.toggleCalls, 1);
  });

  testWidgets('tap close calls stop', (tester) async {
    final fake = _FakeController(const PodcastPlayerState(
      status: PlaybackStatus.playing,
      episodeTitle: 'E',
    ));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, const MiniPlayer()));
    await tester.tap(find.text('✕'));
    await tester.pump();

    expect(fake.stopCalls, 1);
  });

  testWidgets('tap body invokes onTap', (tester) async {
    var expanded = false;
    final fake = _FakeController(const PodcastPlayerState(
      status: PlaybackStatus.playing,
      episodeTitle: 'Episode One',
    ));
    final container = containerWith(fake);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      _wrap(container, MiniPlayer(onTap: () => expanded = true)),
    );
    await tester.tap(find.text('Episode One'));
    await tester.pump();

    expect(expanded, isTrue);
  });
}
