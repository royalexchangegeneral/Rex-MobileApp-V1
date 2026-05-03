import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'new_ticket_screen.dart';

class ComplaintScreen extends StatelessWidget {
  final bool isAgentFlow;
  const ComplaintScreen({super.key, this.isAgentFlow = false});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Service Request', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Filing a Complaint banner
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFCE4EC), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_outlined, color: Colors.red, size: 20)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Filing a Complaint', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 4),
                Text('We take all complaints seriously and will investigate them promptly. Please select the specific issue below.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.4)),
              ])),
            ])),
          const SizedBox(height: 20),
          _item(context, Icons.computer_outlined, 'NIID Upload & Correction', 'Issues with National Identity Information Database upload or information correction', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
          _item(context, Icons.access_time, 'Delayed Claim Payment', 'Complaints regarding delayed or overdue claim payments and processing', const Color(0xFFFCE4EC), const Color(0xFFE53935)),
          _item(context, Icons.directions_car_outlined, 'VIS Issue', 'Regulatory fine issues and Vehicle Inspection Service related complaints', const Color(0xFFFFF3E0), const Color(0xFFE8923E)),
          SizedBox(height: 16),
          // Important Information
          Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.info_outline, color: AppTheme.primaryNavy, size: 20)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Important Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('Please provide detailed information about your complaint to help us resolve it quickly.', style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
              ])),
            ])),
          const SizedBox(height: 80),
        ])),
      floatingActionButton: isAgentFlow ? null : Transform.translate(offset: const Offset(0, 15), child: SizedBox(width: 52, height: 52, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), elevation: 1, child: const Icon(Icons.add, color: Colors.white, size: 30)))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgentFlow ? buildAgentBottomNav(context, currentIndex: 0) : BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 4,
        child: SizedBox(height: 44, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _nav(context, Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
          _nav(context, Icons.description_outlined, 'Policies', false, null), const SizedBox(width: 48),
          _nav(context, Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
          _nav(context, Icons.person_outline, 'Profile', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
        ]))),
    );
  }

  Widget _item(BuildContext ctx, IconData icon, String title, String sub, Color bg, Color ic) {
    return Padding(padding: EdgeInsets.only(bottom: 12), child: GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => NewTicketScreen(initialCategory: title, isAgentFlow: isAgentFlow))),
      child: Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: ic, size: 20)),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[500], height: 1.3)),
          ])),
        ]))));
  }

  Widget _nav(BuildContext c, IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}
