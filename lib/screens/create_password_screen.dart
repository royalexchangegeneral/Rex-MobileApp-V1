import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'customer_dashboard_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_password', _newPasswordController.text.trim());
      
      // Notify the platform to save credentials to Keychain / password manager
      TextInput.finishAutofillContext();
      
      final isSignupFlow = prefs.getBool('is_signup_flow') ?? false;
      
      if (isSignupFlow) {
        // Signup flow
        final hasExistingPolicy = prefs.getBool('has_existing_policy') ?? false;
        
        if (hasExistingPolicy) {
          setState(() => _isLoading = false);
          await prefs.remove('is_signup_flow');
          await prefs.remove('has_existing_policy');
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
            (r) => false,
          );
        } else {
          // User doesn't have existing policy - create customer account
          await _createSignupCustomer();
        }
      } else {
        // Normal flow - go to existing policy question
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.of(context).pushNamed('/existing-policy-question');
        }
      }
    }
  }

  Future<void> _createSignupCustomer() async {
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

          setState(() => _isLoading = false);

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
            await prefs.remove('is_signup_flow');
            await prefs.remove('has_existing_policy');

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
          setState(() => _isLoading = false);
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(custData['Message']?.toString() ??
                    custData['message']?.toString() ??
                    'Customer creation failed'),
                backgroundColor: Colors.red));
        }
      } else {
        setState(() => _isLoading = false);
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
      setState(() => _isLoading = false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
          child: AutofillGroup(
            child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                
                Text(
                  'Create Your Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'This password will be used to sign into your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: 32),
                
                Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'must be 8 characters',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => _obscureNewPassword = !_obscureNewPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 24),
                
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'enter password again',
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
