import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';

/// Adaptive scaffold that provides responsive layouts for different screen sizes.
///
/// Layout modes:
/// - **Phone** (< 768px): Single column, full-screen navigation
/// - **Tablet Portrait** (768-1024px): Two columns (article list + detail),
///   source list slides in from left
/// - **Tablet Landscape / Desktop** (> 1024px): Three columns
///   (source list + article list + detail)
///
/// Supports draggable column width adjustment.
class AdaptiveScaffold extends StatefulWidget {
  /// The source list panel (left sidebar).
  final Widget sourceList;

  /// The article list panel (middle column).
  final Widget articleList;

  /// The detail panel (right/main content).
  final Widget? detailView;

  /// Placeholder widget when no detail is selected.
  final Widget? detailPlaceholder;

  /// Whether the source list sidebar is visible (tablet portrait mode).
  final bool showSourceList;

  /// Callback when source list visibility changes.
  final ValueChanged<bool>? onSourceListVisibilityChanged;

  /// Initial source list width (default: 240).
  final double initialSourceListWidth;

  /// Initial article list width (default: 320).
  final double initialArticleListWidth;

  /// Minimum column width for resizing.
  final double minColumnWidth;

  const AdaptiveScaffold({
    super.key,
    required this.sourceList,
    required this.articleList,
    this.detailView,
    this.detailPlaceholder,
    this.showSourceList = false,
    this.onSourceListVisibilityChanged,
    this.initialSourceListWidth = AppDimensions.sourceListWidth,
    this.initialArticleListWidth = AppDimensions.articleListWidth,
    this.minColumnWidth = 200.0,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold>
    with SingleTickerProviderStateMixin {
  late double _sourceListWidth;
  late double _articleListWidth;

  // For sidebar slide animation (tablet portrait)
  late AnimationController _sidebarAnimController;
  late Animation<Offset> _sidebarSlide;

  @override
  void initState() {
    super.initState();
    _sourceListWidth = widget.initialSourceListWidth;
    _articleListWidth = widget.initialArticleListWidth;

    _sidebarAnimController = AnimationController(
      duration: AppDurations.pageTransition,
      vsync: this,
      value: widget.showSourceList ? 1.0 : 0.0,
    );
    _sidebarSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sidebarAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AdaptiveScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showSourceList != oldWidget.showSourceList) {
      if (widget.showSourceList) {
        _sidebarAnimController.forward();
      } else {
        _sidebarAnimController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _sidebarAnimController.dispose();
    super.dispose();
  }

  _LayoutMode _getLayoutMode(double width) {
    if (width >= AppDimensions.desktopBreakpoint) {
      return _LayoutMode.threeColumn;
    } else if (width >= AppDimensions.tabletBreakpoint) {
      return _LayoutMode.twoColumn;
    }
    return _LayoutMode.singleColumn;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutMode = _getLayoutMode(constraints.maxWidth);

        switch (layoutMode) {
          case _LayoutMode.singleColumn:
            return _buildSingleColumn(theme);
          case _LayoutMode.twoColumn:
            return _buildTwoColumn(theme, constraints.maxWidth);
          case _LayoutMode.threeColumn:
            return _buildThreeColumn(theme, constraints.maxWidth);
        }
      },
    );
  }

  /// Phone layout: single column, full-screen navigation.
  Widget _buildSingleColumn(ReederThemeData theme) {
    // In single column mode, navigation is handled by the router
    // Show whichever panel is currently active
    if (widget.detailView != null) {
      return widget.detailView!;
    }
    return widget.articleList;
  }

  /// Tablet portrait: two columns (article list + detail).
  /// Source list slides in from left as overlay.
  Widget _buildTwoColumn(ReederThemeData theme, double maxWidth) {
    return Stack(
      children: [
        // Main two-column layout
        Row(
          children: [
            // Article list
            SizedBox(
              width: _articleListWidth,
              child: widget.articleList,
            ),

            // Drag handle between article list and detail
            _DragHandle(
              onDrag: (delta) {
                setState(() {
                  _articleListWidth = (_articleListWidth + delta).clamp(
                    widget.minColumnWidth,
                    maxWidth - AppDimensions.minDetailWidth,
                  );
                });
              },
              theme: theme,
            ),

            // Detail view
            Expanded(
              child: widget.detailView ??
                  widget.detailPlaceholder ??
                  _DefaultPlaceholder(theme: theme),
            ),
          ],
        ),

        // Source list overlay (slides in from left)
        if (_sidebarAnimController.value > 0) ...[
          // Scrim
          GestureDetector(
            onTap: () {
              widget.onSourceListVisibilityChanged?.call(false);
            },
            child: FadeTransition(
              opacity: _sidebarAnimController,
              child: const ColoredBox(
                color: Color(0x40000000),
                child: SizedBox.expand(),
              ),
            ),
          ),

          // Sidebar
          SlideTransition(
            position: _sidebarSlide,
            child: SizedBox(
              width: _sourceListWidth,
              child: ColoredBox(
                color: theme.backgroundColor,
                child: widget.sourceList,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Tablet landscape / Desktop: three columns.
  Widget _buildThreeColumn(ReederThemeData theme, double maxWidth) {
    return Row(
      children: [
        // Source list
        SizedBox(
          width: _sourceListWidth,
          child: widget.sourceList,
        ),

        // Drag handle between source list and article list
        _DragHandle(
          onDrag: (delta) {
            setState(() {
              _sourceListWidth = (_sourceListWidth + delta).clamp(
                widget.minColumnWidth,
                maxWidth -
                    _articleListWidth -
                    AppDimensions.minDetailWidth -
                    2,
              );
            });
          },
          theme: theme,
        ),

        // Article list
        SizedBox(
          width: _articleListWidth,
          child: widget.articleList,
        ),

        // Drag handle between article list and detail
        _DragHandle(
          onDrag: (delta) {
            setState(() {
              _articleListWidth = (_articleListWidth + delta).clamp(
                widget.minColumnWidth,
                maxWidth -
                    _sourceListWidth -
                    AppDimensions.minDetailWidth -
                    2,
              );
            });
          },
          theme: theme,
        ),

        // Detail view
        Expanded(
          child: widget.detailView ??
              widget.detailPlaceholder ??
              _DefaultPlaceholder(theme: theme),
        ),
      ],
    );
  }
}

/// Layout mode enumeration.
enum _LayoutMode {
  singleColumn,
  twoColumn,
  threeColumn,
}

/// Draggable handle between columns for width adjustment.
class _DragHandle extends StatefulWidget {
  final void Function(double delta) onDrag;
  final ReederThemeData theme;

  const _DragHandle({
    required this.onDrag,
    required this.theme,
  });

  @override
  State<_DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<_DragHandle> {
  bool _isHovering = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
        onHorizontalDragUpdate: (details) {
          widget.onDrag(details.delta.dx);
        },
        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _isDragging || _isHovering ? 4 : 1,
          color: _isDragging
              ? widget.theme.accentColor
              : _isHovering
                  ? widget.theme.accentColor.withOpacity(0.5)
                  : widget.theme.separatorColor,
        ),
      ),
    );
  }
}

/// Default placeholder shown when no detail view is selected.
class _DefaultPlaceholder extends StatelessWidget {
  final ReederThemeData theme;

  const _DefaultPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📖',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: AppDimensions.spacing),
            Text(
              'Select an article to read',
              style: theme.typography.body.copyWith(
                color: theme.tertiaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
