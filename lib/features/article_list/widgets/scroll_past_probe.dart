import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Collects the list rows that have scrolled completely above the viewport.
///
/// Rows register a probe while they are mounted and unregister on dispose, so
/// the reporter only ever looks at <b>live</b> render objects. That matters for
/// a scrolling list: cached geometry goes stale as soon as rows are recycled or
/// shifted by a refresh, while a live render object always reports where it
/// actually is.
class ScrollPastReporter {
  final Set<_ScrollPastEntry> _entries = {};

  /// Number of mounted probes (visible rows plus the cache extent).
  int get debugMountedCount => _entries.length;

  void _add(_ScrollPastEntry entry) => _entries.add(entry);

  void _remove(_ScrollPastEntry entry) => _entries.remove(entry);

  /// Ids of the mounted rows whose bottom edge is above the viewport top.
  ///
  /// Rows still on screen (or below it) are not included.
  List<int> collectScrolledPast() {
    if (_entries.isEmpty) return const [];
    List<int>? ids;
    for (final entry in _entries) {
      final id = entry.scrolledPastItemId();
      if (id == null) continue;
      (ids ??= <int>[]).add(id);
    }
    return ids ?? const [];
  }
}

/// One mounted row: resolves the geometry of its live render object.
class _ScrollPastEntry {
  _ScrollPastEntry(this.itemId, this._renderObject);

  int itemId;
  final RenderObject? Function() _renderObject;

  /// Returns [itemId] if this row is entirely above the viewport top.
  int? scrolledPastItemId() {
    final box = _renderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;

    final viewport = RenderAbstractViewport.of(box);
    if (viewport is! RenderBox) return null;

    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    return top + box.size.height <= 0 ? itemId : null;
  }
}

/// Reports row visibility to a [ScrollPastReporter], transparent to layout.
///
/// Wrap each list row with this widget when the "mark as read on scroll"
/// setting is enabled; it adds no layout, paint or semantics behaviour.
class ScrollPastProbe extends StatefulWidget {
  /// Id of the article rendered by [child].
  final int itemId;

  /// Shared reporter owned by the list page.
  final ScrollPastReporter reporter;

  /// The row content.
  final Widget child;

  const ScrollPastProbe({
    super.key,
    required this.itemId,
    required this.reporter,
    required this.child,
  });

  @override
  State<ScrollPastProbe> createState() => _ScrollPastProbeState();
}

class _ScrollPastProbeState extends State<ScrollPastProbe> {
  late _ScrollPastEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = _ScrollPastEntry(widget.itemId, () => context.findRenderObject());
    widget.reporter._add(_entry);
  }

  @override
  void didUpdateWidget(ScrollPastProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recycled rows are reused for a different article.
    _entry.itemId = widget.itemId;
    if (oldWidget.reporter != widget.reporter) {
      oldWidget.reporter._remove(_entry);
      widget.reporter._add(_entry);
    }
  }

  @override
  void dispose() {
    widget.reporter._remove(_entry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}