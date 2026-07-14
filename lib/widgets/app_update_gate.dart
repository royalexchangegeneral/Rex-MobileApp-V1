import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_update_service.dart';

class AppUpdateGate extends StatefulWidget {
  final Widget child;

  const AppUpdateGate({super.key, required this.child});

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  bool _checked = false;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (_checked || !mounted) return;
    _checked = true;

    final updateInfo = await AppUpdateService.checkForUpdate();
    if (!mounted || updateInfo == null || !updateInfo.updateAvailable) return;

    await _showUpdateDialog(updateInfo);
  }

  Future<void> _showUpdateDialog(AppUpdateInfo updateInfo) async {
    if (_dialogShowing || !mounted) return;
    _dialogShowing = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (dialogContext) {
        return PopScope(
          canPop: !updateInfo.forceUpdate,
          child: AlertDialog(
            title: Text(updateInfo.title),
            content: Text(updateInfo.message),
            actions: [
              if (!updateInfo.forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                onPressed: () => _openStore(updateInfo.storeUrl),
                child: const Text('Update now'),
              ),
            ],
          ),
        );
      },
    );

    _dialogShowing = false;
  }

  Future<void> _openStore(String storeUrl) async {
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
