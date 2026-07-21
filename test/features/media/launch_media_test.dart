import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/models/feed_item.dart';
import 'package:reeder/data/services/podcast_service.dart';
import 'package:reeder/features/media/media_launcher.dart';
import 'package:reeder/features/podcast_player/podcast_controller.dart';

class _FakeController extends StateNotifier<PodcastPlayerState>
    implements PodcastController {
  _FakeController() : super(const PodcastPlayerState());

  String? playedAudioUrl;
  String? playedTitle;
  String? playedFeedTitle;

  @override
  Future<void> playEpisode({
    required String audioUrl,
    String? episodeTitle,
    String? feedTitle,
    String? artworkUrl,
    List<PodcastChapter>? chapters,
    Duration? startPosition,
  }) async {
    playedAudioUrl = audioUrl;
    playedTitle = episodeTitle;
    playedFeedTitle = feedTitle;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

FeedItem _item({
  required ContentType contentType,
  String? audioUrl,
  String? videoUrl,
  String title = 'Item',
}) {
  final now = DateTime(2024, 1, 1);
  return FeedItem(
    id: 7,
    feedId: 3,
    title: title,
    url: 'https://example.com/7',
    audioUrl: audioUrl,
    videoUrl: videoUrl,
    imageUrl: 'https://img/art.png',
    publishedAt: now,
    fetchedAt: now,
    contentType: contentType,
    isRead: false,
    isStarred: false,
    createdAt: now,
  );
}

/// Builds a GoRouter whose home has a button that runs [onPressed] with a
/// BuildContext + WidgetRef, plus stub player routes that render markers.
Widget _harness({
  required _FakeController fake,
  required void Function(BuildContext, WidgetRef) onPressed,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => onPressed(context, ref),
                child: const Text('go'),
              ),
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: 'podcast-player',
            name: 'podcastPlayer',
            builder: (context, state) =>
                const Scaffold(body: Text('PODCAST_PLAYER')),
          ),
          GoRoute(
            path: 'video-player',
            name: 'videoPlayer',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return Scaffold(
                body: Text('VIDEO:${extra['videoUrl']}:${extra['title']}'),
              );
            },
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [podcastControllerProvider.overrideWith((ref) => fake)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('audio: plays episode and navigates to podcast player',
      (tester) async {
    final fake = _FakeController();
    final item = _item(
      contentType: ContentType.audio,
      audioUrl: 'https://cdn/ep.mp3',
      title: 'My Episode',
    );

    await tester.pumpWidget(_harness(
      fake: fake,
      onPressed: (context, ref) =>
          launchMedia(context, ref, item, timelineId: 'all', feedTitle: 'Feed X'),
    ));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(fake.playedAudioUrl, 'https://cdn/ep.mp3');
    expect(fake.playedTitle, 'My Episode');
    expect(fake.playedFeedTitle, 'Feed X');
    expect(find.text('PODCAST_PLAYER'), findsOneWidget);
  });

  testWidgets('video: navigates to video player with extra', (tester) async {
    final fake = _FakeController();
    final item = _item(
      contentType: ContentType.video,
      videoUrl: 'https://cdn/v.mp4',
      title: 'Clip',
    );

    await tester.pumpWidget(_harness(
      fake: fake,
      onPressed: (context, ref) => launchMedia(context, ref, item, timelineId: 'all'),
    ));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('VIDEO:https://cdn/v.mp4:Clip'), findsOneWidget);
    expect(fake.playedAudioUrl, isNull);
  });

  testWidgets('article: invokes openArticle, no navigation', (tester) async {
    final fake = _FakeController();
    var opened = false;
    final item = _item(contentType: ContentType.article);

    await tester.pumpWidget(_harness(
      fake: fake,
      onPressed: (context, ref) => launchMedia(
        context,
        ref,
        item,
        timelineId: 'all',
        openArticle: () => opened = true,
      ),
    ));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(find.text('go'), findsOneWidget); // still on home
    expect(fake.playedAudioUrl, isNull);
  });

  testWidgets('audio without url falls back to article', (tester) async {
    final fake = _FakeController();
    var opened = false;
    final item = _item(contentType: ContentType.audio); // no audioUrl

    await tester.pumpWidget(_harness(
      fake: fake,
      onPressed: (context, ref) =>
          launchMedia(context, ref, item, timelineId: 'all', openArticle: () => opened = true),
    ));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(fake.playedAudioUrl, isNull);
    expect(find.text('PODCAST_PLAYER'), findsNothing);
  });
}
