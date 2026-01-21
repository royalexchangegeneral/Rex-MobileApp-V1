import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'new_policy_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});
  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _drawerSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        title: Image.asset(
          'assets/images/image 4.png',
          height: 22,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('rex', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(' insurance', style: TextStyle(color: AppTheme.primaryNavy, fontSize: 12)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('320', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          Text('Active Policies', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ]),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                          child: const Text('View Policies', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickAction(Icons.description_outlined, 'New\nPolicies', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen()))),
                        _buildQuickAction(Icons.assignment_outlined, 'New\nClaims', onTap: () {}),
                        _buildQuickAction(Icons.cloud_download_outlined, 'View\nCertificate', onTap: () {}),
                        _buildQuickAction(Icons.payment_outlined, '\nPayments', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // My Policies Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Policies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 12),
              // Policy Cards
              _buildPolicyCard('Motor Insurance', 'Policy #MOT-2025-089', '28 May, 2025', Icons.directions_car, const Color(0xFF1A3A5C), 'Active', Colors.green),
              const SizedBox(height: 12),
              _buildPolicyCard('Fire Insurance', 'Policy #FIR-2025-089', '28 May, 2025', Icons.local_fire_department, const Color(0xFFFF6B6B), 'Active', Colors.green),
              const SizedBox(height: 12),
              _buildPolicyCard('Marine Insurance', 'Policy #AUT-2025-089', '28 May, 2025', Icons.directions_boat, const Color(0xFF1A3A5C), 'Active', Colors.green),
              const SizedBox(height: 24),
              // My Claims Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Claims', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 12),
              _buildClaimCard('Third-party Claim', 'Claim #CLM-2025-089', Icons.directions_car, const Color(0xFF1A3A5C), 'In Progress', const Color(0xFFFF9800)),
              const SizedBox(height: 12),
              _buildClaimCard('Personal Accident', 'Claim #CLM-2025-089', Icons.directions_car, const Color(0xFF1A3A5C), 'Completed', Colors.green),
              const SizedBox(height: 24),
              // Discover Insurance
              const Text('Discover Insurance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 16),
              _buildDiscoverCard('Insurance Basics', 'Learn the basic of insurance', Icons.school_outlined, const Color(0xFF4A90D9)),
              const SizedBox(height: 12),
              _buildDiscoverCard('Tips & Guides', 'Learn the fundamentals', Icons.lightbulb_outline, const Color(0xFFFFB74D)),
              const SizedBox(height: 12),
              _buildDiscoverCard('Claims Process', 'Get step-by-step guidance', Icons.chat_bubble_outline, const Color(0xFFE91E63)),
              const SizedBox(height: 12),
              _buildDiscoverCard('FAQ', 'Get answers to questions', Icons.help_outline, const Color(0xFFFFB74D)),
              const SizedBox(height: 24),
              // Request Agent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF3F8FF), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.support_agent, color: AppTheme.primaryNavy), const SizedBox(width: 8), const Text('Request Agent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy))]),
                    const SizedBox(height: 8),
                    const Text('Need a personal insurance agent?', style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Request Now')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.description_outlined, 'Policies', 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_outlined, 'Claims', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.3), textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(String title, String policyNumber, String renewalDate, IconData icon, Color iconColor, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(policyNumber, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 6),
          Row(children: [Text('Renewal Date', style: TextStyle(fontSize: 10, color: Colors.grey[600])), const Spacer(), Text(renewalDate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accentOrange))]),
        ],
      ),
    );
  }

  Widget _buildClaimCard(String title, String claimNumber, IconData icon, Color iconColor, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(claimNumber, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildDiscoverCard(String title, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ])),
        Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      ]),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ]),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: AppTheme.primaryNavy,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppTheme.primaryNavy, size: 30),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Aderomi Abaranje', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('aaderonmi@example.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home_outlined, 'Home', 0),
                _buildDrawerItem(Icons.people_outline, 'My Policies', 1),
                _buildDrawerItem(Icons.add_circle_outline, 'Buy Insurance', 2),
                _buildDrawerItem(Icons.assignment_outlined, 'Make a Claim', 3),
                _buildDrawerItem(Icons.share_outlined, 'Refer a Friend', 4),
                _buildDrawerItem(Icons.help_outline, 'FAQ', 5),
                _buildDrawerItem(Icons.phone_outlined, 'Call your Agent', 6),
              ],
            ),
          ),
          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) => const LoginScreen()), (route) => false);
              },
              child: Row(
                children: const [
                  Icon(Icons.logout, color: AppTheme.primaryNavy),
                  SizedBox(width: 16),
                  Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryNavy)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _drawerSelectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : AppTheme.primaryNavy),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryNavy, fontWeight: FontWeight.w500)),
        trailing: isSelected ? null : Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          setState(() => _drawerSelectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
