import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/agent_policy_provider.dart';
import 'agent_dashboard_screen.dart';
import 'agent_profile_screen.dart';
import 'clients_list_screen.dart';
import 'reports_screen.dart';
import 'policy_details_screen.dart';

class AgentPoliciesScreen extends StatefulWidget {
  const AgentPoliciesScreen({super.key});

  @override
  State<AgentPoliciesScreen> createState() => _AgentPoliciesScreenState();
}

class _AgentPoliciesScreenState extends State<AgentPoliciesScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Active', 'Expired'];
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredPolicies {
    final ap = Provider.of<AgentPolicyProvider>(context, listen: false);
    var policies = ap.policies;

    if (_selectedFilter == 1) {
      policies = policies.where((p) => p['status'] == 'Active').toList();
    } else if (_selectedFilter == 2) {
      policies = policies.where((p) => p['status'] == 'Expired').toList();
    }

    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      policies = policies.where((p) {
        final text = '${p['policyClass']} ${p['policyId']} ${p['insured']} ${p['customerName']}'.toLowerCase();
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
    return Consumer<AgentPolicyProvider>(builder: (context, ap, _) {
      final policies = _filteredPolicies;
      final activeCount = ap.policies.where((p) => p['status'] == 'Active').length;
      final expiredCount = ap.policies.where((p) => p['status'] == 'Expired').length;

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('My Policies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
                  _buildSummaryCard('${ap.policies.length}', 'Total', Icons.description_outlined, AppTheme.primaryNavy),
                  const SizedBox(width: 10),
                  _buildSummaryCard('$activeCount', 'Active', Icons.check_circle_outline, Colors.green),
                  const SizedBox(width: 10),
                  _buildSummaryCard('$expiredCount', 'Expired', Icons.error_outline, Colors.red),
                ],
              ),
              SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search by policy number, client name...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
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

              if (ap.loading)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
              else if (policies.isEmpty)
                Padding(padding: const EdgeInsets.all(30), child: Center(child: Text('No policies found', style: TextStyle(color: Colors.grey[500], fontSize: 12))))
              else
                ...policies.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildPolicyCard(p),
                )),

              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1E2D64),
          unselectedItemColor: Colors.grey,
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AgentDashboardScreen()), (r) => false);
            if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsListScreen()));
            if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentProfileScreen()));
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Policy'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clients'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      );
    });
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

  Widget _buildPolicyCard(Map<String, dynamic> p) {
    final isActive = p['status'] == 'Active';
    final statusColor = isActive ? Colors.green : Colors.grey;
    final policyClass = p['policyClass']?.toString() ?? '';

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.description_outlined, color: AppTheme.primaryNavy, size: 18),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$policyClass Insurance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 2),
                    Text(p['customerName']?.toString() ?? '', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    Text('Policy #${p['policyId']}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(p['status'] ?? 'Unknown', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
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
                    Text(isActive ? 'Renewal' : 'Expired on', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(p['endDate']?.toString() ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? AppTheme.accentOrange : Colors.red)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Premium', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    SizedBox(height: 2),
                    Text('₦${p['premium'] ?? '0'} / yearly', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PolicyDetailsScreen(
                policyType: '$policyClass Insurance',
                policyNumber: p['policyId']?.toString() ?? '',
                policyData: p,
                isAgentFlow: true,
              ))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.accentOrange : AppTheme.primaryNavy,
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
}
