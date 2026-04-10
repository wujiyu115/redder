import 'package:flutter/widgets.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/theme/app_theme.dart';

/// A collapsible section in the source list.
///
/// Displays a section header with an expand/collapse indicator
/// and a list of child items (feeds within a folder).
class SourceSection extends StatefulWidget {
  /// Section title (folder name).
  final String title;

  /// Optional icon name.
  final String? iconName;

  /// Whether the section is expanded.
  final bool isExpanded;

  /// Unread count for the section.
  final int unreadCount;

  /// Child widgets (feed items).
  final List<Widget> children;

  /// Callback when the section header is tapped.
  final VoidCallback? onTap;

  /// Callback when the section header is long-pressed.
  final VoidCallback? onLongPress;

  const SourceSection({
    super.key,
    required this.title,
    this.iconName,
    this.isExpanded = true,
    this.unreadCount = 0,
    this.children = const [],
    this.onTap,
    this.onLongPress,
  });

  @override
  State<SourceSection> createState() => _SourceSectionState();
}

class _SourceSectionState extends State<SourceSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: AppDurations.standard,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        GestureDetector(
          onTap: _toggleExpanded,
          onLongPress: widget.onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.listItemPaddingH,
              vertical: AppDimensions.spacingS,
            ),
            child: Row(
              children: [
                // Expand/collapse indicator
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: AppDurations.standard,
                  child: Text(
                    '▶',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),

                // Folder icon
                if (widget.iconName != null) ...[
                  Text(
                    '📁',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                ],

                // Title
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.typography.body.copyWith(
                      color: theme.primaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Unread count
                if (widget.unreadCount > 0)
                  Text(
                    '${widget.unreadCount}',
                    style: theme.typography.caption.copyWith(
                      color: theme.secondaryTextColor,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Children (animated)
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
