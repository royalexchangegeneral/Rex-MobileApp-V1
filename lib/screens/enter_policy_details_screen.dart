import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'customer_dashboard_screen.dart';

class EnterPolicyDetailsScreen extends StatefulWidget {
  const EnterPolicyDetailsScreen({super.key});
  @override
  State<EnterPolicyDetailsScreen> createState() =>
      _EnterPolicyDetailsScreenState();
}

class _EnterPolicyDetailsScreenState extends State<EnterPolicyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _policyNumberController = TextEditingController();
  bool _isVerifying = false;
  bool _isCreating = false;
  final List<Map<String, dynamic>> _verifiedPolicies = [];

  String? _safeValue(String? value) =>
      (value == null || value.isEmpty) ? null : value;

  String _safeAddress(String? value) =>
      (value == null || value.isEmpty) ? 'Lagos' : value;

  String _normalizeDob(String? dob) {
    const defaultDob = '1990-01-01';
    if (dob == null || dob.trim().isEmpty) return defaultDob;
    final normalized = dob.trim().replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
      }
      if (parts[2].length == 4) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    }
    try {
      final date = DateTime.parse(normalized);
      return date.toIso8601String().split('T').first;
    } catch (_) {
      return defaultDob;
    }
  }

  @override
  void dispose() {
    _policyNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    final policyNo = _policyNumberController.text.trim();
    // Check if already verified
    if (_verifiedPolicies.any((p) => p['PolicyNo'] == policyNo)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This policy is already verified')));
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final r = await http
          .get(
            Uri.parse(
                'https://eportaltest.rexinsure.com/api/getpolicy?IntCode=TESTCODE&Password=royal1234&PolicyNo=${Uri.encodeComponent(policyNo)}'),
          )
          .timeout(const Duration(seconds: 15));
      print('=== GET POLICY: ${r.statusCode} ===');
      print('Body: ${r.body}');
      setState(() => _isVerifying = false);
      if (r.statusCode == 200 || r.statusCode == 201) {
        final data = json.decode(r.body);
        if (data['Status']?.toString().toLowerCase() == 'success' &&
            data['Data'] != null &&
            (data['Data'] as List).isNotEmpty) {
          setState(() {
            _verifiedPolicies.add(Map<String, dynamic>.from(data['Data'][0]));
            _policyNumberController.clear();
          });
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Policy verified'),
                backgroundColor: Colors.green));
        } else {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Policy not found'),
                backgroundColor: Colors.red));
        }
      } else {
        String errorMsg = 'Policy not found';
        try {
          final d = json.decode(r.body);
          errorMsg =
              d['Message']?.toString() ?? d['message']?.toString() ?? errorMsg;
        } catch (_) {}
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<bool> _authenticateUser(String email, String password) async {
    final authProvider = context.read<AuthProvider>();
    final loginResult = await authProvider.login(email, password);
    if (!loginResult.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loginResult.message ?? 'Unable to authenticate user.'),
          backgroundColor: Colors.red,
        ));
      }
      return false;
    }
    return true;
  }

  Future<void> _handleContinue() async {
    if (_verifiedPolicies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your policy first')));
      return;
    }
    setState(() => _isCreating = true);
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('signup_first_name') ?? '';
    final lastName = prefs.getString('signup_last_name') ?? '';
    final email = prefs.getString('signup_email') ?? '';
    final phone = prefs.getString('signup_phone') ?? '';
    final nin = prefs.getString('signup_nin') ?? '';
    final password = prefs.getString('signup_password') ?? '';
    final dob = prefs.getString('signup_dob') ?? '';
    final state = prefs.getString('signup_state') ?? '';
    final lga = prefs.getString('signup_lga') ?? '';
    final address = prefs.getString('signup_address') ?? '';

    final formattedDob = _normalizeDob(dob);

    try {
      // Step 1: Create Customer
      final custPayload = {
        'cust_first_name': firstName,
        'cust_middle_name': null,
        'cust_last_name': lastName,
        'cust_type': 'Individual',
        'cust_occupation': 'Business',
        'cust_phone_no': phone,
        'cust_email': email,
        'cust_address': _safeAddress(address),
        'cust_town': null,
        'cust_nationality': 'Nigerian',
        'cust_state': _safeValue(state),
        'cust_lga': _safeValue(lga),
        'cust_dob': _safeValue(formattedDob),
        'cust_national_id_name': 'NIN',
        'cust_national_id_no': nin,
      };
      print('=== CREATE CUSTOMER ===');
      print('Payload: ${json.encode(custPayload)}');
      final custR = await http
          .post(
              Uri.parse('https://eportaltest.rexinsure.com/api/createcustomer'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(custPayload))
          .timeout(const Duration(seconds: 15));
      print('Response: ${custR.statusCode} - ${custR.body}');

      if (custR.statusCode == 200 || custR.statusCode == 201) {
        final custData = json.decode(custR.body);
        if (custData['Status']?.toString().toLowerCase() == 'success' &&
            custData['StatusCode'] != 409) {
          // Step 2: Create Login
          final loginPayload = {
            'cust_first_name': firstName,
            'cust_middle_name': '',
            'cust_last_name': lastName,
            'cust_occupation': 'Business',
            'cust_phone_no': phone,
            'cust_email': email,
            'cust_password': password,
          };
          print('=== CREATE LOGIN ===');
          print('Payload: ${json.encode(loginPayload)}');
          final loginR = await http
              .post(
                  Uri.parse(
                      'https://eportaltest.rexinsure.com/api/createlogin'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(loginPayload))
              .timeout(const Duration(seconds: 15));
          print('Response: ${loginR.statusCode} - ${loginR.body}');

          setState(() => _isCreating = false);
          if (loginR.statusCode == 200 || loginR.statusCode == 201) {
            final loginData = json.decode(loginR.body);
            final authenticated = await _authenticateUser(email, password);
            if (authenticated) {
              // Clear signup data
              for (final key in [
                'signup_first_name',
                'signup_last_name',
                'signup_email',
                'signup_phone',
                'signup_nin',
                'signup_password',
                'signup_dob',
                'signup_state',
                'signup_lga',
                'signup_address'
              ]) {
                await prefs.remove(key);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Account created & policy linked!'),
                    backgroundColor: Colors.green));
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CustomerDashboardScreen()),
                    (r) => false);
              }
            } else {
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Login failed: ${loginData['Message'] ?? 'Unknown'}'),
                    backgroundColor: Colors.red));
            }
          } else {
            final authenticated = await _authenticateUser(email, password);
            if (!authenticated && mounted) {
              String errorMsg = 'Login creation failed';
              try {
                final d = json.decode(loginR.body);
                errorMsg = d['Message']?.toString() ??
                    d['message']?.toString() ??
                    errorMsg;
              } catch (_) {}
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(errorMsg), backgroundColor: Colors.red));
            }
          }
        } else {
          setState(() => _isCreating = false);
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Customer creation failed: ${custData['Message'] ?? 'Unknown'}'),
                backgroundColor: Colors.red));
        }
      } else {
        setState(() => _isCreating = false);
        String errorMsg = 'Customer creation failed';
        try {
          final d = json.decode(custR.body);
          errorMsg =
              d['Message']?.toString() ?? d['message']?.toString() ?? errorMsg;
        } catch (_) {}
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 16, top: 8),
                child: SvgPicture.asset('assets/icons/loginicon.svg',
                    width: 40, height: 40))
          ]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text('Enter Your Policy Details',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    if (_verifiedPolicies.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text('${_verifiedPolicies.length} policy(ies) verified',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500)),
                    ],
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _policyNumberController,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'enter policy number',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : Colors.grey[50],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryBlue, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please enter your policy number'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _handleVerify,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Verify',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                        )),
                    // Verified Policies
                    if (_verifiedPolicies.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ..._verifiedPolicies.asMap().entries.map((entry) {
                        final i = entry.key;
                        final p = entry.value;
                        return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text('Policy ${i + 1} Verified',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green))),
                                    GestureDetector(
                                        onTap: () => setState(() =>
                                            _verifiedPolicies.removeAt(i)),
                                        child: const Icon(Icons.close,
                                            color: Colors.grey, size: 18)),
                                  ]),
                                  const SizedBox(height: 12),
                                  _row('Insured',
                                      p['Insured']?.toString() ?? '-'),
                                  _row('Policy No',
                                      p['PolicyNo']?.toString() ?? '-'),
                                  _row('Product',
                                      p['ProductCover']?.toString() ?? '-'),
                                  _row('Premium',
                                      '₦${p['Premium']?.toString() ?? '0'}'),
                                  _row('Sum Assured',
                                      '₦${p['SumAssured']?.toString() ?? '0'}'),
                                  _row('Start Date',
                                      p['StartDate']?.toString() ?? '-'),
                                  _row('End Date',
                                      p['EndDate']?.toString() ?? '-'),
                                  _row(
                                      'Status',
                                      DateTime.tryParse(p['EndDate']
                                                          ?.toString() ??
                                                      '')
                                                  ?.isAfter(DateTime.now()) ==
                                              true
                                          ? 'Active'
                                          : 'Expired'),
                                ]));
                      }),
                      // Add Policy button
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_circle_outline,
                            size: 18, color: AppTheme.accentOrange),
                        label: const Text('Add another policy',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentOrange)),
                      ),
                    ],
                    const SizedBox(height: 40),
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _verifiedPolicies.isNotEmpty && !_isCreating
                                  ? _handleContinue
                                  : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.accentOrange : AppTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[300]),
                          child: _isCreating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Continue',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                        )),
                  ])),
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(l,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
        Expanded(
            flex: 3,
            child: Text(v,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.right)),
      ]));
}
