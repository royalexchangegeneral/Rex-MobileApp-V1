import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'create_password_screen.dart';
import 'customer_dashboard_screen.dart';
import 'agent_dashboard_screen.dart';

class PolicyPurchaseSuccessScreen extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAgent;
  final String? reference;
  final String? message;
  final Map<String, String> accountData;
  const PolicyPurchaseSuccessScreen({
    super.key,
    this.isLoggedIn = false,
    this.isAgent = false,
    this.reference,
    this.message,
    this.accountData = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Success message
              Text(
                'Your policy has been\nsuccessfully purchased',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              // Reference ID
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  children: [
                    const TextSpan(text: 'Reference ID: '),
                    TextSpan(
                      text: reference != null ? '#$reference' : '#REX-000000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Backend message
              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                      height: 1.4),
                ),

              const SizedBox(height: 24),

              // Info text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'A copy of your certificate has been emailed to you.\nYou can also click ',
                    ),
                    TextSpan(
                      text: 'here',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' to download it.\nYou can also view, download, or share it later from\nthe Policy Details page.',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Homepage button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLoggedIn) {
                      if (isAgent) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AgentDashboardScreen()),
                            (route) => false);
                      } else {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerDashboardScreen()),
                            (route) => false);
                      }
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/user-portal', (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Homepage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Create Account button (only for non-logged-in users)
              if (!isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePasswordScreen(
                            createLoginWithApi: true,
                            accountData: {
                              ...accountData,
                              'reference': reference ?? '',
                            },
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(
                          color: AppTheme.primaryNavy, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Do you want to create an account?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
