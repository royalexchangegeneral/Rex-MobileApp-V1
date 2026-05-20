import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'private_car_purchase_screen.dart';
import 'comprehensive_personal_info_screen.dart';
import 'new_policy_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'customer_renewal_screen.dart';
import 'quote_screen.dart';
import 'royal_auto_purchase_screen.dart';

class CustomerMotorInsuranceScreen extends StatelessWidget {
  final bool isAgent;
  final Map<String, dynamic>? clientData;
  final String agentCode;

  const CustomerMotorInsuranceScreen(
      {super.key, this.isAgent = false, this.clientData, this.agentCode = ''});

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _cardColor(BuildContext context, Color lightColor) =>
      _isDark(context) ? const Color(0xFF111827) : lightColor;

  Color _cardBorderColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFF334155) : Colors.transparent;

  Color _secondaryTextColor(BuildContext context) =>
      _isDark(context) ? const Color(0xFFCBD5E1) : Colors.grey[700]!;

  Color _buttonColor(BuildContext context) =>
      _isDark(context) ? AppTheme.accentOrange : AppTheme.primaryNavy;

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
        title: Text('Motor Insurance',
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
              title: 'Private Car',
              subtitle: 'For sum insured/benefit up to',
              amount: '₦ 1,000,000.00',
              premium: '₦15,000',
              premiumPeriod: 'yearly',
              bgColor: const Color(0xFFE3EDF7),
              iconBgColor: const Color(0xFF3D5A80),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrivateCarPurchaseScreen(
                          clientData: clientData,
                          price: 'N15,000',
                          isLoggedIn: true,
                          isAgent: isAgent,
                          agentCode: agentCode))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Private Bus',
              subtitle: 'For sum insured/benefit up to',
              amount: '₦ 1,000,000.00',
              premium: '₦20,000',
              premiumPeriod: 'yearly',
              bgColor: const Color(0xFFF5E6DC),
              iconBgColor: const Color(0xFFBFA58A),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrivateCarPurchaseScreen(
                          clientData: clientData,
                          vehicleType: 'Private Bus',
                          price: '₦20,000',
                          isLoggedIn: true,
                          isAgent: isAgent,
                          agentCode: agentCode))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Commercial Bus',
              subtitle: 'For sum insured/benefit up to',
              amount: '₦ 1,000,000.00',
              premium: '₦20,000',
              premiumPeriod: 'yearly',
              bgColor: const Color(0xFFE0F5F0),
              iconBgColor: const Color(0xFF2A9D8F),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrivateCarPurchaseScreen(
                          clientData: clientData,
                          vehicleType: 'Commercial Bus',
                          price: '₦20,000',
                          isLoggedIn: true,
                          isAgent: isAgent,
                          agentCode: agentCode))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Motorcycle',
              subtitle: 'For sum insured/benefit up to',
              amount: '₦ 1,000,000.00',
              premium: '₦3,000',
              premiumPeriod: 'yearly',
              bgColor: const Color(0xFFFFF9DB),
              iconBgColor: const Color(0xFF6B705C),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrivateCarPurchaseScreen(
                          clientData: clientData,
                          vehicleType: 'Motorcycle',
                          price: '₦3,000',
                          isLoggedIn: true,
                          isAgent: isAgent,
                          agentCode: agentCode))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Tricycle (Keke)',
              subtitle: 'For sum insured/benefit up to',
              amount: '₦ 1,000,000.00',
              premium: '₦5,000',
              premiumPeriod: 'yearly',
              bgColor: const Color(0xFFF5E6DC),
              iconBgColor: const Color(0xFFE07A5F),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrivateCarPurchaseScreen(
                          clientData: clientData,
                          vehicleType: 'Tricycle (Keke)',
                          price: '₦5,000',
                          isLoggedIn: true,
                          isAgent: isAgent,
                          agentCode: agentCode))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Motor Comprehensive (Private & Commercial)',
              subtitle: 'Coverage up to',
              amount: '₦3,000,000',
              premium: '5%',
              premiumPeriod: 'of sum insured',
              bgColor: const Color(0xFFE3EDF7),
              iconBgColor: const Color(0xFF3D5A80),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ComprehensivePersonalInfoScreen(
                          isLoggedIn: true, isAgent: isAgent))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Royal Auto Bronze',
              subtitle: 'Coverage up to',
              amount: '₦3,000,000',
              premium: '3%',
              premiumPeriod: '+ ₦15,000/m',
              bgColor: const Color(0xFFF8E0E0),
              iconBgColor: const Color(0xFFC1121F),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoyalAutoPurchaseScreen(
                          productName: 'Royal Auto Bronze',
                          price: 'Premium – 3% + N15,000/m'))),
            ),
            const SizedBox(height: 12),
            _buildInsuranceCard(
              context,
              title: 'Royal Auto Silver',
              subtitle: 'Coverage up to',
              amount: '₦3,000,000',
              premium: '3%',
              premiumPeriod: '+ ₦15,000/m',
              bgColor: const Color(0xFFFFF5E6),
              iconBgColor: const Color(0xFFC1121F),
              onBuyNow: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoyalAutoPurchaseScreen(
                          productName: 'Royal Auto Silver',
                          price: 'Premium – 3% + N15,000/m'))),
            ),
            const SizedBox(height: 12),
            _buildGetQuoteCard(
              context,
              title: 'Royal Auto Plan (Gold)',
              subtitle: 'Royal Auto Gold',
              amount: 'For sum insured/benefit more than above',
              bgColor: const Color(0xFFE0F5F0),
              iconBgColor: const Color(0xFF2A9D8F),
              onGetQuote: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuoteScreen(
                          insuranceType: 'Royal Auto Plan (Gold)'))),
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

  Widget _buildNairaText(String text,
      {double fontSize = 13,
      FontWeight fontWeight = FontWeight.bold,
      Color color = Colors.black}) {
    return Text(text,
        style: TextStyle(
            fontSize: fontSize, fontWeight: fontWeight, color: color));
  }

  Widget _buildInsuranceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required String premium,
    required String premiumPeriod,
    required Color bgColor,
    required Color iconBgColor,
    required VoidCallback onBuyNow,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _cardColor(context, bgColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorderColor(context)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10, color: _secondaryTextColor(context))),
                _buildNairaText(amount,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onBuyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Buy Now',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium',
                            style: TextStyle(
                                fontSize: 10,
                                color: _secondaryTextColor(context))),
                        const SizedBox(height: 2),
                        Text(
                            premium.contains('%')
                                ? '$premium $premiumPeriod'
                                : '$premium / $premiumPeriod',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerRenewalScreen())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _buttonColor(context),
                        side: BorderSide(color: _buttonColor(context)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Renew Now',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: const Icon(Icons.directions_car,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
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

  Widget _buildGetQuoteCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required Color bgColor,
    required Color iconBgColor,
    required VoidCallback onGetQuote,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _cardColor(context, bgColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorderColor(context)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10, color: _secondaryTextColor(context))),
                Text(amount,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onGetQuote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Get Quote',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: const Icon(Icons.directions_car,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
