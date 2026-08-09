import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';
import '../utils/explore_kyc_flow.dart';
import 'create_password_screen.dart';
import 'customer_dashboard_screen.dart';
import 'agent_dashboard_screen.dart';

class PolicyPurchaseSuccessScreen extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAgent;
  final String? reference;
  final String? message;
  final Map<String, String> accountData;
  final bool isExploreFlow;
  const PolicyPurchaseSuccessScreen({
    super.key,
    this.isLoggedIn = false,
    this.isAgent = false,
    this.reference,
    this.message,
    this.accountData = const {},
    this.isExploreFlow = false,
  });

  @override
  State<PolicyPurchaseSuccessScreen> createState() =>
      _PolicyPurchaseSuccessScreenState();
}

class _PolicyPurchaseSuccessScreenState
    extends State<PolicyPurchaseSuccessScreen> {
  bool _creatingCustomer = false;

  @override
  void initState() {
    super.initState();
    if (widget.isExploreFlow) {
      ExploreKycFlow.complete();
    }
  }

  String _value(String key, {String fallback = ''}) {
    final value = widget.accountData[key]?.trim() ?? '';
    return value.isNotEmpty ? value : fallback;
  }

  bool _isSuccessResponse(Map<String, dynamic> data) {
    final status = (data['Status'] ?? data['status'])?.toString().toLowerCase();
    final statusCode =
        (data['StatusCode'] ?? data['Statuscode'] ?? data['statusCode'])
            ?.toString();
    return status == 'success' ||
        status == 'true' ||
        statusCode == '200' ||
        statusCode == '201';
  }

  Future<void> _createCustomerThenOpenPassword() async {
    final email = _value('email');
    final phone = _value('phone');

    if (email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Missing customer email or phone number'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _creatingCustomer = true);

    final requestBody = {
      'cust_first_name': _value('firstName', fallback: 'Customer'),
      'cust_middle_name': '',
      'cust_last_name': _value('lastName', fallback: '.'),
      'cust_type': 'Individual',
      'cust_occupation': _value('occupation', fallback: 'Business'),
      'cust_phone_no': phone,
      'cust_email': email,
      'cust_address': _value('address', fallback: '.'),
      'cust_town': '',
      'cust_nationality': 'Nigerian',
      'cust_state': _value('state', fallback: 'Lagos'),
      'cust_lga': _value('lga', fallback: 'Ikeja'),
      'cust_dob': _value('dob', fallback: '1990-01-01'),
      'cust_national_id_name': _value('idType', fallback: 'NIN'),
      'cust_national_id_no': _value('nin'),
    };

    try {
      debugPrint('=== CREATE CUSTOMER BEFORE PASSWORD SCREEN ===');
      debugPrint('URL: https://eportaltest.rexinsure.com/api/createcustomer');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('https://eportaltest.rexinsure.com/api/createcustomer'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final responseData =
            data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};

        if (_isSuccessResponse(responseData)) {
          setState(() => _creatingCustomer = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Customer created successfully'),
              backgroundColor: Colors.green));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePasswordScreen(
                createLoginWithApi: true,
                accountData: {
                  ...widget.accountData,
                  'reference': widget.reference ?? '',
                },
              ),
            ),
          );
          return;
        }

        final message = responseData['Message']?.toString() ??
            responseData['message']?.toString() ??
            'Unable to create customer';
        setState(() => _creatingCustomer = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } else {
        setState(() => _creatingCustomer = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromResponse(response,
              fallback: 'Unable to create customer')),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _creatingCustomer = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromException(e,
              fallback: 'Unable to create customer')),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success message
              Text(
                'Your policy has been\nsuccessfully purchased',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              // Reference ID
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  children: [
                    const TextSpan(text: 'Reference ID: '),
                    TextSpan(
                      text: widget.reference != null
                          ? '#${widget.reference}'
                          : '#REX-000000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Backend message
              if (widget.message != null)
                Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                      height: 1.4),
                ),

              const SizedBox(height: 24),

              // Info text
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  'Certificate document sent to your email.\nView, download, or share it later from Policy Details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Spacer(),

              // Homepage button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.isAgent) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AgentDashboardScreen()),
                          (route) => false);
                    } else if (widget.isLoggedIn) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerDashboardScreen()),
                          (route) => false);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/user-portal', (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Homepage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Create Account button (only for non-logged-in users)
              if (!widget.isLoggedIn &&
                  !widget.isAgent &&
                  !widget.isExploreFlow)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _creatingCustomer
                        ? null
                        : _createCustomerThenOpenPassword,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(
                          color: AppTheme.primaryNavy, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _creatingCustomer
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Do you want to create an account?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
