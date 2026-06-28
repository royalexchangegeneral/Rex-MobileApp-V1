import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_policy_provider.dart';
import '../providers/policy_provider.dart';
import '../utils/app_theme.dart';
import '../utils/renewal_guard.dart';
import '../utils/theme_helper.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'policy_renewal_screen.dart';

class CustomerRenewalScreen extends StatefulWidget {
  final bool isAgentFlow;

  const CustomerRenewalScreen({super.key, this.isAgentFlow = false});

  @override
  State<CustomerRenewalScreen> createState() => _CustomerRenewalScreenState();
}

class _CustomerRenewalScreenState extends State<CustomerRenewalScreen> {
  final _policyController = TextEditingController();

  @override
  void dispose() {
    _policyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter policy Number Or Reg. No.',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            TextField(
              controller: _policyController,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'enter policy number',
                hintStyle: TextStyle(
                    color: ThemeHelper.getSecondaryTextColor(context),
                    fontSize: 14),
                filled: true,
                fillColor: ThemeHelper.getCardColor(context),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: ThemeHelper.getBorderColor(context))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: ThemeHelper.getBorderColor(context))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryNavy, width: 2)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final value = _policyController.text.trim();
                  if (value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Please enter a policy number or reg number')));
                    return;
                  }
                  final policyData = _findPolicy(value);
                  if (widget.isAgentFlow && policyData == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Policy not found. Please enter a valid policy number or reg number.')));
                    return;
                  }

                  if (!RenewalGuard.canRenew(policyData)) {
                    RenewalGuard.showNotRenewableDialog(context);
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PolicyRenewalScreen(
                              policyType:
                                  policyData?['policyClass']?.toString() ??
                                      'Motor Insurance',
                              policyNumber:
                                  policyData?['policyId']?.toString() ?? value,
                              premium:
                                  policyData?['premium']?.toString() ?? '0',
                              isAgentFlow: widget.isAgentFlow,
                              policyData: policyData)));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Continue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isAgentFlow
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
                ),
              ),
            ),
      floatingActionButtonLocation:
          widget.isAgentFlow ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.isAgentFlow
          ? buildAgentBottomNav(context, currentIndex: 1)
          : BottomAppBar(
              color: AppTheme.bottomNavBackgroundColor(context),
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_outlined, 'Home', false,
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerDashboardScreen()),
                              (route) => false)),
                      _buildNavItem(
                          Icons.description_outlined, 'Policies', true),
                      const SizedBox(width: 48),
                      _buildNavItem(Icons.assignment_outlined, 'Claims', false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyClaimsScreen()))),
                      _buildNavItem(Icons.person_outline, 'Profile', false,
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

  Widget _buildNavItem(IconData icon, String label, bool isSelected,
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

  Map<String, dynamic>? _findPolicy(String value) {
    final query = value.toLowerCase().trim();
    if (query.isEmpty) return null;

    final policies = widget.isAgentFlow
        ? context.read<AgentPolicyProvider>().policies
        : context.read<PolicyProvider>().policies;
    for (final policy in policies) {
      final searchableValues = [
        'policyId',
        'PolicyID',
        'insured',
        'Insured',
        'RegNo',
        'RegNumber',
        'RegistrationNo',
        'RegistrationNumber',
        'VehicleRegNo',
        'VehicleRegistrationNo',
        'vehregno',
        'registrationNo',
        'regNumber',
      ].map((key) => policy[key]?.toString().toLowerCase().trim());

      if (searchableValues.any((value) => value == query)) {
        return policy;
      }
    }
    return null;
  }
}
