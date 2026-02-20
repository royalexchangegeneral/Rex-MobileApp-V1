import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';
import 'customer_motor_insurance_screen.dart';
import 'protection_plans_screen.dart';
import 'royal_care_screen.dart';
import 'underwritten_products_screen.dart';

class NewPolicyScreen extends StatelessWidget {
  const NewPolicyScreen({super.key});

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
        title: const Text('New Policy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
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
              child: const Column(
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
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                  ),
                  SizedBox(height: 8),
                  Text('Click here for advice.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.grey[300],
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
                  if (trailingIcon != null) const SizedBox(width: 40),
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

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ],
    );
  }

  Widget _buildMotorInsuranceCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerMotorInsuranceScreen())),
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
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/car-front.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFF4A90D9), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Motor Insurance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 4),
                        Text('This policy covers the third party against Bodily injury and death resulting from a car accident caused by the insured.', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProtectionPlansScreen())),
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
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/Capa_1.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFFE91E63), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Protection Plans', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 4),
                        Text('This product caters to both Single Transit and Open Cover Insurance.', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoyalCareScreen())),
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
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/svg3474.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFFE91E63), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Royal Care', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 4),
                        Text('Protect your equipment', style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnderwrittenProductsScreen())),
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
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
              child: SvgPicture.asset('assets/icons/Capa_1 (1).svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Color(0xFF4A90D9), BlendMode.srcIn)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Underwritten Products', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
