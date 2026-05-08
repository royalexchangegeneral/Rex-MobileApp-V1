import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import '../widgets/agent_bottom_nav.dart';
import '../widgets/paystack_webview.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'policy_purchase_success_screen.dart';

class PolicyRenewalScreen extends StatelessWidget {
  final String policyType;
  final String policyNumber;
  final String premium;
  final bool isAgentFlow;
  final Map<String, dynamic>? policyData;

  const PolicyRenewalScreen(
      {super.key,
      required this.policyType,
      required this.policyNumber,
      this.premium = '0',
      this.isAgentFlow = false,
      this.policyData});

  Future<void> _initiatePayment(BuildContext context, String email) async {
    final cleaned = premium.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleaned) ?? 0;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.white)));

    final result = await PaymentService.initiateRenewal(
      email: email,
      premium: amount.toInt(),
      policyNumber: policyNumber,
    );

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result.success && result.authorizationUrl != null) {
      final payResult = await Navigator.push<PaymentVerifyResult>(
          context,
          MaterialPageRoute(
              builder: (_) => PaystackWebView(url: result.authorizationUrl!)));
      if (payResult != null && payResult.success && context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => PolicyPurchaseSuccessScreen(
                    isLoggedIn: true,
                    isAgent: isAgentFlow,
                    reference: payResult.reference,
                    message: payResult.message)),
            (route) => false);
      } else if (payResult != null && !payResult.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(payResult.message ?? 'Payment verification failed'),
            backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? 'Payment failed'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userData = auth.userData;
    final email = userData?['Email']?.toString() ?? 'customer@rexinsure.com';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Renewal',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    Text('Summary',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                    height: 3,
                    decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Policy Information
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: ThemeHelper.getSecondaryCardColor(context),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Policy Information',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 14),
                        _buildInfoRow(context, 'Policy Number', policyNumber),
                        _buildInfoRow(context, 'Product', policyType),
                        _buildInfoRow(context, 'Premium', '₦$premium'),
                        _buildInfoRow(context, 'Start Date', '2/04/2025'),
                        _buildInfoRow(context, 'End Date', '2/04/2026'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personal Information
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: ThemeHelper.getSecondaryCardColor(context),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personal Information',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 14),
                        if (isAgentFlow && policyData != null) ...[
                          _buildInfoRow(
                              context,
                              'Insured',
                              policyData!['insured']?.toString() ??
                                  policyData!['customerName']?.toString() ??
                                  '-'),
                          _buildInfoRow(context, 'Policy Class',
                              policyData!['policyClass']?.toString() ?? '-'),
                          _buildInfoRow(context, 'Sum Insured',
                              '₦${policyData!['sumInsured']?.toString() ?? '0'}'),
                          _buildInfoRow(context, 'Start Date',
                              policyData!['startDate']?.toString() ?? '-'),
                          _buildInfoRow(context, 'End Date',
                              policyData!['endDate']?.toString() ?? '-'),
                        ] else ...[
                          _buildInfoRow(context, 'First Name',
                              userData?['FirstName']?.toString() ?? '-'),
                          _buildInfoRow(
                              context,
                              'Last Name',
                              userData?['LastName']?.toString() ??
                                  userData?['Lastname']?.toString() ??
                                  '-'),
                          _buildInfoRow(context, 'Email',
                              userData?['Email']?.toString() ?? '-'),
                          _buildInfoRow(
                              context,
                              'Phone Number',
                              userData?['Phone']?.toString() ??
                                  userData?['PhoneNo']?.toString() ??
                                  '-'),
                          _buildInfoRow(context, 'Occupation',
                              userData?['Occupation']?.toString() ?? '-'),
                          _buildInfoRow(context, 'State',
                              userData?['State']?.toString() ?? '-'),
                          _buildInfoRow(context, 'LGA',
                              userData?['LGA']?.toString() ?? '-'),
                          _buildInfoRow(context, 'Address',
                              userData?['Address']?.toString() ?? '-'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Information
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: ThemeHelper.getSecondaryCardColor(context),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle Information',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 14),
                        _buildInfoRow(context, 'Reg Number', 'AB 789 CD'),
                        _buildInfoRow(
                            context, 'Chassis No.', '1HGCMBB2633A123456'),
                        _buildInfoRow(context, 'Make', 'Honda'),
                        _buildInfoRow(context, 'Colour', 'Silver'),
                        _buildInfoRow(context, 'Model', 'City VX'),
                        _buildInfoRow(context, 'Engine Number', 'G4KEBX123456'),
                        _buildInfoRow(context, 'Engine Capacity', '1.5L'),
                        _buildInfoRow(context, 'Year', '2024'),
                        _buildInfoRow(context, 'Model', '2024'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Renew Now button
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 8, 24, 16 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: ThemeHelper.getBorderColor(context),
                                  borderRadius: BorderRadius.circular(2))),
                          SizedBox(height: 24),
                          InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              _initiatePayment(context, email);
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          ThemeHelper.getBorderColor(context)),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: ThemeHelper.isDarkMode(context)
                                            ? Colors.cyan[700]!
                                                .withOpacity(0.16)
                                            : Colors.cyan[50],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.payment,
                                        color: ThemeHelper.isDarkMode(context)
                                            ? Colors.cyan[200]
                                            : Colors.cyan[600],
                                        size: 24)),
                                SizedBox(width: 16),
                                Text('Pay with Paystack',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                                const Spacer(),
                                Icon(Icons.radio_button_checked,
                                    color: AppTheme.primaryNavy, size: 22),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Renew Now',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAgentFlow
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
                            builder: (_) => const NewPolicyScreen())),
                    backgroundColor: AppTheme.accentOrange,
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ))),
      floatingActionButtonLocation:
          isAgentFlow ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgentFlow
          ? buildAgentBottomNav(context, currentIndex: 1)
          : BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, Icons.home_outlined, 'Home', false,
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerDashboardScreen()),
                              (route) => false)),
                      _buildNavItem(context, Icons.description_outlined,
                          'Policies', true),
                      const SizedBox(width: 48),
                      _buildNavItem(
                          context, Icons.assignment_outlined, 'Claims', false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyClaimsScreen()))),
                      _buildNavItem(
                          context, Icons.person_outline, 'Profile', false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerProfileScreen()))),
                    ],
                  )),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: ThemeHelper.getSecondaryTextColor(context)))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
            color: isSelected
                ? AppTheme.primaryNavy
                : ThemeHelper.getSecondaryTextColor(context),
            size: 20),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? AppTheme.primaryNavy
                    : ThemeHelper.getSecondaryTextColor(context))),
      ]),
    );
  }
}
