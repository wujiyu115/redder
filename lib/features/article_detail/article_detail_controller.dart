import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/app_database.dart';
import '../../data/models/app_settings_helpers.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../../data/services/reader_view_service.dart';
import '../../shared/providers/settings_provider.dart';
import '../source_list/source_list_controller.dart';

/// Provider family for article detail controllers, keyed by article ID.
final articleDetailControllerProvider = StateNotifierProvider.family<
    ArticleDetailController, AsyncValue<ArticleDetailState>, int>(
  (ref, articleId) => ArticleDetailController(ref, articleId),
);

/// Controller for the article detail page.
///
/// Manages article data, read state, tag state, reader view,
/// and navigation to next/previous articles.
class ArticleDetailController
    extends StateNotifier<AsyncValue<ArticleDetailState>> {
  final Ref _ref;
  final int articleId;

  late final ArticleRepository _articleRepo;
  late final FeedRepository _feedRepo;
  late final TagRepository _tagRepo;
  late final ReaderViewService _readerViewService;

  ArticleDetailController(this._ref, this.articleId)
      : super(const AsyncValue.loading()) {
    _articleRepo = ArticleRepository();
    _feedRepo = _ref.read(feedRepositoryProvider);
    _tagRepo = _ref.read(tagRepositoryProvider);
    _readerViewService = ReaderViewService();
    _loadArticle();
  }

  /// Loads the article and its associated data.
  Future<void> _loadArticle() async {
    try {
      final article = await _articleRepo.getArticleById(articleId);
      if (article == null) {
        state = AsyncValue.error(
          Exception('Article not found'),
          StackTrace.current,
        );
        return;
      }

      // Load feed info
      final feed = await _feedRepo.getFeedById(article.feedId);

      // Load tag states
      final tagStates = await _loadTagStates(articleId);

      // Get reading settings
      final settings = _ref.read(settingsProvider).valueOrNull;
      final fontSize = settings?.fontSize ?? 16.0;
      final lineHeight = settings?.lineHeight ?? 1.5;
      final bionicReading = settings?.bionicReading ?? false;

      // Check if auto reader view is enabled for this feed
      final isAutoReader = feed?.autoReaderView ?? false;

      state = AsyncValue.data(ArticleDetailState(
        article: article,
        feedTitle: feed?.title,
        feedIconUrl: feed?.iconUrl,
        feedSiteUrl: feed?.siteUrl,
        tagStates: tagStates,
        isReaderView: isAutoReader,
        readerContent: null,
        fontSize: fontSize,
        lineHeight: lineHeight,
        bionicReading: bionicReading,
      ));

      // If auto reader view, load reader content
      if (isAutoReader) {
        await _loadReaderContent();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Loads tag states for the article.
  Future<Map<int, bool>> _loadTagStates(int itemId) async {
    final laterTag = await _tagRepo.getLaterTag();
    final bookmarksTag = await _tagRepo.getBookmarksTag();
    final favoritesTag = await _tagRepo.getFavoritesTag();

    final states = <int, bool>{};

    if (laterTag != null) {
      states[laterTag.id] = await _tagRepo.isItemTagged(laterTag.id, itemId);
    }
    if (bookmarksTag != null) {
      states[bookmarksTag.id] =
          await _tagRepo.isItemTagged(bookmarksTag.id, itemId);
    }
    if (favoritesTag != null) {
      states[favoritesTag.id] =
          await _tagRepo.isItemTagged(favoritesTag.id, itemId);
    }

    return states;
  }

  /// Marks the article as read.
  Future<void> markAsRead() async {
    await _articleRepo.markAsRead(articleId);
  }

  /// Toggles the starred state.
  Future<void> toggleStarred() async {
    await _articleRepo.toggleStarred(articleId);
    final currentState = state.valueOrNull;
    if (currentState != null) {
      final updatedArticle = await _articleRepo.getArticleById(articleId);
      if (updatedArticle != null) {
        state = AsyncValue.data(currentState.copyWith(
          article: updatedArticle,
        ));
      }
    }
  }

  /// Toggles a tag on the article.
  Future<void> toggleTag(int tagId) async {
    final isNowTagged = await _tagRepo.toggleTag(tagId, articleId);
    final currentState = state.valueOrNull;
    if (currentState != null) {
      final updatedStates = Map<int, bool>.from(currentState.tagStates);
      updatedStates[tagId] = isNowTagged;
      state = AsyncValue.data(currentState.copyWith(
        tagStates: updatedStates,
      ));
    }
  }

  /// Toggles reader view mode.
  Future<void> toggleReaderView() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newIsReaderView = !currentState.isReaderView;

    state = AsyncValue.data(currentState.copyWith(
      isReaderView: newIsReaderView,
    ));

    if (newIsReaderView && currentState.readerContent == null) {
      await _loadReaderContent();
    }
  }

  /// Loads reader view content by extracting the main article text.
  Future<void> _loadReaderContent() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    try {
      final readerContent = await _readerViewService.extractContent(
        currentState.article.url,
        fallbackContent: currentState.article.content,
      );

      state = AsyncValue.data(currentState.copyWith(
        readerContent: readerContent,
      ));
    } catch (e) {
      // If reader view fails, fall back to original content
      state = AsyncValue.data(currentState.copyWith(
        isReaderView: false,
      ));
    }
  }

  /// Shares the article URL.
  Future<void> share() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    await Share.share(
      currentState.article.url,
      subject: currentState.article.title,
    );
  }

  /// Loads the next article in the timeline.
  ///
  /// Returns the next article's ID, or null if there is no next article.
  Future<int?> loadNextArticle() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    // Get articles published before the current one
    final articles = await _articleRepo.getArticles(limit: 2, offset: 0);

    // Find the current article's index and return the next one
    for (int i = 0; i < articles.length - 1; i++) {
      if (articles[i].id == articleId) {
        return articles[i + 1].id;
      }
    }

    return null;
  }

  /// Reloads the article data.
  Future<void> reload() => _loadArticle();
}

/// State for the article detail page.
class ArticleDetailState {
  final FeedItem article;
  final String? feedTitle;
  final String? feedIconUrl;
  final String? feedSiteUrl;
  final Map<int, bool> tagStates;
  final bool isReaderView;
  final String? readerContent;
  final double fontSize;
  final double lineHeight;
  final bool bionicReading;

  const ArticleDetailState({
    required this.article,
    this.feedTitle,
    this.feedIconUrl,
    this.feedSiteUrl,
    this.tagStates = const {},
    this.isReaderView = false,
    this.readerContent,
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.bionicReading = false,
  });

  ArticleDetailState copyWith({
    FeedItem? article,
    String? feedTitle,
    String? feedIconUrl,
    String? feedSiteUrl,
    Map<int, bool>? tagStates,
    bool? isReaderView,
    String? readerContent,
    double? fontSize,
    double? lineHeight,
    bool? bionicReading,
  }) {
    return ArticleDetailState(
      article: article ?? this.article,
      feedTitle: feedTitle ?? this.feedTitle,
      feedIconUrl: feedIconUrl ?? this.feedIconUrl,
      feedSiteUrl: feedSiteUrl ?? this.feedSiteUrl,
      tagStates: tagStates ?? this.tagStates,
      isReaderView: isReaderView ?? this.isReaderView,
      readerContent: readerContent ?? this.readerContent,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      bionicReading: bionicReading ?? this.bionicReading,
    );
  }
}
