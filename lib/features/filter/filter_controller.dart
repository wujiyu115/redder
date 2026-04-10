import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../data/models/feed.dart';
import '../../data/models/filter_helpers.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/article_repository.dart';
import '../source_list/source_list_controller.dart';

/// Provider for the list of all filters.
final filtersProvider = StateNotifierProvider<FiltersNotifier, AsyncValue<List<Filter>>>(
  (ref) => FiltersNotifier(ref),
);

/// Provider family for a single filter by ID.
final filterByIdProvider = FutureProvider.family<Filter?, int>((ref, id) async {
  final db = AppDatabase.instance;
  return (db.select(db.filters)..where((t) => t.id.equals(id))).getSingleOrNull();
});

/// Provider for filter timeline items, keyed by filter ID.
final filterTimelineProvider = StateNotifierProvider.family<
    FilterTimelineController, AsyncValue<FilterTimelineState>, int>(
  (ref, filterId) => FilterTimelineController(ref, filterId),
);

/// Notifier that manages the list of all filters.
class FiltersNotifier extends StateNotifier<AsyncValue<List<Filter>>> {
  AppDatabase get _db => AppDatabase.instance;

  FiltersNotifier(Ref ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final filters = await (_db.select(_db.filters)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      state = AsyncValue.data(filters);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a new filter.
  Future<Filter> createFilter({
    required String name,
    List<String> includeKeywords = const [],
    List<String> excludeKeywords = const [],
    List<String> mediaTypes = const [],
    List<String> feedTypes = const [],
    bool matchWholeWord = false,
  }) async {
    final allFilters = await _db.select(_db.filters).get();
    final maxOrder = allFilters.isEmpty
        ? 0
        : allFilters.map((f) => f.sortOrder).reduce((a, b) => a > b ? a : b);

    final now = DateTime.now();
    final id = await _db.into(_db.filters).insert(
      FiltersCompanion.insert(
        name: name,
        includeKeywords: Value(jsonEncode(includeKeywords)),
        excludeKeywords: Value(jsonEncode(excludeKeywords)),
        mediaTypes: Value(jsonEncode(mediaTypes)),
        feedTypes: Value(jsonEncode(feedTypes)),
        matchWholeWord: Value(matchWholeWord),
        sortOrder: Value(maxOrder + 1),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final filter = await (_db.select(_db.filters)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    await _load();
    return filter;
  }

  /// Updates an existing filter.
  Future<void> updateFilter(
    int filterId, {
    required String name,
    List<String> includeKeywords = const [],
    List<String> excludeKeywords = const [],
    List<String> mediaTypes = const [],
    List<String> feedTypes = const [],
    bool matchWholeWord = false,
  }) async {
    await (_db.update(_db.filters)..where((t) => t.id.equals(filterId)))
        .write(FiltersCompanion(
      name: Value(name),
      includeKeywords: Value(jsonEncode(includeKeywords)),
      excludeKeywords: Value(jsonEncode(excludeKeywords)),
      mediaTypes: Value(jsonEncode(mediaTypes)),
      feedTypes: Value(jsonEncode(feedTypes)),
      matchWholeWord: Value(matchWholeWord),
      updatedAt: Value(DateTime.now()),
    ));
    await _load();
  }

  /// Deletes a filter by ID.
  Future<void> deleteFilter(int filterId) async {
    await (_db.delete(_db.filters)..where((t) => t.id.equals(filterId))).go();
    await _load();
  }

  /// Reorders filters by updating their sortOrder.
  Future<void> reorderFilters(List<int> filterIds) async {
    await _db.batch((batch) {
      for (int i = 0; i < filterIds.length; i++) {
        batch.update(
          _db.filters,
          FiltersCompanion(sortOrder: Value(i)),
          where: ($FiltersTable t) => t.id.equals(filterIds[i]),
        );
      }
    });
    await _load();
  }

  /// Reloads the filter list.
  Future<void> reload() => _load();
}

/// Controller for a filter's timeline (matching articles).
class FilterTimelineController
    extends StateNotifier<AsyncValue<FilterTimelineState>> {
  final Ref _ref;
  final int filterId;

  late final ArticleRepository _articleRepo;
  late final FeedRepository _feedRepo;

  static const int _pageSize = 30;
  int _currentOffset = 0;
  bool _isLoadingMore = false;

  FilterTimelineController(this._ref, this.filterId)
      : super(const AsyncValue.loading()) {
    _articleRepo = _ref.read(articleRepositoryProvider);
    _feedRepo = _ref.read(feedRepositoryProvider);
    _loadInitial();
  }

  AppDatabase get _db => AppDatabase.instance;

  /// Loads the initial page of filtered articles.
  Future<void> _loadInitial() async {
    try {
      _currentOffset = 0;
      final filter = await (_db.select(_db.filters)
            ..where((t) => t.id.equals(filterId)))
          .getSingleOrNull();
      if (filter == null) {
        state = const AsyncValue.data(FilterTimelineState(
          items: [],
          feedTitles: {},
          feedIcons: {},
          hasMore: false,
        ));
        return;
      }

      final items = await _loadFilteredItems(filter, offset: 0, limit: _pageSize);
      final feedMeta = await _loadFeedMetadata(items);

      state = AsyncValue.data(FilterTimelineState(
        items: items,
        feedTitles: feedMeta.titles,
        feedIcons: feedMeta.icons,
        hasMore: items.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Loads more filtered articles (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore) return;

    _isLoadingMore = true;
    _currentOffset += _pageSize;

    try {
      final filter = await (_db.select(_db.filters)
            ..where((t) => t.id.equals(filterId)))
          .getSingleOrNull();
      if (filter == null) return;

      final newItems = await _loadFilteredItems(
        filter,
        offset: _currentOffset,
        limit: _pageSize,
      );
      final feedMeta = await _loadFeedMetadata(newItems);

      state = AsyncValue.data(FilterTimelineState(
        items: [...currentState.items, ...newItems],
        feedTitles: {...currentState.feedTitles, ...feedMeta.titles},
        feedIcons: {...currentState.feedIcons, ...feedMeta.icons},
        hasMore: newItems.length >= _pageSize,
      ));
    } catch (e) {
      _currentOffset -= _pageSize;
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refreshes the filter timeline.
  Future<void> refresh() async {
    await _loadInitial();
  }

  /// Loads articles that match the filter criteria.
  Future<List<FeedItem>> _loadFilteredItems(
    Filter filter, {
    required int offset,
    required int limit,
  }) async {
    // Load a larger batch and filter in memory
    final batchSize = (offset + limit) * 3;
    final allItems = await _articleRepo.getArticles(
      limit: batchSize,
      offset: 0,
    );

    // Build a feed type map for matching
    final feedTypeMap = <int, FeedType>{};
    final feeds = await _feedRepo.getAllFeeds();
    for (final feed in feeds) {
      feedTypeMap[feed.id] = feed.type;
    }

    // Apply filter
    final matched = allItems.where((item) {
      final feedType = feedTypeMap[item.feedId] ?? FeedType.blog;
      return filter.matches(item, feedType);
    }).toList();

    // Apply pagination
    if (offset >= matched.length) return [];
    final end = (offset + limit).clamp(0, matched.length);
    return matched.sublist(offset, end);
  }

  /// Loads feed titles and icons for the given items.
  Future<_FeedMeta> _loadFeedMetadata(List<FeedItem> items) async {
    final titles = <int, String>{};
    final icons = <int, String?>{};
    final feedIds = items.map((i) => i.feedId).toSet();

    for (final feedId in feedIds) {
      if (!titles.containsKey(feedId)) {
        final feed = await _feedRepo.getFeedById(feedId);
        if (feed != null) {
          titles[feedId] = feed.title;
          icons[feedId] = feed.iconUrl;
        }
      }
    }

    return _FeedMeta(titles: titles, icons: icons);
  }
}

/// State for a filter timeline.
class FilterTimelineState {
  final List<FeedItem> items;
  final Map<int, String> feedTitles;
  final Map<int, String?> feedIcons;
  final bool hasMore;

  const FilterTimelineState({
    required this.items,
    required this.feedTitles,
    required this.feedIcons,
    required this.hasMore,
  });
}

class _FeedMeta {
  final Map<int, String> titles;
  final Map<int, String?> icons;

  const _FeedMeta({required this.titles, required this.icons});
}
