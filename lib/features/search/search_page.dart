import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_text_field.dart';
import 'search_controller.dart' as sc;

/// Full-text search page.
///
/// Provides a search input field with debounced search,
/// displays results with keyword highlighting in titles.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final searchState = ref.watch(sc.searchControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.search,
        showBackButton: true,
        onBack: () {
          ref.read(sc.searchControllerProvider.notifier).clear();
          context.pop();
        },
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.listItemPaddingH,
              vertical: AppDimensions.spacingS,
            ),
            child: ReederTextField(
              controller: _searchController,
              focusNode: _focusNode,
              placeholder: l10n.searchArticles,
              onChanged: (value) {
                ref
                    .read(sc.searchControllerProvider.notifier)
                    .updateQuery(value);
              },
              onSubmitted: (value) {
                ref
                    .read(sc.searchControllerProvider.notifier)
                    .search(value);
              },
            ),
          ),

          // Separator
          Container(
            height: AppDimensions.separatorThickness,
            color: theme.separatorColor,
          ),

          // Results
          Expanded(
            child: _buildResults(searchState, theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(sc.SearchState searchState, ReederThemeData theme, AppLocalizations l10n) {
    if (searchState.isLoading) {
      return Center(
        child: Text(
          l10n.searching,
          style: theme.typography.body.copyWith(
            color: theme.secondaryTextColor,
          ),
        ),
      );
    }

    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing),
          child: Text(
            l10n.searchError(searchState.error!),
            style: theme.typography.body.copyWith(
              color: const Color(0xFFFF3B30),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!searchState.hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔍',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: AppDimensions.spacing),
              Text(
                l10n.searchYourArticles,
                style: theme.typography.listTitle.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                l10n.searchByTitleContentAuthor,
                style: theme.typography.caption.copyWith(
                  color: theme.tertiaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔍',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: AppDimensions.spacing),
              Text(
                l10n.noResultsFound,
                style: theme.typography.listTitle.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                l10n.tryDifferentKeywords,
                style: theme.typography.caption.copyWith(
                  color: theme.tertiaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final item = searchState.results[index];
        return _HighlightedArticleItem(
          item: item,
          query: searchState.query,
          feedTitle: searchState.feedTitles[item.feedId],
          feedIconUrl: searchState.feedIcons[item.feedId],
          onTap: () => context.push('/timeline/all/article/${item.id}'),
          theme: theme,
        );
      },
    );
  }
}

/// Article list item with keyword highlighting in the title.
class _HighlightedArticleItem extends StatelessWidget {
  final FeedItem item;
  final String query;
  final String? feedTitle;
  final String? feedIconUrl;
  final VoidCallback? onTap;
  final ReederThemeData theme;

  const _HighlightedArticleItem({
    required this.item,
    required this.query,
    this.feedTitle,
    this.feedIconUrl,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.listItemPaddingH,
          vertical: AppDimensions.spacingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feed info
            if (feedTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  feedTitle!,
                  style: theme.typography.caption.copyWith(
                    color: theme.secondaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Highlighted title
            _buildHighlightedTitle(),

            // Summary
            if (item.summary != null && item.summary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.summary!,
                  style: theme.typography.summary.copyWith(
                    color: theme.secondaryTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Separator
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingM),
              child: Container(
                height: AppDimensions.separatorThickness,
                color: theme.separatorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the title with search query highlighted.
  Widget _buildHighlightedTitle() {
    if (query.isEmpty) {
      return Text(
        item.title,
        style: theme.typography.listTitle.copyWith(
          color: theme.primaryTextColor,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final title = item.title;
    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (start < title.length) {
      final matchIndex = lowerTitle.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        // No more matches, add remaining text
        spans.add(TextSpan(
          text: title.substring(start),
          style: theme.typography.listTitle.copyWith(
            color: theme.primaryTextColor,
          ),
        ));
        break;
      }

      // Add text before match
      if (matchIndex > start) {
        spans.add(TextSpan(
          text: title.substring(start, matchIndex),
          style: theme.typography.listTitle.copyWith(
            color: theme.primaryTextColor,
          ),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: title.substring(matchIndex, matchIndex + query.length),
        style: theme.typography.listTitle.copyWith(
          color: theme.accentColor,
          fontWeight: FontWeight.w700,
        ),
      ));

      start = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
