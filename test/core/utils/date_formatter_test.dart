import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/utils/date_formatter.dart';

void main() {
  group('relativeTime', () {
    test('future date -> Just now', () {
      expect(
        DateFormatter.relativeTime(DateTime.now().add(const Duration(hours: 1))),
        'Just now',
      );
    });

    test('< 1 minute -> Just now', () {
      expect(
        DateFormatter.relativeTime(
            DateTime.now().subtract(const Duration(seconds: 30))),
        'Just now',
      );
    });

    test('minutes', () {
      expect(
        DateFormatter.relativeTime(
            DateTime.now().subtract(const Duration(minutes: 5))),
        '5m',
      );
    });

    test('hours', () {
      expect(
        DateFormatter.relativeTime(
            DateTime.now().subtract(const Duration(hours: 3))),
        '3h',
      );
    });

    test('days (< 7)', () {
      expect(
        DateFormatter.relativeTime(
            DateTime.now().subtract(const Duration(days: 3))),
        '3d',
      );
    });

    test('same year older than a week -> "Mon D"', () {
      final now = DateTime.now();
      // Pick Jan 15 of the current year, but only if it's > 7 days ago.
      final date = DateTime(now.year, 1, 15);
      if (now.difference(date).inDays >= 7) {
        expect(DateFormatter.relativeTime(date), 'Jan 15');
      }
    });

    test('different year -> "Mon D, YYYY"', () {
      expect(
        DateFormatter.relativeTime(DateTime(2020, 3, 5)),
        'Mar 5, 2020',
      );
    });
  });

  group('fullDate / shortDate', () {
    test('fullDate', () {
      expect(DateFormatter.fullDate(DateTime(2024, 1, 15)), 'January 15, 2024');
    });

    test('shortDate', () {
      expect(DateFormatter.shortDate(DateTime(2024, 12, 31)), 'Dec 31, 2024');
    });
  });

  group('dateTime', () {
    test('afternoon -> PM 12-hour', () {
      expect(
        DateFormatter.dateTime(DateTime(2024, 1, 15, 15, 45)),
        'Jan 15, 2024 at 3:45 PM',
      );
    });

    test('midnight -> 12 AM', () {
      expect(
        DateFormatter.dateTime(DateTime(2024, 1, 15, 0, 5)),
        'Jan 15, 2024 at 12:05 AM',
      );
    });

    test('noon -> 12 PM', () {
      expect(
        DateFormatter.dateTime(DateTime(2024, 1, 15, 12, 0)),
        'Jan 15, 2024 at 12:00 PM',
      );
    });
  });

  group('readingTime', () {
    test('zero words -> < 1 min', () {
      expect(DateFormatter.readingTime(0), '< 1 min read');
    });

    test('1 minute (<=200 words)', () {
      expect(DateFormatter.readingTime(150), '1 min read');
    });

    test('multiple minutes rounds up', () {
      expect(DateFormatter.readingTime(450), '3 min read');
    });
  });

  group('readingTimeFromContent', () {
    test('null / empty -> empty', () {
      expect(DateFormatter.readingTimeFromContent(null), '');
      expect(DateFormatter.readingTimeFromContent(''), '');
    });

    test('strips html then counts', () {
      final content = '<p>${List.filled(400, 'word').join(' ')}</p>';
      expect(DateFormatter.readingTimeFromContent(content), '2 min read');
    });
  });

  group('duration', () {
    test('under an hour -> M:SS', () {
      expect(DateFormatter.duration(90), '1:30');
    });

    test('with hours -> H:MM:SS', () {
      expect(DateFormatter.duration(3725), '1:02:05');
    });

    test('sub-minute pads seconds', () {
      expect(DateFormatter.duration(30), '0:30');
    });
  });
}
