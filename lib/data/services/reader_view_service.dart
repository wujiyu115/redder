import '../../core/network/dio_client.dart';

/// Service for extracting clean article content for Reader View.
///
/// Attempts to extract the main article body from a web page,
/// removing navigation, ads, sidebars, and other non-content elements.
///
/// Uses a multi-strategy approach:
/// 1. Try to use the feed's original content if it's full-text
/// 2. Fetch the web page and extract the main content
/// 3. Fall back to the original content if extraction fails
class ReaderViewService {
  final DioClient _client;

  ReaderViewService({DioClient? client})
      : _client = client ?? DioClient.instance;

  /// Extracts clean article content from a URL.
  ///
  /// [url] - The article's original URL
  /// [fallbackContent] - The feed's original content to use as fallback
  ///
  /// Returns cleaned HTML content suitable for rendering.
  Future<String> extractContent(
    String url, {
    String? fallbackContent,
  }) async {
    try {
      // Fetch the full web page
      final html = await _client.getString(url);

      // Extract the main content
      final extracted = _extractMainContent(html);

      if (extracted != null && extracted.isNotEmpty) {
        return extracted;
      }
    } catch (e) {
      // Network error or parsing error, fall through to fallback
    }

    // Fall back to original content
    if (fallbackContent != null && fallbackContent.isNotEmpty) {
      return _cleanContent(fallbackContent);
    }

    throw Exception('Unable to extract article content');
  }

  /// Extracts the main content from an HTML page.
  ///
  /// Looks for common content containers in order of priority:
  /// 1. <article> tag
  /// 2. Elements with role="main"
  /// 3. Elements with common content class names
  /// 4. The largest text block
  String? _extractMainContent(String html) {
    // Strategy 1: Look for <article> tag content
    final articleMatch = RegExp(
      r'<article[^>]*>(.*?)</article>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(html);

    if (articleMatch != null) {
      return _cleanContent(articleMatch.group(1)!);
    }

    // Strategy 2: Look for main content containers
    final contentSelectors = [
      RegExp(r'<[^>]+class="[^"]*(?:post-content|article-content|entry-content|post-body|article-body|story-body|main-content)[^"]*"[^>]*>(.*?)</(?:div|section|article)>', dotAll: true, caseSensitive: false),
      RegExp(r'<[^>]+role="main"[^>]*>(.*?)</(?:div|section|main)>', dotAll: true, caseSensitive: false),
      RegExp(r'<main[^>]*>(.*?)</main>', dotAll: true, caseSensitive: false),
    ];

    for (final selector in contentSelectors) {
      final match = selector.firstMatch(html);
      if (match != null) {
        final content = match.group(1)!;
        if (_hasSubstantialContent(content)) {
          return _cleanContent(content);
        }
      }
    }

    // Strategy 3: Look for the largest paragraph-rich block
    final divBlocks = RegExp(
      r'<div[^>]*>(.*?)</div>',
      dotAll: true,
      caseSensitive: false,
    ).allMatches(html);

    String? bestBlock;
    int bestScore = 0;

    for (final match in divBlocks) {
      final block = match.group(1)!;
      final score = _contentScore(block);
      if (score > bestScore) {
        bestScore = score;
        bestBlock = block;
      }
    }

    if (bestBlock != null && bestScore > 100) {
      return _cleanContent(bestBlock);
    }

    return null;
  }

  /// Cleans HTML content by removing unwanted elements.
  String _cleanContent(String html) {
    var cleaned = html;

    // Remove script tags
    cleaned = cleaned.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', dotAll: true, caseSensitive: false),
      '',
    );

    // Remove style tags
    cleaned = cleaned.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true, caseSensitive: false),
      '',
    );

    // Remove nav elements
    cleaned = cleaned.replaceAll(
      RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true, caseSensitive: false),
      '',
    );

    // Remove footer elements
    cleaned = cleaned.replaceAll(
      RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true, caseSensitive: false),
      '',
    );

    // Remove aside elements
    cleaned = cleaned.replaceAll(
      RegExp(r'<aside[^>]*>.*?</aside>', dotAll: true, caseSensitive: false),
      '',
    );

    // Remove common ad/social/comment class elements
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<[^>]+class="[^"]*(?:ad-|ads-|social|share|comment|related|sidebar|newsletter|subscribe|popup|modal|cookie|banner)[^"]*"[^>]*>.*?</(?:div|section|aside)>',
        dotAll: true,
        caseSensitive: false,
      ),
      '',
    );

    // Remove hidden elements
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<[^>]+(?:style="[^"]*display:\s*none[^"]*"|hidden)[^>]*>.*?</[^>]+>',
        dotAll: true,
        caseSensitive: false,
      ),
      '',
    );

    // Remove empty paragraphs
    cleaned = cleaned.replaceAll(
      RegExp(r'<p[^>]*>\s*</p>', caseSensitive: false),
      '',
    );

    // Normalize whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.trim();

    return cleaned;
  }

  /// Checks if content has substantial text (not just navigation/links).
  bool _hasSubstantialContent(String html) {
    final textOnly = html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    return textOnly.length > 200;
  }

  /// Scores content based on paragraph density and text length.
  int _contentScore(String html) {
    int score = 0;

    // Count paragraphs
    final paragraphs = RegExp(r'<p[^>]*>', caseSensitive: false)
        .allMatches(html)
        .length;
    score += paragraphs * 30;

    // Count text length
    final textOnly = html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    score += textOnly.length ~/ 10;

    // Penalize link-heavy content
    final links = RegExp(r'<a[^>]*>', caseSensitive: false)
        .allMatches(html)
        .length;
    score -= links * 5;

    // Penalize short content
    if (textOnly.length < 100) score -= 50;

    return score;
  }
}
