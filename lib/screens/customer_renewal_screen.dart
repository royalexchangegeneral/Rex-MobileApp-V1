import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'policy_renewal_screen.dart';

class CustomerRenewalScreen extends StatefulWidget {
  const CustomerRenewalScreen({super.key});

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Renewal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter policy Number Or Reg. No.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 12),
            TextField(
              controller: _policyController,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'enter policy number',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final value = _policyController.text.trim();
                  if (value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a policy number or reg number')));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PolicyRenewalScreen(policyType: 'Motor Insurance', policyNumber: value)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50, height: 50,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
          backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(height: 50, child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false)),
            _buildNavItem(Icons.description_outlined, 'Policies', true),
            const SizedBox(width: 40),
            _buildNavItem(Icons.assignment_outlined, 'Claims', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
            _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
          ],
        )),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ]),
    );
  }
}
