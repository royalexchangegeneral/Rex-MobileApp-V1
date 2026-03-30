import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import 'policy_purchase_success_screen.dart';

class ComprehensiveSummaryScreen extends StatelessWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;
  final Map<String, String> personalInfo;
  final Map<String, dynamic> vehicleData;

  const ComprehensiveSummaryScreen({super.key, required this.vehicleType, required this.sumInsured, required this.premium, required this.regNumber, this.personalInfo = const {}, this.vehicleData = const {}});

  static const String _paystackSecretKey = 'sk_test_dd6287962b39d4040217583eb0c2abef0d1239b5';

  int _parsePremiumToKobo() {
    final cleaned = premium.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleaned) ?? 0;
    return (amount * 100).toInt();
  }

  Future<void> _initiatePayment(BuildContext context) async {
    final email = personalInfo['email'] ?? 'customer@rexinsure.com';
    final amountInKobo = _parsePremiumToKobo();
    final ref = 'REX_COMP_${DateTime.now().millisecondsSinceEpoch}';

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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicyPurchaseSuccessScreen()));
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(vehicleType, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('Step 5 of 5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: List.generate(5, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 4 ? 4 : 0), decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(2)))))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Product', 'Motor Comprehensive'),
                  _buildInfoRow('Sum Insured', 'N$sumInsured'),
                  _buildInfoRow('Premium', premium),
                  const SizedBox(height: 24),
                  const Text('Vehicle Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Reg Number', vehicleData['registrationNo']?.toString() ?? regNumber),
                  _buildInfoRow('Chassis No.', vehicleData['chassisNo']?.toString() ?? '-'),
                  _buildInfoRow('Make', vehicleData['vehicleMake']?.toString().trim() ?? '-'),
                  _buildInfoRow('Model', vehicleData['vehicleModel']?.toString() ?? '-'),
                  _buildInfoRow('Colour', vehicleData['vehicleColor']?.toString() ?? '-'),
                  _buildInfoRow('Engine Number', vehicleData['vehicleEngineno']?.toString() ?? '-'),
                  _buildInfoRow('Engine Capacity', vehicleData['vehicleEngineCapacity']?.toString() ?? '-'),
                  _buildInfoRow('Category', vehicleData['vehicleCategory']?.toString() ?? '-'),
                  _buildInfoRow('Owner', vehicleData['ownersName']?.toString() ?? '-'),
                  const SizedBox(height: 24),
                  const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  _buildInfoRow('First Name', personalInfo['firstName'] ?? '-'),
                  _buildInfoRow('Last Name', personalInfo['lastName'] ?? '-'),
                  _buildInfoRow('Email', personalInfo['email'] ?? '-'),
                  _buildInfoRow('Phone Number', personalInfo['phone'] ?? '-'),
                  _buildInfoRow('Occupation', personalInfo['occupation'] ?? '-'),
                  _buildInfoRow('State', personalInfo['state'] ?? '-'),
                  _buildInfoRow('LGA', personalInfo['lga'] ?? '-'),
                  _buildInfoRow('Address', personalInfo['address'] ?? '-'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(width: double.infinity, child: ElevatedButton(
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
                            onTap: () { Navigator.pop(ctx); _initiatePayment(context); },
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
                child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
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
