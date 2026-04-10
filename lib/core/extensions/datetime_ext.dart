/// Extension methods on [DateTime] for the Reeder app.
extension DateTimeExt on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this date is within the last 7 days.
  bool get isThisWeek {
    final now = DateTime.now();
    final diff = now.difference(this);
    return diff.inDays < 7 && !diff.isNegative;
  }

  /// Returns true if this date is in the current year.
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// Returns the start of the day (midnight).
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Returns the end of the day (23:59:59.999).
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Returns a human-readable relative time string.
  ///
  /// Examples: "Just now", "5m ago", "2h ago", "3d ago"
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.isNegative) return 'Just now';
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Returns a compact relative time string (without "ago").
  ///
  /// Examples: "Just now", "5m", "2h", "3d"
  String get timeAgoCompact {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.isNegative) return 'Just now';
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }

  /// Returns the difference in days from now (positive = past).
  int get daysAgo {
    return DateTime.now().difference(this).inDays;
  }

  /// Checks if this date is before the given number of days ago.
  bool isOlderThan(int days) {
    return daysAgo > days;
  }

  /// Returns a new DateTime with only the date part (no time).
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }
}
