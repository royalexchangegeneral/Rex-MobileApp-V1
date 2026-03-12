import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

class ExistingPolicyQuestionScreen extends StatefulWidget {
  const ExistingPolicyQuestionScreen({super.key});

  @override
  State<ExistingPolicyQuestionScreen> createState() => _ExistingPolicyQuestionScreenState();
}

class _ExistingPolicyQuestionScreenState extends State<ExistingPolicyQuestionScreen> {
  String? _selectedOption;

  void _handleContinue() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    if (_selectedOption == 'yes') {
      Navigator.pushNamed(context, '/enter-policy-details');
    } else {
      Navigator.pushNamed(context, '/get-covered');
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: SvgPicture.asset(
              'assets/icons/loginicon.svg',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              const Text(
                'Do You Have An Existing Insurance Policy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'If you have an existing policy, we will link it to your account for easy access',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Yes Option
              GestureDetector(
                onTap: () => setState(() => _selectedOption = 'yes'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedOption == 'yes' ? AppTheme.primaryBlue : Colors.grey[300]!,
                      width: _selectedOption == 'yes' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedOption == 'yes' ? AppTheme.primaryBlue : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedOption == 'yes'
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // No Option
              GestureDetector(
                onTap: () => setState(() => _selectedOption = 'no'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedOption == 'no' ? AppTheme.primaryBlue : Colors.grey[300]!,
                      width: _selectedOption == 'no' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedOption == 'no' ? AppTheme.primaryBlue : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedOption == 'no'
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Need Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: AppTheme.primaryNavy, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Not sure what to buy?, do you need assistance choosing, customizing, or purchasing a new insurance policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Click here for advice.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
