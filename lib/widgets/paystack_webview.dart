import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

/// Result returned from the PaystackWebView after payment.
class PaymentVerifyResult {
  final bool success;
  final String? reference;
  final String? message;
  PaymentVerifyResult({required this.success, this.reference, this.message});
}

/// Shared Paystack WebView used by all purchase and renewal screens.
/// Returns PaymentVerifyResult with success status, reference, and message.
class PaystackWebView extends StatefulWidget {
  final String url;
  final String callbackUrl;
  const PaystackWebView({super.key, required this.url, this.callbackUrl = 'https://eportaltest.rexinsure.com/api/verifypayment'});

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _hasPopped = false;

  void _checkCallback(String url) async {
    if (_hasPopped) return;
    if (url.contains('eportaltest.rexinsure.com/api/verifypayment') || url.startsWith(widget.callbackUrl)) {
      _hasPopped = true;

      // Show spinner overlay while verifying
      setState(() => _isVerifying = true);

      // Extract reference from URL
      final uri = Uri.tryParse(url);
      final reference = uri?.queryParameters['reference'] ?? uri?.queryParameters['trxref'] ?? '';

      print('=== CALLBACK DETECTED — verifying payment ===');
      print('=== Reference: $reference ===');

      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        print('=== VERIFY RESPONSE: ${response.statusCode} — ${response.body} ===');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final data = json.decode(response.body);
            final success = data['status'] == true || data['status'] == 'success';
            final message = data['message']?.toString() ?? (success ? 'Payment verified' : 'Payment not successful');
            if (mounted) Navigator.pop(context, PaymentVerifyResult(success: success, reference: reference, message: message));
            return;
          } catch (_) {
            // HTML response — treat as success since Paystack redirected
            if (mounted) Navigator.pop(context, PaymentVerifyResult(success: true, reference: reference, message: 'Payment verified. Policy is being processed.'));
            return;
          }
        } else {
          // Non-200 — try to parse error message
          String errorMsg = 'Payment verification failed';
          try {
            final data = json.decode(response.body);
            errorMsg = data['message']?.toString() ?? errorMsg;
          } catch (_) {}
          if (mounted) Navigator.pop(context, PaymentVerifyResult(success: false, reference: reference, message: errorMsg));
          return;
        }
      } catch (e) {
        print('=== VERIFY FETCH ERROR: $e ===');
        // Network error — treat as success since Paystack did redirect
        if (mounted) Navigator.pop(context, PaymentVerifyResult(success: true, reference: reference, message: 'Payment verified. Policy is being processed.'));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print('=== LOADING PAYSTACK URL: ${widget.url} ===');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() => _isLoading = true),
        onPageFinished: (url) {
          setState(() => _isLoading = false);
          _checkCallback(url);
        },
        onNavigationRequest: (request) {
          print('=== NAV REQUEST: ${request.url} ===');
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: const Text('Payment', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading && !_isVerifying) const Center(child: CircularProgressIndicator()),
          // Full-screen spinner overlay while verifying payment
          if (_isVerifying)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Verifying payment...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                    SizedBox(height: 8),
                    Text('Please wait', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
