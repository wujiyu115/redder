/// Utility class for formatting dates and times in the Reeder app.
///
/// Provides relative time formatting (e.g., "2h ago"),
/// absolute formatting, and reading time estimation.
class DateFormatter {
  DateFormatter._();

  /// Formats a date as a relative time string.
  ///
  /// Examples:
  /// - "Just now" (< 1 minute)
  /// - "5m" (minutes)
  /// - "2h" (hours)
  /// - "3d" (days, < 7 days)
  /// - "Jan 15" (same year)
  /// - "Jan 15, 2023" (different year)
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) return 'Just now';

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    // Same year: "Jan 15"
    if (date.year == now.year) {
      return '${_monthAbbr(date.month)} ${date.day}';
    }

    // Different year: "Jan 15, 2023"
    return '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  }

  /// Formats a date as a full date string.
  ///
  /// Example: "January 15, 2024"
  static String fullDate(DateTime date) {
    return '${_monthFull(date.month)} ${date.day}, ${date.year}';
  }

  /// Formats a date as a short date string.
  ///
  /// Example: "Jan 15, 2024"
  static String shortDate(DateTime date) {
    return '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  }

  /// Formats a date with time.
  ///
  /// Example: "Jan 15, 2024 at 3:45 PM"
  static String dateTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${shortDate(date)} at $hour:$minute $period';
  }

  /// Estimates reading time based on word count.
  ///
  /// Assumes average reading speed of 200 words per minute.
  /// Returns formatted string like "3 min read".
  static String readingTime(int wordCount) {
    final minutes = (wordCount / 200).ceil();
    if (minutes <= 0) return '< 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes min read';
  }

  /// Estimates reading time from HTML content.
  static String readingTimeFromContent(String? content) {
    if (content == null || content.isEmpty) return '';
    // Strip HTML tags and count words
    final text = content.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return readingTime(words);
  }

  /// Formats a duration in seconds to a readable string.
  ///
  /// Examples: "1:23:45", "45:30", "0:30"
  static String duration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  static String _monthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  static String _monthFull(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}
