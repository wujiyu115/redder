import 'dart:convert';

import '../../core/database/app_database.dart';
import 'feed.dart';
import 'feed_item.dart';

/// Extension on the generated Filter data class to provide filter matching logic
/// and JSON list helpers.
///
/// Separated from filter.dart to avoid circular dependency:
/// filter.dart is imported by app_database.dart, so it cannot import
/// app_database.dart back. This file can safely import app_database.dart.
extension FilterHelpers on Filter {
  /// Decodes a JSON-encoded list of strings.
  static List<String> _decodeList(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  List<String> get includeKeywordsList => _decodeList(includeKeywords);
  List<String> get excludeKeywordsList => _decodeList(excludeKeywords);
  List<String> get mediaTypesList => _decodeList(mediaTypes);
  List<String> get feedTypesList => _decodeList(feedTypes);

  /// Checks if a feed item matches this filter's criteria.
  bool matches(FeedItem item, FeedType feedType) {
    final mediaList = mediaTypesList;
    final feedList = feedTypesList;
    final excludeList = excludeKeywordsList;
    final includeList = includeKeywordsList;

    // Check media type filter
    if (mediaList.isNotEmpty) {
      if (!mediaList.contains(ContentType.values[item.contentType.index].name)) {
        return false;
      }
    }

    // Check feed type filter
    if (feedList.isNotEmpty) {
      if (!feedList.contains(feedType.name)) {
        return false;
      }
    }

    // Check exclude keywords
    if (excludeList.isNotEmpty) {
      final searchText =
          '${item.title} ${item.summary ?? ''} ${item.content ?? ''}'
              .toLowerCase();
      for (final keyword in excludeList) {
        if (_containsKeyword(searchText, keyword.toLowerCase())) {
          return false;
        }
      }
    }

    // Check include keywords
    if (includeList.isNotEmpty) {
      final searchText =
          '${item.title} ${item.summary ?? ''} ${item.content ?? ''}'
              .toLowerCase();
      for (final keyword in includeList) {
        if (_containsKeyword(searchText, keyword.toLowerCase())) {
          return true;
        }
      }
      return false; // None of the include keywords matched
    }

    return true;
  }

  /// Checks if text contains a keyword, respecting whole word matching.
  bool _containsKeyword(String text, String keyword) {
    if (matchWholeWord) {
      final pattern = RegExp(r'\b' + RegExp.escape(keyword) + r'\b');
      return pattern.hasMatch(text);
    }
    return text.contains(keyword);
  }
}
