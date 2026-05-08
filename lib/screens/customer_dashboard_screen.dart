import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'new_policy_screen.dart';
import 'new_claims_screen.dart';
import 'policy_details_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'faq_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'discover_insurance_screen.dart';
import 'claims_process_screen.dart';
import 'my_certificate_screen.dart';
import 'payments_screen.dart';
import 'my_policies_screen.dart';
import 'notifications_screen.dart';
import '../providers/notifications_provider.dart';
import '../providers/policy_provider.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});
  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _drawerSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false)
          .fetchNotifications(context);
      Provider.of<PolicyProvider>(context, listen: false)
          .fetchPolicies(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.menu,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        title: Image.asset(
          'assets/images/image 4.png',
          height: 22,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('rex',
                  style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(' insurance',
                  style: TextStyle(color: AppTheme.primaryNavy, fontSize: 12)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, child) => Stack(children: [
              IconButton(
                  icon: Icon(Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()))
                      .then((_) => notifProvider.fetchNotifications(context))),
              if (notifProvider.unreadCount > 0)
                Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text('${notifProvider.unreadCount}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)))),
            ]),
          ),
        ],
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
                decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<PolicyProvider>(
                                  builder: (_, pp, __) => Text(
                                      '${pp.activePolicies}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold))),
                              Text('Active Policies',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ]),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyPoliciesScreen())),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10)),
                          child: const Text('View Policies',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickAction(
                            Icons.description_outlined, 'New\nPolicies',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NewPolicyScreen()))),
                        _buildQuickAction(
                            Icons.assignment_outlined, 'New\nClaims',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NewClaimsScreen()))),
                        _buildQuickAction(
                            Icons.cloud_download_outlined, 'View\nCertificate',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MyCertificateScreen()))),
                        _buildQuickAction(Icons.payment_outlined, '\nPayments',
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PaymentsScreen()))),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // My Policies Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Policies',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyPoliciesScreen())),
                      child: const Text('View All',
                          style: TextStyle(
                              color: AppTheme.accentOrange,
                              fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 12),
              // Policy Cards from API
              Consumer<PolicyProvider>(builder: (_, pp, __) {
                if (pp.loading)
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()));
                if (pp.policies.isEmpty)
                  return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                          child: Text('No policies found',
                              style: TextStyle(color: Colors.grey[500]))));
                final displayPolicies = pp.policies.take(3).toList();
                return Column(
                    children: displayPolicies.map((p) {
                  final isActive = p['status'] == 'Active';
                  final icon = p['policyClass']
                          .toString()
                          .toLowerCase()
                          .contains('motor')
                      ? Icons.directions_car
                      : p['policyClass']
                              .toString()
                              .toLowerCase()
                              .contains('shop')
                          ? Icons.store
                          : p['policyClass']
                                  .toString()
                                  .toLowerCase()
                                  .contains('personal')
                              ? Icons.person
                              : Icons.description;
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPolicyCard(
                        '${p['policyClass']} Insurance',
                        'Policy #${p['policyId']}',
                        p['endDate'] ?? '',
                        icon,
                        const Color(0xFF1A3A5C),
                        isActive ? 'Active' : 'Expired',
                        isActive ? Colors.green : Colors.grey,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PolicyDetailsScreen(
                                    policyType: '${p['policyClass']} Insurance',
                                    policyNumber: p['policyId'] ?? '',
                                    policyData: p))),
                      ));
                }).toList());
              }),
              SizedBox(height: 24),
              // My Claims Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Claims',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyClaimsScreen())),
                      child: const Text('View All',
                          style: TextStyle(
                              color: AppTheme.accentOrange,
                              fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<PolicyProvider>(builder: (_, pp, __) {
                if (pp.loading)
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator()));
                if (pp.claims.isEmpty)
                  return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                          child: Text('No claims found',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12))));
                final displayClaims = pp.claims.take(3).toList();
                return Column(
                    children: displayClaims.map((c) {
                  final claimId = c['ClaimID']?.toString() ?? '';
                  final claimType = c['ClaimType']?.toString() ??
                      c['PolicyClass']?.toString() ??
                      'Claim';
                  final claimStatus = c['ClaimStatus']?.toString() ??
                      c['Status']?.toString() ??
                      'Pending';
                  final statusColor = claimStatus
                              .toLowerCase()
                              .contains('complet') ||
                          claimStatus.toLowerCase().contains('settled')
                      ? Colors.green
                      : claimStatus.toLowerCase().contains('progress') ||
                              claimStatus.toLowerCase().contains('process')
                          ? const Color(0xFFFF9800)
                          : claimStatus.toLowerCase().contains('reject') ||
                                  claimStatus.toLowerCase().contains('denied')
                              ? Colors.red
                              : Colors.grey;
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildClaimCard(
                        claimType,
                        'Claim #$claimId',
                        Icons.assignment_outlined,
                        const Color(0xFF1A3A5C),
                        claimStatus,
                        statusColor,
                      ));
                }).toList());
              }),
              SizedBox(height: 24),
              // Discover Insurance
              Text('Discover Insurance',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),
              _buildDiscoverCard(
                  'Insurance Basics',
                  'Learn the basic of insurance',
                  Icons.school_outlined,
                  const Color(0xFF4A90D9),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DiscoverInsuranceScreen()))),
              const SizedBox(height: 12),
              // _buildDiscoverCard('Tips & Guides', 'Learn the fundamentals', Icons.lightbulb_outline, const Color(0xFFFFB74D)),
              // const SizedBox(height: 12),
              _buildDiscoverCard('Claims Process', 'Get step-by-step guidance',
                  Icons.chat_bubble_outline, const Color(0xFFE91E63),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClaimsProcessScreen()))),
              const SizedBox(height: 12),
              _buildDiscoverCard('FAQ', 'Get answers to questions',
                  Icons.help_outline, const Color(0xFFFFB74D),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FaqScreen()))),
              const SizedBox(height: 24),
              // Request Agent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: ThemeHelper.getCardColor(context),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.support_agent, color: AppTheme.primaryNavy),
                      SizedBox(width: 8),
                      Text('Request Agent',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy))
                    ]),
                    const SizedBox(height: 8),
                    Text('Need a personal insurance agent?',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () => _callAgent(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Request Now')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
            backgroundColor: AppTheme.accentOrange,
            shape: const CircleBorder(),
            elevation: 1,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.description_outlined, 'Policies', 1),
              const SizedBox(width: 48),
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
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 10, height: 1.3),
                textAlign: TextAlign.center,
                maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(String title, String policyNumber, String renewalDate,
      IconData icon, Color iconColor, String status, Color statusColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: ThemeHelper.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          children: [
            Row(children: [
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: iconColor, size: 20)),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    Text(policyNumber,
                        style: TextStyle(
                            fontSize: 10,
                            color: ThemeHelper.getSecondaryTextColor(context))),
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Text('Renewal Date',
                  style: TextStyle(
                      fontSize: 10,
                      color: ThemeHelper.getSecondaryTextColor(context))),
              const Spacer(),
              Text(renewalDate,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange))
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimCard(String title, String claimNumber, IconData icon,
      Color iconColor, String status, Color statusColor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: ThemeHelper.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20)),
        SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          Text(claimNumber,
              style: TextStyle(
                  fontSize: 10,
                  color: ThemeHelper.getSecondaryTextColor(context))),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Text(status,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildDiscoverCard(
      String title, String subtitle, IconData icon, Color iconColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: ThemeHelper.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!)),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 20)),
          SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10,
                        color: ThemeHelper.getSecondaryTextColor(context))),
              ])),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ]),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MyPoliciesScreen()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
            color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ]),
    );
  }

  Future<void> _callAgent() async {
    final uri = Uri(scheme: 'tel', path: '+2347080606100');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showPhoneNumberDialog();
      }
    } catch (_) {
      if (mounted) _showPhoneNumberDialog();
    }
  }

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call Agent',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('+234 708 0606 100',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
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
            color: AppTheme.primaryNavy,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.person, color: AppTheme.primaryNavy, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 3),
              children: [
                _buildDrawerItem(Icons.home_outlined, 'Home', 0),
                _buildDrawerItem(Icons.people_outline, 'My Policies', 1),
                _buildDrawerItem(Icons.add_circle_outline, 'Buy Insurance', 2),
                _buildDrawerItem(Icons.assignment_outlined, 'Make a Claim', 3),
                // _buildDrawerItem(Icons.share_outlined, 'Refer a Friend', 4),
                _buildDrawerItem(Icons.help_outline, 'FAQ', 5),
                _buildDrawerItem(Icons.phone_outlined, 'Call your Agent', 6),
                _buildDrawerItem(Icons.logout, 'Log Out', 7, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index,
      {bool isLogout = false}) {
    final isSelected = _drawerSelectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color:
            isSelected && !isLogout ? AppTheme.primaryNavy : Colors.transparent,
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
                  : AppTheme.primaryNavy,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red
                : isSelected
                    ? Colors.white
                    : AppTheme.primaryNavy,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: isSelected || isLogout
            ? null
            : Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          if (isLogout) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (ctx) => const LoginScreen()),
              (route) => false,
            );
          } else {
            setState(() => _drawerSelectedIndex = index);
            Navigator.pop(context);
            if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyPoliciesScreen()));
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NewPolicyScreen()));
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NewClaimsScreen()));
            } else if (index == 5) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()));
            } else if (index == 6) {
              _callAgent();
            }
          }
        },
      ),
    );
  }
}
