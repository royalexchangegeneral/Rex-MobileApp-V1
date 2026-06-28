import 'package:flutter/material.dart';
import '../widgets/agent_bottom_nav.dart';
import 'add_client_screen.dart';
import 'add_corporate_client_screen.dart';

class SelectClientTypeScreen extends StatelessWidget {
  const SelectClientTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

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
          'Add A New Client',
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
              'Select Client Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the type of client you want to onboard to get started with the right process',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Individual Client Card
            _buildClientTypeCard(
              context,
              icon: Icons.person_outline,
              iconColor: const Color(0xFF2196F3),
              iconBgColor: const Color(0xFFE3F2FD),
              title: 'Individual Client',
              description:
                  'For onboarding a single customer looking to purchase a personal insurance policy.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AddClientScreen(clientType: 'individual'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Corporate Client Card
            _buildClientTypeCard(
              context,
              icon: Icons.business_center_outlined,
              iconColor: const Color(0xFFFF9800),
              iconBgColor: const Color(0xFFFFF3E0),
              title: 'Corporate Client',
              description:
                  'Select this if you\'re onboarding a business, organization, or group entity.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCorporateClientScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildAgentBottomNav(context, currentIndex: 2),
    );
  }

  Widget _buildClientTypeCard(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
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
