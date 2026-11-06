import '../extensions/string_ext.dart';
import '../../data/services/podcast_service.dart';

/// A chapter line found in a show-notes block, kept private to the parser.
class _ChapterLine {
  const _ChapterLine(this.start, this.title);

  final Duration start;
  final String title;
}

/// Leading timestamp of a chapter line: `00:00`, `1:02:03`, `[00:00]`,
/// optionally followed by a separator (`-`, `–`, `—`, `:`) before the title.
final RegExp _chapterTimestamp = RegExp(
  r'^\s*\[?(\d{1,3}):([0-5]\d)(?::([0-5]\d))?\]?\s*(?:[-–—:|]\s*)?(.*)$',
);

/// Splits HTML show notes into plain-text lines, one per `<br>`, `</p>`, `<li>`
/// or newline. Podcast notes commonly put each chapter on its own line.
final RegExp _lineBreak = RegExp(
  r'<br\s*/?>|</p>|</li>|</div>|\r?\n',
  caseSensitive: false,
);

/// Extracts chapter markers from podcast show notes.
///
/// The player has always had a chapters list, but nothing ever populated it:
/// `PodcastPlayerState.chapters` was only filled by the (unused) `chapters`
/// parameter. Most podcasts publish their chapters as timestamped lines in the
/// show notes, so deriving them here makes the existing chapter UI real without
/// a schema change or an extra network round-trip.
///
/// Returns an empty list unless at least two well-formed, strictly increasing
/// timestamps are found — a lone coincidence ("recorded at 12:30") is not a
/// chapter list.
List<PodcastChapter> chaptersFromShowNotes(String? html) {
  if (html == null || html.trim().isEmpty) return const [];

  final found = <_ChapterLine>[];
  for (final rawLine in html.split(_lineBreak)) {
    final line = rawLine.plainText;
    if (line.isEmpty) continue;

    final match = _chapterTimestamp.firstMatch(line);
    if (match == null) continue;

    final first = int.parse(match.group(1)!);
    final second = int.parse(match.group(2)!);
    final third = match.group(3);
    // Two components are mm:ss, three are hh:mm:ss.
    final start = third == null
        ? Duration(minutes: first, seconds: second)
        : Duration(hours: first, minutes: second, seconds: int.parse(third));

    found.add(_ChapterLine(start, match.group(4)!.trim()));
  }

  if (found.length < 2) return const [];

  // Keep only a strictly increasing run: show notes often repeat the current
  // playback time in ad/segment blurbs, which would otherwise break seeking.
  final ascending = <_ChapterLine>[];
  for (final chapter in found) {
    if (ascending.isEmpty || chapter.start > ascending.last.start) {
      ascending.add(chapter);
    }
  }
  if (ascending.length < 2) return const [];

  return [
    for (var i = 0; i < ascending.length; i++)
      PodcastChapter(
        title: ascending[i].title.isEmpty
            ? _formatTimestamp(ascending[i].start)
            : ascending[i].title,
        startTime: ascending[i].start,
        // The next chapter starts where this one ends; the last one is
        // open-ended (the player clamps to the media duration).
        endTime: i + 1 < ascending.length ? ascending[i + 1].start : null,
      ),
  ];
}

String _formatTimestamp(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$minutes:$seconds';
  return '$minutes:$seconds';
}