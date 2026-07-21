import 'package:flutter/widgets.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom action bar for the article detail page.
///
/// Displays quick action buttons:
/// - Later (clock icon)
/// - Bookmark (bookmark icon)
/// - Favorite/Star (heart icon)
/// - Share (share icon)
/// - Open in Browser (globe icon)
///
/// Each built-in tag button receives its tag ID directly,
/// so the action bar doesn't need to know tag names.
class ArticleActionBar extends StatelessWidget {
  /// The article ID.
  final int articleId;

  /// Whether the article is starred.
  final bool isStarred;

  /// Map of tag ID → is tagged state for built-in tags.
  /// Expected keys: Later tag ID, Bookmarks tag ID, Favorites tag ID.
  final Map<int, bool> tagStates;

  /// Whether the article is read.
  final bool isRead;

  /// Callback to toggle star.
  final VoidCallback? onToggleStar;

  /// Callback to toggle a tag (receives tag ID).
  final void Function(int tagId)? onToggleTag;

  /// Callback to mark as unread.
  final VoidCallback? onMarkAsUnread;

  /// Callback to share the article.
  final VoidCallback? onShare;

  /// Callback to open in browser.
  final VoidCallback? onOpenInBrowser;

  const ArticleActionBar({
    super.key,
    required this.articleId,
    this.isStarred = false,
    this.isRead = true,
    this.tagStates = const {},
    this.onToggleStar,
    this.onToggleTag,
    this.onMarkAsUnread,
    this.onShare,
    this.onOpenInBrowser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Extract tag IDs in order: Later, Bookmarks, Favorites
    // tagStates is populated in order by ArticleDetailController._loadTagStates
    final tagIds = tagStates.keys.toList();
    final laterTagId = tagIds.isNotEmpty ? tagIds[0] : null;
    final bookmarksTagId = tagIds.length > 1 ? tagIds[1] : null;

    return Container(
      height: AppDimensions.bottomBarHeight,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.separatorColor,
            width: AppDimensions.separatorThickness,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Later
          _ActionButton(
            icon: '🕐',
            label: l10n.later,
            isActive: laterTagId != null && (tagStates[laterTagId] ?? false),
            activeColor: theme.accentColor,
            inactiveColor: theme.iconColor,
            onTap: laterTagId != null
                ? () => onToggleTag?.call(laterTagId)
                : null,
          ),

          // Bookmark
          _ActionButton(
            icon: '🏷',
            activeIcon: '🔖',
            label: l10n.bookmark,
            isActive: bookmarksTagId != null &&
                (tagStates[bookmarksTagId] ?? false),
            activeColor: theme.accentColor,
            inactiveColor: theme.iconColor,
            onTap: bookmarksTagId != null
                ? () => onToggleTag?.call(bookmarksTagId)
                : null,
          ),

          // Favorite (uses isStarred on FeedItem directly)
          _ActionButton(
            icon: '♡',
            activeIcon: '❤',
            label: l10n.favorite,
            isActive: isStarred,
            activeColor: theme.destructiveColor,
            inactiveColor: theme.iconColor,
            onTap: onToggleStar,
          ),

          // Mark as Unread
          _ActionButton(
            icon: '◯',
            activeIcon: '●',
            label: l10n.markUnread,
            isActive: !isRead,
            activeColor: theme.accentColor,
            inactiveColor: theme.iconColor,
            onTap: onMarkAsUnread,
          ),

          // Share
          _ActionButton(
            icon: '↗',
            label: l10n.share,
            isActive: false,
            activeColor: theme.accentColor,
            inactiveColor: theme.iconColor,
            onTap: onShare,
          ),

          // Open in Browser
          _ActionButton(
            icon: '🌐',
            label: l10n.browser,
            isActive: false,
            activeColor: theme.accentColor,
            inactiveColor: theme.iconColor,
            onTap: onOpenInBrowser,
          ),
        ],
      ),
    );
  }
}

/// A single action button in the action bar.
class _ActionButton extends StatefulWidget {
  final String icon;
  final String? activeIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    this.activeIcon,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  bool get _isEnabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? widget.activeColor : widget.inactiveColor;
    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: AppDurations.micro,
        child: AnimatedOpacity(
          duration: AppDurations.micro,
          opacity: !_isEnabled
              ? 0.3
              : _isPressed
                  ? 0.6
                  : 1.0,
          child: SizedBox(
            width: 64,
            height: AppDimensions.bottomBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: AppDurations.micro,
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                  ),
                  child: Text(
                    widget.isActive && widget.activeIcon != null
                        ? widget.activeIcon!
                        : widget.icon,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.micro,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.0,
                    color: color,
                  ),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
