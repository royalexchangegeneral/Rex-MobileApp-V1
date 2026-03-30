import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'new_claims_screen.dart';
import 'help_support_screen.dart';
import 'service_request_screen.dart';
import 'policy_renewal_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class PolicyDetailsScreen extends StatelessWidget {
  final String policyType;
  final String policyNumber;
  
  const PolicyDetailsScreen({
    super.key,
    required this.policyType,
    required this.policyNumber,
  });

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
        title: const Text('Policy Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Third Party Insurance', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('Policy #FIR-2025-089', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              SizedBox(height: 2),
                              Text('Apr 12, 2025', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Date', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              SizedBox(height: 2),
                              Text('Apr 11, 2026', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
            
            // Quick Actions
            Row(
              children: [
                Expanded(child: _buildQuickAction(Icons.refresh, 'Renew Policy', const Color(0xFFE8F4FD), const Color(0xFF4A90D9), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PolicyRenewalScreen(policyType: policyType, policyNumber: policyNumber))))),
                Expanded(child: _buildQuickAction(Icons.edit_document, 'Update Policy', const Color(0xFFFFF5E6), const Color(0xFFFFB74D), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRequestScreen())))),
                Expanded(child: _buildQuickAction(Icons.assignment, 'File Claim', const Color(0xFFF3E8FF), const Color(0xFF9C27B0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewClaimsScreen(policyNumber: policyNumber))))),
                Expanded(child: _buildQuickAction(Icons.headset_mic, 'Support', const Color(0xFFE8F4FD), const Color(0xFF4A90D9), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())))),
              ],
            ),
            const SizedBox(height: 24),
            
            // Vehicle Information
            const Text('Vehicle Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Reg No.', 'GGE801CQ'),
                  _buildInfoRow('VIN', '1HGCMBB2633A123456'),
                  _buildInfoRow('Vehicle Type', 'Toyota Corolla'),
                  _buildInfoRow('Vehicle Make', 'Toyota'),
                  _buildInfoRow('Vehicle Model', 'Corolla'),
                  _buildInfoRow('Vehicle Color', 'Silver'),
                  _buildInfoRow('Engine Number', '2024'),
                  _buildInfoRow('Year', '2024'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Coverage Details
            const Text('Coverage Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildCoverageItem('Collision Cover', 'Covers damage to your car', 'N345,000'),
                  const SizedBox(height: 12),
                  _buildCoverageItem('Liability Coverage', 'Covers damage to others', 'N345,000'),
                  const SizedBox(height: 12),
                  _buildCoverageItem('Personal Injury', 'Medical expenses coverage', 'N345,000'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Documents
            const Text('Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDocumentItem('Policy Document', Icons.picture_as_pdf, Colors.red),
                  const SizedBox(height: 10),
                  _buildDocumentItem('Insurance form', Icons.picture_as_pdf, Colors.red),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Talk to an Agent
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.headset_mic, color: AppTheme.primaryNavy, size: 18),
                      SizedBox(width: 6),
                      Text('Talk to an Agent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Akoke Ayorinde', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text('+234 905 8395 885', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text('Call Now', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewClaimsScreen(policyNumber: policyNumber))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('File a claim', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description, size: 14),
                label: const Text('View Certificate', style: TextStyle(fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryNavy,
                  side: const BorderSide(color: AppTheme.primaryNavy),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
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
              _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
              }),
              _buildNavItem(Icons.description_outlined, 'Policies', true),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_outlined, 'Claims', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
              }),
              _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildCoverageItem(String title, String subtitle, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDocumentItem(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.black)),
        ),
        const Icon(Icons.download, color: AppTheme.accentOrange, size: 18),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 18),
          Text(label, style: TextStyle(fontSize: 9, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
        ],
      ),
    );
  }
}