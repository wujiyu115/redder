import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/data/services/podcast_service.dart';

void main() {
  group('PodcastPlayerState defaults', () {
    const s = PodcastPlayerState();

    test('idle by default', () {
      expect(s.status, PlaybackStatus.idle);
      expect(s.position, Duration.zero);
      expect(s.duration, Duration.zero);
      expect(s.speed, 1.0);
      expect(s.volume, 1.0);
      expect(s.chapters, isEmpty);
      expect(s.episodeTitle, isNull);
    });

    test('isPlaying false when idle', () => expect(s.isPlaying, isFalse));
    test('isActive false when idle', () => expect(s.isActive, isFalse));
  });

  group('isPlaying / isActive', () {
    test('playing', () {
      const s = PodcastPlayerState(status: PlaybackStatus.playing);
      expect(s.isPlaying, isTrue);
      expect(s.isActive, isTrue);
    });

    test('paused: not playing but active', () {
      const s = PodcastPlayerState(status: PlaybackStatus.paused);
      expect(s.isPlaying, isFalse);
      expect(s.isActive, isTrue);
    });

    test('loading: neither', () {
      const s = PodcastPlayerState(status: PlaybackStatus.loading);
      expect(s.isPlaying, isFalse);
      expect(s.isActive, isFalse);
    });

    test('completed: neither', () {
      const s = PodcastPlayerState(status: PlaybackStatus.completed);
      expect(s.isPlaying, isFalse);
      expect(s.isActive, isFalse);
    });
  });

  group('progress', () {
    test('zero duration -> 0.0', () {
      const s = PodcastPlayerState(position: Duration(seconds: 5));
      expect(s.progress, 0.0);
    });

    test('midpoint -> 0.5', () {
      const s = PodcastPlayerState(
        position: Duration(seconds: 30),
        duration: Duration(seconds: 60),
      );
      expect(s.progress, 0.5);
    });

    test('position beyond duration clamps to 1.0', () {
      const s = PodcastPlayerState(
        position: Duration(seconds: 90),
        duration: Duration(seconds: 60),
      );
      expect(s.progress, 1.0);
    });
  });

  group('remaining', () {
    test('duration - position', () {
      const s = PodcastPlayerState(
        position: Duration(seconds: 20),
        duration: Duration(seconds: 60),
      );
      expect(s.remaining, const Duration(seconds: 40));
    });
  });

  group('copyWith', () {
    test('overrides only given fields', () {
      const s = PodcastPlayerState(episodeTitle: 'A', speed: 1.0);
      final c = s.copyWith(speed: 1.5);
      expect(c.speed, 1.5);
      expect(c.episodeTitle, 'A');
    });

    test('preserves fields when nothing passed', () {
      const s = PodcastPlayerState(
        status: PlaybackStatus.playing,
        episodeTitle: 'Ep',
        feedTitle: 'Feed',
        position: Duration(seconds: 3),
      );
      final c = s.copyWith();
      expect(c.status, PlaybackStatus.playing);
      expect(c.episodeTitle, 'Ep');
      expect(c.feedTitle, 'Feed');
      expect(c.position, const Duration(seconds: 3));
    });
  });

  group('PodcastChapter', () {
    test('constructs with fields', () {
      const ch = PodcastChapter(
        title: 'Intro',
        startTime: Duration(seconds: 0),
        endTime: Duration(seconds: 60),
        imageUrl: 'https://img',
      );
      expect(ch.title, 'Intro');
      expect(ch.startTime, Duration.zero);
      expect(ch.endTime, const Duration(seconds: 60));
      expect(ch.imageUrl, 'https://img');
    });

    test('endTime and imageUrl optional', () {
      const ch = PodcastChapter(title: 'X', startTime: Duration(seconds: 5));
      expect(ch.endTime, isNull);
      expect(ch.imageUrl, isNull);
    });
  });

  group('availableSpeeds', () {
    test('contains normal and extreme speeds, sorted', () {
      expect(PodcastService.availableSpeeds, contains(1.0));
      expect(PodcastService.availableSpeeds.first, 0.5);
      expect(PodcastService.availableSpeeds.last, 3.0);
      final sorted = [...PodcastService.availableSpeeds]..sort();
      expect(PodcastService.availableSpeeds, sorted);
    });
  });
}
