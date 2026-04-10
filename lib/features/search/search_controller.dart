import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/feed_repository.dart';
import '../source_list/source_list_controller.dart';

/// Provider for the search controller.
final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>(
  (ref) => SearchController(ref),
);

/// Controller for the search page.
///
/// Manages search query, debounced search execution,
/// and search result state.
class SearchController extends StateNotifier<SearchState> {
  final Ref _ref;
  late final ArticleRepository _articleRepo;
  late final FeedRepository _feedRepo;

  Timer? _debounceTimer;
  static const _debounceDelay = Duration(milliseconds: 300);

  SearchController(this._ref) : super(const SearchState.initial()) {
    _articleRepo = _ref.read(articleRepositoryProvider);
    _feedRepo = _ref.read(feedRepositoryProvider);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Updates the search query with debouncing.
  void updateQuery(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const SearchState.initial();
      return;
    }

    state = SearchState(
      query: query,
      results: state.results,
      feedTitles: state.feedTitles,
      feedIcons: state.feedIcons,
      isLoading: true,
      hasSearched: state.hasSearched,
    );

    _debounceTimer = Timer(_debounceDelay, () {
      _performSearch(query.trim());
    });
  }

  /// Performs the search immediately.
  Future<void> search(String query) async {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      state = const SearchState.initial();
      return;
    }
    await _performSearch(query.trim());
  }

  /// Performs the actual search.
  Future<void> _performSearch(String query) async {
    state = SearchState(
      query: query,
      results: const [],
      feedTitles: const {},
      feedIcons: const {},
      isLoading: true,
      hasSearched: true,
    );

    try {
      final results = await _articleRepo.searchArticles(query, limit: 100);

      // Load feed metadata
      final feedTitles = <int, String>{};
      final feedIcons = <int, String?>{};
      final feedIds = results.map((r) => r.feedId).toSet();

      for (final feedId in feedIds) {
        final feed = await _feedRepo.getFeedById(feedId);
        if (feed != null) {
          feedTitles[feedId] = feed.title;
          feedIcons[feedId] = feed.iconUrl;
        }
      }

      if (mounted) {
        state = SearchState(
          query: query,
          results: results,
          feedTitles: feedTitles,
          feedIcons: feedIcons,
          isLoading: false,
          hasSearched: true,
        );
      }
    } catch (e) {
      if (mounted) {
        state = SearchState(
          query: query,
          results: const [],
          feedTitles: const {},
          feedIcons: const {},
          isLoading: false,
          hasSearched: true,
          error: e.toString(),
        );
      }
    }
  }

  /// Clears the search.
  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState.initial();
  }
}

/// State for the search page.
class SearchState {
  final String query;
  final List<FeedItem> results;
  final Map<int, String> feedTitles;
  final Map<int, String?> feedIcons;
  final bool isLoading;
  final bool hasSearched;
  final String? error;

  const SearchState({
    required this.query,
    required this.results,
    required this.feedTitles,
    required this.feedIcons,
    required this.isLoading,
    required this.hasSearched,
    this.error,
  });

  const SearchState.initial()
      : query = '',
        results = const [],
        feedTitles = const {},
        feedIcons = const {},
        isLoading = false,
        hasSearched = false,
        error = null;
}
