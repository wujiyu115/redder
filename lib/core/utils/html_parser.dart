import 'package:html/parser.dart' as html_parser;

/// Utility class for parsing and processing HTML content.
///
/// Provides methods for extracting text, images, and summaries
/// from HTML article content.
class HtmlParser {
  HtmlParser._();

  /// Strips all HTML tags and returns plain text.
  static String stripTags(String html) {
    final document = html_parser.parse(html);
    return document.body?.text ?? '';
  }

  /// Extracts a plain text summary from HTML content.
  ///
  /// Returns the first [maxLength] characters of the text content.
  static String extractSummary(String html, {int maxLength = 200}) {
    final text = stripTags(html).trim();
    if (text.length <= maxLength) return text;

    // Try to break at a word boundary
    final truncated = text.substring(0, maxLength);
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > maxLength * 0.7) {
      return '${truncated.substring(0, lastSpace)}…';
    }
    return '$truncated…';
  }

  /// Extracts all image URLs from HTML content.
  static List<String> extractImageUrls(String html) {
    final document = html_parser.parse(html);
    final images = document.querySelectorAll('img');
    return images
        .map((img) => img.attributes['src'])
        .where((src) => src != null && src.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// Extracts the first image URL from HTML content.
  static String? extractFirstImageUrl(String html) {
    final urls = extractImageUrls(html);
    return urls.isNotEmpty ? urls.first : null;
  }

  /// Counts the number of words in HTML content.
  static int wordCount(String html) {
    final text = stripTags(html).trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  /// Extracts all links from HTML content.
  static List<HtmlLink> extractLinks(String html) {
    final document = html_parser.parse(html);
    final anchors = document.querySelectorAll('a');
    return anchors
        .map((a) => HtmlLink(
              url: a.attributes['href'] ?? '',
              text: a.text.trim(),
            ))
        .where((link) => link.url.isNotEmpty)
        .toList();
  }

  /// Checks if HTML content contains meaningful text (not just tags).
  static bool hasContent(String? html) {
    if (html == null || html.isEmpty) return false;
    final text = stripTags(html).trim();
    return text.isNotEmpty;
  }

  /// Extracts feed URLs from HTML link tags (for feed discovery).
  ///
  /// Looks for `<link>` tags with RSS/Atom/JSON Feed types.
  static List<DiscoveredFeed> discoverFeeds(String html) {
    final document = html_parser.parse(html);
    final links = document.querySelectorAll('link[rel="alternate"]');

    const feedTypes = {
      'application/rss+xml',
      'application/atom+xml',
      'application/feed+json',
      'application/json',
    };

    return links
        .where((link) {
          final type = link.attributes['type']?.toLowerCase() ?? '';
          return feedTypes.contains(type);
        })
        .map((link) => DiscoveredFeed(
              url: link.attributes['href'] ?? '',
              title: link.attributes['title'] ?? '',
              type: link.attributes['type'] ?? '',
            ))
        .where((feed) => feed.url.isNotEmpty)
        .toList();
  }
}

/// Represents a link extracted from HTML content.
class HtmlLink {
  final String url;
  final String text;

  const HtmlLink({required this.url, required this.text});
}

/// Represents a feed discovered from HTML link tags.
class DiscoveredFeed {
  final String url;
  final String title;
  final String type;

  const DiscoveredFeed({
    required this.url,
    required this.title,
    required this.type,
  });
}
