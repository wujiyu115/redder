import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/feed.dart';
import '../../data/models/feed_item.dart';
import '../../data/models/filter_helpers.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_text_field.dart';
import '../../shared/widgets/reeder_switch.dart';
import '../../shared/widgets/reeder_section_header.dart';
import '../../shared/widgets/reeder_button.dart';
import '../../shared/widgets/reeder_dialog.dart';
import 'filter_controller.dart';

/// Page for creating or editing a content filter.
///
/// Allows configuring:
/// - Filter name
/// - Include keywords (items must contain at least one)
/// - Exclude keywords (items containing any are filtered out)
/// - Media type filter (article/audio/video/image)
/// - Feed type filter (blog/podcast/video/mixed)
/// - Whole word matching toggle
class FilterEditorPage extends ConsumerStatefulWidget {
  /// The filter ID to edit. Null for creating a new filter.
  final int? filterId;

  const FilterEditorPage({
    super.key,
    this.filterId,
  });

  @override
  ConsumerState<FilterEditorPage> createState() => _FilterEditorPageState();
}

class _FilterEditorPageState extends ConsumerState<FilterEditorPage> {
  final _nameController = TextEditingController();
  final _includeKeywordController = TextEditingController();
  final _excludeKeywordController = TextEditingController();

  List<String> _includeKeywords = [];
  List<String> _excludeKeywords = [];
  Set<String> _selectedMediaTypes = {};
  Set<String> _selectedFeedTypes = {};
  bool _matchWholeWord = false;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.filterId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadFilter();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadFilter() async {
    final filter = await ref.read(filterByIdProvider(widget.filterId!).future);
    if (filter != null && mounted) {
      setState(() {
        _nameController.text = filter.name;
        _includeKeywords = List.from(filter.includeKeywordsList);
        _excludeKeywords = List.from(filter.excludeKeywordsList);
        _selectedMediaTypes = Set.from(filter.mediaTypesList);
        _selectedFeedTypes = Set.from(filter.feedTypesList);
        _matchWholeWord = filter.matchWholeWord;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _includeKeywordController.dispose();
    _excludeKeywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: _isEditing ? l10n.editFilter : l10n.newFilterTitle,
        showBackButton: true,
        onBack: () => context.pop(),
        actions: [
          ReederButton.text(
            label: l10n.save,
            onPressed: _isSaving ? null : _saveFilter,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Text(l10n.loading))
          : _buildForm(theme, l10n),
    );
  }

  Widget _buildForm(ReederThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing,
      ),
      children: [
        // ─── Name ─────────────────────────────────────────
        ReederSectionHeader(title: l10n.name),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
          ),
          child: ReederTextField(
            controller: _nameController,
            placeholder: l10n.filterName,
          ),
        ),

        // ─── Include Keywords ─────────────────────────────
        ReederSectionHeader(title: l10n.includeKeywords),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
          ),
          child: Text(
            l10n.includeKeywordsDesc,
            style: theme.typography.caption.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildKeywordInput(
          controller: _includeKeywordController,
          keywords: _includeKeywords,
          onAdd: (keyword) {
            setState(() => _includeKeywords.add(keyword));
          },
          onRemove: (index) {
            setState(() => _includeKeywords.removeAt(index));
          },
          theme: theme,
          l10n: l10n,
        ),

        // ─── Exclude Keywords ─────────────────────────────
        ReederSectionHeader(title: l10n.excludeKeywords),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
          ),
          child: Text(
            l10n.excludeKeywordsDesc,
            style: theme.typography.caption.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildKeywordInput(
          controller: _excludeKeywordController,
          keywords: _excludeKeywords,
          onAdd: (keyword) {
            setState(() => _excludeKeywords.add(keyword));
          },
          onRemove: (index) {
            setState(() => _excludeKeywords.removeAt(index));
          },
          theme: theme,
          l10n: l10n,
        ),

        // ─── Media Types ──────────────────────────────────
        ReederSectionHeader(title: l10n.contentTypes),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
          ),
          child: Text(
            l10n.contentTypesDesc,
            style: theme.typography.caption.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildChipGroup(
          options: ContentType.values.map((t) => t.name).toList(),
          labels: [l10n.article, l10n.audio, l10n.video, l10n.image],
          selected: _selectedMediaTypes,
          onToggle: (value) {
            setState(() {
              if (_selectedMediaTypes.contains(value)) {
                _selectedMediaTypes.remove(value);
              } else {
                _selectedMediaTypes.add(value);
              }
            });
          },
          theme: theme,
        ),

        // ─── Feed Types ───────────────────────────────────
        ReederSectionHeader(title: l10n.feedTypes),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
          ),
          child: Text(
            l10n.feedTypesDesc,
            style: theme.typography.caption.copyWith(
              color: theme.secondaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        _buildChipGroup(
          options: FeedType.values.map((t) => t.name).toList(),
          labels: [l10n.blog, l10n.podcast, l10n.video, l10n.mixed],
          selected: _selectedFeedTypes,
          onToggle: (value) {
            setState(() {
              if (_selectedFeedTypes.contains(value)) {
                _selectedFeedTypes.remove(value);
              } else {
                _selectedFeedTypes.add(value);
              }
            });
          },
          theme: theme,
        ),

        // ─── Options ──────────────────────────────────────
        ReederSectionHeader(title: l10n.options),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.listItemPaddingH,
            vertical: AppDimensions.spacingS,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.matchWholeWords,
                      style: theme.typography.body.copyWith(
                        color: theme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.matchWholeWordsDesc,
                      style: theme.typography.caption.copyWith(
                        color: theme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              ReederSwitch(
                value: _matchWholeWord,
                onChanged: (value) {
                  setState(() => _matchWholeWord = value);
                },
              ),
            ],
          ),
        ),

        // ─── Delete Button (edit mode only) ───────────────
        if (_isEditing) ...[
          const SizedBox(height: AppDimensions.spacingXL),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.listItemPaddingH,
            ),
            child: GestureDetector(
              onTap: _confirmDelete,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingM,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: const Color(0xFFFF3B30),
                    width: 1,
                  ),
                ),
                child: Text(
                  l10n.deleteFilter,
                  style: theme.typography.button.copyWith(
                    color: const Color(0xFFFF3B30),
                  ),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppDimensions.spacingXXL),
      ],
    );
  }

  /// Builds a keyword input field with chip display.
  Widget _buildKeywordInput({
    required TextEditingController controller,
    required List<String> keywords,
    required void Function(String) onAdd,
    required void Function(int) onRemove,
    required ReederThemeData theme,
    required AppLocalizations l10n,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.listItemPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keyword chips
          if (keywords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
              child: Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingS,
                children: [
                  for (int i = 0; i < keywords.length; i++)
                    _KeywordChip(
                      label: keywords[i],
                      onRemove: () => onRemove(i),
                      theme: theme,
                    ),
                ],
              ),
            ),

          // Input field
          ReederTextField(
            controller: controller,
            placeholder: l10n.addKeyword,
            onSubmitted: (value) {
              final keyword = value.trim();
              if (keyword.isNotEmpty && !keywords.contains(keyword)) {
                onAdd(keyword);
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  /// Builds a group of selectable chips.
  Widget _buildChipGroup({
    required List<String> options,
    required List<String> labels,
    required Set<String> selected,
    required void Function(String) onToggle,
    required ReederThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.listItemPaddingH,
      ),
      child: Wrap(
        spacing: AppDimensions.spacingS,
        runSpacing: AppDimensions.spacingS,
        children: [
          for (int i = 0; i < options.length; i++)
            _SelectableChip(
              label: labels[i],
              isSelected: selected.contains(options[i]),
              onTap: () => onToggle(options[i]),
              theme: theme,
            ),
        ],
      ),
    );
  }

  /// Saves the filter (create or update).
  Future<void> _saveFilter() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(l10n.pleaseEnterFilterName);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(filtersProvider.notifier);

      if (_isEditing) {
        await notifier.updateFilter(
          widget.filterId!,
          name: name,
          includeKeywords: _includeKeywords,
          excludeKeywords: _excludeKeywords,
          mediaTypes: _selectedMediaTypes.toList(),
          feedTypes: _selectedFeedTypes.toList(),
          matchWholeWord: _matchWholeWord,
        );
      } else {
        await notifier.createFilter(
          name: name,
          includeKeywords: _includeKeywords,
          excludeKeywords: _excludeKeywords,
          mediaTypes: _selectedMediaTypes.toList(),
          feedTypes: _selectedFeedTypes.toList(),
          matchWholeWord: _matchWholeWord,
        );
      }

      if (mounted) context.pop(true);
    } catch (e) {
      _showError(l10n.failedToSaveFilter(e.toString()));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Shows a delete confirmation dialog.
  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.deleteFilter,
        message: l10n.deleteFilterConfirm(_nameController.text),
        actions: [
          ReederDialogAction(
            label: l10n.cancel,
            isDefault: true,
          ),
          ReederDialogAction(
            label: l10n.delete,
            isDestructive: true,
            onPressed: () async {
              await ref
                  .read(filtersProvider.notifier)
                  .deleteFilter(widget.filterId!);
              if (mounted) {
                Navigator.of(ctx).pop();
                context.pop(true);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    final l10n = AppLocalizations.of(context)!;
    ReederDialog.show(
      context: context,
      builder: (ctx) => ReederDialog(
        title: l10n.error,
        message: message,
        actions: [
          ReederDialogAction(label: l10n.ok, isDefault: true),
        ],
      ),
    );
  }
}

/// A removable keyword chip.
class _KeywordChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final ReederThemeData theme;

  const _KeywordChip({
    required this.label,
    required this.onRemove,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.typography.caption.copyWith(
              color: theme.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Text(
              '✕',
              style: TextStyle(
                fontSize: 12,
                color: theme.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A selectable chip for type filtering.
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ReederThemeData theme;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.accentColor
              : theme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected
                ? theme.accentColor
                : theme.separatorColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.typography.caption.copyWith(
            color: isSelected
                ? const Color(0xFFFFFFFF)
                : theme.primaryTextColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
