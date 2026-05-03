import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/agent_policy_provider.dart';
import '../providers/notifications_provider.dart';
import 'select_client_type_screen.dart';
import 'buy_new_policy_screen.dart';
import 'clients_list_screen.dart';
import 'agent_profile_screen.dart';
import 'reports_screen.dart';
import 'agent_policies_screen.dart';
import 'policy_details_screen.dart';
import 'notifications_screen.dart';
import 'my_claims_screen.dart';
import 'new_claims_screen.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  String _selectedPeriod = 'this_month';
  final Map<String, String> _periodLabels = {
    'today': 'Today',
    'this_week': 'This Week',
    'this_month': 'This Month',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AgentPolicyProvider>(context, listen: false).fetchAgentPolicies(context);
      Provider.of<AgentPolicyProvider>(context, listen: false).fetchCustomerCount(context);
      Provider.of<AgentPolicyProvider>(context, listen: false).fetchCommission(context);
      Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          height: 32,
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, child) => Stack(children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen(isAgentFlow: true))).then((_) => notifProvider.fetchNotifications(context)),
              ),
              if (notifProvider.unreadCount > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('${notifProvider.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
            ]),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commission Card with Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2D64), Color(0xFF2A3F7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Commission amount and dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Consumer<AgentPolicyProvider>(builder: (_, ap, __) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₦${ap.commission}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              const Text('Commission', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          );
                        }),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() => _selectedPeriod = value);
                          Provider.of<AgentPolicyProvider>(context, listen: false).fetchCommission(context, period: value);
                        },
                        itemBuilder: (_) => _periodLabels.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)))).toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_periodLabels[_selectedPeriod] ?? 'This Month', style: const TextStyle(fontSize: 11, color: Colors.white)),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Consumer<AgentPolicyProvider>(builder: (_, ap, __) => _buildStatItem('${ap.totalClients}', 'Total Client'))),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Expanded(child: _buildStatItem('0', 'Pending Claims')),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Expanded(child: Consumer<AgentPolicyProvider>(builder: (_, ap, __) => _buildStatItem('${ap.activePolicies}', 'Active Policies'))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Access
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    'Add Client',
                    Icons.person_add_outlined,
                    const Color(0xFF1E2D64),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectClientTypeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    'New Policy',
                    Icons.add_circle_outline,
                    const Color(0xFF1E2D64),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyNewPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    'File a Claim',
                    Icons.assignment_outlined,
                    const Color(0xFF1E2D64),
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NewClaimsScreen(isAgentFlow: true)));
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // My Policies
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Policies',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentPoliciesScreen())),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Policy List from API
            Consumer<AgentPolicyProvider>(builder: (_, ap, __) {
              if (ap.loading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              if (ap.policies.isEmpty) return Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No policies found', style: TextStyle(color: Colors.grey[500], fontSize: 12))));
              final sortedPolicies = List<Map<String, dynamic>>.from(ap.policies);
              sortedPolicies.sort((a, b) {
                final dateA = DateTime.tryParse(a['startDate']?.toString() ?? '') ?? DateTime(1900);
                final dateB = DateTime.tryParse(b['startDate']?.toString() ?? '') ?? DateTime(1900);
                return dateB.compareTo(dateA); // most recent first
              });
              final displayPolicies = sortedPolicies.take(5).toList();
              return Column(children: displayPolicies.map((p) {
                final isActive = p['status'] == 'Active';
                final policyClass = p['policyClass']?.toString() ?? '';
                final icon = policyClass.toLowerCase().contains('motor') || policyClass.toLowerCase().contains('comprehensive') ? Icons.directions_car_outlined
                  : policyClass.toLowerCase().contains('shop') ? Icons.store_outlined
                  : policyClass.toLowerCase().contains('home') ? Icons.home_outlined
                  : policyClass.toLowerCase().contains('personal') ? Icons.person_outline
                  : policyClass.toLowerCase().contains('family') ? Icons.family_restroom_outlined
                  : policyClass.toLowerCase().contains('student') ? Icons.school_outlined
                  : policyClass.toLowerCase().contains('parcel') ? Icons.local_shipping_outlined
                  : policyClass.toLowerCase().contains('driver') ? Icons.two_wheeler_outlined
                  : Icons.description_outlined;
                return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildPolicyItem(
                  context,
                  '$policyClass Insurance',
                  'Policy #${p['policyId']}',
                  p['endDate'] ?? '',
                  isActive ? 'Active' : 'Expired',
                  icon,
                  isActive ? const Color(0xFF4CAF50) : Colors.grey,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PolicyDetailsScreen(
                    policyType: '$policyClass Insurance',
                    policyNumber: p['policyId']?.toString() ?? '',
                    policyData: p,
                    isAgentFlow: true,
                  ))),
                ));
              }).toList());
            }),
            
            const SizedBox(height: 24),
            
            // Policy Analytics
            const Text(
              'Policy Analytics',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Chart Container
            Consumer<AgentPolicyProvider>(builder: (_, ap, __) {
              final monthData = ap.getPolicyCountsByMonth();
              final labels = monthData.keys.toList();
              final values = monthData.values.toList();
              final maxVal = values.isEmpty ? 1.0 : (values.reduce((a, b) => a > b ? a : b)).toDouble();
              final yMax = maxVal < 5 ? 5.0 : maxVal;
              final dataPoints = values.map((v) => v.toDouble()).toList();

              return Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${yMax.toInt()}', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                                Text('${(yMax * 0.75).toInt()}', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                                Text('${(yMax * 0.5).toInt()}', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                                Text('${(yMax * 0.25).toInt()}', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                                Text('0', style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomPaint(
                              painter: LineChartPainter(dataPoints, maxValue: yMax),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 38),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: labels.map((m) => Text(m, style: TextStyle(fontSize: 9, color: Colors.grey[600]))).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            // Recent Notifications
            const Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Consumer<NotificationsProvider>(builder: (_, notifProvider, __) {
              if (notifProvider.loading) return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
              if (notifProvider.notifications.isEmpty) return Padding(padding: const EdgeInsets.all(12), child: Center(child: Text('No notifications', style: TextStyle(color: Colors.grey[500], fontSize: 12))));
              final displayNotifs = notifProvider.notifications.take(4).toList();
              return Column(children: displayNotifs.map((n) {
                final title = n['title']?.toString() ?? '';
                final desc = n['description']?.toString() ?? n['message']?.toString() ?? '';
                final time = n['created_at']?.toString() ?? '';
                final isRead = notifProvider.readIds.contains(n['id']);
                return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildActivityItem(
                  context, title, desc, time,
                  isRead ? Icons.check_circle : Icons.notifications_outlined,
                  isRead ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                ));
              }).toList());
            }),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AgentPoliciesScreen(),
              ),
            );
          } else if (index == 2) {
            // Navigate to Clients screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClientsListScreen(),
              ),
            );
          } else if (index == 3) {
            // Navigate to Reports screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportsScreen(),
              ),
            );
          } else if (index == 4) {
            // Navigate to Profile screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AgentProfileScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Policy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(
    BuildContext context,
    String title,
    String policyNumber,
    String renewalDate,
    String status,
    IconData icon,
    Color statusColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D64).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E2D64), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  policyNumber,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Renewal Date',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                renewalDate,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
  
  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';
    final userEmail = authProvider.userEmail ?? 'user@example.com';
    
    return Drawer(
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2D64),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 3),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_outline,
                  title: 'All Customers',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientsListScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Policies',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentPoliciesScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Claims',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen(isAgentFlow: true)));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.trending_up,
                  title: 'Reports',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Log Out',
                  isLogout: true,
                  onTap: () {
                    Navigator.pop(context);
                    // Add logout logic here
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/user-portal',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isLogout = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E2D64) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : const Color(0xFF1E2D64)),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isLogout
                ? Colors.red
                : isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1E2D64)),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildActivityItem(
    BuildContext context,
    String name,
    String activity,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double maxValue;
  
  LineChartPainter(this.dataPoints, {this.maxValue = 1000.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;
    
    final paint = Paint()
      ..color = const Color(0xFF1E2D64)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fill gradient
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x331E2D64), Color(0x001E2D64)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (dataPoints.length - 1);
    final effectiveMax = maxValue == 0 ? 1.0 : maxValue;
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (dataPoints[i] / effectiveMax * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = const Color(0xFF1E2D64)..style = PaintingStyle.fill;
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (dataPoints[i] / effectiveMax * size.height);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
