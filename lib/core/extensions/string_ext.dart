/// Extension methods on [String] for the Reeder app.
extension StringExt on String {
  /// Returns the string truncated to [maxLength] with an ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Returns the string with the first character capitalized.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns the string in title case (each word capitalized).
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize())
        .join(' ');
  }

  /// Checks if the string is a valid URL.
  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// Checks if the string is a valid email address.
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Returns the domain from a URL string.
  String? get domain {
    final uri = Uri.tryParse(this);
    return uri?.host;
  }

  /// Strips HTML tags from the string.
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Returns null if the string is empty, otherwise returns the string.
  String? get nullIfEmpty {
    return isEmpty ? null : this;
  }

  /// Normalizes whitespace (collapses multiple spaces/newlines).
  String get normalizeWhitespace {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Ensures the string starts with the given prefix.
  String ensurePrefix(String prefix) {
    if (startsWith(prefix)) return this;
    return '$prefix$this';
  }

  /// Ensures the string ends with the given suffix.
  String ensureSuffix(String suffix) {
    if (endsWith(suffix)) return this;
    return '$this$suffix';
  }

  /// Converts a relative URL to absolute using a base URL.
  String toAbsoluteUrl(String baseUrl) {
    if (isValidUrl) return this;
    final base = Uri.tryParse(baseUrl);
    if (base == null) return this;
    final resolved = base.resolve(this);
    return resolved.toString();
  }
}
