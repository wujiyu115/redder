import '../../core/network/dio_client.dart';
import 'html_parser.dart';

/// Utility for discovering RSS/Atom/JSON Feed URLs from a web page.
///
/// Parses HTML `<link>` tags with alternate feed types.
/// This is a lightweight utility; for full discovery with feed validation,
/// use [FeedDiscoveryService] instead.
class FeedDiscoverer {
  FeedDiscoverer._();

  /// Discovers feed URLs from a web page URL.
  ///
  /// Fetches the page HTML and extracts feed link tags.
  /// Returns a list of [DiscoveredFeed] with URL, title, and type.
  static Future<List<DiscoveredFeed>> discoverFromUrl(String pageUrl) async {
    try {
      final html = await DioClient.instance.getString(pageUrl);
      return discoverFromHtml(html, baseUrl: pageUrl);
    } catch (_) {
      return [];
    }
  }

  /// Discovers feed URLs from HTML content.
  ///
  /// Extracts `<link rel="alternate">` tags with RSS/Atom/JSON Feed types.
  /// If [baseUrl] is provided, relative URLs are resolved to absolute.
  static List<DiscoveredFeed> discoverFromHtml(
    String html, {
    String? baseUrl,
  }) {
    final feeds = HtmlParser.discoverFeeds(html);

    if (baseUrl == null) return feeds;

    // Resolve relative URLs
    return feeds.map((feed) {
      var url = feed.url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        final base = Uri.tryParse(baseUrl);
        if (base != null) {
          url = base.resolve(url).toString();
        }
      }
      return DiscoveredFeed(
        url: url,
        title: feed.title,
        type: feed.type,
      );
    }).toList();
  }

  /// Generates common feed URL patterns to try for a given domain.
  ///
  /// Returns a list of potential feed URLs based on common conventions.
  static List<String> generateCommonFeedUrls(String siteUrl) {
    final uri = Uri.tryParse(siteUrl);
    if (uri == null) return [];

    final base = '${uri.scheme}://${uri.host}';
    return [
      '$base/feed',
      '$base/feed/',
      '$base/rss',
      '$base/rss/',
      '$base/atom.xml',
      '$base/feed.xml',
      '$base/rss.xml',
      '$base/index.xml',
      '$base/feed/atom',
      '$base/feed/rss',
      '$base/.rss',
      '$base/blog/feed',
      '$base/blog/rss',
    ];
  }
}
