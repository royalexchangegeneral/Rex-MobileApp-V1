import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      duration: const Duration(milliseconds: 1250),
      vsync: this,
    )..repeat();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
    ]).animate(_logoController);

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _logoController.forward();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _ringController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAFA),
      body: SafeArea(
        child: Center(
          child: SizedBox.square(
            dimension: 104,
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LaunchRingPainter(progress: _ringController.value),
                  child: child,
                );
              },
              child: Center(
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/icons/loginicon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LaunchRingPainter extends CustomPainter {
  const _LaunchRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = (progress * math.pi * 2) - math.pi / 2;
    const sweep = math.pi * 1.52;

    final trackPaint = Paint()
      ..color = const Color(0xFFECE9E8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final navyPaint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final orangePaint = Paint()
      ..color = AppTheme.accentOrange
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(rect, startAngle, sweep * 0.5, false, navyPaint);
    canvas.drawArc(
        rect, startAngle + sweep * 0.5, sweep * 0.5, false, orangePaint);
  }

  @override
  bool shouldRepaint(covariant _LaunchRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
