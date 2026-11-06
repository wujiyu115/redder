import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/utils/podcast_chapters.dart';

void main() {
  group('chaptersFromShowNotes', () {
    test('parses mm:ss lines with titles', () {
      final chapters = chaptersFromShowNotes(
        'In this episode:<br>00:00 Intro<br>05:30 The main topic<br>'
        '1:02:03 Outro',
      );

      expect(chapters, hasLength(3));
      expect(chapters[0].title, 'Intro');
      expect(chapters[0].startTime, Duration.zero);
      expect(chapters[1].startTime, const Duration(minutes: 5, seconds: 30));
      expect(chapters[2].title, 'Outro');
      expect(chapters[2].startTime,
          const Duration(hours: 1, minutes: 2, seconds: 3));
    });

    test('handles <p> and newline separated notes', () {
      final chapters = chaptersFromShowNotes(
        '<p>00:00 — Cold open</p>\n<p>02:15 – Interview</p>',
      );

      expect(chapters.map((c) => c.title), ['Cold open', 'Interview']);
      expect(chapters[1].startTime, const Duration(minutes: 2, seconds: 15));
    });

    test('feeds each chapter end time from the next start', () {
      final chapters = chaptersFromShowNotes('00:00 A\n01:00 B\n02:00 C');

      expect(chapters[0].endTime, const Duration(minutes: 1));
      expect(chapters[1].endTime, const Duration(minutes: 2));
      expect(chapters[2].endTime, isNull);
    });

    test('keeps only strictly increasing timestamps', () {
      // "Recorded live at 12:30 12:30" style repeats must not create chapters.
      final chapters = chaptersFromShowNotes(
        '00:00 Intro\n05:00 Topic\n02:00 Flashback\n09:00 Topic two',
      );

      expect(chapters.map((c) => c.startTime.inMinutes), [0, 5, 9]);
    });

    test('falls back to the timestamp when a line has no title', () {
      final chapters = chaptersFromShowNotes('00:00\n03:20 Roundup');

      expect(chapters.first.title, '00:00');
    });

    test('needs at least two chapters', () {
      expect(chaptersFromShowNotes('00:00 Intro'), isEmpty);
    });

    test('ignores prose with a single inline time', () {
      expect(
        chaptersFromShowNotes('<p>We recorded this at 12:30 in the studio.</p>'),
        isEmpty,
      );
    });

    test('returns empty for empty or null input', () {
      expect(chaptersFromShowNotes(null), isEmpty);
      expect(chaptersFromShowNotes('   '), isEmpty);
    });

    test('decodes entities before matching', () {
      final chapters = chaptersFromShowNotes(
        '00:00 Bread &amp; butter<br>01:10 Q&amp;A',
      );

      expect(chapters.map((c) => c.title), ['Bread & butter', 'Q&A']);
    });
  });
}