import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
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
  final Map<String, dynamic>? policyData;
  final bool isAgentFlow;
  
  const PolicyDetailsScreen({
    super.key,
    required this.policyType,
    required this.policyNumber,
    this.policyData,
    this.isAgentFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = policyData;
    final status = data?['status']?.toString() ?? 'Unknown';
    final isActive = status == 'Active';
    final startDate = data?['startDate']?.toString() ?? '';
    final endDate = data?['endDate']?.toString() ?? '';
    final policyClass = data?['policyClass']?.toString() ?? policyType;
    final policyId = data?['policyId']?.toString() ?? policyNumber;
    final premium = data?['premium']?.toString() ?? '';
    final insured = data?['insured']?.toString() ?? '';
    final sumInsured = data?['sumInsured']?.toString() ?? '';
    final customerName = data?['customerName']?.toString() ?? '';

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
        actions: const [],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(_getPolicyIcon(policyClass), color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(policyClass, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('Policy #$policyId', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(startDate, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(endDate, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                Expanded(child: _buildQuickAction(Icons.refresh, 'Renew Policy', const Color(0xFFE8F4FD), const Color(0xFF4A90D9), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PolicyRenewalScreen(policyType: policyType, policyNumber: policyNumber, isAgentFlow: isAgentFlow))))),
                Expanded(child: _buildQuickAction(Icons.edit_document, 'Update Policy', const Color(0xFFFFF5E6), const Color(0xFFFFB74D), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceRequestScreen(isAgentFlow: isAgentFlow))))),
                Expanded(child: _buildQuickAction(Icons.assignment, 'File Claim', const Color(0xFFF3E8FF), const Color(0xFF9C27B0), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewClaimsScreen(policyNumber: policyNumber, isAgentFlow: isAgentFlow))))),
                Expanded(child: _buildQuickAction(Icons.headset_mic, 'Support', const Color(0xFFE8F4FD), const Color(0xFF4A90D9), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpSupportScreen(isAgentFlow: isAgentFlow))))),
              ],
            ),
            const SizedBox(height: 24),
            
            // Policy Details section (was Vehicle Information)
            const Text('Policy Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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
                  _buildInfoRow('Policy ID', policyId),
                  _buildInfoRow('Policy Class', policyClass),
                  _buildInfoRow('Status', status),
                  _buildInfoRow('Insured', insured),
                  if (customerName.isNotEmpty) _buildInfoRow('Customer Name', customerName),
                  _buildInfoRow('Premium', premium.isNotEmpty ? '₦$premium' : 'N/A'),
                  _buildInfoRow('Sum Insured', sumInsured.isNotEmpty ? '₦$sumInsured' : 'N/A'),
                  _buildInfoRow('Start Date', startDate),
                  _buildInfoRow('End Date', endDate),
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
                            const Text('Rex Support', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text('+234 708 0606 100', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _callSupport(context),
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewClaimsScreen(policyNumber: policyNumber, isAgentFlow: isAgentFlow))),
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
      floatingActionButton: isAgentFlow ? null : SizedBox(
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
      bottomNavigationBar: isAgentFlow
        ? buildAgentBottomNav(context, currentIndex: 1)
        : BottomAppBar(
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

  IconData _getPolicyIcon(String policyClass) {
    final lower = policyClass.toLowerCase();
    if (lower.contains('motor') || lower.contains('car') || lower.contains('vehicle')) return Icons.directions_car;
    if (lower.contains('shop')) return Icons.store;
    if (lower.contains('home') || lower.contains('house')) return Icons.home;
    if (lower.contains('personal')) return Icons.person;
    if (lower.contains('student')) return Icons.school;
    if (lower.contains('parcel')) return Icons.local_shipping;
    if (lower.contains('driver') || lower.contains('rider')) return Icons.two_wheeler;
    return Icons.description;
  }

  static Future<void> _callSupport(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '+2347080606100');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Call Rex Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Call Rex Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    }
  }

  Widget _buildQuickAction(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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
          Flexible(child: Text(value.isNotEmpty ? value : 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.black))),
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
