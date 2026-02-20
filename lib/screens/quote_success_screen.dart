import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class QuoteSuccessScreen extends StatefulWidget {
  const QuoteSuccessScreen({super.key});

  @override
  State<QuoteSuccessScreen> createState() => _QuoteSuccessScreenState();
}

class _QuoteSuccessScreenState extends State<QuoteSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate back to Underwritten Products screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Pop twice: first to close success screen, then to close quote form
        Navigator.of(context).pop(); // Close success screen
        Navigator.of(context).pop(); // Close quote form, return to underwritten products
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quote Request Received',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for your submission.\nA representative will contact you shortly\nwith next steps.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}