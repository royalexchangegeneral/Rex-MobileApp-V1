import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/error_messages.dart';

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
  static const String paymentCallbackUrl =
      'https://eportaltest.rexinsure.com/api/verifypayment';

  final String url;
  final String callbackUrl;
  final String? reference;
  const PaystackWebView({
    super.key,
    required this.url,
    this.reference,
    this.callbackUrl = paymentCallbackUrl,
  });

  @override
  State<PaystackWebView> createState() => _PaystackWebViewState();
}

class _PaystackWebViewState extends State<PaystackWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _hasPopped = false;
  String? _loadErrorMessage;
  String _lastUrl = '';

  bool _isPaymentCallback(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final callbackUri = Uri.tryParse(widget.callbackUrl);
    final path = _normalizePath(uri.path);
    final callbackPath =
        callbackUri == null ? '' : _normalizePath(callbackUri.path);
    final matchesConfiguredCallback = callbackUri != null &&
        uri.host.toLowerCase() == callbackUri.host.toLowerCase() &&
        (path == callbackPath || path.startsWith('$callbackPath/'));

    return matchesConfiguredCallback ||
        ((uri.host.toLowerCase() == 'eportaltest.rexinsure.com' ||
                uri.host.toLowerCase() == 'eporttest.rexinsure.com') &&
            path.contains('verifypayment'));
  }

  bool _isServerErrorUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final host = uri.host.toLowerCase();
    return host == 'eportaltest.rexinsure.com' ||
        host == 'eporttest.rexinsure.com' ||
        host == 'checkout.paystack.com' ||
        host.endsWith('.paystack.co') ||
        host.endsWith('.paystack.com');
  }

  String _normalizePath(String path) {
    var normalized = path.toLowerCase();
    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Future<void> _checkCallback(String url) async {
    if (_hasPopped) return;
    if (_isPaymentCallback(url)) {
      _hasPopped = true;

      // Show spinner overlay while verifying
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = true;
        });
      }

      // Extract reference from URL
      final uri = Uri.tryParse(url);
      final reference = uri?.queryParameters['reference'] ??
          uri?.queryParameters['trxref'] ??
          widget.reference ??
          '';

      debugPrint('=== CALLBACK DETECTED — verifying payment ===');
      debugPrint('=== Reference: $reference ===');

      try {
        final response =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        debugPrint(
            '=== VERIFY RESPONSE: ${response.statusCode} — ${response.body} ===');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final data = json.decode(response.body);
            final status = data['status']?.toString().toLowerCase() ??
                data['Status']?.toString().toLowerCase() ??
                '';
            final success = data['status'] == true ||
                data['Status'] == true ||
                status == 'success' ||
                status.contains('success');
            final message = data['message']?.toString() ??
                data['Message']?.toString() ??
                (success ? 'Payment verified' : 'Payment not successful');
            if (mounted) {
              Navigator.pop(
                  context,
                  PaymentVerifyResult(
                      success: success,
                      reference: reference,
                      message: message));
            }
            return;
          } catch (_) {
            if (mounted) {
              Navigator.pop(
                  context,
                  PaymentVerifyResult(
                      success: false,
                      reference: reference,
                      message: ErrorMessages.fromResponse(response,
                          fallback:
                              'Payment verification response was not valid. Please confirm payment status before continuing.')));
            }
            return;
          }
        } else {
          final errorMsg = ErrorMessages.fromResponse(response,
              fallback: 'Payment verification failed');
          if (mounted) {
            Navigator.pop(
                context,
                PaymentVerifyResult(
                    success: false, reference: reference, message: errorMsg));
          }
          return;
        }
      } catch (e) {
        debugPrint('=== VERIFY FETCH ERROR: $e ===');
        if (mounted) {
          Navigator.pop(
              context,
              PaymentVerifyResult(
                  success: false,
                  reference: reference,
                  message:
                      'Unable to verify payment. Please confirm payment status before continuing.'));
        }
      }
    }
  }

  void _showPaymentLoadError(String message) {
    if (!mounted || _hasPopped) return;
    debugPrint('=== PAYMENT WEBVIEW LOAD ERROR SHOWN ===');
    debugPrint('Last URL: $_lastUrl');
    debugPrint('Message: $message');
    debugPrint('========================================');
    setState(() {
      _isLoading = false;
      _isVerifying = false;
      _loadErrorMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('=== LOADING PAYSTACK URL: ${widget.url} ===');
    _lastUrl = widget.url;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        debugPrint('=== PAYSTACK CONSOLE ===');
        debugPrint('Level: ${message.level}');
        debugPrint('Message: ${message.message}');
        debugPrint('========================');
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          _lastUrl = url;
          debugPrint('=== PAYMENT PAGE STARTED ===');
          debugPrint('URL: $url');
          debugPrint('============================');
          if (_isPaymentCallback(url)) {
            _checkCallback(url);
            return;
          }
          setState(() {
            _isLoading = true;
            _loadErrorMessage = null;
          });
        },
        onPageFinished: (url) {
          _lastUrl = url;
          debugPrint('=== PAYMENT PAGE FINISHED ===');
          debugPrint('URL: $url');
          debugPrint('=============================');
          setState(() => _isLoading = false);
          _checkCallback(url);
        },
        onUrlChange: (change) {
          final url = change.url;
          if (url != null) {
            _lastUrl = url;
            debugPrint('=== PAYMENT URL CHANGE ===');
            debugPrint('URL: $url');
            debugPrint('==========================');
          }
          if (url != null && _isPaymentCallback(url)) {
            _checkCallback(url);
          }
        },
        onHttpError: (error) {
          final statusCode = error.response?.statusCode;
          final url = error.response?.uri?.toString() ??
              error.request?.uri.toString() ??
              '';
          debugPrint('=== PAYMENT WEBVIEW HTTP ERROR ===');
          debugPrint('URL: $url');
          debugPrint('Status: $statusCode');
          debugPrint('==================================');
          if (statusCode != null &&
              statusCode >= 500 &&
              _isServerErrorUrl(url)) {
            _showPaymentLoadError(
                'Payment page returned a server error. Please confirm payment status before trying again.');
          }
        },
        onWebResourceError: (error) {
          final url = error.url ?? '';
          debugPrint('=== PAYMENT WEBVIEW RESOURCE ERROR ===');
          debugPrint('URL: $url');
          debugPrint('Code: ${error.errorCode}');
          debugPrint('Description: ${error.description}');
          debugPrint('======================================');
          if (error.isForMainFrame == true && _isServerErrorUrl(url)) {
            _showPaymentLoadError(
                'Unable to load the payment page. Please check your connection and try again.');
          }
        },
        onNavigationRequest: (request) {
          _lastUrl = request.url;
          debugPrint('=== NAV REQUEST: ${request.url} ===');
          if (_isPaymentCallback(request.url)) {
            _checkCallback(request.url);
            return NavigationDecision.prevent;
          }
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
        title: const Text('Payment',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadErrorMessage != null) _buildPaymentError(context),
          if (_isLoading && !_isVerifying)
            const Center(child: CircularProgressIndicator()),
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
                    Text('Verifying payment...',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                    SizedBox(height: 8),
                    Text('Please wait',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentError(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment_outlined,
                  size: 48, color: Color(0xFF1E2D64)),
              const SizedBox(height: 16),
              const Text(
                'Payment could not continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loadErrorMessage ?? 'Payment page unavailable.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      PaymentVerifyResult(
                        success: false,
                        reference: widget.reference,
                        message: _loadErrorMessage,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadErrorMessage = null;
                        _isLoading = true;
                      });
                      _controller.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
