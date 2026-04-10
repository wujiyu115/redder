import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the podcast service singleton.
final podcastServiceProvider = Provider<PodcastService>((ref) {
  final service = PodcastService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Represents a chapter marker in a podcast episode.
class PodcastChapter {
  /// Chapter title.
  final String title;

  /// Start time of the chapter.
  final Duration startTime;

  /// Optional end time of the chapter.
  final Duration? endTime;

  /// Optional chapter image URL.
  final String? imageUrl;

  const PodcastChapter({
    required this.title,
    required this.startTime,
    this.endTime,
    this.imageUrl,
  });
}

/// Represents the current playback state.
enum PlaybackStatus {
  /// No audio loaded.
  idle,

  /// Audio is loading/buffering.
  loading,

  /// Audio is playing.
  playing,

  /// Audio is paused.
  paused,

  /// Playback completed.
  completed,

  /// An error occurred.
  error,
}

/// Current state of the podcast player.
class PodcastPlayerState {
  /// Current playback status.
  final PlaybackStatus status;

  /// Currently playing episode title.
  final String? episodeTitle;

  /// Currently playing feed title.
  final String? feedTitle;

  /// Episode artwork URL.
  final String? artworkUrl;

  /// Audio URL being played.
  final String? audioUrl;

  /// Current playback position.
  final Duration position;

  /// Total duration of the episode.
  final Duration duration;

  /// Buffered position.
  final Duration bufferedPosition;

  /// Current playback speed.
  final double speed;

  /// Current volume (0.0 to 1.0).
  final double volume;

  /// Parsed chapter markers.
  final List<PodcastChapter> chapters;

  /// Current chapter index.
  final int? currentChapterIndex;

  /// Error message if status is error.
  final String? errorMessage;

  const PodcastPlayerState({
    this.status = PlaybackStatus.idle,
    this.episodeTitle,
    this.feedTitle,
    this.artworkUrl,
    this.audioUrl,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 1.0,
    this.volume = 1.0,
    this.chapters = const [],
    this.currentChapterIndex,
    this.errorMessage,
  });

  /// Whether audio is currently playing.
  bool get isPlaying => status == PlaybackStatus.playing;

  /// Whether audio is loaded (playing or paused).
  bool get isActive =>
      status == PlaybackStatus.playing || status == PlaybackStatus.paused;

  /// Progress as a value between 0.0 and 1.0.
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Remaining time.
  Duration get remaining => duration - position;

  PodcastPlayerState copyWith({
    PlaybackStatus? status,
    String? episodeTitle,
    String? feedTitle,
    String? artworkUrl,
    String? audioUrl,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    double? volume,
    List<PodcastChapter>? chapters,
    int? currentChapterIndex,
    String? errorMessage,
  }) {
    return PodcastPlayerState(
      status: status ?? this.status,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      feedTitle: feedTitle ?? this.feedTitle,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Service for managing podcast audio playback.
///
/// Wraps `just_audio` to provide:
/// - Play/pause/seek controls
/// - 15s rewind / 30s fast-forward
/// - Playback speed control (0.5x - 3.0x)
/// - Volume control
/// - Chapter marker parsing
/// - Position/duration/buffered streams
class PodcastService {
  final AudioPlayer _player = AudioPlayer();

  PodcastPlayerState _state = const PodcastPlayerState();

  /// Stream of player state updates.
  Stream<PodcastPlayerState> get stateStream => _createStateStream();

  /// Current player state.
  PodcastPlayerState get currentState => _state;

  /// Available playback speeds.
  static const List<double> availableSpeeds = [
    0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0,
  ];

  /// Creates a combined stream of all player state changes.
  Stream<PodcastPlayerState> _createStateStream() async* {
    // Listen to player state changes
    await for (final playerState in _player.playerStateStream) {
      PlaybackStatus status;
      switch (playerState.processingState) {
        case ProcessingState.idle:
          status = PlaybackStatus.idle;
          break;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          status = PlaybackStatus.loading;
          break;
        case ProcessingState.ready:
          status = playerState.playing
              ? PlaybackStatus.playing
              : PlaybackStatus.paused;
          break;
        case ProcessingState.completed:
          status = PlaybackStatus.completed;
          break;
      }

      _state = _state.copyWith(
        status: status,
        position: _player.position,
        duration: _player.duration ?? Duration.zero,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        volume: _player.volume,
        currentChapterIndex: _getCurrentChapterIndex(),
      );

      yield _state;
    }
  }

  /// Loads and plays an audio episode.
  Future<void> play({
    required String audioUrl,
    String? episodeTitle,
    String? feedTitle,
    String? artworkUrl,
    List<PodcastChapter>? chapters,
    Duration? startPosition,
  }) async {
    try {
      _state = _state.copyWith(
        status: PlaybackStatus.loading,
        episodeTitle: episodeTitle,
        feedTitle: feedTitle,
        artworkUrl: artworkUrl,
        audioUrl: audioUrl,
        chapters: chapters ?? [],
        position: Duration.zero,
        duration: Duration.zero,
      );

      final duration = await _player.setUrl(audioUrl);
      _state = _state.copyWith(
        duration: duration ?? Duration.zero,
      );

      if (startPosition != null) {
        await _player.seek(startPosition);
      }

      await _player.play();
    } catch (e) {
      _state = _state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resumes playback.
  Future<void> resume() async {
    await _player.play();
  }

  /// Pauses playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Toggles play/pause.
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Seeks to a specific position.
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Seeks relative to current position.
  Future<void> seekRelative(Duration offset) async {
    final newPosition = _player.position + offset;
    final clamped = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(
        0,
        (_player.duration ?? Duration.zero).inMilliseconds,
      ),
    );
    await _player.seek(clamped);
  }

  /// Skips backward 15 seconds.
  Future<void> skipBackward() async {
    await seekRelative(const Duration(seconds: -15));
  }

  /// Skips forward 30 seconds.
  Future<void> skipForward() async {
    await seekRelative(const Duration(seconds: 30));
  }

  /// Sets the playback speed.
  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 3.0);
    await _player.setSpeed(clamped);
    _state = _state.copyWith(speed: clamped);
  }

  /// Cycles to the next available speed.
  Future<void> cycleSpeed() async {
    final currentIndex = availableSpeeds.indexOf(_state.speed);
    final nextIndex = (currentIndex + 1) % availableSpeeds.length;
    await setSpeed(availableSpeeds[nextIndex]);
  }

  /// Sets the volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    await _player.setVolume(clamped);
    _state = _state.copyWith(volume: clamped);
  }

  /// Seeks to a specific chapter.
  Future<void> seekToChapter(int chapterIndex) async {
    if (chapterIndex >= 0 && chapterIndex < _state.chapters.length) {
      await seekTo(_state.chapters[chapterIndex].startTime);
    }
  }

  /// Stops playback and resets state.
  Future<void> stop() async {
    await _player.stop();
    _state = const PodcastPlayerState();
  }

  /// Gets the current chapter index based on position.
  int? _getCurrentChapterIndex() {
    if (_state.chapters.isEmpty) return null;

    final position = _player.position;
    for (int i = _state.chapters.length - 1; i >= 0; i--) {
      if (position >= _state.chapters[i].startTime) {
        return i;
      }
    }
    return 0;
  }

  /// Disposes the audio player.
  void dispose() {
    _player.dispose();
  }
}
