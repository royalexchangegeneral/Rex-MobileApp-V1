import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'home_protection_id_screen.dart';
import 'customer_renewal_screen.dart';
import 'quote_screen.dart';

class HomeProtectionPlanScreen extends StatelessWidget {
  const HomeProtectionPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Home Protection Plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.tune, color: Colors.black), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOptionCard(context, title: 'Option A', subtitle: 'For sum insured/benefit up to', amount: '₦500,000.00', premium: '₦2500', bgColor: const Color(0xFFFFF3E0), iconColor: const Color(0xFFB8860B),
              onBuy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Option A', totalSteps: 4))),
              onRenew: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(context, title: 'Option B', subtitle: 'For sum insured/benefit up to', amount: '₦750,000.00', premium: '₦3750', bgColor: const Color(0xFFFFFDE7), iconColor: const Color(0xFFB8860B),
              onBuy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Option B', totalSteps: 4))),
              onRenew: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(context, title: 'Option C', subtitle: 'For sum insured/benefit up to', amount: '₦1,000,000.00', premium: '₦5000', bgColor: const Color(0xFFFCE4EC), iconColor: const Color(0xFFC62828),
              onBuy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Option C', totalSteps: 4))),
              onRenew: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(context, title: 'Option D', subtitle: 'For sum insured/benefit up to', amount: '₦1,500,000.00', premium: '₦7500', bgColor: const Color(0xFFFFF8E1), iconColor: const Color(0xFFB8860B),
              onBuy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Option D', totalSteps: 4))),
              onRenew: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _buildOptionCard(context, title: 'Option E', subtitle: 'For sum insured/benefit up to', amount: '₦2,000,000.00', premium: '₦10000', bgColor: const Color(0xFFE8F5E9), iconColor: const Color(0xFF2E7D32),
              onBuy: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Option E', totalSteps: 4))),
              onRenew: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            // Get Quote card
            _buildGetQuoteCard(context, amount: '₦2,000,000.00', bgColor: const Color(0xFFFFF8E1), iconColor: const Color(0xFFB8860B),
              onGetQuote: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuoteScreen(insuranceType: 'Home Protection Plan'))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: SizedBox(width: 50, height: 50, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(height: 50, child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(context, Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
            _nav(context, Icons.description_outlined, 'Policies', true, null),
            const SizedBox(width: 40),
            _nav(context, Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
            _nav(context, Icons.person_outline, 'Profile', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
          ],
        )),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required String title, required String subtitle, required String amount, required String premium, required Color bgColor, required Color iconColor, required VoidCallback onBuy, required VoidCallback onRenew}) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(onPressed: onBuy, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Buy Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Premium', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text('$premium yearly', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                  ]),
                  OutlinedButton(onPressed: onRenew, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryNavy, side: const BorderSide(color: AppTheme.primaryNavy), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Renew Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                ]),
              ],
            ),
          ),
          Positioned(top: 8, right: 8, child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.home_outlined, color: iconColor, size: 18),
          )),
        ],
      ),
    );
  }

  Widget _buildGetQuoteCard(BuildContext context, {required String amount, required Color bgColor, required Color iconColor, required VoidCallback onGetQuote}) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('For sum insured/benefit above', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(onPressed: onGetQuote, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Get Quote', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
          Positioned(top: 8, right: 8, child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.home_outlined, color: iconColor, size: 18),
          )),
        ],
      ),
    );
  }

  Widget _nav(BuildContext context, IconData icon, String label, bool sel, VoidCallback? onTap) => InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: sel ? AppTheme.primaryNavy : Colors.grey, size: 20),
    Text(label, style: TextStyle(fontSize: 10, color: sel ? AppTheme.primaryNavy : Colors.grey)),
  ]));
}
