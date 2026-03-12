import 'package:flutter/material.dart';
import 'new_policy_screen.dart';
import 'select_client_screen.dart';

class BuyNewPolicyScreen extends StatelessWidget {
  const BuyNewPolicyScreen({super.key});

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
          'Buy New Policy',
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
              'Who Are You Buying For?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
              onTap: () {
                // Contact support action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contacting support...')),
                );
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
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
                      color: Colors.black,
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
