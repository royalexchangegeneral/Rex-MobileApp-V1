import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/policy_provider.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'policy_details_screen.dart';

class MyPoliciesScreen extends StatefulWidget {
  const MyPoliciesScreen({super.key});

  @override
  State<MyPoliciesScreen> createState() => _MyPoliciesScreenState();
}

class _MyPoliciesScreenState extends State<MyPoliciesScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Renewal', 'Active', 'Expired'];
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> get _policies {
    final pp = Provider.of<PolicyProvider>(context, listen: false);
    return pp.policies.map((p) {
      final isActive = p['status'] == 'Active';
      final isExpired = p['status'] == 'Expired';
      return {
        'title': p['policyClass'] ?? '',
        'vehicle': p['insured'] ?? '',
        'policyNo': 'Policy #${p['policyId'] ?? ''}',
        'status': p['status'] ?? 'Unknown',
        'statusColor': isActive ? Colors.green : isExpired ? Colors.grey : Colors.red,
        'renewalLabel': isExpired ? 'Expired on' : 'Renewal',
        'renewalDate': p['endDate'] ?? '',
        'premium': '₦${p['premium'] ?? '0'} / yearly',
        'rawData': p,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredPolicies {
    final query = _searchController.text.toLowerCase().trim();
    var policies = _policies;

    // Filter by tab
    if (_selectedFilter == 1) {
      policies = policies.where((p) => p['status'] == 'Expired').toList();
    } else if (_selectedFilter == 2) {
      policies = policies.where((p) => p['status'] == 'Active').toList();
    } else if (_selectedFilter == 3) {
      policies = policies.where((p) => p['status'] == 'Expired').toList();
    }

    // Search
    if (query.isNotEmpty) {
      policies = policies.where((p) {
        final text = '${p['title']} ${p['policyNo']} ${p['vehicle']}'.toLowerCase();
        return text.contains(query);
      }).toList();
    }
    return policies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policies = _filteredPolicies;
    final activeCount = _policies.where((p) => p['status'] == 'Active').length;
    final renewalCount = _policies.where((p) => p['status'] == 'Renewal Due').length;
    final expiredCount = _policies.where((p) => p['status'] == 'Expired').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Policies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                _buildSummaryCard('$activeCount', 'Active', Icons.description_outlined, Colors.green),
                const SizedBox(width: 10),
                _buildSummaryCard('$renewalCount', 'Due for Renewal', Icons.access_time, AppTheme.accentOrange),
                const SizedBox(width: 10),
                _buildSummaryCard('$expiredCount', 'Expired', Icons.error_outline, Colors.red),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search with policy number',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryNavy : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isSelected ? AppTheme.primaryNavy : Colors.grey[300]!),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Policy cards
            ...List.generate(policies.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index < policies.length - 1 ? 14 : 0),
                child: _buildPolicyCard(policies[index]),
              );
            }),
            const SizedBox(height: 100),
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

  Widget _buildSummaryCard(String count, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 6),
            Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(Map<String, dynamic> policy) {
    final isRenewal = policy['status'] == 'Renewal Due';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined, color: AppTheme.primaryNavy, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(policy['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 2),
                    Text(policy['vehicle'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    Text(policy['policyNo'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (policy['statusColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(policy['status'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: policy['statusColor'])),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dates row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(policy['renewalLabel'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(
                      policy['renewalDate'],
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isRenewal ? Colors.red : AppTheme.accentOrange),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Premium', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(policy['premium'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // View Details button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PolicyDetailsScreen(
                policyType: policy['title'],
                policyNumber: policy['policyNo'].replaceAll('Policy #', ''),
                policyData: policy['rawData'] as Map<String, dynamic>?,
              ))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
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

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
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
