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
              subtitle: 'Protect your private residence and business premises',
              iconBgColor: const Color(0xFFFFF5F5),
              svgIcon: 'assets/icons/Capa_1 (1).svg',
              trailingSvgIcon: 'assets/icons/Capa_1 (1).svg',
              onTap: () => _openProductDescription(context, 'Fire Insurance'),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'General Accident',
              subtitle:
                  'Protect your life and finances against accidental injuries, disability, or death.',
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
              subtitle:
                  'Protect your engineering projects, equipment, and construction works',
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
              subtitle: 'Protect your shipment',
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
              subtitle:
                  'Protect your industrial assets, machinery, and operations',
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
              subtitle: 'Protect your energy assets and operations',
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
              subtitle: 'Protect your crops and livestock',
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
              subtitle: 'Protect your project payments and contract delivery',
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
                                fontSize: 9,
                                color: _secondaryTextColor(context)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 72),
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
          'title': 'FIRE INSURANCE',
          'subtitle': 'Fire & Special Perils (FSP) Insurance',
          'overviewTitle': 'Product Overview / Summary',
          'summary':
              'The Fire & Special Perils (FSP) policy provides cover for both private residences and business premises against loss or damage to insured property caused by fire and related perils such as flood, storm, tempest, explosion (domestic gas and boilers), lightning, burst water pipes, and other specified risks.',
          'coversTitle': 'Key Features and Benefits',
          'covers': [
            'Covers both private residences and business premises.',
            'Provides financial protection against fire and a wide range of specified perils.',
            'Protects buildings and insured property from accidental loss or damage.',
            'Helps minimize the financial impact of unexpected events affecting homes and businesses.',
          ],
          'targetTitle': 'Target Customer Segment',
          'targetCustomers': [
            'Homeowners with private residences.',
            'Owners of business premises.',
            'Individuals and businesses seeking protection against fire and related perils affecting insured property.',
          ],
          'taglineTitle': 'Recommended Customer-Friendly Tagline',
          'tagline':
              'Protecting Your Home and Business Against Fire and Special Perils',
        };
      case 'general accident':
        return {
          'title': 'GENERAL ACCIDENT INSURANCE',
          'productSections': [
            {
              'subtitle': 'Product Name: Professional Indemnity Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Professional Indemnity Insurance is a form of liability insurance that helps protect professionals such as doctors, pharmacists, nurses, lawyers, engineers, architects and other professions against legal liability arising from professional negligence in the course of their business.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protection against legal liability to pay damages to persons who have sustained loss due to professional negligence',
                'Safeguards professionals from financial consequences of errors, omissions, or negligent acts',
                'Supports business continuity by mitigating the financial impact of claims',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Doctors',
                'Pharmacists',
                'Nurses',
                'Lawyers',
                'Engineers',
                'Architects',
                'Brokers',
                'Other professionals offering specialized services',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline':
                  'Helping you stay secure when professional mistakes happen',
            },
            {
              'subtitle':
                  'Product Name: Directors & Officers (D&O) Liability Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Directors and officers (D&O) liability insurance is insurance coverage intended to protect individuals from personal losses if they are sued as a result of serving as a director or an officer of a business or other type of organization.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects directors and officers from personal losses',
                'Covers legal fees and other related costs',
                'Supports organizations in managing the financial impact of lawsuits',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Directors of companies or organizations',
                'Officers of businesses or organizations',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline':
                  'Reducing the impact of high-stakes leadership decisions',
            },
            {
              'subtitle': 'Product Name: Public Liability Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'This policy covers legal liabilities arising from the activities of the insured\'s business (excluding product-related liabilities) for bodily injury, death of third parties, or loss or damage to their property. It also covers the cost of litigation.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects businesses against third-party liability claims',
                'Covers compensation for injury, death, or property damage',
                'Includes legal and litigation cost coverage',
                'Reduces financial impact of public-facing business risks',
                'Supports business continuity during claims or disputes',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Business owners',
                'Companies with physical operations or public interaction',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Reducing the impact of everyday business risks',
            },
            {
              'subtitle': 'Product Name: Occupiers Liability Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Covers the insured\'s legal liability arising from ownership, maintenance, or use of designated premises for injury, death, or property damage to third parties occurring on or around the premises.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects against claims from incidents on insured premises',
                'Covers legal liability for bodily injury, death, or property damage',
                'Extends to adjoining areas and defined facility spaces (e.g., parking areas, storage garages, recreation areas)',
                'Supports compliance with statutory insurance requirements',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Owners or occupiers of public buildings',
                'Operators of facilities accessible to the public (educational, medical, commercial, or recreational)',
                'Businesses with physical premises exposed to public use',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline':
                  'Protection for your premises and the people around it',
            },
            {
              'subtitle': 'Product Name: Employer\'s Liability Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides insurance cover for employers against liability for injury, disease, or death of employees arising in the course of employment, as required under the Employee Compensation Act of 2010.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects employers from employee compensation claims',
                'Covers workplace-related injury, disease, or death',
                'Helps ensure compliance with statutory requirements',
                'Reduces financial impact of employment-related liabilities',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Employers across all sectors',
                'Businesses with staff engaged in operational or field activities',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Supporting your team and strengthening your business',
            },
            {
              'subtitle': 'Product Name: Product Liability Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides cover for compensation claims arising from injury or property damage caused by defective products supplied or distributed by the insured.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects against claims from faulty or defective products',
                'Covers compensation costs for third-party injury or property damage',
                'Applies across manufacturing, sales, and distribution activities',
                'Helps safeguard business reputation and financial stability',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Manufacturers',
                'Distributors and suppliers',
                'Retailers and wholesalers',
                'Service providers handling or altering products',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Reducing the impact of product performance failures',
            },
            {
              'subtitle': 'Product Name: Group Personal Accident Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides 24-hour accident insurance cover for groups, offering compensation for injuries, disability, or death resulting from accidental events.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Round-the-clock accident protection',
                'Covers multiple individuals under a single policy',
                'Financial support in the event of accidental injury or death',
                'Suitable for organizational or group arrangements',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Employers and corporate organizations',
                'Associations and cooperatives',
                'Institutions covering staff or members',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Coverage for employees or team wherever they go',
            },
            {
              'subtitle': 'Product Name: Personal Accident Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Annual policy that provides worldwide 24-hour cover, offering compensation for injury, disability, or death resulting from accidental events.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                '24-hour global accident protection',
                'Individual cover for personal use',
                'Financial support in case of accidental injury, disability, or death',
                'Flexible protection regardless of location',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Individuals seeking personal protection',
                'Professionals, travelers, and self-employed persons',
                'Anyone requiring standalone accident cover',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Insurance support for everyday life',
            },
            {
              'subtitle': 'Product Name: Goods-in-Transit Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides cover for loss, damage, or theft of goods while being transported by road or inland waterways, including handling and temporary storage during transit.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects goods during transportation and handling',
                'Covers theft, loss, or damage in transit',
                'Includes protection during loading, unloading, and temporary storage',
                'Flexible policy options based on transit frequency',
              ],
              'policyTypesTitle': '3. Policy Types',
              'policyTypes': [
                'Open Cover: Annual agreement with a defined estimated carrying value; each transit is covered within agreed limits',
                'Declaration Policy: Cover based on periodic declarations of actual transits made',
                'Single Transit: One-off cover for occasional shipments',
              ],
              'targetTitle': '4. Target Customer Segment',
              'targetCustomers': [
                'Importers and exporters',
                'Logistics and transport companies',
                'Manufacturers and distributors',
                'Businesses moving goods regularly or occasionally',
              ],
              'taglineTitle': '5. Recommended Customer-Friendly Tagline',
              'tagline': 'Secure your goods, every step of the journey',
            },
            {
              'subtitle': 'Product Name: Fidelity Guarantee Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides cover for financial loss suffered by an employer due to fraud or dishonesty committed by employees.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Protects against employee fraud and dishonesty',
                'Covers loss of money or business property',
                'Helps safeguard business assets and cash flow',
                'Reduces financial exposure from internal risks',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Businesses handling cash or valuable assets',
                'Financial institutions and service companies',
                'Organizations with employees in trusted or sensitive roles',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Protection against internal financial risks',
            },
            {
              'subtitle': 'Product Name: All Risk Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides cover against accidental loss of or damage to insured assets within a specified geographical area, regardless of where the items are located.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Broad protection for insured assets',
                'Covers accidental loss or damage',
                'Flexible cover not limited to a fixed location',
                'Helps protect valuable personal or business property',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Individuals with valuable personal assets',
                'Businesses with movable equipment or assets',
                'Organizations requiring flexible asset protection',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Comprehensive protection for what matters most',
            },
          ],
        };
      case 'engineering insurance':
        return {
          'title': 'ENGINEERING INSURANCE',
          'subtitle': 'Product Name: Contractors\' All Risk Insurance',
          'overviewTitle': '1. Product Overview / Summary',
          'summary':
              'Provides protection against physical loss or damage to construction works during the course of a project, including associated liabilities.',
          'coversTitle': '2. Key Features and Benefits',
          'covers': [
            'Covers construction works from start to completion',
            'Protects building materials and works in progress',
            'Covers construction plant and equipment',
            'Includes protection against third-party injury or property damage claims',
            'Helps reduce financial setbacks from construction risks',
          ],
          'targetTitle': '3. Target Customer Segment',
          'targetCustomers': [
            'Contractors and construction companies',
            'Property developers',
            'Engineering and infrastructure firms',
          ],
          'taglineTitle': '4. Recommended Customer-Friendly Tagline',
          'tagline': 'Coverage for every stage of your building project',
        };
      case 'marine insurance':
        return {
          'title': 'MARINE INSURANCE',
          'productSections': [
            {
              'subtitle': 'Product Name: Marine Cargo Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides cover for goods transported by sea from the point of embarkation to the point of destination, protecting against loss or damage during transit.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Covers goods in international and domestic sea transit',
                'Protection against loss or damage during shipping',
                'Flexible cover options based on risk needs',
                'Helps reduce financial loss from cargo incidents',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Importers and exporters',
                'Shipping and logistics companies',
                'Manufacturers and distributors engaged in international trade',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Safeguarding your cargo every step of the journey',
            },
            {
              'subtitle': 'Product Name: Marine Hull Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Covers loss or damage to hull and machinery of insured vessels, including ships, boats, ferries, and barges owned by the insured.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Covers loss or damage to vessel hull and machinery',
                'Protects the vessel structure (hull) and operational systems',
                'Includes machinery such as engines, boilers, generators, and cooling systems used for propulsion, lighting, and temperature control',
                'Applies to various vessels including ships, boats, ferries, and barges',
                'Helps reduce financial loss from damage or breakdown of marine vessels',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Ship and vessel owners',
                'Shipping and transport companies',
                'Marine and logistics operators',
                'Commercial marine asset owners',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Peace of mind for your vessels, wherever they go',
            },
          ],
        };
      case 'industrial all risk':
        return {
          'overviewTitle': '1. Product Overview / Summary',
          'summary':
              'Provides cover against accidental loss of or damage to insured assets within a specified geographical area, regardless of where the items are located.',
          'coversTitle': '2. Key Features and Benefits',
          'covers': [
            'Broad protection for insured assets',
            'Covers accidental loss or damage',
            'Flexible cover not limited to a fixed location',
            'Helps protect valuable personal or business property',
          ],
          'targetTitle': '3. Target Customer Segment',
          'targetCustomers': [
            'Individuals with valuable personal assets',
            'Businesses with movable equipment or assets',
            'Organizations requiring flexible asset protection',
          ],
          'taglineTitle': '4. Recommended Customer-Friendly Tagline',
          'tagline': 'Comprehensive protection for what matters most',
        };
      case 'energy insurance':
        return {
          'title': 'Energy Insurance',
          'overviewTitle': '1. Product Overview / Summary',
          'summary':
              'Provides insurance cover for operations and assets involved in the exploration, production, refining, storage, and transportation of oil, gas, and other energy resources, including petrochemical risks.',
          'coversTitle': '2. Key Features and Benefits',
          'covers': [
            'Covers assets and operations across the energy value chain',
            'Includes protection for oil, gas, and petrochemical activities',
            'Covers liabilities arising from energy production and consumption',
            'Provides financial protection against accidents affecting workers, third parties, and property',
          ],
          'targetTitle': '3. Target Customer Segment',
          'targetCustomers': [
            'Oil and gas companies',
            'Energy and power sector operators',
            'Petrochemical and refining companies',
            'Industrial energy producers and distributors',
          ],
          'taglineTitle': '4. Recommended Customer-Friendly Tagline',
          'tagline':
              'Protecting the energy sector with confidence and coverage',
        };
      case 'agriculture insurance':
        return {
          'title': 'AGRICULTURE INSURANCE',
          'productSections': [
            {
              'subtitle': 'Product Name: Weather Index Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'An insurance product that provides cover against climate changes affecting crop growth from germination to maturity, using predefined weather indices.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Covers climate-related risks affecting crop production',
                'Uses measurable weather indices such as rainfall, temperature, soil moisture, humidity, and evaporation',
                'Automatic payouts triggered by predefined index thresholds',
                'Suitable for group-based agricultural protection',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Smallholder farmers',
                'Farmer cooperatives and agricultural groups',
                'Agribusiness stakeholders involved in crop production',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline':
                  'Protection for your harvest against changing weather patterns',
            },
            {
              'subtitle': 'Product Name: Area-Yield Index Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'A crop insurance product that provides compensation based on the average yield of a defined area, rather than individual farm performance.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Uses area-based yield data as the basis for compensation',
                'Protects against yield loss from drought, flood, pests, diseases, windstorm, excessive rainfall, and fire',
                'Payout is triggered when area yield falls below a pre-set guaranteed threshold',
                'Does not require individual farm loss assessment',
                'Suitable for group-based agricultural risk protection',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Smallholder farmers',
                'Farmer cooperatives and agricultural groups',
                'Agricultural communities within defined geographic areas',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline':
                  'Coverage for seasons when harvests fall below expectations',
            },
            {
              'subtitle': 'Product Name: Poultry Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides protection against physical loss or death of poultry arising from diseases, accidents, and adverse weather conditions affecting poultry production.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Covers loss or death of poultry due to uncontrollable diseases',
                'Protection against unforeseen accidents',
                'Covers mortality resulting from excessive weather conditions (e.g., drought)',
                'Optional cover for Avian influenza',
                'Helps reduce financial loss in poultry farming operations',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Poultry farmers',
                'Smallholder farmers and agricultural groups',
                'Commercial poultry production businesses',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Safeguarding your poultry and your income',
            },
            {
              'subtitle': 'Product Name: Livestock Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides protection for livestock farmers against physical loss or death of livestock such as sheep, goats, and cattle arising from disease, accidents, and adverse weather conditions.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Covers loss of livestock due to uncontrollable diseases',
                'Protection against unforeseen accidents',
                'Covers mortality resulting from adverse weather conditions such as drought',
                'Helps reduce financial loss from livestock mortality',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Smallholder livestock farmers',
                'Livestock-rearing communities and agricultural groups',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Protecting your herd and reducing financial loss',
            },
            {
              'subtitle': 'Product Name: Fish Farm Insurance',
              'overviewTitle': '1. Product Overview / Summary',
              'summary':
                  'Provides protection for fish farmers against physical loss or death of fish stock, with possible extension to fishponds and hatcheries, arising from flood, fire, and uncontrollable diseases.',
              'coversTitle': '2. Key Features and Benefits',
              'covers': [
                'Covers loss or death of fish stock',
                'Protection against flood and fire risks',
                'Covers uncontrollable diseases affecting fish stock',
                'Can be extended to fishponds and hatcheries',
                'Helps reduce financial loss in aquaculture operations',
              ],
              'targetTitle': '3. Target Customer Segment',
              'targetCustomers': [
                'Fish farmers',
                'Aquaculture businesses',
                'Smallholder and commercial fish production operators',
              ],
              'taglineTitle': '4. Recommended Customer-Friendly Tagline',
              'tagline': 'Safeguarding your ponds and your harvest',
            },
          ],
        };
      case 'bond insurance':
        return {
          'title': 'Bond Insurance',
          'overviewTitle': '1. Product Overview / Summary',
          'summary':
              'A bond is a guarantee issued by the insurer (Rex Insurance) to a contractor, under which an agreed sum is paid in the event of the contractor\'s default.',
          'coversTitle': '2. Key Features and Benefits',
          'covers': [
            'Provides financial guarantee in case of contractor default',
            'Assures project owners of contractor performance and commitment',
            'Protects advance payments made before delivery of goods or services',
            'Supports fair tendering by ensuring bidder financial capability',
            'Helps reduce financial risk in contracting and procurement processes',
          ],
          'bondTypesTitle': '3. Types of Bonds',
          'bondTypes': [
            'Advance Payment Bond: Secures advance payments made before goods or services are delivered, protecting against contractor default',
            'Performance Bond: Guarantees satisfactory completion of a project as per contract terms',
            'Bid Bond: Assures that a bidder can accept the contract at the quoted price and covers additional costs if the bid is forfeited',
          ],
          'targetTitle': '4. Target Customer Segment',
          'targetCustomers': [
            'Contractors and construction companies',
            'Project owners and developers',
            'Government and private procurement bodies',
            'Businesses involved in tendering and contracting processes',
          ],
          'taglineTitle': '5. Recommended Customer-Friendly Tagline',
          'tagline': 'Confidence in every contract you award or win',
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
    final covers = ((_content['covers'] as List?) ?? const []).cast<String>();
    final bondTypes =
        ((_content['bondTypes'] as List?) ?? const []).cast<String>();
    final targetCustomers =
        ((_content['targetCustomers'] as List?) ?? const []).cast<String>();
    final productSections = ((_content['productSections'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final descriptions = _descriptions;
    final displayTitle = _content['title']?.toString() ?? product;
    final productSubtitle = _content['subtitle']?.toString() ?? '';
    final overviewTitle = _content['overviewTitle']?.toString() ?? '';
    final coversTitle = _content['coversTitle']?.toString() ?? 'Key Coverage';
    final targetTitle =
        _content['targetTitle']?.toString() ?? 'Target Customer Segment';
    final taglineTitle = _content['taglineTitle']?.toString() ??
        'Recommended Customer-Friendly Tagline';
    final tagline = _content['tagline']?.toString() ?? '';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = _isDark(context);
    final iconColor = isDark ? const Color(0xFFFFC073) : AppTheme.accentOrange;
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

    Widget sectionHeading(String text) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: keyCoverageColor,
        ),
      );
    }

    Widget bulletRow(String text, IconData icon) {
      return Padding(
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
              child: Icon(icon, color: AppTheme.primaryNavy, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: onSurface)),
            ),
          ],
        ),
      );
    }

    Widget taglineBox(String text) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: iconBorderColor),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.3,
                color: onSurface)),
      );
    }

    Widget productSection(Map<String, dynamic> section) {
      final sectionSubtitle = section['subtitle']?.toString() ?? '';
      final sectionSummary = section['summary']?.toString() ?? '';
      final sectionCovers =
          ((section['covers'] as List?) ?? const []).cast<String>();
      final sectionPolicyTypes =
          ((section['policyTypes'] as List?) ?? const []).cast<String>();
      final sectionCustomers =
          ((section['targetCustomers'] as List?) ?? const []).cast<String>();
      final sectionTagline = section['tagline']?.toString() ?? '';

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionSubtitle.isNotEmpty) ...[
              Text(sectionSubtitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: keyCoverageColor)),
              const SizedBox(height: 14),
            ],
            sectionHeading(section['overviewTitle']?.toString() ??
                '1. Product Overview / Summary'),
            const SizedBox(height: 10),
            Text(sectionSummary,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.36,
                    color: _secondaryTextColor(context))),
            const SizedBox(height: 18),
            sectionHeading(section['coversTitle']?.toString() ??
                '2. Key Features and Benefits'),
            const SizedBox(height: 14),
            ...sectionCovers.map((cover) => bulletRow(cover, Icons.check)),
            if (sectionPolicyTypes.isNotEmpty) ...[
              const SizedBox(height: 4),
              sectionHeading(
                  section['policyTypesTitle']?.toString() ?? '3. Policy Types'),
              const SizedBox(height: 14),
              ...sectionPolicyTypes.map(
                (policyType) =>
                    bulletRow(policyType, Icons.description_outlined),
              ),
            ],
            const SizedBox(height: 4),
            sectionHeading(section['targetTitle']?.toString() ??
                '3. Target Customer Segment'),
            const SizedBox(height: 14),
            ...sectionCustomers
                .map((customer) => bulletRow(customer, Icons.person_outline)),
            if (sectionTagline.isNotEmpty) ...[
              const SizedBox(height: 4),
              sectionHeading(section['taglineTitle']?.toString() ??
                  '4. Recommended Customer-Friendly Tagline'),
              const SizedBox(height: 10),
              taglineBox(sectionTagline),
            ],
          ],
        ),
      );
    }

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
                        child: Text(displayTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: onSurface)),
                      ),
                      if (productSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(productSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                  color: keyCoverageColor)),
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (productSections.isNotEmpty) ...[
                        ...productSections.map(productSection),
                      ] else ...[
                        if (overviewTitle.isNotEmpty) ...[
                          sectionHeading(overviewTitle),
                          const SizedBox(height: 10),
                        ],
                        ...descriptions.map(
                          (description) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text(description,
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
                        sectionHeading(coversTitle),
                        const SizedBox(height: 14),
                        ...covers.map((cover) => bulletRow(cover, Icons.check)),
                        if (bondTypes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          sectionHeading(
                              _content['bondTypesTitle']?.toString() ??
                                  'Types of Bonds'),
                          const SizedBox(height: 14),
                          ...bondTypes.map(
                            (bondType) =>
                                bulletRow(bondType, Icons.description_outlined),
                          ),
                        ],
                        if (targetCustomers.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          sectionHeading(targetTitle),
                          const SizedBox(height: 14),
                          ...targetCustomers.map(
                            (customer) =>
                                bulletRow(customer, Icons.person_outline),
                          ),
                        ],
                        if (tagline.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          sectionHeading(taglineTitle),
                          const SizedBox(height: 10),
                          taglineBox(tagline),
                        ],
                      ],
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
