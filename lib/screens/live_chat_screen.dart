import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});
  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  static const String _tawkPropertyId = '6687fe38eaf3bd8d4d1876c4';
  static const String _tawkWidgetId = '1i21ji3qp';

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) {
            setState(() {
              _isLoading = true;
              _hasLoadError = false;
            });
          }
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true && mounted) {
            setState(() {
              _isLoading = false;
              _hasLoadError = true;
            });
          }
        },
      ))
      ..setBackgroundColor(Colors.white);

    _initializeChat();
  }

  String get _chatHtml => '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <style>
    html, body {
      height: 100%;
      margin: 0;
      background: #ffffff;
      overflow: hidden;
    }
    #tawk-host {
      position: fixed;
      inset: 0;
      background: #ffffff;
    }
    .tawk-min-container,
    .tawk-button-circle,
    iframe[title*="chat"]:not([style*="display: none"]) {
      width: 100% !important;
      height: 100% !important;
      max-width: none !important;
      max-height: none !important;
    }
  </style>
</head>
<body>
  <div id="tawk-host"></div>
  <script>
    window.Tawk_API = window.Tawk_API || {};
    window.Tawk_LoadStart = new Date();
    window.Tawk_API.embedded = 'tawk-host';
    window.Tawk_API.onLoad = function () {
      window.Tawk_API.maximize();
    };
    (function () {
      var script = document.createElement('script');
      var firstScript = document.getElementsByTagName('script')[0];
      script.async = true;
      script.src = 'https://embed.tawk.to/$_tawkPropertyId/$_tawkWidgetId';
      script.charset = 'UTF-8';
      script.setAttribute('crossorigin', '*');
      firstScript.parentNode.insertBefore(script, firstScript);
    })();
  </script>
</body>
</html>
''';

  Future<void> _loadChat() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }
    await _controller.loadHtmlString(_chatHtml, baseUrl: 'https://tawk.to');
  }

  Future<void> _initializeChat() async {
    await _configureAndroidWebView();
    await _controller.loadHtmlString(_chatHtml, baseUrl: 'https://tawk.to');
  }

  Future<void> _configureAndroidWebView() async {
    final platformController = _controller.platform;
    if (platformController is! AndroidWebViewController) {
      return;
    }

    await platformController.setMediaPlaybackRequiresUserGesture(false);

    final cookieManager = WebViewCookieManager();
    final platformCookieManager = cookieManager.platform;
    if (platformCookieManager is AndroidWebViewCookieManager) {
      await platformCookieManager.setAcceptThirdPartyCookies(
        platformController,
        true,
      );
    }

    platformController.setOnShowFileSelector((params) async {
      try {
        final fileType = _fileTypeFromAcceptTypes(params.acceptTypes);
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: params.mode == FileSelectorMode.openMultiple,
          type: fileType,
          allowedExtensions: fileType == FileType.custom
              ? _extensionsFromAcceptTypes(params.acceptTypes)
              : null,
        );

        if (result == null) {
          return <String>[];
        }

        return result.files
            .map((file) => file.path)
            .whereType<String>()
            .map((path) => Uri.file(path).toString())
            .toList();
      } catch (_) {
        return <String>[];
      }
    });
  }

  FileType _fileTypeFromAcceptTypes(List<String> acceptTypes) {
    final normalizedTypes = acceptTypes
        .map((type) => type.toLowerCase().trim())
        .where((type) => type.isNotEmpty)
        .toList();

    if (normalizedTypes.isEmpty || normalizedTypes.contains('*/*')) {
      return FileType.any;
    }

    if (normalizedTypes.every((type) => type.startsWith('image/'))) {
      return FileType.image;
    }

    if (normalizedTypes.every((type) => type.startsWith('video/'))) {
      return FileType.video;
    }

    if (normalizedTypes.every((type) => type.startsWith('audio/'))) {
      return FileType.audio;
    }

    if (normalizedTypes.every(_isFileExtension)) {
      return FileType.custom;
    }

    return FileType.any;
  }

  List<String>? _extensionsFromAcceptTypes(List<String> acceptTypes) {
    final extensions = acceptTypes
        .map((type) => type.toLowerCase().trim())
        .where(_isFileExtension)
        .map((type) => type.substring(1))
        .toList();

    return extensions.isEmpty ? null : extensions;
  }

  bool _isFileExtension(String acceptType) {
    return acceptType.startsWith('.') && acceptType.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          title: Text('Chat',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          centerTitle: true),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_hasLoadError) _buildErrorState(context),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ]),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.support_agent,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Chat is unavailable',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadChat,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
