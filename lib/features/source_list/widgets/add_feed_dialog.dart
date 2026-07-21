import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/reeder_dialog.dart';
import '../../../shared/widgets/reeder_text_field.dart';
import '../../../data/services/feed_discovery_service.dart';
import '../source_list_controller.dart';

/// Shows the add feed dialog.
///
/// Allows users to enter a URL, discover available feeds,
/// preview them, and subscribe.
void showAddFeedDialog(BuildContext context) {
  ReederDialog.show(
    context: context,
    builder: (context) => const _AddFeedDialogContent(),
  );
}

class _AddFeedDialogContent extends ConsumerStatefulWidget {
  const _AddFeedDialogContent();

  @override
  ConsumerState<_AddFeedDialogContent> createState() =>
      _AddFeedDialogContentState();
}

class _AddFeedDialogContentState
    extends ConsumerState<_AddFeedDialogContent> {
  final _urlController = TextEditingController();
  final _discoveryService = FeedDiscoveryService();

  bool _isLoading = false;
  String? _error;
  List<DiscoveredFeedInfo>? _discoveredFeeds;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _discoverFeeds() async {
    final l10n = AppLocalizations.of(context)!;
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = l10n.pleaseEnterUrl);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _discoveredFeeds = null;
    });

    try {
      final feeds = await _discoveryService.discover(url);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (feeds.isEmpty) {
          _error = l10n.noFeedsFound;
        } else {
          _discoveredFeeds = feeds;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = l10n.errorDiscoveringFeeds(e.toString());
      });
    }
  }

  Future<void> _subscribeFeed(DiscoveredFeedInfo feedInfo) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(sourceListControllerProvider.notifier)
          .addFeed(feedInfo.feedUrl);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            l10n.addFeed,
            style: theme.typography.articleTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing),

          // Grouped input card: URL field + discover action share one frame
          // so the address bar no longer floats on its own.
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: theme.separatorColor, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // URL field (frameless — the card provides the frame)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing,
                    vertical: AppDimensions.spacingM,
                  ),
                  child: ReederTextField(
                    controller: _urlController,
                    placeholder: l10n.enterFeedUrl,
                    bordered: false,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _discoverFeeds(),
                  ),
                ),

                // Hairline separator between field and action
                Container(
                  height: 0.5,
                  color: theme.separatorColor,
                ),

                // Discover action row (part of the same card)
                GestureDetector(
                  onTap: _isLoading ? null : _discoverFeeds,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing,
                    ),
                    child: Center(
                      child: Text(
                        _isLoading ? l10n.searching : l10n.discoverFeeds,
                        style: theme.typography.body.copyWith(
                          color: _isLoading
                              ? theme.secondaryTextColor
                              : theme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              _error!,
              style: theme.typography.caption.copyWith(
                color: theme.destructiveColor,
              ),
            ),
          ],

          // Discovered feeds list
          if (_discoveredFeeds != null && !_isLoading) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.foundFeeds(_discoveredFeeds!.length),
              style: theme.typography.caption.copyWith(
                color: theme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            for (final feed in _discoveredFeeds!)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingS,
                ),
                child: GestureDetector(
                  onTap: () => _subscribeFeed(feed),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingM),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.title,
                          style: theme.typography.listTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (feed.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            feed.description!,
                            style: theme.typography.caption.copyWith(
                              color: theme.secondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          l10n.feedItemsInfo(feed.itemCount, feed.type.name),
                          style: theme.typography.caption.copyWith(
                            color: theme.tertiaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
