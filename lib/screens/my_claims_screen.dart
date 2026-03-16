import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'new_claims_screen.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({super.key});

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'In progress', 'Approved', 'Completed'];

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
        title: const Text('My Claims', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D64),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('N43,450', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Total Claims', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('Approved claims', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 4),
                              const Text('4', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
                        Expanded(
                          child: Column(
                            children: [
                              Text('In Progress', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 4),
                              const Text('12', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filter chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E2D64) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isSelected ? const Color(0xFF1E2D64) : Colors.grey[300]!),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // My Claims header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Claims', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(fontSize: 11, color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Claim cards
            _buildClaimCard(
              title: 'Third-Party Claim',
              vehicle: 'Honda Civic 2022',
              claimNumber: 'Claim #CL-2024-001',
              status: 'In Progress',
              statusColor: const Color(0xFFE8923E),
              claimAmount: 'N540,000',
              dateFiled: 'Dec 18, 2024',
              estPayout: 'N231,950',
              estPayoutColor: const Color(0xFFE8923E),
              showViewDetails: true,
            ),

            const SizedBox(height: 14),

            _buildClaimCard(
              title: 'Third-Party Claim',
              vehicle: 'Honda Civic 2022',
              claimNumber: 'Claim #CL-2024-001',
              status: 'Completed',
              statusColor: Colors.grey,
              claimAmount: 'N540,000',
              dateFiled: 'Dec 18, 2024',
              estPayout: 'Approved',
              estPayoutColor: Colors.green,
              showViewDetails: true,
              showApprovedIcon: false,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewClaimsScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.edit_note_outlined, color: Colors.white, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
              }),
              _buildNavItem(Icons.description_outlined, 'Policies', false, () {}),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_outlined, 'Claims', true, () {}),
              _buildNavItem(Icons.person_outline, 'Profile', false, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimCard({
    required String title,
    required String vehicle,
    required String claimNumber,
    required String status,
    required Color statusColor,
    required String claimAmount,
    required String dateFiled,
    required String estPayout,
    required Color estPayoutColor,
    bool showViewDetails = false,
    bool showApprovedIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D64).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_outlined, color: Color(0xFF1E2D64), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 2),
                    Text(vehicle, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text(claimNumber, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              if (showApprovedIcon) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppTheme.accentOrange, size: 16),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claim Amount', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(claimAmount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(showApprovedIcon ? 'Completed' : 'Date Filed', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(dateFiled, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(showApprovedIcon ? 'Approved' : 'Est. Payout', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(estPayout, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: estPayoutColor)),
                  ],
                ),
              ),
            ],
          ),

          if (showViewDetails) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2D64),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
        ],
      ),
    );
  }
}
