import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/models/feed_item.dart';
import 'package:reeder/features/media/media_launcher.dart';

FeedItem _item({
  required ContentType contentType,
  String? audioUrl,
  String? videoUrl,
}) {
  final now = DateTime(2024, 1, 1);
  return FeedItem(
    id: 1,
    feedId: 1,
    title: 'Test',
    url: 'https://example.com/1',
    audioUrl: audioUrl,
    videoUrl: videoUrl,
    publishedAt: now,
    fetchedAt: now,
    contentType: contentType,
    isRead: false,
    isStarred: false,
    createdAt: now,
  );
}

void main() {
  group('resolveMediaKind', () {
    test('audio with url -> audio', () {
      expect(
        resolveMediaKind(_item(
          contentType: ContentType.audio,
          audioUrl: 'https://cdn/ep.mp3',
        )),
        MediaKind.audio,
      );
    });

    test('audio without url -> article', () {
      expect(
        resolveMediaKind(_item(contentType: ContentType.audio)),
        MediaKind.article,
      );
    });

    test('audio with empty url -> article', () {
      expect(
        resolveMediaKind(_item(contentType: ContentType.audio, audioUrl: '')),
        MediaKind.article,
      );
    });

    test('video with url -> video', () {
      expect(
        resolveMediaKind(_item(
          contentType: ContentType.video,
          videoUrl: 'https://cdn/v.mp4',
        )),
        MediaKind.video,
      );
    });

    test('video without url -> article', () {
      expect(
        resolveMediaKind(_item(contentType: ContentType.video)),
        MediaKind.article,
      );
    });

    test('article -> article', () {
      expect(
        resolveMediaKind(_item(contentType: ContentType.article)),
        MediaKind.article,
      );
    });

    test('image -> article', () {
      expect(
        resolveMediaKind(_item(contentType: ContentType.image)),
        MediaKind.article,
      );
    });

    test('audio contentType ignored when only videoUrl present -> article', () {
      expect(
        resolveMediaKind(_item(
          contentType: ContentType.audio,
          videoUrl: 'https://cdn/v.mp4',
        )),
        MediaKind.article,
      );
    });
  });

  group('isEmbedVideoUrl', () {
    test('youtube.com watch url -> true', () {
      expect(isEmbedVideoUrl('https://www.youtube.com/watch?v=abc'), isTrue);
    });

    test('youtu.be short url -> true', () {
      expect(isEmbedVideoUrl('https://youtu.be/abc'), isTrue);
    });

    test('vimeo -> true', () {
      expect(isEmbedVideoUrl('https://vimeo.com/12345'), isTrue);
    });

    test('dailymotion -> true', () {
      expect(isEmbedVideoUrl('https://www.dailymotion.com/video/x'), isTrue);
    });

    test('twitch -> true', () {
      expect(isEmbedVideoUrl('https://twitch.tv/streamer'), isTrue);
    });

    test('case insensitive', () {
      expect(isEmbedVideoUrl('HTTPS://YOUTUBE.COM/watch?v=x'), isTrue);
    });

    test('direct mp4 -> false', () {
      expect(isEmbedVideoUrl('https://cdn.example.com/video.mp4'), isFalse);
    });

    test('empty -> false', () {
      expect(isEmbedVideoUrl(''), isFalse);
    });
  });
}
