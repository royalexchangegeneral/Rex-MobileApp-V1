import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'new_ticket_screen.dart';
import 'office_locations_screen.dart';

class ServiceRequestScreen extends StatelessWidget {
  final bool isAgentFlow;
  const ServiceRequestScreen({super.key, this.isAgentFlow = false});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          title: Text('Service Request',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          centerTitle: true),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section(context, 'Policy Services'),
            _item(
                context,
                Icons.headset_mic_outlined,
                'Policy Certificate',
                'General service inquiries',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0)),
            _item(
                context,
                Icons.check_circle_outline,
                'Policy Confirmation',
                'Duration, cover period, limits',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0)),
            _item(
                context,
                Icons.shield_outlined,
                'Policy Verification',
                'Genuity verification',
                const Color(0xFFE8EAF6),
                const Color(0xFF283593)),
            _item(
                context,
                Icons.edit_document,
                'Policy Endorsement',
                'Policy alterations & changes',
                const Color(0xFFFFF3E0),
                const Color(0xFFE8923E)),
            const SizedBox(height: 24),
            _section(context, 'Document Services'),
            _item(
                context,
                Icons.description_outlined,
                'No Claim Document',
                'customers outside the country',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0)),
            _item(
                context,
                Icons.verified_outlined,
                'No Claim Verification',
                'Document verification',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0)),
            _item(
                context,
                Icons.credit_card_outlined,
                'Request for brown card',
                'Agent & Customer',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32)),
            const SizedBox(height: 24),
            _section(context, 'Information Services'),
            _item(
                context,
                Icons.location_on_outlined,
                'Office Address',
                'Location information',
                const Color(0xFFFFF3E0),
                const Color(0xFFE8923E)),
            _item(
                context,
                Icons.people_outline,
                'Staff/Agent Information',
                'General information',
                const Color(0xFFFFF3E0),
                const Color(0xFFE8923E)),
            const SizedBox(height: 24),
            _section(context, 'Claims & Updates'),
            _item(
                context,
                Icons.notifications_outlined,
                'Claim Notification',
                'New claim alerts',
                const Color(0xFFFCE4EC),
                const Color(0xFFE91E63)),
            _item(
                context,
                Icons.update_outlined,
                'Claim Updates',
                'Status updates',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0)),
            const SizedBox(height: 24),
            _section(context, 'Enquiries'),
            _item(
                context,
                Icons.autorenew_outlined,
                'Renewal Enquiries',
                'Policy renewal questions',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32)),
            _item(
                context,
                Icons.info_outline,
                'Product Enquiries',
                'Product information',
                const Color(0xFFE8F5E9),
                const Color(0xFF2E7D32)),
            const SizedBox(height: 24),
            _section(context, 'Payment Services'),
            _item(
                context,
                Icons.payment_outlined,
                'Online Payment Issues',
                'Without insurance certificate',
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0)),
            _item(
                context,
                Icons.sync_outlined,
                'Duplicate Transactions',
                'Deletion/reversal (Agents)',
                const Color(0xFFFFF3E0),
                const Color(0xFFE8923E)),
            const SizedBox(height: 80),
          ])),
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
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 30)))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                        _nav(
                            context,
                            Icons.home_outlined,
                            'Home',
                            false,
                            () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CustomerDashboardScreen()),
                                (r) => false)),
                        _nav(context, Icons.description_outlined, 'Policies',
                            false, null),
                        SizedBox(width: 48),
                        _nav(
                            context,
                            Icons.assignment_outlined,
                            'Claims',
                            false,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MyClaimsScreen()))),
                        _nav(
                            context,
                            Icons.person_outline,
                            'Profile',
                            true,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CustomerProfileScreen()))),
                      ]))),
    );
  }

  Widget _section(BuildContext context, String t) => Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(t,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface)));

  Widget _item(BuildContext ctx, IconData icon, String title, String sub,
      Color bg, Color ic) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
            onTap: () {
              if (title == 'Office Address') {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) =>
                            OfficeLocationsScreen(isAgentFlow: isAgentFlow)));
              } else {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) => NewTicketScreen(
                            initialCategory: title, isAgentFlow: isAgentFlow)));
              }
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                    color: ThemeHelper.getCardColor(ctx),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration:
                          BoxDecoration(color: bg, shape: BoxShape.circle),
                      child: Icon(icon, color: ic, size: 20)),
                  SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(ctx).colorScheme.onSurface)),
                        Text(sub,
                            style: TextStyle(
                                fontSize: 10,
                                color: ThemeHelper.getSecondaryTextColor(ctx))),
                      ])),
                ]))));
  }

  Widget _nav(BuildContext c, IconData i, String l, bool s, VoidCallback? o) =>
      InkWell(
          onTap: o,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20),
            Text(l,
                style: TextStyle(
                    fontSize: 10,
                    color: s ? AppTheme.primaryNavy : Colors.grey))
          ]));
}
