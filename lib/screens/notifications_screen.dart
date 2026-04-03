import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isAgentFlow;
  const NotificationsScreen({super.key, this.isAgentFlow = false});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0;
  bool get _isAgent => widget.isAgentFlow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications(context);
    });
  }
  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> items, Set<int> read) {
    if (_filter == 1) return items.where((n) => read.contains(n['id'] ?? items.indexOf(n))).toList();
    if (_filter == 2) return items.where((n) => !read.contains(n['id'] ?? items.indexOf(n))).toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notifProvider, child) {
        final list = _filtered(notifProvider.notifications, notifProvider.readIds);
        return Scaffold(backgroundColor: Colors.white,
          appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            title: const Text('Notification', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
          body: notifProvider.loading ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: List.generate(3, (i) => Padding(padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                child: GestureDetector(onTap: () => setState(() => _filter = i),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(color: _filter == i ? AppTheme.primaryNavy : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: _filter == i ? AppTheme.primaryNavy : Colors.grey[300]!)),
                    child: Text(['All','Read','Unread'][i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _filter == i ? Colors.white : Colors.black))))))),
              const SizedBox(height: 20),
              if (list.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No notifications', style: TextStyle(color: Colors.grey[500]))))
              else ...list.map((n) => _card(n, notifProvider)),
              const SizedBox(height: 80),
            ])),
          floatingActionButton: _isAgent ? null : SizedBox(width: 50, height: 50, child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
            backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), child: const Icon(Icons.add, color: Colors.white, size: 24))),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _isAgent ? buildAgentBottomNav(context, currentIndex: 0) : BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 6,
            child: SizedBox(height: 50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _nav(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
              _nav(Icons.description_outlined, 'Policies', false, null), const SizedBox(width: 40),
              _nav(Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
              _nav(Icons.person_outline, 'Profile', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
            ]))),
        );
      }
    );
  }
  Widget _card(Map<String, dynamic> n, NotificationsProvider notifProvider) {
    final id = n['id'] ?? notifProvider.notifications.indexOf(n);
    final unread = !notifProvider.readIds.contains(id);
    final title = n['title']?.toString() ?? n['Title']?.toString() ?? n['subject']?.toString() ?? n['Subject']?.toString() ?? '';
    final msg = n['message']?.toString() ?? n['Message']?.toString() ?? n['body']?.toString() ?? n['Body']?.toString() ?? n['description']?.toString() ?? n['Description']?.toString() ?? n['content']?.toString() ?? '';
    final time = n['time']?.toString() ?? n['created_at']?.toString() ?? n['CreatedAt']?.toString() ?? n['date']?.toString() ?? n['Date']?.toString() ?? n['timestamp']?.toString() ?? '';
    
    // Debug: print all keys for first item
    if (notifProvider.notifications.indexOf(n) == 0) { print('=== NOTIFICATION KEYS: ${n.keys.toList()} ==='); n.forEach((k, v) => print('  $k: $v')); }
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(
      onTap: () {
        if (unread) notifProvider.markAsRead(context, id);
      },
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: unread ? const Color(0xFFF8F9FF) : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryNavy.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(_iconFor(title), color: AppTheme.primaryNavy, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
            if (msg.isNotEmpty) ...[const SizedBox(height: 4), Text(msg, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4))],
            const SizedBox(height: 6),
            Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ])),
          if (unread) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppTheme.primaryNavy, shape: BoxShape.circle)),
        ]))));
  }

  IconData _iconFor(String t) {
    final l = t.toLowerCase();
    if (l.contains('payment')) return Icons.payment_outlined;
    if (l.contains('claim')) return Icons.check_circle_outline;
    if (l.contains('renew')) return Icons.autorenew;
    if (l.contains('offer')) return Icons.local_offer_outlined;
    return Icons.notifications_outlined;
  }

  Widget _nav(IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}
