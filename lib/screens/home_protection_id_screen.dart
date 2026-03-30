import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'quote_screen.dart';

class HomeProtectionIdScreen extends StatefulWidget {
  final String planType;
  final int totalSteps;
  const HomeProtectionIdScreen({super.key, required this.planType, this.totalSteps = 4});
  @override
  State<HomeProtectionIdScreen> createState() => _HomeProtectionIdScreenState();
}

class _HomeProtectionIdScreenState extends State<HomeProtectionIdScreen> {
  String? _selectedIdType;
  final _idNumberController = TextEditingController();
  final List<String> _idTypes = ['BVN', 'NIN'];

  String get _idLabel {
    if (_selectedIdType == 'BVN') return 'Bank Verification Number';
    if (_selectedIdType == 'NIN') return 'National Identification Number';
    return '';
  }

  String get _idHint {
    if (_selectedIdType == 'BVN') return 'enter your BVN';
    if (_selectedIdType == 'NIN') return 'enter your NIN';
    return '';
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Home Protection Plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Step 2 of ${widget.totalSteps}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                      const Text('Mode of Identification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(children: List.generate(widget.totalSteps, (i) => Expanded(child: Container(
                    height: 3, margin: EdgeInsets.only(right: i < widget.totalSteps - 1 ? 4 : 0),
                    decoration: BoxDecoration(color: i < 2 ? AppTheme.primaryNavy : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  )))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Type dropdown
                  const Text('Select mode of Identification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonFormField<String>(
                      value: _selectedIdType,
                      hint: Text('select identification', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                      items: _idTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() { _selectedIdType = val; _idNumberController.clear(); }),
                    ),
                  ),

                  // ID Number field (shown when type is selected)
                  if (_selectedIdType != null) ...[
                    const SizedBox(height: 20),
                    Text(_idLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _idNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _idHint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Continue button
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedIdType != null && _idNumberController.text.trim().length == 11) ? () {
                    // Navigate to quote screen for now
                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuoteScreen(insuranceType: 'Home Protection - ${widget.planType}')));
                  } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), disabledBackgroundColor: Colors.grey[300]),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
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
            _nav(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
            _nav(Icons.description_outlined, 'Policies', true, null),
            const SizedBox(width: 40),
            _nav(Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
            _nav(Icons.person_outline, 'Profile', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
          ],
        )),
      ),
    );
  }

  Widget _nav(IconData icon, String label, bool sel, VoidCallback? onTap) => InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: sel ? AppTheme.primaryNavy : Colors.grey, size: 20),
    Text(label, style: TextStyle(fontSize: 10, color: sel ? AppTheme.primaryNavy : Colors.grey)),
  ]));
}
