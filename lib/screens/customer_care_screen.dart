import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({super.key});

  @override
  State<CustomerCareScreen> createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Customer Care', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search help',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                suffixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),
            
            // Select Issue Category
            const Text('Select Issue Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            
            _buildCategoryCard(
              icon: Icons.headset_mic_outlined,
              iconBgColor: const Color(0xFFE8F4FD),
              iconColor: const Color(0xFF4A90D9),
              title: 'Service Request',
              subtitle: 'General service inquiries',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            
            _buildCategoryCard(
              icon: Icons.description_outlined,
              iconBgColor: const Color(0xFFFFF5E6),
              iconColor: const Color(0xFFFFB74D),
              title: 'Policy Endorsement',
              subtitle: 'Policy alterations & changes',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            
            _buildCategoryCard(
              icon: Icons.warning_outlined,
              iconBgColor: const Color(0xFFFFF5F5),
              iconColor: const Color(0xFFFF6B6B),
              title: 'Complaint',
              subtitle: 'File a formal complaint',
              onTap: () {},
            ),
            const SizedBox(height: 32),
            
            // Recent Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View all', style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTicketCard(
              ticketNumber: '#TK001223',
              title: 'Claim status update',
              timeAgo: 'Created 25 mins ago',
              status: 'Open',
              statusColor: const Color(0xFFB8860B),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            
            _buildTicketCard(
              ticketNumber: '#TK001234',
              title: 'Policy premium inquiry',
              timeAgo: 'Created 2 days ago',
              status: 'Pending',
              statusColor: const Color(0xFFFFB74D),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            
            _buildTicketCard(
              ticketNumber: '#TK001223',
              title: 'Claim status update',
              timeAgo: 'Created 6 days ago',
              status: 'Resolved',
              statusColor: Colors.green,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            
            _buildTicketCard(
              ticketNumber: '#TK001223',
              title: 'Claim status update',
              timeAgo: 'Created 6 days ago',
              status: 'Resolved',
              statusColor: Colors.green,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            
            // Create New Ticket Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Create New Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppTheme.accentOrange,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false),
              _buildNavItem(Icons.description_outlined, 'Policies', false),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_outlined, 'Claims', false),
              _buildNavItem(Icons.person_outline, 'Profile', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required String ticketNumber,
    required String title,
    required String timeAgo,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticketNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ],
    );
  }
}