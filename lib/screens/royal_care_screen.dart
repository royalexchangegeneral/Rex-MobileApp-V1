import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';
import 'new_policy_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'royal_personal_care_screen.dart';
import 'royal_group_care_screen.dart';
import 'royal_family_care_screen.dart';

class RoyalCareScreen extends StatelessWidget {
  final bool isAgent;
  final bool isFromNewPolicy;
  final bool isCustomerFlow;

  const RoyalCareScreen(
      {super.key,
      this.isAgent = false,
      this.isFromNewPolicy = false,
      this.isCustomerFlow = false});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _cardColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : const Color(0xFFFAFAFA);

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : Colors.grey.shade200;

  Color _secondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

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
        title: Text('Royal Care',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.tune,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRoyalCareCard(
              context,
              title: 'Royal Personal Care',
              subtitle: 'Protect your equipment',
              iconBgColor: const Color(0xFFE8F4FD),
              svgIcon: 'assets/icons/svg3474.svg',
              trailingSvgIcon: 'assets/icons/svg3474.svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RoyalPersonalCareScreen(
                          isFromNewPolicy: isFromNewPolicy,
                          isCustomerFlow: isCustomerFlow))),
            ),
            const SizedBox(height: 12),
            _buildRoyalCareCard(
              context,
              title: 'Royal Group Care',
              subtitle: 'Protect your Assets',
              iconBgColor: const Color(0xFFFCE4EC),
              svgIcon: 'assets/icons/Capa_1 2.svg',
              trailingSvgIcon: 'assets/icons/Capa_1 2.svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RoyalGroupCareScreen(
                          isFromNewPolicy: isFromNewPolicy))),
            ),
            const SizedBox(height: 12),
            _buildRoyalCareCard(
              context,
              title: 'Royal Family Care',
              subtitle: 'Protect your tools',
              iconBgColor: const Color(0xFFFFF5E6),
              svgIcon: 'assets/icons/Layer_1.svg',
              trailingSvgIcon: 'assets/icons/Layer_1.svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RoyalFamilyCareScreen(
                          isFromNewPolicy: isFromNewPolicy,
                          isCustomerFlow: isCustomerFlow))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: isAgent
          ? null
          : Transform.translate(
              offset: const Offset(0, 15),
              child: SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NewPolicyScreen(isAgent: isAgent))),
                  backgroundColor: AppTheme.accentOrange,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
      floatingActionButtonLocation:
          isAgent ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgent
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.bottomNavSelectedColor(context),
              unselectedItemColor: AppTheme.bottomNavUnselectedColor(context),
              currentIndex: 1,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 22),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined, size: 22),
                  label: 'Policy',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline, size: 22),
                  label: 'Clients',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined, size: 22),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 22),
                  label: 'Profile',
                ),
              ],
            )
          : BottomAppBar(
              color: AppTheme.bottomNavBackgroundColor(context),
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                height: 44,
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
                        context, Icons.description_outlined, 'Policies', true),
                    const SizedBox(width: 48),
                    _buildNavItem(
                        context, Icons.assignment_outlined, 'Claims', false,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyClaimsScreen()));
                    }),
                    _buildNavItem(
                        context, Icons.person_outline, 'Profile', false,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerProfileScreen()));
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRoyalCareCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required String svgIcon,
    required String trailingSvgIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: _cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor(context)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(svgIcon, width: 22, height: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 10,
                                color: _secondaryTextColor(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(trailingSvgIcon, width: 40, height: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
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
