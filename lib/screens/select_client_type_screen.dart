import 'package:flutter/material.dart';
import 'add_client_screen.dart';
import 'add_corporate_client_screen.dart';

class SelectClientTypeScreen extends StatelessWidget {
  const SelectClientTypeScreen({super.key});

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
          'Add A New Client',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Client Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the type of client you want to onboard to get started with the right process',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
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
              description: 'For onboarding a single customer looking to purchase a personal insurance policy.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddClientScreen(clientType: 'individual'),
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
              description: 'Select this if you\'re onboarding a business, organization, or group entity.',
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        selectedFontSize: 11,
        unselectedFontSize: 11,
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

  Widget _buildClientTypeCard(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
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
