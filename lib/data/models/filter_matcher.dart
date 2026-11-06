import '../../core/database/app_database.dart';
import 'feed.dart';
import 'dart:convert';

import 'feed_item.dart';

/// JSON-encoded list columns of [Filter], decoded on demand.
///
/// Lives here (not in `filter_helpers.dart`) so [FilterMatcher] can use it
/// without importing a file that imports it back.
extension FilterJsonLists on Filter {
  static List<String> _decode(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  List<String> get includeKeywordsList => _decode(includeKeywords);
  List<String> get excludeKeywordsList => _decode(excludeKeywords);
  List<String> get mediaTypesList => _decode(mediaTypes);
  List<String> get feedTypesList => _decode(feedTypes);
}

/// Precompiled form of a [Filter], for use inside hot loops.
///
/// [FilterHelpers.matches] is semantically fine but expensive per call: it
/// `jsonDecode`s four list columns, rebuilds `title + summary + content`
/// (content is full article HTML) and, in whole-word mode, compiles one
/// `RegExp` per keyword. Filtered timelines call it once per candidate — up to
/// a few hundred candidates per page — and that work lands on the UI isolate.
///
/// Build one [FilterMatcher] per query and reuse it for every item.
class FilterMatcher {
  FilterMatcher(Filter filter)
      : _mediaTypes = filter.mediaTypesList.toSet(),
        _feedTypes = filter.feedTypesList.toSet(),
        _includeKeywords =
            filter.includeKeywordsList.map((k) => k.toLowerCase()).toList(),
        _excludeKeywords =
            filter.excludeKeywordsList.map((k) => k.toLowerCase()).toList(),
        _wholeWord = filter.matchWholeWord;

  final Set<String> _mediaTypes;
  final Set<String> _feedTypes;
  final List<String> _includeKeywords;
  final List<String> _excludeKeywords;
  final bool _wholeWord;

  late final List<RegExp> _includePatterns = _compile(_includeKeywords);
  late final List<RegExp> _excludePatterns = _compile(_excludeKeywords);

  List<RegExp> _compile(List<String> keywords) => [
        for (final keyword in keywords)
          RegExp(r'\b' + RegExp.escape(keyword) + r'\b'),
      ];

  /// Whether [item] belongs to the filter.
  ///
  /// The decision is settled on the short fields (title + summary) whenever
  /// possible: lowercasing [FeedItem.content] — full article HTML, tens of KB
  /// per row — dominated the whole scan, and most rows are decided without it.
  bool matches(FeedItem item, FeedType feedType) {
    if (_mediaTypes.isNotEmpty) {
      final contentType = ContentType.values[item.contentType.index].name;
      if (!_mediaTypes.contains(contentType)) return false;
    }
    if (_feedTypes.isNotEmpty && !_feedTypes.contains(feedType.name)) {
      return false;
    }

    final hasExcludes = _excludeKeywords.isNotEmpty;
    final hasIncludes = _includeKeywords.isNotEmpty;
    if (!hasExcludes && !hasIncludes) return true;

    final head = '${item.title} ${item.summary ?? ''}'.toLowerCase();
    if (hasExcludes && _matchesAny(head, _excludeKeywords, _excludePatterns)) {
      return false;
    }

    final headHit = hasIncludes &&
        _matchesAny(head, _includeKeywords, _includePatterns);

    // Only touch the (large) article body when the short fields cannot settle
    // the decision: an exclude keyword can still veto a head match, and an
    // include keyword that missed the head may still be in the body.
    if (!hasExcludes && headHit) return true;
    if (!hasIncludes) {
      // Exclude-only filter and the head is clean.
      final content = item.content;
      if (content == null || content.isEmpty) return true;
      return !_matchesAny(
        content.toLowerCase(),
        _excludeKeywords,
        _excludePatterns,
      );
    }

    final content = item.content;
    final body = (content == null || content.isEmpty)
        ? null
        : content.toLowerCase();
    if (body != null &&
        hasExcludes &&
        _matchesAny(body, _excludeKeywords, _excludePatterns)) {
      return false;
    }
    if (headHit) return true;
    if (body == null) return false;
    // Combined so a keyword containing a space can straddle the boundary.
    return _matchesAny('$head $body', _includeKeywords, _includePatterns);
  }

  bool _matchesAny(String text, List<String> keywords, List<RegExp> patterns) {
    for (var i = 0; i < keywords.length; i++) {
      final hit = _wholeWord ? patterns[i].hasMatch(text) : text.contains(keywords[i]);
      if (hit) return true;
    }
    return false;
  }
}