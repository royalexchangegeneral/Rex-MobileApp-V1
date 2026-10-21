import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_update_service.dart';

class AppUpdateGate extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final Future<AppUpdateInfo?> Function() checkForUpdate;

  const AppUpdateGate({
    super.key,
    required this.child,
    required this.navigatorKey,
    this.checkForUpdate = AppUpdateService.checkForUpdate,
  });

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate>
    with WidgetsBindingObserver {
  bool _checking = false;
  DateTime? _lastCheck;
  String? _dismissedVersion;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (_checking || _dialogShowing || !mounted) return;
    final now = DateTime.now();
    if (_lastCheck != null &&
        now.difference(_lastCheck!) < const Duration(minutes: 5)) return;
    _checking = true;
    try {
      final updateInfo = await widget.checkForUpdate();
      if (!mounted) return;
      // Failed requests can be retried on the next resume.
      if (updateInfo != null) _lastCheck = now;
      if (updateInfo == null || !updateInfo.updateAvailable) return;
      if (!updateInfo.forceUpdate &&
          updateInfo.latestVersion == _dismissedVersion) return;
      await _showUpdateDialog(updateInfo);
    } catch (_) {
      // Version checks must not interrupt normal app use.
    } finally {
      _checking = false;
    }
  }

  Future<void> _showUpdateDialog(AppUpdateInfo updateInfo) async {
    final dialogContext = widget.navigatorKey.currentState?.overlay?.context;
    if (_dialogShowing || !mounted || dialogContext == null) return;
    _dialogShowing = true;

    await showDialog<void>(
      context: dialogContext,
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

    if (!updateInfo.forceUpdate) {
      _dismissedVersion = updateInfo.latestVersion;
    }
    _dialogShowing = false;
  }

  Future<void> _openStore(String storeUrl) async {
    try {
      final uri = Uri.tryParse(storeUrl);
      if (uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Keep the update prompt open so the user can retry.
    }
    final messengerContext = widget.navigatorKey.currentContext;
    if (!mounted || messengerContext == null || !messengerContext.mounted) {
      return;
    }
    ScaffoldMessenger.of(messengerContext).showSnackBar(
      const SnackBar(
          content: Text('Unable to open the store. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
