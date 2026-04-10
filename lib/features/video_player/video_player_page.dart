import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';

/// Video player page supporting native playback and WebView fallback.
///
/// Features:
/// - Native video playback via video_player + chewie for direct URLs
/// - WebView fallback for YouTube and other embedded platforms
/// - Full-screen toggle
/// - Playback controls (play/pause, seek, volume)
class VideoPlayerPage extends StatefulWidget {
  /// Direct video URL for native playback.
  final String? videoUrl;

  /// Embed URL for WebView playback (YouTube, Vimeo, etc.).
  final String? embedUrl;

  /// Video title.
  final String? title;

  const VideoPlayerPage({
    super.key,
    this.videoUrl,
    this.embedUrl,
    this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _useWebView = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Determine playback mode
    if (widget.videoUrl != null && !_isEmbedUrl(widget.videoUrl!)) {
      // Native video playback
      await _initNativePlayer(widget.videoUrl!);
    } else {
      // WebView fallback for YouTube, Vimeo, etc.
      setState(() {
        _useWebView = true;
        _isInitialized = true;
      });
    }
  }

  /// Checks if a URL is an embed/platform URL that needs WebView.
  bool _isEmbedUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        lower.contains('vimeo.com') ||
        lower.contains('dailymotion.com') ||
        lower.contains('twitch.tv');
  }

  Future<void> _initNativePlayer(String url) async {
    try {
      final uri = Uri.parse(url);
      _videoController = VideoPlayerController.networkUrl(uri);
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        errorBuilder: (context, errorMessage) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('❌', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppDimensions.spacing),
                Text(
                  l10n.failedToPlayVideo,
                  style: TextStyle(
                    fontSize: 16,
                    color: ReederTheme.of(context).primaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: ReederTheme.of(context).secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          // Fallback to WebView
          _useWebView = true;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: widget.title ?? l10n.video,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: _isInitialized ? _buildContent(theme) : _buildLoading(theme, l10n),
    );
  }

  Widget _buildLoading(ReederThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppDimensions.spacing),
          Text(
            l10n.loadingVideo,
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ReederThemeData theme) {
    if (_useWebView) {
      return _buildWebViewPlayer(theme);
    }

    if (_chewieController != null) {
      return _buildNativePlayer(theme);
    }

    return _buildError(theme);
  }

  Widget _buildNativePlayer(ReederThemeData theme) {
    return Column(
      children: [
        // Video player
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
          ),
        ),

        // Title bar
        if (widget.title != null)
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing),
            child: Text(
              widget.title!,
              style: theme.typography.listTitle.copyWith(
                color: theme.primaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildWebViewPlayer(ReederThemeData theme) {
    final url = widget.embedUrl ?? widget.videoUrl;
    if (url == null) return _buildError(theme);

    // Convert YouTube watch URLs to embed URLs
    final embedUrl = _convertToEmbedUrl(url);

    return Column(
      children: [
        // WebView player
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              javaScriptEnabled: true,
              supportZoom: false,
            ),
          ),
        ),

        // Title bar
        if (widget.title != null)
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing),
            child: Text(
              widget.title!,
              style: theme.typography.listTitle.copyWith(
                color: theme.primaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildError(ReederThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('❌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppDimensions.spacing),
          Text(
            l10n.unableToPlayVideo,
            style: theme.typography.listTitle.copyWith(
              color: theme.primaryTextColor,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXL,
              ),
              child: Text(
                _errorMessage!,
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Converts platform URLs to embeddable URLs.
  String _convertToEmbedUrl(String url) {
    // YouTube watch URL → embed URL
    final youtubeMatch = RegExp(
      r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)',
    ).firstMatch(url);
    if (youtubeMatch != null) {
      return 'https://www.youtube.com/embed/${youtubeMatch.group(1)}?autoplay=1';
    }

    // Vimeo URL → embed URL
    final vimeoMatch = RegExp(
      r'vimeo\.com/(\d+)',
    ).firstMatch(url);
    if (vimeoMatch != null) {
      return 'https://player.vimeo.com/video/${vimeoMatch.group(1)}?autoplay=1';
    }

    return url;
  }
}
