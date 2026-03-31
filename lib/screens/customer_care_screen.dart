import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'new_ticket_screen.dart';
import 'service_request_screen.dart';
import 'complaint_screen.dart';

class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({super.key});
  @override
  State<CustomerCareScreen> createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.headset_mic_outlined, 'title': 'Service Request', 'sub': 'General service inquiries', 'bg': const Color(0xFFE3F2FD), 'ic': const Color(0xFF1565C0)},
    {'icon': Icons.warning_amber_outlined, 'title': 'Complaint', 'sub': 'File a formal complaint', 'bg': const Color(0xFFFCE4EC), 'ic': const Color(0xFFE53935)},
  ];

  final List<Map<String, dynamic>> _tickets = [
    {'id': '#TK001223', 'title': 'Claim status update', 'time': 'Created 25 mins ago', 'status': 'Open', 'color': Colors.green},
    {'id': '#TK001234', 'title': 'Policy premium inquiry', 'time': 'Created 2 days ago', 'status': 'Pending', 'color': Colors.orange},
    {'id': '#TK001223', 'title': 'Claim status update', 'time': 'Created 6 days ago', 'status': 'Resolved', 'color': Colors.green},
    {'id': '#TK001223', 'title': 'Claim status update', 'time': 'Created 6 days ago', 'status': 'Resolved', 'color': Colors.green},
  ];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Customer Care', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search
          TextField(controller: _searchController, style: const TextStyle(fontSize: 13, color: Colors.black),
            decoration: InputDecoration(hintText: 'Search help', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
          const SizedBox(height: 24),
          const Text('Select Issue Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 14),
          ...List.generate(_categories.length, (i) {
            final c = _categories[i];
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildCategoryItem(c['icon'], c['title'], c['sub'], c['bg'], c['ic']));
          }),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            GestureDetector(onTap: () {}, child: const Text('View all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accentOrange))),
          ]),
          const SizedBox(height: 14),
          ...List.generate(_tickets.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildTicketCard(_tickets[i]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewTicketScreen())),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Create New Ticket', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )),
          const SizedBox(height: 80),
        ])),
      floatingActionButton: SizedBox(width: 50, height: 50, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), child: const Icon(Icons.add, color: Colors.white, size: 24))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(height: 50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _nav(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
          _nav(Icons.description_outlined, 'Policies', false, null), const SizedBox(width: 40),
          _nav(Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
          _nav(Icons.person_outline, 'Profile', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
        ]))),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, String sub, Color bg, Color ic) {
    return GestureDetector(onTap: () {
      if (title == 'Service Request') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRequestScreen()));
      } else if (title == 'Complaint') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewTicketScreen()));
      }
    }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: ic, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ])),
        Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
      ])));
  }

  Widget _buildTicketCard(Map<String, dynamic> t) {
    final isResolved = t['status'] == 'Resolved';
    final isPending = t['status'] == 'Pending';
    final statusColor = isResolved ? Colors.green : isPending ? Colors.orange : Colors.green;
    final statusBg = isResolved ? const Color(0xFFE8F5E9) : isPending ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['id'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(t['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(t['time'], style: TextStyle(fontSize: 10, color: Colors.grey[400])),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: statusColor)),
          child: Text(t['status'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor))),
      ]));
  }

  Widget _nav(IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}
