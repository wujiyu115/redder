import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import 'podcast_controller.dart';

/// Mini player widget displayed at the bottom of the screen.
///
/// Shows:
/// - Episode artwork (small)
/// - Episode title + feed title
/// - Play/pause button
/// - Progress bar
///
/// Tapping expands to the full player page.
class MiniPlayer extends ConsumerWidget {
  /// Callback when the mini player is tapped (expand to full player).
  final VoidCallback? onTap;

  const MiniPlayer({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(podcastControllerProvider);
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Don't show if nothing is playing
    if (!playerState.isActive) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: AppDimensions.miniPlayerHeight,
        decoration: BoxDecoration(
          color: theme.secondaryBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.separatorColor,
              width: AppDimensions.separatorThickness,
            ),
          ),
        ),
        child: Column(
          children: [
            // Progress bar (thin line at top)
            _MiniProgressBar(
              progress: playerState.progress,
              accentColor: theme.accentColor,
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing,
                ),
                child: Row(
                  children: [
                    // Artwork
                    _MiniArtwork(
                      artworkUrl: playerState.artworkUrl,
                      theme: theme,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),

                    // Title info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerState.episodeTitle ?? l10n.unknownEpisode,
                            style: theme.typography.body.copyWith(
                              color: theme.primaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (playerState.feedTitle != null)
                            Text(
                              playerState.feedTitle!,
                              style: theme.typography.caption.copyWith(
                                color: theme.secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),

                    // Play/Pause button
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(podcastControllerProvider.notifier)
                            .togglePlayPause();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Text(
                            playerState.isPlaying ? '⏸' : '▶',
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Close button
                    GestureDetector(
                      onTap: () {
                        ref.read(podcastControllerProvider.notifier).stop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 36,
                        height: 44,
                        child: Center(
                          child: Text(
                            '✕',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: theme.tertiaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin progress bar at the top of the mini player.
class _MiniProgressBar extends StatelessWidget {
  final double progress;
  final Color accentColor;

  const _MiniProgressBar({
    required this.progress,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: ColoredBox(color: accentColor),
      ),
    );
  }
}

/// Small artwork thumbnail for the mini player.
class _MiniArtwork extends StatelessWidget {
  final String? artworkUrl;
  final ReederThemeData theme;

  const _MiniArtwork({
    this.artworkUrl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    const size = 40.0;

    if (artworkUrl != null && artworkUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: CachedNetworkImage(
          imageUrl: artworkUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _defaultArtwork(),
        ),
      );
    }

    return _defaultArtwork();
  }

  Widget _defaultArtwork() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: const Center(
        child: Text('🎙', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
