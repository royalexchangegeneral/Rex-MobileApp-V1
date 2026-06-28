import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/session_cache_cleaner.dart';
import '../providers/agent_policy_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
import 'login_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'help_support_screen.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;

    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'Agent Name';
    final userEmail = authProvider.userEmail ?? 'agent@example.com';
    final userCode = authProvider.userCode ?? 'AG0000';
    final userData = authProvider.userData ?? {};

    // Extract data from userData
    final custType = userData['CustType'] ?? 'Senior Insurance Agent';
    final address = userData['Address'] ?? 'Downtown Branch, Lagos';
    final phone = userData['MobileNo'] ?? '+1 (555) 123-4567';

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
          'Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Profile Header with overlapping stats card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D64),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          custType,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Agent ID: $userCode',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlapping Stats Card
                  Positioned(
                    bottom: -40,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.25 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Consumer<AgentPolicyProvider>(
                              builder: (_, ap, __) => _buildStatItem(
                                  context, '₦${ap.commission}', 'Commission')),
                          Container(
                            width: 1,
                            height: 40,
                            color: borderColor,
                          ),
                          Consumer<AgentPolicyProvider>(
                              builder: (_, ap, __) => _buildStatItem(context,
                                  '${ap.totalClients}', 'Active Clients')),
                          Container(
                            width: 1,
                            height: 40,
                            color: borderColor,
                          ),
                          Consumer<AgentPolicyProvider>(
                              builder: (_, ap, __) => _buildStatItem(context,
                                  '${ap.activePolicies}', 'Active Policies')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Personal Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    context,
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.withValues(alpha: 0.1),
                    label: 'Email',
                    value: userEmail,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    icon: Icons.phone_outlined,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.withValues(alpha: 0.1),
                    label: 'Phone',
                    value: phone,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.purple,
                    iconBgColor: Colors.purple.withValues(alpha: 0.1),
                    label: 'Office Location',
                    value: address,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Performance This Month
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance This Month',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceItem(
                    context,
                    icon: Icons.flag_outlined,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.withValues(alpha: 0.1),
                    label: 'Sales Target',
                    value: '\$45,000 / \$50,000',
                    progress: 0.9,
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceItem(
                    context,
                    icon: Icons.attach_money,
                    iconColor: Colors.amber,
                    iconBgColor: Colors.amber.withValues(alpha: 0.1),
                    label: 'Commission Earned',
                    value: '\$12,450',
                    percentage: '20%',
                    showUpArrow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notification Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.security_outlined,
                    title: 'Security Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecuritySettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help and support',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const HelpSupportScreen(isAgentFlow: true))),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    context,
                    icon: Icons.logout,
                    title: 'Log out',
                    isLogout: true,
                    onTap: () async {
                      clearSessionCaches(context);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: buildAgentBottomNav(context, currentIndex: 4),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    double? progress,
    String? percentage,
    bool showUpArrow = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (percentage != null) ...[
                        const Spacer(),
                        Text(
                          percentage,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (showUpArrow)
                          const Icon(
                            Icons.arrow_upward,
                            size: 16,
                            color: Colors.green,
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
    bool isLogout = false,
    bool hasToggle = false,
    bool toggleValue = false,
    ValueChanged<bool>? onToggleChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final agentAccent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;
    final arrowColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

    return InkWell(
      onTap: hasToggle ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : agentAccent,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isLogout
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (hasToggle)
              Switch(
                value: toggleValue,
                onChanged: onToggleChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: agentAccent,
              ),
            if (showArrow && !hasToggle)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: arrowColor,
              ),
          ],
        ),
      ),
    );
  }
}
