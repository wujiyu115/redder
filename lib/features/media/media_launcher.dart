import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../data/models/feed_item.dart';
import '../podcast_player/podcast_controller.dart';

/// The playback destination for a feed item.
enum MediaKind { audio, video, article }

/// Determines how a feed item should be opened.
///
/// Audio/video kinds require a usable media URL; otherwise the item falls
/// back to the text article view.
MediaKind resolveMediaKind(FeedItem item) {
  if (item.contentType == ContentType.audio &&
      (item.audioUrl?.isNotEmpty ?? false)) {
    return MediaKind.audio;
  }
  if (item.contentType == ContentType.video &&
      (item.videoUrl?.isNotEmpty ?? false)) {
    return MediaKind.video;
  }
  return MediaKind.article;
}

/// Whether a video URL points to an embed/platform player that needs a
/// WebView instead of native playback.
bool isEmbedVideoUrl(String url) {
  final lower = url.toLowerCase();
  return lower.contains('youtube.com') ||
      lower.contains('youtu.be') ||
      lower.contains('vimeo.com') ||
      lower.contains('dailymotion.com') ||
      lower.contains('twitch.tv');
}

/// Opens a feed item in the appropriate destination.
///
/// - audio: starts playback and pushes the full-screen podcast player
/// - video: pushes the video player page
/// - article: invokes [openArticle] (text detail view)
void launchMedia(
  BuildContext context,
  WidgetRef ref,
  FeedItem item, {
  String? feedTitle,
  VoidCallback? openArticle,
}) {
  switch (resolveMediaKind(item)) {
    case MediaKind.audio:
      ref.read(podcastControllerProvider.notifier).playEpisode(
            audioUrl: item.audioUrl!,
            episodeTitle: item.title,
            feedTitle: feedTitle,
            artworkUrl: item.imageUrl,
          );
      context.pushNamed('podcastPlayer');
    case MediaKind.video:
      context.pushNamed(
        'videoPlayer',
        extra: {
          'videoUrl': item.videoUrl,
          'title': item.title,
        },
      );
    case MediaKind.article:
      openArticle?.call();
  }
}
