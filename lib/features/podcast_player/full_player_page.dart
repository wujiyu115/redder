import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/podcast_service.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_slider.dart';
import 'podcast_controller.dart';

/// Full-screen podcast player page.
///
/// Displays:
/// - Large artwork
/// - Episode title and feed title
/// - Playback progress slider
/// - Time labels (current / remaining)
/// - Transport controls (skip back 15s, play/pause, skip forward 30s)
/// - Speed control button
/// - Volume slider
/// - Chapter list (if available)
class FullPlayerPage extends ConsumerStatefulWidget {
  const FullPlayerPage({super.key});

  @override
  ConsumerState<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends ConsumerState<FullPlayerPage> {
  bool _showChapters = false;

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final playerState = ref.watch(podcastControllerProvider);
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.nowPlaying,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: playerState.isActive
          ? _buildPlayer(context, playerState, theme, mediaQuery, l10n)
          : _buildEmpty(theme, l10n),
    );
  }

  Widget _buildEmpty(ReederThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎙', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppDimensions.spacing),
          Text(
            l10n.noEpisodePlaying,
            style: theme.typography.listTitle.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(
    BuildContext context,
    PodcastPlayerState playerState,
    ReederThemeData theme,
    MediaQueryData mediaQuery,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXL,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Artwork ────────────────────────────────────
          _LargeArtwork(
            artworkUrl: playerState.artworkUrl,
            theme: theme,
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Title Info ─────────────────────────────────
          Text(
            playerState.episodeTitle ?? l10n.unknownEpisode,
            style: theme.typography.articleTitle.copyWith(
              color: theme.primaryTextColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            playerState.feedTitle ?? '',
            style: theme.typography.body.copyWith(
              color: theme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Progress Slider ────────────────────────────
          _ProgressSlider(
            position: playerState.position,
            duration: playerState.duration,
            bufferedPosition: playerState.bufferedPosition,
            onSeek: (position) {
              ref.read(podcastControllerProvider.notifier).seekTo(position);
            },
            theme: theme,
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Transport Controls ─────────────────────────
          _TransportControls(
            isPlaying: playerState.isPlaying,
            isLoading: playerState.status == PlaybackStatus.loading,
            onSkipBackward: () {
              ref.read(podcastControllerProvider.notifier).skipBackward();
            },
            onTogglePlayPause: () {
              ref.read(podcastControllerProvider.notifier).togglePlayPause();
            },
            onSkipForward: () {
              ref.read(podcastControllerProvider.notifier).skipForward();
            },
            theme: theme,
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // ─── Speed + Volume Row ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speed button
              GestureDetector(
                onTap: () {
                  ref.read(podcastControllerProvider.notifier).cycleSpeed();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                    vertical: AppDimensions.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Text(
                    '${playerState.speed}x',
                    style: theme.typography.body.copyWith(
                      color: theme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ─── Volume Slider ──────────────────────────────
          const SizedBox(height: AppDimensions.spacing),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing,
            ),
            child: Row(
              children: [
                Text(
                  '🔈',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.secondaryTextColor,
                  ),
                ),
                Expanded(
                  child: ReederSlider(
                    value: playerState.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      ref
                          .read(podcastControllerProvider.notifier)
                          .setVolume(value);
                    },
                  ),
                ),
                Text(
                  '🔊',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // ─── Chapters ──────────────────────────────────
          if (playerState.chapters.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXL),
            GestureDetector(
              onTap: () => setState(() => _showChapters = !_showChapters),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    l10n.chapters,
                    style: theme.typography.sectionHeader.copyWith(
                      color: theme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    _showChapters ? '▼' : '▶',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_showChapters)
              _ChapterList(
                chapters: playerState.chapters,
                currentIndex: playerState.currentChapterIndex,
                onChapterTap: (index) {
                  ref
                      .read(podcastControllerProvider.notifier)
                      .seekToChapter(index);
                },
                theme: theme,
              ),
          ],

          // Bottom padding
          SizedBox(height: mediaQuery.padding.bottom + AppDimensions.spacingXXL),
        ],
      ),
    );
  }
}

/// Large artwork display.
class _LargeArtwork extends StatelessWidget {
  final String? artworkUrl;
  final ReederThemeData theme;

  const _LargeArtwork({this.artworkUrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.65;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: SizedBox(
        width: size,
        height: size,
        child: artworkUrl != null && artworkUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: artworkUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _defaultArtwork(size),
              )
            : _defaultArtwork(size),
      ),
    );
  }

  Widget _defaultArtwork(double size) {
    return Container(
      width: size,
      height: size,
      color: theme.secondaryBackgroundColor,
      child: const Center(
        child: Text('🎙', style: TextStyle(fontSize: 80)),
      ),
    );
  }
}

/// Playback progress slider with time labels.
class _ProgressSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final void Function(Duration) onSeek;
  final ReederThemeData theme;

  const _ProgressSlider({
    required this.position,
    required this.duration,
    required this.bufferedPosition,
    required this.onSeek,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        // Slider
        ReederSlider(
          value: progress.clamp(0.0, 1.0),
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            final newPosition = Duration(
              milliseconds: (value * duration.inMilliseconds).round(),
            );
            onSeek(newPosition);
          },
        ),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
              Text(
                '-${_formatDuration(duration - position)}',
                style: theme.typography.caption.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Transport controls (skip back, play/pause, skip forward).
class _TransportControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onSkipBackward;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onSkipForward;
  final ReederThemeData theme;

  const _TransportControls({
    required this.isPlaying,
    required this.isLoading,
    required this.onSkipBackward,
    required this.onTogglePlayPause,
    required this.onSkipForward,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward 15s
        GestureDetector(
          onTap: onSkipBackward,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⏪',
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.primaryTextColor,
                  ),
                ),
                Text(
                  '15',
                  style: theme.typography.caption.copyWith(
                    color: theme.secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppDimensions.spacingXL),

        // Play/Pause
        GestureDetector(
          onTap: onTogglePlayPause,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.accentColor,
            ),
            child: Center(
              child: isLoading
                  ? Text(
                      '⏳',
                      style: TextStyle(
                        fontSize: 28,
                        color: theme.backgroundColor,
                      ),
                    )
                  : Text(
                      isPlaying ? '⏸' : '▶',
                      style: TextStyle(
                        fontSize: 28,
                        color: theme.backgroundColor,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(width: AppDimensions.spacingXL),

        // Skip forward 30s
        GestureDetector(
          onTap: onSkipForward,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⏩',
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.primaryTextColor,
                  ),
                ),
                Text(
                  '30',
                  style: theme.typography.caption.copyWith(
                    color: theme.secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Chapter list display.
class _ChapterList extends StatelessWidget {
  final List<PodcastChapter> chapters;
  final int? currentIndex;
  final void Function(int) onChapterTap;
  final ReederThemeData theme;

  const _ChapterList({
    required this.chapters,
    this.currentIndex,
    required this.onChapterTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spacingS),
      child: Column(
        children: [
          for (int i = 0; i < chapters.length; i++)
            GestureDetector(
              onTap: () => onChapterTap(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingM,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.separatorColor,
                      width: AppDimensions.separatorThickness,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Playing indicator
                    SizedBox(
                      width: 24,
                      child: i == currentIndex
                          ? Text(
                              '▶',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.accentColor,
                              ),
                            )
                          : Text(
                              '${i + 1}',
                              style: theme.typography.caption.copyWith(
                                color: theme.tertiaryTextColor,
                              ),
                            ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),

                    // Chapter title
                    Expanded(
                      child: Text(
                        chapters[i].title,
                        style: theme.typography.body.copyWith(
                          color: i == currentIndex
                              ? theme.accentColor
                              : theme.primaryTextColor,
                          fontWeight: i == currentIndex
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Time
                    Text(
                      _formatDuration(chapters[i].startTime),
                      style: theme.typography.caption.copyWith(
                        color: theme.tertiaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
