import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/session_cache_cleaner.dart';
import '../providers/theme_provider.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'customer_dashboard_screen.dart';
import 'my_claims_screen.dart';
import 'my_policies_screen.dart';
import 'new_policy_screen.dart';
import 'help_support_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardColor => _isDark ? const Color(0xFF111827) : Colors.white;

  Color get _borderColor =>
      _isDark ? const Color(0xFF334155) : Colors.grey[200]!;

  Color get _secondaryTextColor =>
      _isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color get _brandActionColor =>
      _isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

  @override
  void initState() {
    super.initState();
    // Ensure auth state is loaded from SharedPreferences if userData is null
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userData == null && auth.isAuthenticated) {
        auth.checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    // Try all key variants the API may return
    final firstName = userData?['FirstName']?.toString() ??
        userData?['Firstname']?.toString() ??
        userData?['firstname']?.toString() ??
        '';
    final surname = userData?['LastName']?.toString() ??
        userData?['Lastname']?.toString() ??
        userData?['Surname']?.toString() ??
        userData?['lastname']?.toString() ??
        '';
    final email =
        userData?['Email']?.toString() ?? userData?['email']?.toString() ?? '';
    final phone = userData?['Phone']?.toString() ??
        userData?['MobileNo']?.toString() ??
        userData?['PhoneNo']?.toString() ??
        userData?['PhoneNumber']?.toString() ??
        userData?['mobileno']?.toString() ??
        '';

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
        title: Text('Profile',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile avatar and name
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        _isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                    child: Icon(Icons.person,
                        size: 44,
                        color: _isDark
                            ? const Color(0xFF94A3B8)
                            : Colors.grey[400]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$firstName $surname',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Referral banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A4F8F), Color(0xFF1E2D64)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Invite a friend and both\nearn points',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.4),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Refer Now',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Personal Information',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem(context, 'First Name', firstName,
                      showDivider: false),
                  _buildInfoItem(context, 'Last Name', surname,
                      showDivider: false),
                  Divider(
                      color: _borderColor,
                      height: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildInfoItem(context, 'Email Address', email),
                  _buildInfoItem(context, 'Phone Number', phone,
                      showDivider: false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Settings',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    Icons.notifications_outlined,
                    'Notification Settings',
                    const Color(0xFFFFF3E0),
                    const Color(0xFFE8923E),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const NotificationSettingsScreen())),
                  ),
                  Divider(
                      color: _borderColor,
                      height: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildSettingsItem(
                    context,
                    Icons.verified_user_outlined,
                    'Security Settings',
                    const Color(0xFFE8EAF6),
                    const Color(0xFF1E2D64),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SecuritySettingsScreen())),
                  ),
                  Divider(
                      color: _borderColor,
                      height: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildSettingsItemWithToggle(
                    context,
                    Icons.dark_mode_outlined,
                    'Dark Theme',
                    const Color(0xFFE8EAF6),
                    const Color(0xFF1E2D64),
                  ),
                  Divider(
                      color: _borderColor,
                      height: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildSettingsItem(
                    context,
                    Icons.help_outline,
                    'Help and support',
                    const Color(0xFFE8EAF6),
                    const Color(0xFF1E2D64),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen())),
                  ),
                ],
              ),
            ),

            // Log out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                    child:
                        const Icon(Icons.logout, color: Colors.red, size: 20),
                  ),
                  title: const Text('Log out',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.red)),
                  onTap: () async {
                    clearSessionCaches(context);
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
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
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.bottomNavBackgroundColor(context),
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_outlined, 'Home', false,
                  onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CustomerDashboardScreen()),
                    (route) => false);
              }),
              _buildNavItem(
                  context, Icons.description_outlined, 'Policies', false,
                  onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyPoliciesScreen()));
              }),
              const SizedBox(width: 48),
              _buildNavItem(context, Icons.assignment_outlined, 'Claims', false,
                  onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
              }),
              _buildNavItem(context, Icons.person_outline, 'Profile', true,
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value,
      {bool showDivider = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(fontSize: 11, color: _secondaryTextColor)),
          const SizedBox(height: 4),
          Text(value.isNotEmpty ? value : '-',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          if (showDivider) Divider(color: _borderColor, height: 1),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title,
      Color bgColor, Color iconColor,
      {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemWithToggle(BuildContext context, IconData icon,
      String title, Color bgColor, Color iconColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = MediaQuery.of(context).platformBrightness;
    final isEffectivelyDark = themeProvider.isSystemMode
        ? brightness == Brightness.dark
        : themeProvider.isDarkMode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface)),
      subtitle: Text(
        themeProvider.isSystemMode
            ? 'Following system'
            : (isEffectivelyDark ? 'Dark' : 'Light'),
        style: TextStyle(fontSize: 10, color: _secondaryTextColor),
      ),
      trailing: Switch(
        value: isEffectivelyDark,
        onChanged: (val) => themeProvider.setTheme(val),
        activeThumbColor: Colors.white,
        activeTrackColor: _brandActionColor,
      ),
      onLongPress: () {
        themeProvider.useSystemTheme();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Theme set to follow system'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2)),
        );
      },
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected,
      {required VoidCallback onTap}) {
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
}
