import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../data/models/feed.dart';
import '../../data/models/feed_item.dart';
import '../podcast_player/podcast_controller.dart';
import '../source_list/source_list_controller.dart';

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
/// - article: honors the feed's `defaultViewer`:
///   - [ViewerType.browser] → in-app browser at `item.url`
///   - [ViewerType.reader] → article detail (reader view is the detail
///     page's default when reader content is available)
///   - [ViewerType.article] → [openArticle] callback (text detail view)
///
/// Audio/video kinds still override the per-feed viewer: media items always
/// launch the player.
Future<void> launchMedia(
  BuildContext context,
  WidgetRef ref,
  FeedItem item, {
  String? feedTitle,
  VoidCallback? openArticle,
}) async {
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
      await _openArticleByFeedViewer(context, ref, item, openArticle);
  }
}

/// Resolves the per-feed `defaultViewer` for an article item and routes it.
Future<void> _openArticleByFeedViewer(
  BuildContext context,
  WidgetRef ref,
  FeedItem item,
  VoidCallback? openArticle,
) async {
  // Defaults to article view if the feed lookup fails for any reason,
  // so the user always lands somewhere usable.
  ViewerType viewer = ViewerType.article;
  try {
    final feed = await ref.read(feedRepositoryProvider).getFeedById(item.feedId);
    if (feed != null) viewer = feed.defaultViewer;
  } catch (_) {
    // Fall through with the default article viewer.
  }
  if (!context.mounted) return;

  switch (viewer) {
    case ViewerType.browser:
      await context.push('/browser', extra: item.url);
    case ViewerType.reader:
      // TODO(forcing-reader-view): article_detail_page does not yet accept a
      // route param to force reader view on entry. For now, open the detail
      // route via openArticle — the detail page already prefers
      // `readerContent` when available, so reader-style content shows when
      // the extraction succeeded. Wire a `forceReader` query/extra once the
      // detail page (agent X) exposes it.
      openArticle?.call();
    case ViewerType.article:
      openArticle?.call();
  }
}
