/// Bionic Reading algorithm implementation.
///
/// Bionic Reading works by bolding the first few letters of each word,
/// creating artificial fixation points that guide the eye through text
/// more efficiently. The number of bolded letters depends on word length.
///
/// Reference: https://bionic-reading.com/
class BionicReading {
  BionicReading._();

  /// Matches a single "letter" character (Latin, Latin-extended, or CJK).
  /// Hoisted to a `static final` so it is compiled once instead of on every
  /// character/word — this runs on the article-rendering hot path.
  static final RegExp _letter =
      RegExp(r'[a-zA-ZÀ-ɏ一-鿿]');

  /// Matches runs of non-whitespace or whitespace (word/separator tokens).
  static final RegExp _wordOrSpace = RegExp(r'(\S+|\s+)');

  /// Matches the opening tag name at the start of an HTML tag.
  static final RegExp _tagNamePattern = RegExp(r'^<([a-zA-Z][a-zA-Z0-9]*)');

  /// Converts plain text to HTML with Bionic Reading formatting.
  ///
  /// Each word gets its first N letters wrapped in `<b>` tags,
  /// where N depends on the word length.
  ///
  /// Example:
  /// ```
  /// "Hello world" → "<b>Hel</b>lo <b>wor</b>ld"
  /// ```
  static String applyToText(String text) {
    if (text.isEmpty) return text;

    final buffer = StringBuffer();
    // Iterate word/whitespace tokens with allMatches so separators are kept.
    // (Dart's String.split discards the separator even with a capturing
    // group, which would collapse all whitespace between words.)
    for (final match in _wordOrSpace.allMatches(text)) {
      final segment = match.group(0)!;
      if (segment.trim().isEmpty) {
        // Preserve whitespace
        buffer.write(segment);
      } else {
        buffer.write(_processWord(segment));
      }
    }

    return buffer.toString();
  }

  /// Converts HTML content to Bionic Reading formatted HTML.
  ///
  /// Processes only text nodes, preserving all HTML tags and attributes.
  /// Skips content inside `<code>`, `<pre>`, `<script>`, `<style>` tags.
  static String applyToHtml(String html) {
    if (html.isEmpty) return html;

    final buffer = StringBuffer();
    int i = 0;

    // Tags whose content should not be processed
    final skipTags = {'code', 'pre', 'script', 'style', 'kbd', 'samp'};

    while (i < html.length) {
      if (html[i] == '<') {
        // Find the end of the tag
        final tagEnd = html.indexOf('>', i);
        if (tagEnd == -1) {
          // Malformed HTML, just append the rest
          buffer.write(html.substring(i));
          break;
        }

        final tag = html.substring(i, tagEnd + 1);
        buffer.write(tag);

        // Check if this is a skip tag (opening)
        final tagName = _extractTagName(tag);
        if (tagName != null && skipTags.contains(tagName.toLowerCase())) {
          // Find the closing tag (case-insensitively, allowing whitespace like
          // "</PRE >") and copy everything inside as-is.
          final closingPattern =
              RegExp('</\\s*$tagName\\s*>', caseSensitive: false);
          final closingMatch = closingPattern.firstMatch(html.substring(tagEnd + 1));
          if (closingMatch != null) {
            final closeEnd = tagEnd + 1 + closingMatch.end;
            buffer.write(html.substring(tagEnd + 1, closeEnd));
            i = closeEnd;
          } else {
            i = tagEnd + 1;
          }
        } else {
          i = tagEnd + 1;
        }
      } else {
        // Text node - find the next tag
        final nextTag = html.indexOf('<', i);
        final textEnd = nextTag == -1 ? html.length : nextTag;
        final textContent = html.substring(i, textEnd);

        // Apply bionic reading to text content
        buffer.write(_processTextNode(textContent));
        i = textEnd;
      }
    }

    return buffer.toString();
  }

  /// Processes a text node by applying bionic reading to each word.
  static String _processTextNode(String text) {
    if (text.trim().isEmpty) return text;

    final buffer = StringBuffer();
    // Split by word boundaries while preserving separators
    final matches = _wordOrSpace.allMatches(text);

    for (final match in matches) {
      final segment = match.group(0)!;
      if (segment.trim().isEmpty) {
        buffer.write(segment);
      } else {
        buffer.write(_processWord(segment));
      }
    }

    return buffer.toString();
  }

  /// Processes a single word by bolding the fixation point.
  static String _processWord(String word) {
    // Skip very short words, numbers, and special characters
    if (word.length <= 1) return word;

    // Check if the word contains any letters
    if (!_letter.hasMatch(word)) {
      return word;
    }

    // Handle words with leading punctuation
    int leadingPunct = 0;
    while (leadingPunct < word.length &&
        !_letter.hasMatch(word[leadingPunct])) {
      leadingPunct++;
    }

    // Handle words with trailing punctuation
    int trailingPunct = word.length;
    while (trailingPunct > leadingPunct &&
        !_letter.hasMatch(word[trailingPunct - 1])) {
      trailingPunct--;
    }

    final prefix = word.substring(0, leadingPunct);
    final core = word.substring(leadingPunct, trailingPunct);
    final suffix = word.substring(trailingPunct);

    if (core.isEmpty) return word;

    final boldCount = _getBoldCount(core.length);
    final boldPart = core.substring(0, boldCount);
    final normalPart = core.substring(boldCount);

    return '$prefix<b>$boldPart</b>$normalPart$suffix';
  }

  /// Determines how many characters to bold based on word length.
  ///
  /// The algorithm uses roughly the first 40-50% of letters:
  /// - 1 letter: 1 bold
  /// - 2 letters: 1 bold
  /// - 3 letters: 1 bold
  /// - 4 letters: 2 bold
  /// - 5 letters: 2 bold
  /// - 6 letters: 3 bold
  /// - 7 letters: 3 bold
  /// - 8+ letters: ~40% bold
  static int _getBoldCount(int wordLength) {
    if (wordLength <= 3) return 1;
    if (wordLength <= 5) return 2;
    if (wordLength <= 7) return 3;
    // For longer words, bold approximately 40%
    return (wordLength * 0.4).ceil();
  }

  /// Extracts the tag name from an HTML tag string.
  /// Returns null for closing tags or malformed tags.
  static String? _extractTagName(String tag) {
    if (tag.startsWith('</') || tag.startsWith('<!')) return null;

    final match = _tagNamePattern.firstMatch(tag);
    return match?.group(1);
  }
}
