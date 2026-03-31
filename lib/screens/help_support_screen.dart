import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'faq_screen.dart';
import 'customer_care_screen.dart';
import 'office_locations_screen.dart';
import 'live_chat_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});
  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, String>> _faqs = const [
    {'q': 'How do i file a claim?', 'a': 'Go to the Claims section, select your policy, and follow the steps to submit required details and documents'},
    {'q': 'What is covered under my policy?', 'a': 'Your policy covers specific risks as outlined in your policy document. Check your policy details or contact support for specifics.'},
    {'q': 'How to update payment method', 'a': 'Go to your Profile > Account Settings to update your payment information.'},
  ];
  int _expandedIndex = 0;

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Help & Support', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true),
      body: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search
          TextField(controller: _searchController, style: const TextStyle(fontSize: 13, color: Colors.black),
            onSubmitted: (query) {
              if (query.trim().isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FaqScreen(initialSearch: query.trim())));
              }
            },
            decoration: InputDecoration(hintText: 'Search help', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              suffixIcon: GestureDetector(
                onTap: () {
                  if (_searchController.text.trim().isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FaqScreen(initialSearch: _searchController.text.trim())));
                  }
                },
                child: Icon(Icons.search, color: Colors.grey[400]),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
          const SizedBox(height: 24),
          // How can we help you
          const Text('How can we help you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _helpCard(Icons.assignment_outlined, 'Claims', 'File and Track Claims', const Color(0xFFE8EAF6), const Color(0xFF1E2D64), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen(initialCategory: 'Claims'))))),
            const SizedBox(width: 12),
            Expanded(child: _helpCard(Icons.description_outlined, 'Get Quote', 'Compare Rates,\nSave Smarter', const Color(0xFFEDE7F6), const Color(0xFF7C4DFF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen(initialCategory: 'Quotes'))))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _helpCard(Icons.policy_outlined, 'Policies', 'Policy Information', const Color(0xFFFCE4EC), const Color(0xFFE91E63), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen(initialCategory: 'policy'))))),
            const SizedBox(width: 12),
            Expanded(child: _helpCard(Icons.settings_outlined, 'Account', 'Account Settings', const Color(0xFFF3E5F5), const Color(0xFF9C27B0), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen(initialCategory: 'Account'))))),
          ]),
          const SizedBox(height: 28),
          // Contact Us
          const Text('Contact Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 12),
          _contactItem(Icons.headset_mic_outlined, 'Customer Support', 'Get help anytime', const Color(0xFFE3F2FD), const Color(0xFF1565C0), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerCareScreen()))),
          _contactItem(Icons.chat_bubble_outlined, 'Live Chat', 'Available 24/7', const Color(0xFFE0F7FA), const Color(0xFF00ACC1), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveChatScreen()))),
          _contactItem(Icons.phone_outlined, 'Call Us', 'Mon-Fri, 9AM-6PM', const Color(0xFFE8F5E9), const Color(0xFF2E7D32), () => _callAgent()),
          _contactItem(Icons.email_outlined, 'Email Support', 'Response within 24hr', const Color(0xFFF3E5F5), const Color(0xFF7B1FA2), () {}),
          _contactItem(Icons.location_on_outlined, 'Walk-In', 'Locate offices near you.', const Color(0xFFFFF8E1), const Color(0xFFB8860B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfficeLocationsScreen()))),
          const SizedBox(height: 24),
          // FAQs
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('FAQs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
              child: const Text('View all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accentOrange))),
          ]),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (i) {
            final isExpanded = _expandedIndex == i;
            return Column(children: [
              GestureDetector(
                onTap: () => setState(() => _expandedIndex = isExpanded ? -1 : i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(_faqs[i]['q']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                    ]),
                    if (isExpanded) ...[
                      const SizedBox(height: 8),
                      Text(_faqs[i]['a']!, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5)),
                    ],
                  ]),
                ),
              ),
            ]);
          }),
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

  Widget _helpCard(IconData icon, String title, String sub, Color bg, Color ic, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: ic, size: 22)),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ])));
  }

  Widget _contactItem(IconData icon, String title, String sub, Color bg, Color ic, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: ic, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ])),
        Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      ])));
  }

  Future<void> _callAgent() async {
    final uri = Uri(scheme: 'tel', path: '+2347080606100');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showPhoneDialog();
      }
    } catch (_) {
      if (mounted) _showPhoneDialog();
    }
  }

  void _showPhoneDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('+234 708 0606 100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Widget _nav(IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}
