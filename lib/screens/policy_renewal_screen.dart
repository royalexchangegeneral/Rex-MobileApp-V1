import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'policy_purchase_success_screen.dart';

class PolicyRenewalScreen extends StatelessWidget {
  final String policyType;
  final String policyNumber;
  final bool isAgentFlow;

  const PolicyRenewalScreen({super.key, required this.policyType, required this.policyNumber, this.isAgentFlow = false});

  static const String _paystackSecretKey = 'sk_test_dd6287962b39d4040217583eb0c2abef0d1239b5';

  Future<void> _initiatePayment(BuildContext context, String email) async {
    final ref = 'REX_RENEW_${DateTime.now().millisecondsSinceEpoch}';
    final amountInKobo = 1500000; // 15000 * 100

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)));

    try {
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {'Authorization': 'Bearer $_paystackSecretKey', 'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'amount': amountInKobo, 'reference': ref, 'currency': 'NGN', 'callback_url': 'https://rexinsure.com/payment-callback'}),
      ).timeout(const Duration(seconds: 15));

      if (!context.mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final authUrl = data['data']['authorization_url'];
          final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => _PaystackWebView(url: authUrl, callbackUrl: 'https://rexinsure.com/payment-callback')));
          if (result == true && context.mounted) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PolicyPurchaseSuccessScreen()), (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Payment failed'), backgroundColor: Colors.red));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to initialize payment'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userData = auth.userData;
    final email = userData?['Email']?.toString() ?? 'customer@rexinsure.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Renewal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    const Text('Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 3, decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(2))),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Policy Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 14),
                        _buildInfoRow('Policy Number', policyNumber),
                        _buildInfoRow('Product', policyType),
                        _buildInfoRow('Premium', 'N15,000'),
                        _buildInfoRow('Start Date', '2/04/2025'),
                        _buildInfoRow('End Date', '2/04/2026'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personal Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 14),
                        _buildInfoRow('First Name', userData?['FirstName']?.toString() ?? '-'),
                        _buildInfoRow('Last Name', userData?['LastName']?.toString() ?? userData?['Lastname']?.toString() ?? '-'),
                        _buildInfoRow('Email', userData?['Email']?.toString() ?? '-'),
                        _buildInfoRow('Phone Number', userData?['Phone']?.toString() ?? userData?['PhoneNo']?.toString() ?? '-'),
                        _buildInfoRow('Occupation', userData?['Occupation']?.toString() ?? '-'),
                        _buildInfoRow('State', userData?['State']?.toString() ?? '-'),
                        _buildInfoRow('LGA', userData?['LGA']?.toString() ?? '-'),
                        _buildInfoRow('Address', userData?['Address']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vehicle Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 14),
                        _buildInfoRow('Reg Number', 'AB 789 CD'),
                        _buildInfoRow('Chassis No.', '1HGCMBB2633A123456'),
                        _buildInfoRow('Make', 'Honda'),
                        _buildInfoRow('Colour', 'Silver'),
                        _buildInfoRow('Model', 'City VX'),
                        _buildInfoRow('Engine Number', 'G4KEBX123456'),
                        _buildInfoRow('Engine Capacity', '1.5L'),
                        _buildInfoRow('Year', '2024'),
                        _buildInfoRow('Model', '2024'),
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
            padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () { Navigator.pop(ctx); _initiatePayment(context, email); },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                              child: Row(children: [
                                Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.payment, color: Colors.cyan[600], size: 24)),
                                const SizedBox(width: 16),
                                const Text('Pay with Paystack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                                const Spacer(),
                                Icon(Icons.radio_button_checked, color: AppTheme.primaryNavy, size: 22),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Renew Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAgentFlow ? null : SizedBox(width: 50, height: 50, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      )),
      floatingActionButtonLocation: isAgentFlow ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgentFlow ? buildAgentBottomNav(context, currentIndex: 1) : BottomAppBar(
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.right)),
        ],
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

class _PaystackWebView extends StatefulWidget {
  final String url;
  final String callbackUrl;
  const _PaystackWebView({required this.url, required this.callbackUrl});
  @override
  State<_PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<_PaystackWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (request) {
          if (request.url.startsWith(widget.callbackUrl)) { Navigator.pop(context, true); return NavigationDecision.prevent; }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context, false)), title: const Text('Payment', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)), centerTitle: true),
      body: Stack(children: [WebViewWidget(controller: _controller), if (_isLoading) const Center(child: CircularProgressIndicator())]),
    );
  }
}
