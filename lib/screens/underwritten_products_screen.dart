import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';
import 'new_policy_screen.dart';
import 'quote_screen.dart';

class UnderwrittenProductsScreen extends StatelessWidget {
  final bool isAgent;
  
  const UnderwrittenProductsScreen({super.key, this.isAgent = false});

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
        title: const Text('New Insurance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.tune, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInsuranceCard(
              title: 'Fire Insurance',
              subtitle: 'Protect your home',
              iconBgColor: const Color(0xFFFFF5F5),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Fire Insurance'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'General Accident',
              subtitle: 'Protect your vehicle',
              iconBgColor: const Color(0xFFFFF5E6),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'General Accident'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'Engineering Insurance',
              subtitle: 'Protect your equipment',
              iconBgColor: const Color(0xFFE8F4FD),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Engineering Insurance'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'Marine Insurance',
              subtitle: 'This policy covers Single Transit only',
              iconBgColor: const Color(0xFFF3E8FF),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Marine Insurance'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'Industrial All Risk',
              subtitle: 'Protect your tools',
              iconBgColor: const Color(0xFFE0F5F5),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Industrial All Risk'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'Energy Insurance',
              subtitle: 'Protect your tools',
              iconBgColor: const Color(0xFFFFF9DB),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Energy Insurance'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'Agriculture Insurance',
              subtitle: 'Protect your food',
              iconBgColor: const Color(0xFFE8F5E9),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Agriculture Insurance'),
              )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              title: 'Bond Insurance',
              subtitle: 'Protect your Assets',
              iconBgColor: const Color(0xFFF3E8FF),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              cardBgColor: const Color(0xFFFAFAFA),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QuoteScreen(insuranceType: 'Bond Insurance'),
              )),
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
          backgroundColor: AppTheme.primaryNavy,
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
                    _buildNavItem(Icons.home_outlined, 'Home', false),
                    _buildNavItem(Icons.description_outlined, 'Policies', true),
                    const SizedBox(width: 40),
                    _buildNavItem(Icons.assignment_outlined, 'Claims', false),
                    _buildNavItem(Icons.person_outline, 'Profile', false),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInsuranceCard({
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

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ],
    );
  }
}