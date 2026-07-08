import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/extensions/datetime_ext.dart';

void main() {
  group('DateTimeExt.isToday', () {
    test('local "now" is today', () {
      expect(DateTime.now().isToday, isTrue);
    });

    test('a UTC instant that is today in local time is reported as today', () {
      // Regression: previously compared UTC calendar fields against local now,
      // which could be wrong near midnight for non-UTC timezones.
      final nowUtc = DateTime.now().toUtc();
      expect(nowUtc.isToday, isTrue);
    });

    test('yesterday is not today', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, isFalse);
    });
  });

  group('DateTimeExt.isYesterday', () {
    test('a UTC instant from yesterday is reported as yesterday', () {
      final yesterdayUtc =
          DateTime.now().subtract(const Duration(days: 1)).toUtc();
      expect(yesterdayUtc.isYesterday, isTrue);
    });

    test('today is not yesterday', () {
      expect(DateTime.now().isYesterday, isFalse);
    });
  });

  group('DateTimeExt.isThisYear', () {
    test('a UTC instant from now is this year', () {
      expect(DateTime.now().toUtc().isThisYear, isTrue);
    });
  });

  group('DateTimeExt.timeAgo', () {
    test('recent time is "Just now"', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 5));
      expect(recent.timeAgo, 'Just now');
    });

    test('minutes ago', () {
      final t = DateTime.now().subtract(const Duration(minutes: 5));
      expect(t.timeAgo, '5m ago');
    });

    test('future time is "Just now"', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(future.timeAgo, 'Just now');
    });
  });
}
