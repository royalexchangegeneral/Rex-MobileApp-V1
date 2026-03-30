import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'new_ticket_screen.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Service Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {})]),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Filing a Complaint banner
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFCE4EC), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_outlined, color: Colors.red, size: 20)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Filing a Complaint', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 4),
                Text('We take all complaints seriously and will investigate them promptly. Please select the specific issue below.', style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
              ])),
            ])),
          const SizedBox(height: 20),
          _item(context, Icons.computer_outlined, 'NIID Upload & Correction', 'Issues with National Identity Information Database upload or information correction', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
          _item(context, Icons.access_time, 'Delayed Claim Payment', 'Complaints regarding delayed or overdue claim payments and processing', const Color(0xFFFCE4EC), const Color(0xFFE53935)),
          _item(context, Icons.directions_car_outlined, 'VIS Issue', 'Regulatory fine issues and Vehicle Inspection Service related complaints', const Color(0xFFFFF3E0), const Color(0xFFE8923E)),
          const SizedBox(height: 16),
          // Important Information
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.info_outline, color: AppTheme.primaryNavy, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Important Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                Text('Please provide detailed information about your complaint to help us resolve it quickly.', style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
              ])),
            ])),
          const SizedBox(height: 80),
        ])),
      floatingActionButton: SizedBox(width: 50, height: 50, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), child: const Icon(Icons.add, color: Colors.white, size: 24))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(height: 50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _nav(context, Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
          _nav(context, Icons.description_outlined, 'Policies', false, null), const SizedBox(width: 40),
          _nav(context, Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
          _nav(context, Icons.person_outline, 'Profile', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
        ]))),
    );
  }

  Widget _item(BuildContext ctx, IconData icon, String title, String sub, Color bg, Color ic) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => NewTicketScreen(initialCategory: title))),
      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: ic, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[500], height: 1.3)),
          ])),
        ]))));
  }

  Widget _nav(BuildContext c, IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}
