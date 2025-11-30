import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'private_motor_details_screen.dart';

class VehicleInformationScreen extends StatefulWidget {
  const VehicleInformationScreen({super.key});

  @override
  State<VehicleInformationScreen> createState() =>
      _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNumberController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;

  @override
  void dispose() {
    _regNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_regNumberController.text.isEmpty) {
      return;
    }

    // Start verifying
    setState(() {
      _isVerifying = true;
    });

    // Simulate verification process
    await Future.delayed(const Duration(seconds: 2));

    // Show verified state
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });

    // Wait a moment then navigate to summary
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PrivateMotorDetailsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Private Car',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Step 2 of 3',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reg Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _regNumberController,
                      decoration: InputDecoration(
                        hintText: 'enter your reg. no.',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primaryNavy),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying || _isVerified ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isVerified ? Colors.green : AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: _isVerifying 
                          ? AppTheme.primaryNavy.withOpacity(0.7)
                          : Colors.green,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: _isVerifying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Verifying RegNo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : _isVerified
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Registration No Verified',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
