import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'signup_screen.dart';
import '../utils/app_theme.dart';

class ExistingPolicyQuestionScreen extends StatefulWidget {
  const ExistingPolicyQuestionScreen({super.key});

  @override
  State<ExistingPolicyQuestionScreen> createState() =>
      _ExistingPolicyQuestionScreenState();
}

class _ExistingPolicyQuestionScreenState
    extends State<ExistingPolicyQuestionScreen> {
  String? _selectedOption;
  final bool _isCreating = false;

  Future<void> _handleContinue() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an option')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_signup_flow', true);

    if (_selectedOption == 'yes') {
      await prefs.setBool('has_existing_policy', true);
      if (mounted) {
        Navigator.pushNamed(context, '/verify-phone', arguments: '');
      }
    } else {
      await prefs.setBool('has_existing_policy', false);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignupScreen(
              nextRoute: '/verify-phone',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    const selectedColor = AppTheme.primaryBlue;
    final cardColor = isDark ? const Color(0xFF121826) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3A455A) : Colors.grey[300]!;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    final radioBorderColor =
        isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final helpBackgroundColor =
        isDark ? const Color(0xFF111827) : const Color(0xFFE3F2FD);
    final helpBorderColor =
        isDark ? const Color(0xFF2F3B52) : const Color(0xFFE3F2FD);
    final helpTitleColor =
        isDark ? const Color(0xFFA7C7FF) : AppTheme.primaryNavy;
    final adviceLinkColor =
        isDark ? AppTheme.accentOrange : selectedColor;
    const buttonForegroundColor = Colors.white;
    final disabledButtonColor = AppTheme.disabledButtonColor(context);
    final disabledButtonTextColor = AppTheme.disabledButtonTextColor(context);
    final canContinue = _selectedOption != null && !_isCreating;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                'Do You Have An Existing Insurance Policy?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'If you have an existing policy, we will link it to your account for easy access',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
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
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedOption == 'yes'
                          ? selectedColor
                          : borderColor,
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
                            color: _selectedOption == 'yes'
                                ? selectedColor
                                : radioBorderColor,
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
                                    color: selectedColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
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
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _selectedOption == 'no' ? selectedColor : borderColor,
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
                            color: _selectedOption == 'no'
                                ? selectedColor
                                : radioBorderColor,
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
                                    color: selectedColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Need Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: helpBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: helpBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline,
                            color: helpTitleColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: helpTitleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Not sure what to buy?, do you need assistance choosing, customizing, or purchasing a new insurance policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'tel', path: '+2347080606100');
                        try {
                          final launched = await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                          if (!launched && context.mounted) {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: const Text('Contact Support',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      content: const Text('+234 708 0606 100',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        } catch (_) {
                          if (context.mounted) {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: const Text('Contact Support',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      content: const Text('+234 708 0606 100',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        }
                      },
                      child: Text(
                        'Click here for advice.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: adviceLinkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Semantics(
                  button: true,
                  enabled: canContinue,
                  child: GestureDetector(
                    onTap: canContinue ? _handleContinue : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            canContinue ? selectedColor : disabledButtonColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: canContinue
                              ? Colors.transparent
                              : isDark
                                  ? const Color(0xFFE2E8F0)
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: buttonForegroundColor, strokeWidth: 2))
                          : Text('Continue',
                              style: TextStyle(
                                  color: canContinue
                                      ? buttonForegroundColor
                                      : disabledButtonTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
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
