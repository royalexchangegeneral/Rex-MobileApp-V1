import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'home_protection_id_screen.dart';
import 'customer_renewal_screen.dart';
import 'quote_screen.dart';

class DriversRidersProtectionScreen extends StatelessWidget {
  const DriversRidersProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Drivers & Riders Protection', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.tune, color: Colors.black), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(context, 'Option A', '₦250,000.00', '₦250,000.00', '₦50,000.00', '₦2000', const Color(0xFFFFF3E0), const Color(0xFF5D4037),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Drivers - Option A', totalSteps: 4))),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _card(context, 'Option B', '₦350,000.00', '₦350,000.00', '₦100,000.00', '₦3400', const Color(0xFFE8F5E9), const Color(0xFF2E7D32),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Drivers - Option B', totalSteps: 4))),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _card(context, 'Option C', '₦500,000.00', '₦500,000.00', '₦150,000.00', '₦5000', const Color(0xFFE8EAF6), const Color(0xFF283593),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Drivers - Option C', totalSteps: 4))),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _card(context, 'Option D', '₦750,000.00', '₦750,000.00', '₦200,000.00', '₦7000', const Color(0xFFE8EAF6), const Color(0xFF283593),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Drivers - Option D', totalSteps: 4))),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            _card(context, 'Option E', '₦1,000,000.00', '₦1,000,000.00', '₦250,000.00', '₦9000', const Color(0xFFFCE4EC), const Color(0xFF880E4F),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeProtectionIdScreen(planType: 'Drivers - Option E', totalSteps: 4))),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerRenewalScreen())),
            ),
            const SizedBox(height: 12),
            // Get Quote
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(color: const Color(0xFFF5F0E8), borderRadius: BorderRadius.circular(12)),
              child: Stack(children: [
                Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('For sum insured/benefit more than above', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuoteScreen(insuranceType: 'Drivers & Riders Protection'))), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Get Quote', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  ]),
                ])),
                Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF5D4037).withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(Icons.sports_motorsports_outlined, color: Color(0xFF5D4037), size: 18))),
              ]),
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
      bottomNavigationBar: BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 6, child: SizedBox(height: 50, child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _nav(context, Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
          _nav(context, Icons.description_outlined, 'Policies', true, null),
          const SizedBox(width: 40),
          _nav(context, Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
          _nav(context, Icons.person_outline, 'Profile', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
        ],
      ))),
    );
  }
  Widget _card(BuildContext context, String title, String death, String disability, String medical, String premium, Color bg, Color iconColor, VoidCallback onBuy, VoidCallback onRenew) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Stack(children: [
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 2),
          Text('For sum insured/benefit up to', style: TextStyle(fontSize: 10, color: Colors.grey[700])),
          const SizedBox(height: 8),
          RichText(text: TextSpan(style: const TextStyle(fontSize: 12, color: Colors.black), children: [
            TextSpan(text: '$death ', style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: '(Death)', style: TextStyle(color: Colors.grey)),
          ])),
          const SizedBox(height: 4),
          RichText(text: TextSpan(style: const TextStyle(fontSize: 12, color: Colors.black), children: [
            TextSpan(text: '$disability ', style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: '(Permanent Disability)', style: TextStyle(color: Colors.grey)),
          ])),
          RichText(text: TextSpan(style: const TextStyle(fontSize: 12, color: Colors.black), children: [
            TextSpan(text: '$medical ', style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: '(Medical Expenses)', style: TextStyle(color: Colors.grey)),
          ])),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(onPressed: onBuy, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Buy Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Premium', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              Text('$premium yearly', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
            ]),
            OutlinedButton(onPressed: onRenew, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryNavy, side: const BorderSide(color: AppTheme.primaryNavy), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Renew Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          ]),
        ])),
        Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(Icons.sports_motorsports_outlined, color: iconColor, size: 18))),
      ]),
    );
  }

  Widget _nav(BuildContext context, IconData icon, String label, bool sel, VoidCallback? onTap) => InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: sel ? AppTheme.primaryNavy : Colors.grey, size: 20),
    Text(label, style: TextStyle(fontSize: 10, color: sel ? AppTheme.primaryNavy : Colors.grey)),
  ]));
}
