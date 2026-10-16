import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';
import '../providers/auth_provider.dart';
import 'customer_dashboard_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final bool createLoginWithApi;
  final Map<String, String> accountData;

  const CreatePasswordScreen({
    super.key,
    this.createLoginWithApi = false,
    this.accountData = const {},
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSignupEmail();
  }

  Future<void> _loadSignupEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _emailController.text =
          widget.accountData['email'] ?? prefs.getString('signup_email') ?? '';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'signup_password', _newPasswordController.text.trim());

      if (widget.createLoginWithApi) {
        await _createPolicyLogin();
      } else {
        await _createSignupAccountWithApi();
      }
    }
  }

  Future<void> _createPolicyLogin() async {
    final authProvider = context.read<AuthProvider>();
    final firstName = (widget.accountData['firstName'] ?? '').trim();
    final lastName = (widget.accountData['lastName'] ?? '').trim();
    final email = (widget.accountData['email'] ?? _emailController.text).trim();
    final phone = (widget.accountData['phone'] ?? '').trim();
    final password = _newPasswordController.text.trim();

    if (email.isEmpty || phone.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Missing customer email or phone number'),
          backgroundColor: Colors.red));
      return;
    }

    try {
      final customerPayload = {
        'cust_first_name': firstName.isNotEmpty ? firstName : 'Customer',
        'cust_middle_name': null,
        'cust_last_name': lastName,
        'cust_type': 'Individual',
        'cust_occupation': widget.accountData['occupation']?.isNotEmpty == true
            ? widget.accountData['occupation']
            : 'Business',
        'cust_phone_no': phone,
        'cust_email': email,
        'cust_address': _safeAddress(widget.accountData['address']),
        'cust_town': null,
        'cust_nationality': 'Nigerian',
        'cust_state': _safeValue(widget.accountData['state']),
        'cust_lga': _safeValue(widget.accountData['lga']),
        'cust_dob': _safeValue(_normalizeDob(widget.accountData['dob'])),
        'cust_national_id_name': 'NIN',
        'cust_national_id_no': widget.accountData['nin'] ?? '',
      };

      debugPrint('=== CREATE POLICY CUSTOMER REQUEST ===');
      debugPrint('URL: https://eportal.rexinsure.com/api/createcustomer');
      debugPrint('Payload: ${json.encode(customerPayload)}');

      final customerResponse = await http
          .post(
            Uri.parse('https://eportal.rexinsure.com/api/createcustomer'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(customerPayload),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('=== CREATE POLICY CUSTOMER RESPONSE ===');
      debugPrint('Status Code: ${customerResponse.statusCode}');
      debugPrint('Response Body: ${customerResponse.body}');

      if (customerResponse.statusCode != 200 &&
          customerResponse.statusCode != 201) {
        await _showSignupApiError(customerResponse.body,
            fallback: 'Customer creation failed');
        return;
      }

      final customerData = _decodeJsonMap(customerResponse.body);
      if (customerData == null) {
        await _showSignupApiError(customerResponse.body,
            fallback: 'Customer creation failed');
        return;
      }

      final customerStatus =
          customerData['Status']?.toString().toLowerCase() ?? '';
      final customerStatusCode = customerData['StatusCode']?.toString() ??
          customerData['Statuscode']?.toString() ??
          '';
      final customerAlreadyExists = customerStatusCode == '409';
      if (customerStatus != 'success' && !customerAlreadyExists) {
        await _showSignupApiError(customerResponse.body,
            fallback: 'Customer creation failed');
        return;
      }

      final payload = {
        'cust_first_name': firstName.isNotEmpty ? firstName : 'Customer',
        'cust_middle_name': '',
        'cust_last_name': lastName,
        'cust_occupation': widget.accountData['occupation']?.isNotEmpty == true
            ? widget.accountData['occupation']
            : 'Business',
        'cust_phone_no': phone,
        'cust_email': email,
        'cust_password': password,
      };

      final response = await http
          .post(
            Uri.parse('https://eportal.rexinsure.com/api/createlogin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _decodeJsonMap(response.body);
        if (data == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Unable to create account. Please try again.'),
              backgroundColor: Colors.red));
          return;
        }

        final status = data['Status']?.toString().toLowerCase() ?? '';
        final statusCode = data['StatusCode']?.toString() ??
            data['Statuscode']?.toString() ??
            '';

        if (status == 'success' || statusCode == '200' || statusCode == '201') {
          final loginResult = await authProvider.login(email, password);
          if (!mounted) return;
          setState(() => _isLoading = false);

          if (loginResult.success) {
            final prefs = await SharedPreferences.getInstance();
            await _clearSignupData(prefs);
            if (!mounted) return;
            TextInput.finishAutofillContext();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const CustomerDashboardScreen()),
              (r) => false,
            );
            return;
          }

          final fallbackSuccess = await authProvider.signup(
            '$firstName $lastName'.trim().isEmpty
                ? 'Customer'
                : '$firstName $lastName'.trim(),
            email,
            password,
            userData: {
              'FirstName': firstName,
              'Surname': lastName,
              'Email': email,
              'Phone': phone,
              'PolicyReference': widget.accountData['reference'] ?? '',
            },
          );
          if (!mounted) return;
          if (fallbackSuccess) {
            final prefs = await SharedPreferences.getInstance();
            await _clearSignupData(prefs);
            if (!mounted) return;
            TextInput.finishAutofillContext();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const CustomerDashboardScreen()),
              (r) => false,
            );
            return;
          }
        }

        final message = data['Message']?.toString() ??
            data['message']?.toString() ??
            'Unable to create account';
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromResponse(response,
              fallback: 'Unable to create account')),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromException(e,
              fallback: 'Unable to create account')),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _createSignupAccountWithApi() async {
    final authProvider = context.read<AuthProvider>();
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('signup_first_name') ?? 'Customer';
    final lastName = prefs.getString('signup_last_name') ?? '';
    final phone = prefs.getString('signup_phone') ?? '';
    final fallbackEmail = phone.isEmpty
        ? 'customer@example.com'
        : '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@rex.mock';
    final email = prefs.getString('signup_email') ?? fallbackEmail;
    final password = _newPasswordController.text.trim();
    final hasExistingPolicy = prefs.getBool('has_existing_policy') ?? false;

    try {
      if (!hasExistingPolicy) {
        final customerPayload = {
          'cust_first_name': firstName,
          'cust_middle_name': null,
          'cust_last_name': lastName,
          'cust_type': 'Individual',
          'cust_occupation': 'Business',
          'cust_phone_no': phone,
          'cust_email': email,
          'cust_address': _safeAddress(prefs.getString('signup_address')),
          'cust_town': null,
          'cust_nationality': 'Nigerian',
          'cust_state': _safeValue(prefs.getString('signup_state')),
          'cust_lga': _safeValue(prefs.getString('signup_lga')),
          'cust_dob': _safeValue(_normalizeDob(prefs.getString('signup_dob'))),
          'cust_national_id_name': 'NIN',
          'cust_national_id_no': prefs.getString('signup_nin') ?? '',
        };

        debugPrint('=== CREATE CUSTOMER REQUEST ===');
        debugPrint('URL: https://eportal.rexinsure.com/api/createcustomer');
        debugPrint('Payload: ${json.encode(customerPayload)}');

        final customerResponse = await http
            .post(
              Uri.parse('https://eportal.rexinsure.com/api/createcustomer'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(customerPayload),
            )
            .timeout(const Duration(seconds: 15));

        debugPrint('=== CREATE CUSTOMER RESPONSE ===');
        debugPrint('Status Code: ${customerResponse.statusCode}');
        debugPrint('Response Body: ${customerResponse.body}');

        if (customerResponse.statusCode != 200 &&
            customerResponse.statusCode != 201) {
          await _showSignupApiError(customerResponse.body,
              fallback: 'Customer creation failed');
          return;
        }

        final customerData = _decodeJsonMap(customerResponse.body);
        if (customerData == null) {
          await _showSignupApiError(customerResponse.body,
              fallback: 'Customer creation failed');
          return;
        }

        final status = customerData['Status']?.toString().toLowerCase();
        final statusCode = customerData['StatusCode']?.toString() ??
            customerData['Statuscode']?.toString();
        if (status != 'success' || statusCode == '409') {
          await _showSignupApiError(customerResponse.body,
              fallback: 'Customer creation failed');
          return;
        }
      }

      final loginPayload = {
        'cust_first_name': firstName,
        'cust_middle_name': '',
        'cust_last_name': lastName,
        'cust_occupation': 'Business',
        'cust_phone_no': phone,
        'cust_email': email,
        'cust_password': password,
      };

      debugPrint('=== CREATE LOGIN REQUEST ===');
      debugPrint('URL: https://eportal.rexinsure.com/api/createlogin');
      debugPrint('Payload: ${json.encode(loginPayload)}');

      final loginResponse = await http
          .post(
            Uri.parse('https://eportal.rexinsure.com/api/createlogin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(loginPayload),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('=== CREATE LOGIN RESPONSE ===');
      debugPrint('Status Code: ${loginResponse.statusCode}');
      debugPrint('Response Body: ${loginResponse.body}');

      if (loginResponse.statusCode != 200 && loginResponse.statusCode != 201) {
        await _showSignupApiError(loginResponse.body,
            fallback: 'Login creation failed');
        return;
      }

      final loginData = _decodeJsonMap(loginResponse.body);
      if (loginData == null) {
        await _showSignupApiError(loginResponse.body,
            fallback: 'Login creation failed');
        return;
      }

      final loginStatus = loginData['Status']?.toString().toLowerCase();
      final loginStatusCode = loginData['StatusCode']?.toString() ??
          loginData['Statuscode']?.toString();

      if (loginStatus != 'success' &&
          loginStatusCode != '200' &&
          loginStatusCode != '201') {
        await _showSignupApiError(loginResponse.body,
            fallback: 'Login creation failed');
        return;
      }

      final loginResult = await authProvider.login(email, password);
      if (!mounted) return;

      if (!loginResult.success) {
        final fallbackSuccess = await authProvider.signup(
          '$firstName $lastName'.trim(),
          email,
          password,
          userData: {
            'FirstName': firstName,
            'Surname': lastName,
            'Email': email,
            'Phone': phone,
            'NIN': prefs.getString('signup_nin') ?? '',
            'DateOfBirth': prefs.getString('signup_dob') ?? '',
            'State': prefs.getString('signup_state') ?? '',
            'Lga': prefs.getString('signup_lga') ?? '',
            'Address': prefs.getString('signup_address') ?? '',
            'HasExistingPolicy': hasExistingPolicy,
          },
        );
        if (!mounted) return;
        if (!fallbackSuccess) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(loginResult.message ?? 'Unable to authenticate account'),
              backgroundColor: Colors.red));
          return;
        }
      }

      await _clearSignupData(prefs);
      if (!mounted) return;
      setState(() => _isLoading = false);
      TextInput.finishAutofillContext();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
        (r) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromException(e,
              fallback: 'Unable to create account')),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _showSignupApiError(String body,
      {required String fallback}) async {
    if (!mounted) return;
    setState(() => _isLoading = false);
    final message = ErrorMessages.fromResponse(http.Response(body, 400),
        fallback: fallback);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _clearSignupData(SharedPreferences prefs) async {
    for (final key in [
      'signup_first_name',
      'signup_last_name',
      'signup_email',
      'signup_phone',
      'signup_nin',
      'signup_nin_skipped',
      'signup_password',
      'signup_dob',
      'signup_state',
      'signup_lga',
      'signup_address',
      'signup_policy_no',
      'signup_details_completed',
      'is_signup_flow',
      'has_existing_policy',
    ]) {
      await prefs.remove(key);
    }
  }

  String? _safeValue(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();

  String _safeAddress(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Lagos' : value.trim();

  String _normalizeDob(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
      }
      if (parts[2].length == 4) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    }
    return normalized;
  }

  Map<String, dynamic>? _decodeJsonMap(String body) {
    try {
      final decoded = json.decode(body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
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
                  if (_emailController.text.isNotEmpty) ...[
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Your email',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryBlue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
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
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.newPassword],
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'must be 8 characters',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(
                              () => _obscureNewPassword = !_obscureNewPassword);
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
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.newPassword],
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'enter password again',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
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
