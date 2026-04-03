import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_service.dart';
import '../utils/app_theme.dart';
import 'agent_dashboard_screen.dart';
import 'clients_list_screen.dart';
import 'reports_screen.dart';
import 'agent_profile_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorAuth = false;
  bool _biometricLogin = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isEnabled();
    if (mounted) setState(() { _biometricAvailable = available; _biometricLogin = enabled; });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Need stored credentials to enable — check if they exist
      final hasCreds = await BiometricService.hasStoredCredentials();
      if (!hasCreds) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login with your password first to enable biometric login'), backgroundColor: Colors.orange));
        }
        return;
      }
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        // Re-enable with existing stored creds
        final creds = await BiometricService.getCredentials();
        if (creds != null) {
          await BiometricService.enable(creds['email']!, creds['password']!);
          setState(() => _biometricLogin = true);
        }
      }
    } else {
      await BiometricService.disable();
      setState(() => _biometricLogin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Security Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Protected',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your account is protected with two-factor authentication and regular security checks',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Two-Factor Authentication
            _buildSecurityItem(
              icon: Icons.key,
              iconColor: const Color(0xFF1E2D64),
              iconBgColor: const Color(0xFF1E2D64).withValues(alpha: 0.1),
              title: 'Two-Factor Authentication',
              subtitle: 'Enabled - Authentication app',
              hasToggle: true,
              toggleValue: _twoFactorAuth,
              onToggleChanged: (value) {
                setState(() {
                  _twoFactorAuth = value;
                });
              },
            ),
            
            const SizedBox(height: 12),
            
            // Password
            _buildSecurityItem(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF1E2D64),
              iconBgColor: const Color(0xFF1E2D64).withValues(alpha: 0.1),
              title: 'Password',
              subtitle: 'Last changed 30 days ago',
              actionText: 'Change',
              onActionTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            // Biometric Login
            _buildSecurityItem(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF1E2D64),
              iconBgColor: const Color(0xFF1E2D64).withValues(alpha: 0.1),
              title: 'Biometric Login',
              subtitle: _biometricLogin ? 'Enabled - Fingerprint / Face ID' : 'Use fingerprint and Face ID to login',
              hasToggle: true,
              toggleValue: _biometricLogin,
              onToggleChanged: _biometricAvailable ? (value) => _toggleBiometric(value) : null,
            ),
            
            const SizedBox(height: 32),
            
            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Activity Items
            _buildActivityItem(
              icon: Icons.phone_iphone,
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.withValues(alpha: 0.1),
              title: 'New Device Login',
              subtitle: 'Iphone 14 Pro . New york',
              time: '2h ago',
            ),
            
            const SizedBox(height: 12),
            
            _buildActivityItem(
              icon: Icons.shield_outlined,
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.withValues(alpha: 0.1),
              title: 'Automatic Check',
              subtitle: 'Security Check Completed',
              time: '5 days ago',
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Provider.of<AuthProvider>(context, listen: false).isCustomer()
          ? SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
                backgroundColor: AppTheme.accentOrange,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isAgent = Provider.of<AuthProvider>(context, listen: false).isAgent();
    
    if (isAgent) {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AgentDashboardScreen()), (route) => false);
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsListScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 22), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined, size: 22), label: 'Policy'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline, size: 22), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined, size: 22), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 22), label: 'Profile'),
        ],
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCustomerNavItem(Icons.home_outlined, 'Home', false, () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
            }),
            _buildCustomerNavItem(Icons.description_outlined, 'Policies', false, () {}),
            const SizedBox(width: 40),
            _buildCustomerNavItem(Icons.assignment_outlined, 'Claims', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
            }),
            _buildCustomerNavItem(Icons.person_outline, 'Profile', true, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
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

  Widget _buildSecurityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    bool hasToggle = false,
    bool toggleValue = false,
    ValueChanged<bool>? onToggleChanged,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (hasToggle)
            Switch(
              value: toggleValue,
              onChanged: onToggleChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF1E2D64),
            ),
          if (actionText != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.4,
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
