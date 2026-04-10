import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_durations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_button.dart';

/// In-app browser page for viewing web content.
///
/// Features:
/// - WebView with full browser capabilities
/// - Navigation controls (back, forward, refresh)
/// - Share and open in external browser
/// - Loading progress indicator
/// - Page title display
class InAppBrowserPage extends StatefulWidget {
  /// The URL to load.
  final String url;

  const InAppBrowserPage({
    super.key,
    required this.url,
  });

  @override
  State<InAppBrowserPage> createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage> {
  InAppWebViewController? _webViewController;
  String _currentUrl = '';
  String _pageTitle = '';
  double _progress = 0.0;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    return ReederScaffold(
      navBar: ReederNavBar(
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pageTitle.isNotEmpty)
              Text(
                _pageTitle,
                style: theme.typography.caption.copyWith(
                  color: theme.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              _currentUrl,
              style: theme.typography.caption.copyWith(
                color: theme.tertiaryTextColor,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        showBackButton: true,
        onBack: () => context.pop(),
        actions: [
          ReederButton.icon(
            icon: Text(
              '↗',
              style: TextStyle(fontSize: 18, color: theme.accentColor),
            ),
            onPressed: _openInExternalBrowser,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          if (_progress > 0 && _progress < 1.0)
            SizedBox(
              height: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 2,
                        color: theme.separatorColor,
                      ),
                      AnimatedContainer(
                        duration: AppDurations.micro,
                        height: 2,
                        width: constraints.maxWidth * _progress,
                        color: theme.accentColor,
                      ),
                    ],
                  );
                },
              ),
            ),

          // WebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: true,
                transparentBackground: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _currentUrl = url?.toString() ?? _currentUrl;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _currentUrl = url?.toString() ?? _currentUrl;
                });
                _updateNavigationState();
              },
              onTitleChanged: (controller, title) {
                setState(() {
                  _pageTitle = title ?? '';
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100.0;
                });
              },
            ),
          ),

          // Bottom toolbar
          _buildBottomToolbar(theme),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar(ReederThemeData theme) {
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
          // Back
          _ToolbarButton(
            icon: '‹',
            fontSize: 28,
            isEnabled: _canGoBack,
            color: theme.accentColor,
            disabledColor: theme.tertiaryTextColor,
            onTap: _canGoBack ? () => _webViewController?.goBack() : null,
          ),

          // Forward
          _ToolbarButton(
            icon: '›',
            fontSize: 28,
            isEnabled: _canGoForward,
            color: theme.accentColor,
            disabledColor: theme.tertiaryTextColor,
            onTap: _canGoForward
                ? () => _webViewController?.goForward()
                : null,
          ),

          // Refresh
          _ToolbarButton(
            icon: '↻',
            fontSize: 20,
            isEnabled: true,
            color: theme.accentColor,
            disabledColor: theme.tertiaryTextColor,
            onTap: () => _webViewController?.reload(),
          ),

          // Share
          _ToolbarButton(
            icon: '↗',
            fontSize: 20,
            isEnabled: true,
            color: theme.accentColor,
            disabledColor: theme.tertiaryTextColor,
            onTap: _shareUrl,
          ),
        ],
      ),
    );
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;
    final canGoForward = await _webViewController?.canGoForward() ?? false;
    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  Future<void> _shareUrl() async {
    await Share.share(_currentUrl, subject: _pageTitle);
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.tryParse(_currentUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// A single button in the browser toolbar.
class _ToolbarButton extends StatelessWidget {
  final String icon;
  final double fontSize;
  final bool isEnabled;
  final Color color;
  final Color disabledColor;
  final VoidCallback? onTap;

  const _ToolbarButton({
    required this.icon,
    this.fontSize = 20,
    required this.isEnabled,
    required this.color,
    required this.disabledColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: AppDimensions.bottomBarHeight,
        child: Center(
          child: Text(
            icon,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
              color: isEnabled ? color : disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
