import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/biometric_service.dart';
import '../providers/notifications_provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
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
  bool _biometricLogin = false;
  bool _biometricAvailable = false;

  Color get _actionColor => Theme.of(context).brightness == Brightness.dark
      ? AppTheme.accentOrange
      : AppTheme.primaryNavy;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricLogin = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final auth = context.read<AuthProvider>();
      final hasLogin = await BiometricService.hasStoredLogin();
      if (!hasLogin) {
        if (auth.isAuthenticated && (auth.loginEmail?.isNotEmpty ?? false)) {
          await BiometricService.enable(auth.loginEmail!);
          if (!mounted) return;
          setState(() => _biometricLogin = true);
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Please login with your password first to enable biometric verification'),
              backgroundColor: Colors.orange));
        }
        return;
      }
      final authenticated = await BiometricService.authenticate();
      if (authenticated) {
        final email = await BiometricService.getStoredEmail();
        if (email != null) {
          await BiometricService.enable(email);
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
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Security Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                      color: ThemeHelper.getSecondaryTextColor(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hidden for now: Two-Factor Authentication and Password cards.

            // Biometric Login
            _buildSecurityItem(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF1E2D64),
              iconBgColor: const Color(0xFF1E2D64).withValues(alpha: 0.1),
              title: 'Biometric Login',
              subtitle: _biometricLogin
                  ? 'Enabled - Fingerprint / Face ID'
                  : 'Use fingerprint and Face ID to verify login',
              hasToggle: true,
              toggleValue: _biometricLogin,
              onToggleChanged: _biometricAvailable
                  ? (value) => _toggleBiometric(value)
                  : null,
            ),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Activity Items from API
            Consumer<NotificationsProvider>(builder: (_, notifProvider, __) {
              if (notifProvider.loading) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator()));
              }
              if (notifProvider.notifications.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                        child: Text('No recent activity',
                            style: TextStyle(
                                color:
                                    ThemeHelper.getSecondaryTextColor(context),
                                fontSize: 12))));
              }
              final items = notifProvider.notifications.take(3).toList();
              return Column(
                  children: items.map((n) {
                final title = n['title']?.toString() ?? '';
                final desc = n['description']?.toString() ??
                    n['message']?.toString() ??
                    '';
                final time = n['created_at']?.toString() ?? '';
                final isRead = notifProvider.readIds.contains(n['id']);
                return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildActivityItem(
                      icon: isRead
                          ? Icons.shield_outlined
                          : Icons.notifications_outlined,
                      iconColor: isRead ? Colors.green : Colors.blue,
                      iconBgColor: isRead
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      title: title,
                      subtitle: desc,
                      time: time,
                    ));
              }).toList());
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Provider.of<AuthProvider>(context, listen: false)
              .isCustomer()
          ? Transform.translate(
              offset: const Offset(0, 15),
              child: SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewPolicyScreen())),
                  backgroundColor: AppTheme.accentOrange,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
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
        selectedItemColor: AppTheme.bottomNavSelectedColor(context),
        unselectedItemColor: AppTheme.bottomNavUnselectedColor(context),
        currentIndex: 4,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AgentDashboardScreen()),
                (route) => false);
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ClientsListScreen()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AgentProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 22), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined, size: 22),
              label: 'Policy'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline, size: 22), label: 'Clients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined, size: 22), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 22), label: 'Profile'),
        ],
      );
    }

    return BottomAppBar(
      color: AppTheme.bottomNavBackgroundColor(context),
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCustomerNavItem(Icons.home_outlined, 'Home', false, () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CustomerDashboardScreen()),
                  (route) => false);
            }),
            _buildCustomerNavItem(
                Icons.description_outlined, 'Policies', false, () {}),
            const SizedBox(width: 48),
            _buildCustomerNavItem(Icons.assignment_outlined, 'Claims', false,
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
            }),
            _buildCustomerNavItem(Icons.person_outline, 'Profile', true, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CustomerProfileScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerNavItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected
                  ? AppTheme.bottomNavSelectedColor(context)
                  : AppTheme.bottomNavUnselectedColor(context),
              size: 20),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? AppTheme.bottomNavSelectedColor(context)
                      : AppTheme.bottomNavUnselectedColor(context))),
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
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeHelper.getSecondaryTextColor(context),
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
              activeTrackColor: _actionColor,
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
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeHelper.getSecondaryTextColor(context),
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
              color: ThemeHelper.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
