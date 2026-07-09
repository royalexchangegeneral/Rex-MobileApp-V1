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
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) {
            setState(() => _isLoading = true);
          }
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      ))
      ..loadRequest(
          Uri.parse('https://tawk.to/chat/6687fe38eaf3bd8d4d1876c4/1i21ji3qp'));

    _configureAndroidFilePicker();
  }

  void _configureAndroidFilePicker() {
    final platformController = _controller.platform;
    if (platformController is! AndroidWebViewController) {
      return;
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
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ]),
    );
  }
}
