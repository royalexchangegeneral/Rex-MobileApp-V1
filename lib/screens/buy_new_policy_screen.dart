import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
import 'new_policy_screen.dart';
import 'select_client_screen.dart';

class BuyNewPolicyScreen extends StatelessWidget {
  const BuyNewPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    final agentAccent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buy New Policy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who Are You Buying For?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose one to continue',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 24),

            // For Myself Card
            _buildOptionCard(
              context,
              icon: Icons.person_outline,
              iconColor: agentAccent,
              iconBgColor: agentAccent.withValues(alpha: 0.12),
              title: 'For Myself',
              description:
                  'Purchase a new insurance policy for your own coverage',
              onTap: () {
                // Navigate to policy selection for self
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewPolicyScreen(isAgent: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // For a Client Card
            _buildOptionCard(
              context,
              icon: Icons.people_outline,
              iconColor: agentAccent,
              iconBgColor: agentAccent.withValues(alpha: 0.12),
              title: 'For a Client',
              description:
                  'Add insurance coverage for one of your registered clients',
              onTap: () {
                // Navigate to client selection
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectClientScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Help text
            InkWell(
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
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: secondaryTextColor),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                        children: [
                          const TextSpan(text: 'Need help choosing? '),
                          TextSpan(
                            text: 'Contact support',
                            style: TextStyle(
                              color: agentAccent,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: buildAgentBottomNav(context, currentIndex: 1),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
