import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/adobe_colors.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  String _currentTitle = '';
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentUrl = widget.url;
  }

  Future<void> _updateNavigationState() async {
    if (_webViewController != null) {
      final back = await _webViewController!.canGoBack();
      final forward = await _webViewController!.canGoForward();
      if (mounted) {
        setState(() {
          _canGoBack = back;
          _canGoForward = forward;
        });
      }
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(_currentUrl.isNotEmpty ? _currentUrl : widget.url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdobeColors.pureBlack,
      appBar: AppBar(
        backgroundColor: AdobeColors.pureBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdobeColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdobeColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _currentUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdobeColors.textMuted,
                fontSize: 10,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _canGoBack ? AdobeColors.orangeAccent : AdobeColors.textMuted,
            ),
            onPressed: _canGoBack ? () => _webViewController?.goBack() : null,
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _canGoForward ? AdobeColors.orangeAccent : AdobeColors.textMuted,
            ),
            onPressed: _canGoForward ? () => _webViewController?.goForward() : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AdobeColors.textSecondary, size: 20),
            onPressed: () => _webViewController?.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: AdobeColors.orangeAccent, size: 20),
            tooltip: 'In Safari öffnen',
            onPressed: _openExternal,
          ),
        ],
        bottom: _progress > 0 && _progress < 1.0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AdobeColors.surfaceBase,
                  valueColor: const AlwaysStoppedAnimation<Color>(AdobeColors.orangeAccent),
                  minHeight: 2,
                ),
              )
            : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          isInspectable: true,
          allowsInlineMediaPlayback: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          javaScriptEnabled: true,
          transparentBackground: false,
          preferredContentMode: UserPreferredContentMode.RECOMMENDED,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        // AUTOMATISCHER SSL-BYPASS: Unerlässlich für Proxmox VE und selbstsignierte Zertifikate im Homelab
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onProgressChanged: (controller, progress) {
          setState(() {
            _progress = progress / 100;
          });
        },
        onTitleChanged: (controller, title) {
          if (title != null && title.isNotEmpty) {
            setState(() {
              _currentTitle = title;
            });
          }
        },
        onLoadStop: (controller, url) async {
          if (url != null) {
            setState(() {
              _currentUrl = url.toString();
            });
          }
          await _updateNavigationState();
        },
      ),
    );
  }
}
