import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../providers/policy_provider.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          title: Text('Payments',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          centerTitle: true),
      body: Consumer<PolicyProvider>(builder: (context, policyProvider, _) {
        if (policyProvider.loading)
          return const Center(child: CircularProgressIndicator());
        final policies = policyProvider.policies;
        if (policies.isEmpty) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Icons.payment, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('No payments found',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ]));
        }
        // Sort by start date, most recent first
        final sorted = List<Map<String, dynamic>>.from(policies);
        sorted.sort((a, b) {
          final da = DateTime.tryParse(a['startDate']?.toString() ?? '') ??
              DateTime(1900);
          final db = DateTime.tryParse(b['startDate']?.toString() ?? '') ??
              DateTime(1900);
          return db.compareTo(da);
        });
        return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recent Payments',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),
              ...sorted.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildPaymentCard(context, p))),
              const SizedBox(height: 100),
            ]));
      }),
      floatingActionButton: Transform.translate(
          offset: const Offset(0, 15),
          child: SizedBox(
              width: 52,
              height: 52,
              child: FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewPolicyScreen())),
                  backgroundColor: AppTheme.accentOrange,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 30)))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 4,
          child: SizedBox(
              height: 44,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _nav(Icons.home_outlined, 'Home', false,
                        onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerDashboardScreen()),
                            (r) => false)),
                    _nav(Icons.description_outlined, 'Policies', false),
                    const SizedBox(width: 48),
                    _nav(Icons.assignment_outlined, 'Claims', false,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyClaimsScreen()))),
                    _nav(Icons.person_outline, 'Profile', false,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerProfileScreen()))),
                  ]))),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> p) {
    final policyClass = p['policyClass']?.toString() ?? '';
    final isActive = p['status'] == 'Active';
    final icon = policyClass.toLowerCase().contains('motor')
        ? Icons.directions_car_outlined
        : policyClass.toLowerCase().contains('home')
            ? Icons.home_outlined
            : policyClass.toLowerCase().contains('shop')
                ? Icons.store_outlined
                : policyClass.toLowerCase().contains('personal')
                    ? Icons.person_outline
                    : policyClass.toLowerCase().contains('family')
                        ? Icons.family_restroom_outlined
                        : policyClass.toLowerCase().contains('student')
                            ? Icons.school_outlined
                            : policyClass.toLowerCase().contains('parcel')
                                ? Icons.local_shipping_outlined
                                : Icons.description_outlined;

    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: ThemeHelper.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(icon, color: AppTheme.primaryNavy, size: 18)),
            SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('$policyClass Insurance',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text('Policy #${p['policyId'] ?? ''}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(14)),
                child: Text(isActive ? 'Active' : 'Expired',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white))),
          ]),
          const SizedBox(height: 14),
          _row('Premium', '₦${p['premium'] ?? '0'}'),
          const SizedBox(height: 8),
          _row('Payment Method', 'Paystack'),
          const SizedBox(height: 8),
          _row('Start Date', p['startDate']?.toString() ?? '-'),
          const SizedBox(height: 8),
          _row('End Date', p['endDate']?.toString() ?? '-'),
          const SizedBox(height: 8),
          _row('Policy ID', p['policyId']?.toString() ?? '-'),
          SizedBox(height: 4),
          Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: p['policyId']?.toString() ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Policy ID copied'),
                        duration: Duration(seconds: 1)));
                  },
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.copy, size: 13, color: AppTheme.accentOrange),
                    SizedBox(width: 4),
                    Text('Copy',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w600))
                  ]))),
        ]));
  }

  Widget _row(String l, String v) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(v,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87))
      ]);

  Widget _nav(IconData icon, String label, bool sel, {VoidCallback? onTap}) =>
      InkWell(
          onTap: onTap,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: sel ? AppTheme.primaryNavy : Colors.grey, size: 20),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: sel ? AppTheme.primaryNavy : Colors.grey))
          ]));
}
