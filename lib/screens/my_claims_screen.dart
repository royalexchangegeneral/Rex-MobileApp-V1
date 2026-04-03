import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/policy_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'new_claims_screen.dart';
import 'new_policy_screen.dart';
import 'my_policies_screen.dart';

class MyClaimsScreen extends StatefulWidget {
  final bool isAgentFlow;
  const MyClaimsScreen({super.key, this.isAgentFlow = false});

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'In Progress', 'Approved', 'Completed'];

  String _getClaimStatus(Map<String, dynamic> c) {
    return c['ClaimStatus']?.toString() ?? c['Status']?.toString() ?? 'Pending';
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('complet') || s.contains('settled')) return Colors.green;
    if (s.contains('progress') || s.contains('process')) return const Color(0xFFE8923E);
    if (s.contains('approv')) return Colors.green;
    if (s.contains('reject') || s.contains('denied')) return Colors.red;
    return Colors.grey;
  }

  List<Map<String, dynamic>> _filteredClaims(List<Map<String, dynamic>> claims) {
    if (_selectedFilter == 0) return claims;
    final filterLabel = _filters[_selectedFilter].toLowerCase();
    return claims.where((c) {
      final status = _getClaimStatus(c).toLowerCase();
      return status.contains(filterLabel.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PolicyProvider>(builder: (context, pp, _) {
      final allClaims = pp.claims;
      final filtered = _filteredClaims(allClaims);
      final approvedCount = allClaims.where((c) {
        final s = _getClaimStatus(c).toLowerCase();
        return s.contains('approv') || s.contains('complet') || s.contains('settled');
      }).length;
      final inProgressCount = allClaims.where((c) {
        final s = _getClaimStatus(c).toLowerCase();
        return s.contains('progress') || s.contains('process') || s.contains('pending');
      }).length;

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
        body: Stack(
          children: [
            SingleChildScrollView(
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
                        Text('${allClaims.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                    Text('Approved', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.8))),
                                    const SizedBox(height: 4),
                                    Text('$approvedCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('In Progress', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.8))),
                                    const SizedBox(height: 4),
                                    Text('$inProgressCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

                  // Claims header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Claims', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                      TextButton(
                        onPressed: () => setState(() => _selectedFilter = 0),
                        child: const Text('View All', style: TextStyle(fontSize: 11, color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (pp.loading)
                    const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(child: Text('No claims found', style: TextStyle(color: Colors.grey[500], fontSize: 12))),
                    )
                  else
                    ...filtered.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildClaimCard(c),
                    )),

                  const SizedBox(height: 100),
                ],
              ),
            ),
            // New claim FAB
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewClaimsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.edit_note_outlined, color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: widget.isAgentFlow ? null : SizedBox(
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
        bottomNavigationBar: widget.isAgentFlow ? buildAgentBottomNav(context, currentIndex: 0) : BottomAppBar(
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
                _buildNavItem(Icons.description_outlined, 'Policies', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPoliciesScreen()));
                }),
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
    });
  }

  Widget _buildClaimCard(Map<String, dynamic> c) {
    final claimId = c['ClaimID']?.toString() ?? '';
    final claimType = c['ClaimType']?.toString() ?? c['PolicyClass']?.toString() ?? 'Claim';
    final status = _getClaimStatus(c);
    final statusColor = _getStatusColor(status);
    final claimAmount = c['ClaimAmount']?.toString() ?? c['Amount']?.toString() ?? '';
    final dateFiled = c['ClaimDate']?.toString() ?? c['DateFiled']?.toString() ?? c['CreatedDate']?.toString() ?? '';
    final policyNo = c['PolicyNo']?.toString() ?? c['PolicyID']?.toString() ?? '';
    final insured = c['Insured']?.toString() ?? c['ClaimantName']?.toString() ?? '';
    final isCompleted = status.toLowerCase().contains('complet') || status.toLowerCase().contains('settled');

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D64).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_outlined, color: Color(0xFF1E2D64), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claimType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 2),
                    if (insured.isNotEmpty) Text(insured, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('Claim #$claimId', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claimAmount.isNotEmpty ? 'Claim Amount' : 'Policy No', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(claimAmount.isNotEmpty ? '₦$claimAmount' : policyNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date Filed', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(dateFiled.isNotEmpty ? dateFiled : 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Status', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(isCompleted ? 'Completed' : status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
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
