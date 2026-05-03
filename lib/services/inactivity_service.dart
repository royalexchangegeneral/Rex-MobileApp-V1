import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Monitors user inactivity and triggers auto-logout after a timeout period.
/// Wraps the app's widget tree to detect taps, scrolls, and other gestures.
class InactivityService extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback? onTimeout;

  const InactivityService({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 5),
    this.onTimeout,
  });

  @override
  State<InactivityService> createState() => InactivityServiceState();

  /// Access the service from anywhere in the widget tree.
  static InactivityServiceState? of(BuildContext context) {
    return context.findAncestorStateOfType<InactivityServiceState>();
  }
}

class InactivityServiceState extends State<InactivityService> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetTimer();
    } else if (state == AppLifecycleState.paused) {
      // Keep timer running when app is backgrounded — if it expires, logout on resume
    }
  }

  /// Reset the inactivity timer. Called on every user interaction.
  void _resetTimer() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      _timer?.cancel();
      return;
    }

    _timer?.cancel();
    _timer = Timer(widget.timeout, _handleTimeout);
  }

  /// Called when the inactivity timeout expires.
  void _handleTimeout() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;

    if (widget.onTimeout != null) {
      widget.onTimeout!();
    } else {
      _performAutoLogout();
    }
  }

  /// Perform the auto-logout and navigate to login.
  void _performAutoLogout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();

    if (!mounted) return;

    // Show session expired dialog then navigate to login
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Session Expired', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'You have been logged out due to inactivity. Please log in again to continue.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Manually pause the timer (e.g., during payment WebView).
  void pauseTimer() {
    _timer?.cancel();
  }

  /// Manually resume the timer.
  void resumeTimer() {
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      onScaleStart: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
