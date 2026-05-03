import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import 'customer_motor_insurance_screen.dart';
import 'protection_plans_screen.dart';
import 'royal_care_screen.dart';
import 'underwritten_products_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';

class NewPolicyScreen extends StatelessWidget {
  final bool isAgent;
  final Map<String, dynamic>? clientData;
  
  const NewPolicyScreen({super.key, this.isAgent = false, this.clientData});

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
        title: Text('New Policy', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMotorInsuranceCard(context),
            const SizedBox(height: 12),
            _buildProtectionPlansCard(context),
            const SizedBox(height: 12),
            _buildRoyalCareCard(context),
            const SizedBox(height: 12),
            _buildUnderwrittenCard(context),
            const SizedBox(height: 24),
            // Need Help Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: AppTheme.primaryNavy, size: 20),
                      SizedBox(width: 8),
                      Text('Need Help?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Not sure what to buy?, do you need assistance choosing, customizing, or purchasing a new insurance policy.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.4),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: '+2347080606100');
                      try {
                        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                        if (!launched && context.mounted) {
                          showDialog(context: context, builder: (ctx) => AlertDialog(
                            title: const Text('Contact Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                          ));
                        }
                      } catch (_) {
                        if (context.mounted) {
                          showDialog(context: context, builder: (ctx) => AlertDialog(
                            title: const Text('Contact Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                          ));
                        }
                      }
                    },
                    child: Text('Click here for advice.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: isAgent ? null : Transform.translate(
        offset: const Offset(0, 15),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.grey[400],
            shape: const CircleBorder(),
            elevation: 1,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
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
              notchMargin: 4,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
                    }),
                    _buildNavItem(Icons.description_outlined, 'Policies', true),
                    const SizedBox(width: 48),
                    _buildNavItem(Icons.assignment_outlined, 'Claims', false, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
                    }),
                    _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    IconData? trailingIcon,
    Color? trailingBgColor,
    bool showArrow = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(description, style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
                      ],
                    ),
                  ),
                  if (showArrow)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
                      child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
                    ),
                  if (trailingIcon != null) const SizedBox(width: 48),
                ],
              ),
            ),
            if (trailingIcon != null)
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: trailingBgColor ?? iconBgColor, shape: BoxShape.circle),
                  child: Icon(trailingIcon, color: iconColor.withOpacity(0.3), size: 40),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
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

  Widget _buildMotorInsuranceCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerMotorInsuranceScreen(isAgent: isAgent, clientData: clientData))),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/car-front.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFF4A90D9), BlendMode.srcIn)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Motor Insurance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('This policy covers the third party against Bodily injury and death resulting from a car accident caused by the insured.', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
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
                decoration: const BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                child: SvgPicture.asset('assets/icons/car-front.svg', width: 40, height: 40, colorFilter: ColorFilter.mode(const Color(0xFF4A90D9).withOpacity(0.3), BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionPlansCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProtectionPlansScreen(isAgent: isAgent))),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/Capa_1.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFFE91E63), BlendMode.srcIn)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Protection Plans', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('This product caters to both Single Transit and Open Cover Insurance.', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
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
                decoration: const BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                child: SvgPicture.asset('assets/icons/Capa_1.svg', width: 40, height: 40, colorFilter: ColorFilter.mode(const Color(0xFFE91E63).withOpacity(0.3), BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoyalCareCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoyalCareScreen(isAgent: isAgent))),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/svg3474.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFFE91E63), BlendMode.srcIn)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Royal Care', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('Protect your equipment', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
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
                decoration: const BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                child: SvgPicture.asset('assets/icons/svg3474.svg', width: 40, height: 40, colorFilter: ColorFilter.mode(const Color(0xFFE91E63).withOpacity(0.3), BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderwrittenCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnderwrittenProductsScreen(isAgent: isAgent))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
              child: SvgPicture.asset('assets/icons/Capa_1 (1).svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFF4A90D9), BlendMode.srcIn)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Underwritten Products', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Lorem ipsum dolor sit amet consectetur.', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
              child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
