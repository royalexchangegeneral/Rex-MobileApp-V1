import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/session_cache_cleaner.dart';

/// Monitors user inactivity and triggers auto-logout after a timeout period.
/// Wraps the app's widget tree to detect taps, scrolls, and other gestures.
class InactivityService extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback? onTimeout;
  final GlobalKey<NavigatorState>? navigatorKey;

  const InactivityService({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 3),
    this.onTimeout,
    this.navigatorKey,
  });

  @override
  State<InactivityService> createState() => InactivityServiceState();

  /// Access the service from anywhere in the widget tree.
  static InactivityServiceState? of(BuildContext context) {
    return context.findAncestorStateOfType<InactivityServiceState>();
  }
}

class InactivityServiceState extends State<InactivityService>
    with WidgetsBindingObserver {
  Timer? _timer;
  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = Provider.of<AuthProvider>(context, listen: false);
    _auth?.addListener(_authStateListener);
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _auth?.removeListener(_authStateListener);
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

  void _authStateListener() {
    if (_auth?.isAuthenticated ?? false) {
      _resetTimer();
    } else {
      _timer?.cancel();
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
    debugPrint('Inactivity timer reset');
  }

  /// Called when the inactivity timeout expires.
  void _handleTimeout() {
    debugPrint('Inactivity timeout triggered');
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
    debugPrint('Performing auto-logout');
    clearSessionCaches(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();

    if (!mounted) return;

    // Show session expired dialog then navigate to login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Showing logout dialog');
      if (!mounted) return;
      final navigatorContext = widget.navigatorKey?.currentContext;
      if (navigatorContext == null) {
        debugPrint('No navigator context available for logout dialog');
        return;
      }
      showDialog(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.timer_off, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Session Expired',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'You have been logged out due to inactivity. Please log in again to continue.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('Navigating to login');
                Navigator.of(ctx).pop();
                Navigator.of(navigatorContext, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Log In',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    });
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
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _resetTimer,
        onPanDown: (_) => _resetTimer(),
        onScaleStart: (_) => _resetTimer(),
        child: widget.child,
      ),
    );
  }
}
