import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
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

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _cardColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : const Color(0xFFFAFAFA);

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : Colors.grey[200]!;

  Color _secondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color _mutedIconColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF94A3B8) : Colors.grey[400]!;

  Color _selectedNavColor(BuildContext context) =>
      AppTheme.bottomNavSelectedColor(context);

  Color _unselectedNavColor(BuildContext context) =>
      AppTheme.bottomNavUnselectedColor(context);

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
        title: Text('New Policy',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
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
                color: _isDark(context)
                    ? const Color(0xFF111827)
                    : const Color(0xFFF3F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline,
                          color: _selectedNavColor(context), size: 20),
                      const SizedBox(width: 8),
                      Text('Need Help?',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedNavColor(context))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Not sure what to buy?, do you need assistance choosing, customizing, or purchasing a new insurance policy.',
                    style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor(context),
                        height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: '+2347080606100');
                      try {
                        final launched = await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                        if (!launched && context.mounted) {
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    title: const Text('Contact Support',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    content: const Text('+234 708 0606 100',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('OK'))
                                    ],
                                  ));
                        }
                      } catch (_) {
                        if (context.mounted) {
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    title: const Text('Contact Support',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    content: const Text('+234 708 0606 100',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('OK'))
                                    ],
                                  ));
                        }
                      }
                    },
                    child: Text('Click here for advice.',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedNavColor(context))),
                  ),
                ],
              ),
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
                  onPressed: null,
                  backgroundColor: AppTheme.disabledButtonColor(context),
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: Icon(Icons.add,
                      color: AppTheme.disabledButtonTextColor(context),
                      size: 30),
                ),
              ),
            ),
      floatingActionButtonLocation:
          isAgent ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgent
          ? buildAgentBottomNav(context, currentIndex: 1)
          : BottomAppBar(
              color: AppTheme.bottomNavBackgroundColor(context),
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, 'Home', false, context,
                        onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerDashboardScreen()),
                          (route) => false);
                    }),
                    _buildNavItem(
                        Icons.description_outlined, 'Policies', true, context),
                    const SizedBox(width: 48),
                    _buildNavItem(
                        Icons.assignment_outlined, 'Claims', false, context,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyClaimsScreen()));
                    }),
                    _buildNavItem(
                        Icons.person_outline, 'Profile', false, context,
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

  Widget _buildNavItem(
      IconData icon, String label, bool isSelected, BuildContext context,
      {VoidCallback? onTap}) {
    final color =
        isSelected ? _selectedNavColor(context) : _unselectedNavColor(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildMotorInsuranceCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CustomerMotorInsuranceScreen(
                  isAgent: isAgent,
                  isFromNewPolicy: true,
                  clientData: clientData))),
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
                    decoration: const BoxDecoration(
                        color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/car-front.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF4A90D9), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Motor Insurance',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(
                            'This policy covers the third party against Bodily injury and death resulting from a car accident caused by the insured.',
                            style: TextStyle(
                                fontSize: 11,
                                color: _secondaryTextColor(context),
                                height: 1.3)),
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
                decoration: const BoxDecoration(
                    color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                child: SvgPicture.asset('assets/icons/car-front.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                        const Color(0xFF4A90D9).withValues(alpha: 0.3),
                        BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionPlansCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProtectionPlansScreen(
                  isAgent: isAgent,
                  isFromNewPolicy: true,
                  isCustomerFlow: !isAgent,
                  clientData: clientData))),
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
                    decoration: const BoxDecoration(
                        color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/Capa_1.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFFE91E63), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Protection Plans',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(
                            'This product caters to both Single Transit and Open Cover Insurance.',
                            style: TextStyle(
                                fontSize: 11,
                                color: _secondaryTextColor(context),
                                height: 1.3)),
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
                decoration: const BoxDecoration(
                    color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                child: SvgPicture.asset('assets/icons/Capa_1.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                        const Color(0xFFE91E63).withValues(alpha: 0.3),
                        BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoyalCareCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RoyalCareScreen(
                  isAgent: isAgent,
                  isFromNewPolicy: true,
                  isCustomerFlow: !isAgent,
                  clientData: clientData))),
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
                    decoration: const BoxDecoration(
                        color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                    child: SvgPicture.asset('assets/icons/svg3474.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFFE91E63), BlendMode.srcIn)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Royal Care',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('Protect your equipment',
                            style: TextStyle(
                                fontSize: 11,
                                color: _secondaryTextColor(context),
                                height: 1.3)),
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
                decoration: const BoxDecoration(
                    color: Color(0xFFFCE4EC), shape: BoxShape.circle),
                child: SvgPicture.asset('assets/icons/svg3474.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                        const Color(0xFFE91E63).withValues(alpha: 0.3),
                        BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderwrittenCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => UnderwrittenProductsScreen(isAgent: isAgent))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F4FD), shape: BoxShape.circle),
              child: SvgPicture.asset('assets/icons/Capa_1 (1).svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF4A90D9), BlendMode.srcIn)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Underwritten Products',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                      'Specialized cover for business, marine, energy, agriculture, engineering, bond, and industrial risks.',
                      style: TextStyle(
                          fontSize: 11,
                          color: _secondaryTextColor(context),
                          height: 1.3)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderColor(context))),
              child: Icon(Icons.arrow_forward_ios,
                  size: 12, color: _mutedIconColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}
