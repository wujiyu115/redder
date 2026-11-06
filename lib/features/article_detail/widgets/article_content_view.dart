import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/bionic_reading.dart';
import '../../../data/services/image_cache_manager.dart';
import '../../../shared/providers/settings_provider.dart';

/// Widget that renders HTML article content.
///
/// Uses `flutter_widget_from_html` to render rich HTML content
/// including images, links, code blocks, blockquotes, tables, etc.
///
/// Supports configurable font size, line height, and Bionic Reading mode.
class ArticleContentView extends StatefulWidget {
  /// The HTML content to render.
  final String content;

  /// Font size in logical pixels.
  final double fontSize;

  /// Line height multiplier.
  final double lineHeight;

  /// Maximum content width for readability.
  final double maxWidth;

  /// Layout mode passed through to `HtmlWidget`.
  ///
  /// [RenderMode.sliverList] builds only the blocks near the viewport and must
  /// be used as a direct child of a `CustomScrollView`; the widget then returns
  /// a sliver. Use [RenderMode.column] when embedding in a box scroll view.
  final RenderMode renderMode;

  /// Whether Bionic Reading mode is enabled.
  final bool bionicReading;

  /// Callback when an image in the content is tapped.
  final void Function(String imageUrl)? onImageTap;

  const ArticleContentView({
    super.key,
    required this.content,
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.maxWidth = AppDimensions.maxContentWidth,
    this.renderMode = RenderMode.sliverList,
    this.bionicReading = false,
    this.onImageTap,
  });

  @override
  State<ArticleContentView> createState() => _ArticleContentViewState();
}

class _ArticleContentViewState extends State<ArticleContentView> {
  /// Content longer than this has its Bionic Reading transform run on a
  /// background isolate. Below it the synchronous path is faster than the
  /// isolate round-trip and avoids a second layout pass.
  static const int _syncTransformLimit = 20000;

  /// Cached transformed HTML. The Bionic Reading transform is regex-heavy
  /// (measured ~5 ms per 50 KB), so it is recomputed only when the source
  /// content or the toggle changes — never on rebuild.
  String? _displayContent;

  /// Guards against a stale isolate result landing after a newer request.
  int _transformToken = 0;

  @override
  void initState() {
    super.initState();
    _prepareDisplayContent();
  }

  @override
  void didUpdateWidget(ArticleContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.bionicReading != widget.bionicReading) {
      _prepareDisplayContent();
    }
  }

  /// Computes [_displayContent] for the current content / toggle combination.
  ///
  /// Called from [initState] and [didUpdateWidget] only, so a plain assignment
  /// is enough for the synchronous branches (a build always follows).
  void _prepareDisplayContent() {
    final raw = widget.content;

    if (!widget.bionicReading || raw.isEmpty) {
      _displayContent = raw;
      return;
    }

    if (raw.length <= _syncTransformLimit) {
      _displayContent = BionicReading.applyToHtml(raw);
      return;
    }

    // Large document: do not spend a frame on the regex. The body is briefly
    // blank instead of shown unbolded, so there is no reflow flash when the
    // fixations land.
    final token = ++_transformToken;
    _displayContent = null;
    compute(_applyBionicReading, raw).then(
      (result) {
        if (!mounted || token != _transformToken) return;
        setState(() => _displayContent = result);
      },
      // Never lose the article if the isolate fails: fall back to the
      // untransformed HTML rather than staying blank.
      onError: (Object error) {
        if (!mounted || token != _transformToken) return;
        setState(() => _displayContent = raw);
      },
    );
  }

  /// True when the built tree must be emitted as a sliver.
  bool get _asSliver => widget.renderMode is SliverListMode;

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    if (widget.content.isEmpty) {
      final empty = Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingXL,
        ),
        child: Center(
          child: Text(
            'No content available',
            style: theme.typography.body.copyWith(
              color: theme.tertiaryTextColor,
            ),
          ),
        ),
      );
      return _asSliver ? SliverToBoxAdapter(child: empty) : empty;
    }

    final displayContent = _displayContent;
    if (displayContent == null) {
      // Bionic Reading transform of a large document is still running on an
      // isolate. Render nothing rather than the unbolded text, which would
      // reflow the whole article a moment later.
      const blank = SizedBox.shrink();
      return _asSliver ? const SliverToBoxAdapter(child: blank) : blank;
    }

    final html = HtmlWidget(
      displayContent,
      renderMode: widget.renderMode,
      factoryBuilder: _ArticleWidgetFactory.new,
      textStyle: TextStyle(
        fontSize: widget.fontSize,
        height: widget.lineHeight,
        color: theme.primaryTextColor,
      ),
      // Document parsing for long HTML runs on a background isolate
      // (`compute`); the page chrome paints first and the text follows. The
      // root build tree is reported as a synthetic `<root>` element, so that
      // case gets a blank placeholder instead of the default animated spinner
      // (a spinner mid-article repaints while parsing). Embedded media keep the
      // default loading widget.
      onLoadingBuilder: (context, element, loadingProgress) =>
          element.localName == 'root' ? const SizedBox.shrink() : null,
      customStylesBuilder: (element) {
        return _buildCustomStyles(element, theme);
      },
      onTapUrl: (url) {
        _handleUrlTap(url);
        return true;
      },
      onTapImage: (imageMetadata) {
        final src = imageMetadata.sources.firstOrNull?.url;
        if (src != null && widget.onImageTap != null) {
          widget.onImageTap!(src);
        }
      },
    );

    if (_asSliver) return html;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: html,
    );
  }

  /// Builds custom CSS-like styles for HTML elements.
  Map<String, String>? _buildCustomStyles(
    dynamic element,
    ReederThemeData theme,
  ) {
    final tag = element.localName;

    switch (tag) {
      case 'a':
        return {
          'color': _colorToHex(theme.accentColor),
          'text-decoration': 'none',
        };
      case 'blockquote':
        return {
          'border-left': '3px solid ${_colorToHex(theme.separatorColor)}',
          'padding-left': '${AppDimensions.spacing}px',
          'margin-left': '0',
          'color': _colorToHex(theme.secondaryTextColor),
          'font-style': 'italic',
        };
      case 'code':
        return {
          'background-color': _colorToHex(theme.secondaryBackgroundColor),
          'padding': '2px 6px',
          'border-radius': '4px',
          'font-size': '${widget.fontSize * 0.9}px',
        };
      case 'pre':
        return {
          'background-color': _colorToHex(theme.secondaryBackgroundColor),
          'padding': '${AppDimensions.spacingM}px',
          'border-radius': '${AppDimensions.radiusM}px',
          'overflow-x': 'auto',
          'font-size': '${widget.fontSize * 0.85}px',
        };
      case 'img':
        return {
          'max-width': '100%',
          'border-radius': '${AppDimensions.radiusM}px',
          'margin': '${AppDimensions.spacingS}px 0',
        };
      case 'h1':
        return {
          'font-size': '${widget.fontSize * 1.5}px',
          'font-weight': '700',
          'margin-top': '${AppDimensions.spacingXL}px',
          'margin-bottom': '${AppDimensions.spacingS}px',
        };
      case 'h2':
        return {
          'font-size': '${widget.fontSize * 1.3}px',
          'font-weight': '600',
          'margin-top': '${AppDimensions.spacingXL}px',
          'margin-bottom': '${AppDimensions.spacingS}px',
        };
      case 'h3':
        return {
          'font-size': '${widget.fontSize * 1.15}px',
          'font-weight': '600',
          'margin-top': '${AppDimensions.spacing}px',
          'margin-bottom': '${AppDimensions.spacingXS}px',
        };
      case 'figure':
        return {
          'margin': '${AppDimensions.spacing}px 0',
          'text-align': 'center',
        };
      case 'figcaption':
        return {
          'font-size': '${widget.fontSize * 0.85}px',
          'color': _colorToHex(theme.tertiaryTextColor),
          'text-align': 'center',
          'margin-top': '${AppDimensions.spacingXS}px',
        };
      case 'table':
        return {
          'border-collapse': 'collapse',
          'width': '100%',
          'margin': '${AppDimensions.spacing}px 0',
        };
      case 'th':
        return {
          'border': '1px solid ${_colorToHex(theme.separatorColor)}',
          'padding': '${AppDimensions.spacingS}px',
          'font-weight': '600',
          'background-color': _colorToHex(theme.secondaryBackgroundColor),
        };
      case 'td':
        return {
          'border': '1px solid ${_colorToHex(theme.separatorColor)}',
          'padding': '${AppDimensions.spacingS}px',
        };
      case 'hr':
        return {
          'border': 'none',
          'border-top': '1px solid ${_colorToHex(theme.separatorColor)}',
          'margin': '${AppDimensions.spacingXL}px 0',
        };
      default:
        return null;
    }
  }

  /// Converts a Color to a hex string for CSS.
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// Handles URL taps by launching the URL.
  Future<void> _handleUrlTap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Isolate entry point for the Bionic Reading transform.
///
/// Must be a top-level function: `compute` rejects closures and static methods.
String _applyBionicReading(String html) => BionicReading.applyToHtml(html);

/// Custom [WidgetFactory] that takes over `<img>` rendering.
///
/// The default factory from `flutter_widget_from_html` builds a
/// `CachedNetworkImage` with no decode-size cap, so full-resolution photos
/// (e.g. 3000x4000) are decoded into memory as-is. It also shows an
/// indeterminate [CircularProgressIndicator] per pending image, which keeps
/// repainting the whole article. Both are replaced by [_ArticleImage].
class _ArticleWidgetFactory extends WidgetFactory {
  @override
  Widget? buildImageWidget(BuildTree tree, ImageSource src) {
    final url = src.url;
    final isRemote = url.startsWith('http://') || url.startsWith('https://');
    // SVG needs the dedicated factory (vector, no raster decode).
    final isSvg = url.toLowerCase().contains('.svg');
    if (!isRemote || isSvg) return super.buildImageWidget(tree, src);

    return _ArticleImage(
      url: url,
      width: src.width,
      height: src.height,
      alt: src.image?.alt,
    );
  }
}

/// A single article image that loads independently of the text flow.
///
/// Behaviour:
/// - Decode width is capped to the visible content width * device pixel ratio,
///   so a 12 MP photo never becomes a 48 MB bitmap.
/// - Space is reserved with a static placeholder of the theme background, so
///   no animated spinner repaints the article while the bytes arrive.
/// - Honours the `cacheImages` setting and shares [ReederImageCacheManager]
///   with the rest of the app (so the size cap / offline toggle apply here too).
class _ArticleImage extends ConsumerWidget {
  const _ArticleImage({
    required this.url,
    this.width,
    this.height,
    this.alt,
  });

  final String url;
  final double? width;
  final double? height;
  final String? alt;

  /// Hard ceiling on the decoded bitmap width.
  static const int _maxDecodeWidth = 2400;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ReederTheme.of(context);
    final cacheImages = ref.watch(cacheImagesProvider);
    final cacheManager = ref.watch(reederImageCacheManagerProvider);
    final maxContentWidth = ref.watch(maxContentWidthProvider);

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final logicalWidth =
        viewportWidth < maxContentWidth ? viewportWidth : maxContentWidth;
    final decodeWidth =
        (logicalWidth * dpr).round().clamp(160, _maxDecodeWidth);

    // The HTML declared both dimensions: the factory already wraps us in an
    // AspectRatio, so the box just has to fill it. Otherwise reserve 16:9 to
    // keep the text from jumping when the image resolves.
    final hasDeclaredSize =
        width != null && height != null && width! > 0 && height! > 0;

    Widget placeholder(BuildContext context, String _) => hasDeclaredSize
        ? ColoredBox(color: theme.secondaryBackgroundColor)
        : AspectRatio(
            aspectRatio: AppDimensions.imageAspectRatio,
            child: ColoredBox(color: theme.secondaryBackgroundColor),
          );

    if (!cacheImages) {
      return Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        cacheWidth: decodeWidth,
        semanticLabel: alt,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder(context, url),
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    final image = CachedNetworkImage(
      imageUrl: url,
      cacheManager: cacheManager,
      memCacheWidth: decodeWidth,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      fadeInDuration: const Duration(milliseconds: 160),
      placeholder: placeholder,
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );

    final label = alt;
    return label == null || label.isEmpty
        ? image
        : Semantics(image: true, label: label, child: image);
  }
}
