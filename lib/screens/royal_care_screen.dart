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
  
  const RoyalCareScreen({super.key, this.isAgent = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Royal Care', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.tune, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRoyalCareCard(
              title: 'Royal Personal Care',
              subtitle: 'Protect your equipment',
              iconBgColor: const Color(0xFFE8F4FD),
              svgIcon: 'assets/icons/svg3474.svg',
              trailingSvgIcon: 'assets/icons/svg3474.svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoyalPersonalCareScreen())),
            ),
            const SizedBox(height: 12),
            _buildRoyalCareCard(
              title: 'Royal Group Care',
              subtitle: 'Protect your Assets',
              iconBgColor: const Color(0xFFFCE4EC),
              svgIcon: 'assets/icons/Capa_1 2.svg',
              trailingSvgIcon: 'assets/icons/Capa_1 2.svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoyalGroupCareScreen())),
            ),
            const SizedBox(height: 12),
            _buildRoyalCareCard(
              title: 'Royal Family Care',
              subtitle: 'Protect your tools',
              iconBgColor: const Color(0xFFFFF5E6),
              svgIcon: 'assets/icons/Layer_1.svg',
              trailingSvgIcon: 'assets/icons/Layer_1.svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoyalFamilyCareScreen())),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: isAgent ? null : SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewPolicyScreen(isAgent: isAgent))),
          backgroundColor: AppTheme.accentOrange,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: isAgent ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgent
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF1E2D64),
              unselectedItemColor: Colors.grey,
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
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_outlined, 'Home', false, onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
              }),
              _buildNavItem(context, Icons.description_outlined, 'Policies', true),
              const SizedBox(width: 40),
              _buildNavItem(context, Icons.assignment_outlined, 'Claims', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
              }),
              _buildNavItem(context, Icons.person_outline, 'Profile', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoyalCareCard({
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required String svgIcon,
    required String trailingSvgIcon,
    required Color cardBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
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
                        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
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

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
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