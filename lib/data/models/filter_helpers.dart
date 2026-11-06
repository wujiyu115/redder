import '../../core/database/app_database.dart';
import 'feed.dart';
import 'filter_matcher.dart';

/// Extension on the generated Filter data class providing filter matching.
///
/// The JSON list getters (`includeKeywordsList`, …) live in `filter_matcher.dart`
/// and are re-exported here for existing call sites.
///
/// Separated from filter.dart to avoid circular dependency:
/// filter.dart is imported by app_database.dart, so it cannot import
/// app_database.dart back. This file can safely import app_database.dart.
export 'filter_matcher.dart' show FilterJsonLists;

extension FilterHelpers on Filter {
  /// Checks if a feed item matches this filter's criteria.
  ///
  /// Convenience wrapper: it compiles a [FilterMatcher] per call, so callers
  /// that test more than a handful of items should hold one themselves.
  bool matches(FeedItem item, FeedType feedType) =>
      FilterMatcher(this).matches(item, feedType);
}
