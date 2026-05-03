import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'new_policy_screen.dart';
import 'select_client_screen.dart';
import 'agent_dashboard_screen.dart';
import 'clients_list_screen.dart';
import 'reports_screen.dart';
import 'agent_profile_screen.dart';

class BuyNewPolicyScreen extends StatelessWidget {
  const BuyNewPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buy New Policy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
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
            const Text(
              'Who Are You Buying For?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose one to continue',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // For Myself Card
            _buildOptionCard(
              context,
              icon: Icons.person_outline,
              iconColor: const Color(0xFF1E2D64),
              iconBgColor: const Color(0xFFE8EAF6),
              title: 'For Myself',
              description: 'Purchase a new insurance policy for your own coverage',
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
              iconColor: const Color(0xFF1E2D64),
              iconBgColor: const Color(0xFFE8EAF6),
              title: 'For a Client',
              description: 'Add insurance coverage for one of your registered clients',
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
                  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!launched && context.mounted) {
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: const Text('Contact Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                    ));
                  }
                } catch (_) {
                  if (context.mounted) {
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: const Text('Contact Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
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
                    Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        children: const [
                          TextSpan(text: 'Need help choosing? '),
                          TextSpan(
                            text: 'Contact support',
                            style: TextStyle(
                              color: Color(0xFF1E2D64),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AgentDashboardScreen()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClientsListScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportsScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AgentProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined, size: 22),
            label: 'Policy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 22),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, size: 22),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 22),
            label: 'Profile',
          ),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
