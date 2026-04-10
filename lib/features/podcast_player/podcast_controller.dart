import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/podcast_service.dart';

/// Provider for the podcast player controller.
///
/// This is a global provider since the podcast player persists
/// across navigation (mini player at bottom of screen).
final podcastControllerProvider =
    StateNotifierProvider<PodcastController, PodcastPlayerState>(
  (ref) => PodcastController(ref),
);

/// Controller for the podcast player.
///
/// Manages the podcast playback state and provides methods
/// for controlling playback. Listens to the PodcastService
/// state stream and updates the UI state accordingly.
class PodcastController extends StateNotifier<PodcastPlayerState> {
  final Ref _ref;
  late final PodcastService _service;
  StreamSubscription<PodcastPlayerState>? _stateSubscription;

  PodcastController(this._ref) : super(const PodcastPlayerState()) {
    _service = _ref.read(podcastServiceProvider);
    _listenToState();
  }

  void _listenToState() {
    _stateSubscription = _service.stateStream.listen((playerState) {
      if (mounted) {
        state = playerState;
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  /// Plays a podcast episode.
  Future<void> playEpisode({
    required String audioUrl,
    String? episodeTitle,
    String? feedTitle,
    String? artworkUrl,
    List<PodcastChapter>? chapters,
    Duration? startPosition,
  }) async {
    await _service.play(
      audioUrl: audioUrl,
      episodeTitle: episodeTitle,
      feedTitle: feedTitle,
      artworkUrl: artworkUrl,
      chapters: chapters,
      startPosition: startPosition,
    );
  }

  /// Toggles play/pause.
  Future<void> togglePlayPause() async {
    await _service.togglePlayPause();
  }

  /// Resumes playback.
  Future<void> resume() async {
    await _service.resume();
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _service.pause();
  }

  /// Skips backward 15 seconds.
  Future<void> skipBackward() async {
    await _service.skipBackward();
  }

  /// Skips forward 30 seconds.
  Future<void> skipForward() async {
    await _service.skipForward();
  }

  /// Seeks to a specific position.
  Future<void> seekTo(Duration position) async {
    await _service.seekTo(position);
  }

  /// Sets the playback speed.
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
  }

  /// Cycles to the next playback speed.
  Future<void> cycleSpeed() async {
    await _service.cycleSpeed();
  }

  /// Sets the volume.
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }

  /// Seeks to a specific chapter.
  Future<void> seekToChapter(int chapterIndex) async {
    await _service.seekToChapter(chapterIndex);
  }

  /// Stops playback.
  Future<void> stop() async {
    await _service.stop();
  }
}
