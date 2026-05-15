import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'customer_dashboard_screen.dart';

class ExistingPolicyQuestionScreen extends StatefulWidget {
  const ExistingPolicyQuestionScreen({super.key});

  @override
  State<ExistingPolicyQuestionScreen> createState() =>
      _ExistingPolicyQuestionScreenState();
}

class _ExistingPolicyQuestionScreenState
    extends State<ExistingPolicyQuestionScreen> {
  String? _selectedOption;
  bool _isCreating = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _showUserInfoForm = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _checkAndLoadUserInfo();
  }

  Future<void> _checkAndLoadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('signup_first_name') ?? '';
    final lastName = prefs.getString('signup_last_name') ?? '';
    final email = prefs.getString('signup_email') ?? '';
    
    // Show form if no user info is saved (new signup flow)
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      setState(() => _showUserInfoForm = true);
    } else {
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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

  Future<void> _handleContinue() async {
    // Validate user info form if shown
    if (_showUserInfoForm) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_first_name', _firstNameController.text.trim());
      await prefs.setString('signup_last_name', _lastNameController.text.trim());
      await prefs.setString('signup_email', _emailController.text.trim());
    }

    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an option')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isSignupFlow = prefs.getBool('is_signup_flow') ?? false;
    
    if (_selectedOption == 'yes') {
      if (isSignupFlow) {
        // Signup flow with existing insurance - mark as YES and go directly to verify phone
        await prefs.setBool('has_existing_policy', true);
        final email = prefs.getString('signup_email') ?? '';
        if (mounted) {
          Navigator.pushNamed(context, '/verify-phone', arguments: email);
        }
      } else {
        // Normal flow with existing insurance - go to enter policy details
        if (mounted) {
          Navigator.pushNamed(context, '/enter-policy-details');
        }
      }
    } else {
      if (isSignupFlow) {
        // Signup flow without existing insurance - mark as NO and continue to phone verification
        await prefs.setBool('has_existing_policy', false);
        final email = prefs.getString('signup_email') ?? '';
        if (mounted) {
          Navigator.pushNamed(context, '/verify-phone', arguments: email);
        }
      } else {
        // Normal flow without existing insurance - create customer and login
        await _createCustomerAndLogin();
      }
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

  Future<void> _createCustomerAndLogin() async {
    setState(() => _isCreating = true);
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('signup_first_name') ?? '';
    final lastName = prefs.getString('signup_last_name') ?? '';
    final email = prefs.getString('signup_email') ?? '';
    final phone = prefs.getString('signup_phone') ?? '';
    final nin = prefs.getString('signup_nin') ?? '';
    final password = prefs.getString('signup_password') ?? '';
    final dob = prefs.getString('signup_dob') ?? '';
    final formattedDob = _normalizeDob(dob);
    final state = prefs.getString('signup_state') ?? '';
    final lga = prefs.getString('signup_lga') ?? '';
    final address = prefs.getString('signup_address') ?? '';

    try {
      // Step 1: Create Customer
      final customerPayload = {
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
      print('Payload: ${json.encode(customerPayload)}');

      final custResponse = await http
          .post(
            Uri.parse('https://eportaltest.rexinsure.com/api/createcustomer'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(customerPayload),
          )
          .timeout(const Duration(seconds: 15));

      print('Response: ${custResponse.statusCode} - ${custResponse.body}');

      if (custResponse.statusCode == 200 || custResponse.statusCode == 201) {
        final custData = json.decode(custResponse.body);
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

          final loginResponse = await http
              .post(
                Uri.parse('https://eportaltest.rexinsure.com/api/createlogin'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(loginPayload),
              )
              .timeout(const Duration(seconds: 15));

          print(
              'Response: ${loginResponse.statusCode} - ${loginResponse.body}');

          setState(() => _isCreating = false);

          final bool authenticated = await _authenticateUser(email, password);

          if (authenticated) {
            // Clear signup data
            await prefs.remove('signup_first_name');
            await prefs.remove('signup_last_name');
            await prefs.remove('signup_email');
            await prefs.remove('signup_phone');
            await prefs.remove('signup_nin');
            await prefs.remove('signup_password');
            await prefs.remove('signup_dob');
            await prefs.remove('signup_state');
            await prefs.remove('signup_lga');
            await prefs.remove('signup_address');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Account created successfully!'),
                  backgroundColor: Colors.green));
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CustomerDashboardScreen()),
                  (r) => false);
            }
          }
        } else {
          setState(() => _isCreating = false);
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(custData['Message']?.toString() ??
                    custData['message']?.toString() ??
                    'Customer creation failed'),
                backgroundColor: Colors.red));
        }
      } else {
        setState(() => _isCreating = false);
        String errorMsg = 'Customer creation failed';
        try {
          final d = json.decode(custResponse.body);
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: SvgPicture.asset(
              'assets/icons/loginicon.svg',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Form (only shown if needed)
                if (_showUserInfoForm) ...[
                  Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'First Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _firstNameController,
                    autofillHints: const [AutofillHints.givenName],
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter first name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Last Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastNameController,
                    autofillHints: const [AutofillHints.familyName],
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter last name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                ],

                SizedBox(height: _showUserInfoForm ? 0 : 20),

                Text(
                  'Do You Have An Existing Insurance Policy?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'If you have an existing policy, we will link it to your account for easy access',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 32),

                // Yes Option
                GestureDetector(
                  onTap: () => setState(() => _selectedOption = 'yes'),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1F2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedOption == 'yes'
                            ? AppTheme.primaryBlue
                            : Colors.grey[300]!,
                        width: _selectedOption == 'yes' ? 2 : 1,
                      ),
                    ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedOption == 'yes'
                                ? AppTheme.primaryBlue
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedOption == 'yes'
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // No Option
              GestureDetector(
                onTap: () => setState(() => _selectedOption = 'no'),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1F2E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedOption == 'no'
                          ? AppTheme.primaryBlue
                          : Colors.grey[300]!,
                      width: _selectedOption == 'no' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedOption == 'no'
                                ? AppTheme.primaryBlue
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedOption == 'no'
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Need Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.help_outline,
                            color: AppTheme.primaryNavy, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Not sure what to buy?, do you need assistance choosing, customizing, or purchasing a new insurance policy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'tel', path: '+2347080606100');
                        try {
                          final launched = await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                          if (!launched && context.mounted) {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: const Text('Contact Support',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      content: const Text('+234 708 0606 100',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        } catch (_) {
                          if (context.mounted) {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: const Text('Contact Support',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      content: const Text('+234 708 0606 100',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        }
                      },
                      child: const Text(
                        'Click here for advice.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedOption != null && !_isCreating
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption != null
                        ? AppTheme.primaryBlue
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Continue',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
