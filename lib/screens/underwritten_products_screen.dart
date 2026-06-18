import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';
import 'new_policy_screen.dart';
import 'quote_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';

class UnderwrittenProductsScreen extends StatelessWidget {
  final bool isAgent;

  const UnderwrittenProductsScreen({super.key, this.isAgent = false});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _cardColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : const Color(0xFFFAFAFA);

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : Colors.grey.shade200;

  Color _secondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  void _openProductDescription(BuildContext context, String product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UnderwrittenProductDescriptionScreen(product: product),
      ),
    );
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
        title: Text('New Insurance',
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
            _buildInsuranceCard(
              context,
              title: 'Fire Insurance',
              subtitle: 'Protect your home',
              iconBgColor: const Color(0xFFFFF5F5),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => _openProductDescription(context, 'Fire Insurance'),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'General Accident',
              subtitle: 'Protect your vehicle',
              iconBgColor: const Color(0xFFFFF5E6),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'General Accident'),
                  )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Engineering Insurance',
              subtitle: 'Protect your equipment',
              iconBgColor: const Color(0xFFE8F4FD),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'Engineering Insurance'),
                  )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Marine Insurance',
              subtitle: 'This policy covers Single Transit only',
              iconBgColor: const Color(0xFFF3E8FF),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'Marine Insurance'),
                  )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Industrial All Risk',
              subtitle: 'Protect your tools',
              iconBgColor: const Color(0xFFE0F5F5),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'Industrial All Risk'),
                  )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Energy Insurance',
              subtitle: 'Protect your tools',
              iconBgColor: const Color(0xFFFFF9DB),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'Energy Insurance'),
                  )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Agriculture Insurance',
              subtitle: 'Protect your food',
              iconBgColor: const Color(0xFFE8F5E9),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'Agriculture Insurance'),
                  )),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Bond Insurance',
              subtitle: 'Protect your Assets',
              iconBgColor: const Color(0xFFF3E8FF),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnderwrittenProductDescriptionScreen(
                        product: 'Bond Insurance'),
                  )),
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

  Widget _buildInsuranceCard(
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

class UnderwrittenProductDescriptionScreen extends StatelessWidget {
  final String product;

  const UnderwrittenProductDescriptionScreen(
      {super.key, required this.product});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _sectionColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : const Color(0xFFFAFAFA);

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : Colors.grey.shade200;

  Color _secondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  IconData get _productIcon {
    switch (product.toLowerCase()) {
      case 'fire insurance':
        return Icons.local_fire_department_outlined;
      case 'general accident':
        return Icons.health_and_safety_outlined;
      case 'engineering insurance':
        return Icons.precision_manufacturing_outlined;
      case 'marine insurance':
        return Icons.directions_boat_filled_outlined;
      case 'industrial all risk':
        return Icons.factory_outlined;
      case 'energy insurance':
        return Icons.bolt_outlined;
      case 'agriculture insurance':
        return Icons.agriculture_outlined;
      case 'bond insurance':
        return Icons.handshake_outlined;
      default:
        return Icons.verified_user_outlined;
    }
  }

  List<String> get _descriptions {
    final summary = _content['summary']?.toString() ?? '';
    return summary.trim().isEmpty ? const [] : [summary.trim()];
  }

  Map<String, dynamic> get _content {
    switch (product.toLowerCase()) {
      case 'fire insurance':
        return {
          'summary':
              'Protect your building, contents, stock, and business assets against fire and related insured damage.',
          'covers': [
            'Fire and lightning damage',
            'Explosion and impact damage',
            'Business premises, contents, and stock',
          ],
        };
      case 'general accident':
        return {
          'summary':
              'Cover everyday accident risks, liability exposures, and unexpected losses affecting your operations.',
          'covers': [
            'Personal and workplace accident exposures',
            'Public liability and third-party injury risks',
            'Unexpected loss events requiring tailored protection',
          ],
        };
      case 'engineering insurance':
        return {
          'summary':
              'Protect machinery, equipment, construction works, and engineering projects from operational or installation risks.',
          'covers': [
            'Machinery breakdown and plant risks',
            'Contract works and installation exposures',
            'Equipment damage during use or project execution',
          ],
        };
      case 'marine insurance':
        return {
          'summary':
              'Protect cargo and goods while they move by sea, air, road, or rail from loss or damage in transit.',
          'covers': [
            'Single transit cargo movement',
            'Import, export, and inland transit risks',
            'Loss or damage to insured goods while in transit',
          ],
        };
      case 'industrial all risk':
        return {
          'summary':
              'Broad protection for industrial businesses, covering property, machinery, stock, and interruption risks.',
          'covers': [
            'Industrial buildings, plant, and machinery',
            'Stock, contents, and business assets',
            'Wider all-risk protection for complex operations',
          ],
        };
      case 'energy insurance':
        return {
          'summary':
              'Specialized protection for energy assets, equipment, operations, and liabilities across energy projects.',
          'covers': [
            'Energy equipment and operational assets',
            'Project and production-related risks',
            'Associated liability and business interruption exposures',
          ],
        };
      case 'agriculture insurance':
        return {
          'summary':
              'Protect farms, crops, livestock, and agribusiness investments from insured events that can disrupt production.',
          'covers': [
            'Crop and farm asset protection',
            'Livestock and agribusiness risks',
            'Loss events affecting agricultural production',
          ],
        };
      case 'bond insurance':
        return {
          'summary':
              'Support contractual obligations with surety protection for performance, advance payment, and related bond needs.',
          'covers': [
            'Performance bond requirements',
            'Advance payment and contract bonds',
            'Surety support for business obligations',
          ],
        };
      default:
        return {
          'summary':
              'Request a tailored underwriting quote based on your business, asset, or project risk.',
          'covers': [
            'Specialized risk assessment',
            'Tailored cover recommendations',
            'Quote support for complex insurance needs',
          ],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final covers = (_content['covers'] as List).cast<String>();
    final descriptions = _descriptions;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = _isDark(context);
    final iconColor =
        isDark ? const Color(0xFFFFC073) : AppTheme.accentOrange;
    final iconBackground = AppTheme.accentOrange.withValues(
      alpha: isDark ? 0.18 : 0.12,
    );
    final iconBorderColor = AppTheme.accentOrange.withValues(
      alpha: isDark ? 0.34 : 0.18,
    );
    final keyCoverageColor =
        isDark ? const Color(0xFFFFC073) : AppTheme.primaryNavy;
    final cardShadowColor = isDark
        ? Colors.transparent
        : AppTheme.primaryNavy.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.primaryNavy, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                  decoration: BoxDecoration(
                    color: _sectionColor(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor(context)),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadowColor,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: iconBackground,
                            shape: BoxShape.circle,
                            border: Border.all(color: iconBorderColor),
                          ),
                          child: Icon(
                            _productIcon,
                            color: iconColor,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(product,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: onSurface)),
                      ),
                      const SizedBox(height: 14),
                      ...descriptions.map(
                        (description) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.36,
                                  color: _secondaryTextColor(context))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: _borderColor(context),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Key Coverage',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: keyCoverageColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...covers.map((cover) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFF3FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check,
                                      color: AppTheme.primaryNavy, size: 19),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(cover,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                          color: onSurface)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 18, 24, 22 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuoteScreen(insuranceType: product),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Next',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
