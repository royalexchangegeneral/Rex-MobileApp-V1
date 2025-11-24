import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class VerificationSuccessScreen extends StatefulWidget {
  const VerificationSuccessScreen({super.key});

  @override
  State<VerificationSuccessScreen> createState() => _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to identity verification after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/identity-verification');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Verification Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your phone number has been successfully\nverified',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
