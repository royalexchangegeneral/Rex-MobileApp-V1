import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/customer_details.dart';
import '../utils/error_messages.dart';
import '../utils/explore_kyc_flow.dart';
import 'create_password_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String email;

  const VerifyPhoneScreen({super.key, required this.email});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _phoneController = TextEditingController();
  bool _isSubmitted = false;
  String _selectedCountryCode = '+234';
  String _selectedCountryFlag = '🇳🇬';
  bool _isPhoneValid = false;
  bool _showExistingPolicyPhoneNote = false;

  final List<Map<String, String>> _countries = [
    {'code': '+234', 'flag': '🇳🇬', 'name': 'Nigeria'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'USA'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'UK'},
    {'code': '+233', 'flag': '🇬🇭', 'name': 'Ghana'},
    {'code': '+254', 'flag': '🇰🇪', 'name': 'Kenya'},
    {'code': '+27', 'flag': '🇿🇦', 'name': 'South Africa'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+86', 'flag': '🇨🇳', 'name': 'China'},
  ];

  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _loadExistingPolicyPhoneNoteState();
  }

  Future<void> _loadExistingPolicyPhoneNoteState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _showExistingPolicyPhoneNote =
          (prefs.getBool('is_signup_flow') ?? false) &&
              (prefs.getBool('has_existing_policy') ?? false);
    });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.length >= 10;
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              final country = _countries[index];
              return ListTile(
                leading: Text(
                  country['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(country['name']!),
                trailing: Text(
                  country['code']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country['code']!;
                    _selectedCountryFlag = country['flag']!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  bool _isSendingOtp = false;

  Future<String> _signupEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('signup_email')?.trim() ?? '';
    final routeEmail = widget.email.trim();
    final email = savedEmail.isNotEmpty ? savedEmail : routeEmail;

    if (savedEmail.isEmpty && routeEmail.isNotEmpty) {
      await prefs.setString('signup_email', routeEmail);
    }

    return email;
  }

  Future<bool> _sendOtp(String phone) async {
    final email = await _signupEmail();
    final normalizedPhone = _phoneNumberForOtpApi(phone);
    final payload = {
      'mobileNo': normalizedPhone,
      'email': email,
    };

    debugPrint('=== SEND PHONE OTP REQUEST ===');
    debugPrint('URL: https://eportal.rexinsure.com/api/send-otp');
    debugPrint('Payload: ${json.encode(payload)}');

    final response = await http
        .post(
          Uri.parse('https://eportal.rexinsure.com/api/send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('=== SEND PHONE OTP RESPONSE ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          ErrorMessages.fromResponse(response, fallback: 'Failed to send OTP'));
    }

    return true;
  }

  Future<void> _submitPhone() async {
    if (_phoneController.text.isEmpty) return;
    final fullPhone = _phoneNumberForOtpApi(_phoneController.text);
    setState(() => _isSendingOtp = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_phone', fullPhone);
      if ((prefs.getString('signup_email') ?? '').isEmpty &&
          widget.email.trim().isNotEmpty) {
        await prefs.setString('signup_email', widget.email.trim());
      }
      await _sendOtp(fullPhone);
      TextInput.finishAutofillContext(shouldSave: false);
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _isSubmitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              ErrorMessages.fromException(e, fallback: 'Failed to send OTP')),
          backgroundColor: Colors.red));
    }
  }

  void _onCodeChanged(int index, String value) {
    // Handle paste / iOS AutoFill: value may contain multiple digits
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      // Distribute digits across all fields starting from the first box
      for (int i = 0; i < 4; i++) {
        if (i < digits.length) {
          _codeControllers[i].text = digits[i];
          _codeControllers[i].selection = TextSelection.fromPosition(
            const TextPosition(offset: 1),
          );
        }
      }
      // Move focus to last filled field or the 4th field
      final lastIndex = (digits.length - 1).clamp(0, 3);
      _codeFocusNodes[lastIndex].requestFocus();
      setState(() {});
      // Auto-verify if all 4 digits are filled
      if (digits.length >= 4 &&
          _codeControllers.every((c) => c.text.isNotEmpty)) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _verifyCode();
        });
      }
      return;
    }

    // Single digit: keep only 1 character
    if (digits.length == 1) {
      if (_codeControllers[index].text != digits) {
        _codeControllers[index].text = digits;
        _codeControllers[index].selection = TextSelection.fromPosition(
          const TextPosition(offset: 1),
        );
      }
      // Move to next field
      if (index < 3) {
        _codeFocusNodes[index + 1].requestFocus();
      }
    } else if (digits.isEmpty) {
      _codeControllers[index].text = '';
    }

    setState(() {});
  }

  void _onBackspace(int index) {
    if (index > 0 && _codeControllers[index].text.isEmpty) {
      _codeFocusNodes[index - 1].requestFocus();
    }
  }

  bool _isVerifyingOtp = false;

  Future<Map<String, dynamic>> _verifyOtp(String phone, String otp) async {
    final email = await _signupEmail();
    final normalizedPhone = _phoneNumberForOtpApi(phone);
    final payload = {
      'mobileNo': normalizedPhone,
      'email': email,
      'otp': otp,
    };

    debugPrint('=== VERIFY PHONE OTP REQUEST ===');
    debugPrint('URL: https://eportal.rexinsure.com/api/mobile/verify-otp');
    debugPrint('Payload: ${json.encode(payload)}');

    final response = await http
        .post(
          Uri.parse('https://eportal.rexinsure.com/api/mobile/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('=== VERIFY PHONE OTP RESPONSE ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(ErrorMessages.fromResponse(response,
          fallback: 'OTP verification failed'));
    }

    final data = _decodeJsonMap(response.body);
    if (data == null) {
      throw Exception(ErrorMessages.fromResponse(response,
          fallback: 'OTP verification failed'));
    }

    if (_isSuccessfulOtpResponse(data)) {
      return data;
    }

    throw Exception(ErrorMessages.fromResponse(response,
        fallback: 'Invalid or expired OTP'));
  }

  Future<void> _verifyCode() async {
    if (_isVerifyingOtp) return;

    final otp = _codeControllers.map((c) => c.text).join();
    if (otp.length != 4) return;

    setState(() => _isVerifyingOtp = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('signup_phone') ?? '';
      var phone = savedPhone.trim();
      if (phone.isEmpty) {
        phone = _phoneNumberForOtpApi(_phoneController.text);
      }

      final otpData = await _verifyOtp(phone, otp);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Phone verified successfully'),
          backgroundColor: Colors.green));
      final isSignupFlow = prefs.getBool('is_signup_flow') ?? false;
      final hasExistingPolicy = prefs.getBool('has_existing_policy') ?? false;
      if (!isSignupFlow) {
        final isExploreFlow = await ExploreKycFlow.isActive();
        if (!mounted) return;
        if (isExploreFlow) {
          Navigator.pushReplacementNamed(context, '/enter-nin');
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
            context, '/user-portal', (route) => false);
        return;
      }

      if (hasExistingPolicy) {
        var policyData = _policyVerifiedIsTrue(otpData)
            ? _policyDataFromOtpResponse(otpData)
            : null;

        policyData ??= await _showPolicyNumberDialog();

        if (!mounted) return;
        if (policyData == null) {
          setState(() => _isVerifyingOtp = false);
          return;
        }

        final accountData = await _savePolicySignupData(policyData);
        if (!mounted) return;
        if (accountData == null) {
          setState(() => _isVerifyingOtp = false);
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CreatePasswordScreen(
              createLoginWithApi: true,
              accountData: accountData,
            ),
          ),
        );
        return;
      }

      final isExploreFlow = await ExploreKycFlow.isActive();
      if (!mounted) return;
      if (isExploreFlow) {
        Navigator.pushReplacementNamed(context, '/enter-nin');
        return;
      }

      Navigator.pushNamed(context, '/enter-nin');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifyingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromException(e,
              fallback: 'OTP verification failed')),
          backgroundColor: Colors.red));
    }
  }

  bool _policyVerifiedIsTrue(Map<String, dynamic> data) {
    final value = _findDeepValue(data, 'policy_verified');
    if (value is bool) return value == true;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  Map<String, dynamic>? _policyDataFromOtpResponse(Map<String, dynamic> data) {
    final directPolicy = _findPolicyMap(data);
    if (directPolicy == null) return null;
    return _flattenPolicyData(directPolicy);
  }

  Map<String, dynamic>? _findPolicyMap(Object? value) {
    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (_looksLikePolicyData(map)) return map;
          final nested = _findPolicyMap(map);
          if (nested != null) return nested;
        }
      }
      return null;
    }

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      if (_looksLikePolicyData(map)) return map;

      for (final key in [
        'policies',
        'Policies',
        'policy',
        'Policy',
        'policy_details',
        'PolicyDetails',
        'Data',
        'data',
        'customer',
        'Customer',
      ]) {
        final nested = _findPolicyMap(map[key]);
        if (nested != null) return nested;
      }

      for (final nestedValue in map.values) {
        final nested = _findPolicyMap(nestedValue);
        if (nested != null) return nested;
      }
    }

    return null;
  }

  bool _looksLikePolicyData(Map<String, dynamic> data) {
    return CustomerDetails.valueFrom(data, const [
          'PolicyNo',
          'PolicyNumber',
          'policyNo',
          'policy_number',
        ]).isNotEmpty ||
        CustomerDetails.valueFrom(data, const [
          'Email',
          'email',
          'cust_email',
        ]).isNotEmpty ||
        CustomerDetails.valueFrom(data, const [
          'MobileNo',
          'Phone',
          'PhoneNo',
          'cust_phone',
          'cust_phone_no',
        ]).isNotEmpty;
  }

  Object? _findDeepValue(Object? value, String key) {
    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
          return entry.value;
        }
        final nested = _findDeepValue(entry.value, key);
        if (nested != null) return nested;
      }
    }
    if (value is List) {
      for (final item in value) {
        final nested = _findDeepValue(item, key);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _showPolicyNumberDialog() async {
    final controller = TextEditingController();
    String? errorText;
    var isLoading = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Verify Policy'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We could not automatically verify a policy for this phone number. Enter your policy number to continue.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Policy Number',
                      hintText: 'P/COM/59/01/L/00000006',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(dialogContext, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final policyNo = controller.text.trim();
                          if (policyNo.isEmpty) {
                            setDialogState(
                                () => errorText = 'Enter a policy number');
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                            errorText = null;
                          });

                          try {
                            final policyData = await _verifyPolicy(policyNo);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext, policyData);
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              isLoading = false;
                              errorText = ErrorMessages.fromException(e,
                                  fallback: 'Policy not found');
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<Map<String, dynamic>> _verifyPolicy(String policyNo) async {
    final uri = Uri.https('eportal.rexinsure.com', '/api/getpolicy', {
      'PolicyNo': policyNo,
      'IntCode': 'Kissflow',
      'Password': '1lovetoeatcook1es',
    });

    debugPrint('=== GET POLICY REQUEST ===');
    debugPrint('URL: $uri');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 15));

    debugPrint('=== GET POLICY RESPONSE ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          ErrorMessages.fromResponse(response, fallback: 'Policy not found'));
    }

    final data = _decodeJsonMap(response.body);
    if (data == null) {
      throw Exception('Policy not found');
    }

    final status = _field(data, 'Status').toLowerCase();
    final statusCode = _field(data, 'StatusCode').isNotEmpty
        ? _field(data, 'StatusCode')
        : _field(data, 'Statuscode');
    final payload = data['Data'] ?? data['data'];

    if ((status == 'success' || statusCode == '200' || statusCode == '201') &&
        payload is List &&
        payload.isNotEmpty &&
        payload.first is Map) {
      final policyData = Map<String, dynamic>.from(payload.first as Map);
      policyData.putIfAbsent('PolicyNo', () => policyNo);
      return policyData;
    }

    if ((status == 'success' || statusCode == '200' || statusCode == '201') &&
        payload is Map) {
      final policyData = Map<String, dynamic>.from(payload);
      policyData.putIfAbsent('PolicyNo', () => policyNo);
      return policyData;
    }

    throw Exception(ErrorMessages.fromResponse(response,
        fallback: 'Policy number could not be verified'));
  }

  Future<Map<String, String>?> _savePolicySignupData(
      Map<String, dynamic> policyData) async {
    final prefs = await SharedPreferences.getInstance();
    final data = _flattenPolicyData(policyData);
    final savedPhone = prefs.getString('signup_phone') ?? '';
    final savedEmail = prefs.getString('signup_email') ?? '';

    final firstName = CustomerDetails.valueFrom(data, const [
      'firstName',
      'FirstName',
      'Firstname',
      'cust_first_name',
    ]);
    final lastName = CustomerDetails.valueFrom(data, const [
      'lastName',
      'LastName',
      'Lastname',
      'Surname',
      'cust_last_name',
    ]);
    final insuredName = CustomerDetails.valueFrom(data, const [
      'Insured',
      'insured',
    ]);
    final insuredNameParts = _namePartsFromInsured(insuredName);
    final email = CustomerDetails.valueFrom(data, const [
      'email',
      'Email',
      'cust_email',
    ]);
    final phone = CustomerDetails.valueFrom(data, const [
      'phone',
      'Phone',
      'PhoneNumber',
      'PhoneNo',
      'MobileNo',
      'Phoneno',
      'cust_phone',
      'cust_phone_no',
    ]);
    final policyNo = CustomerDetails.valueFrom(data, const [
      'PolicyNo',
      'PolicyID',
      'PolicyNumber',
      'policyNo',
      'policyId',
      'policy_number',
    ]);
    final resolvedPhone = savedPhone.isNotEmpty ? savedPhone : phone;
    if (resolvedPhone.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Verified phone number is missing. Please try again.'),
            backgroundColor: Colors.red));
      }
      return null;
    }
    final resolvedEmail = email.isNotEmpty
        ? email
        : savedEmail.isNotEmpty
            ? savedEmail
            : await _showEmailAddressDialog();
    if (resolvedEmail == null || resolvedEmail.trim().isEmpty) {
      return null;
    }

    final accountData = {
      'firstName': firstName.isNotEmpty
          ? firstName
          : insuredNameParts['firstName'] ?? 'Customer',
      'lastName':
          lastName.isNotEmpty ? lastName : insuredNameParts['lastName'] ?? '',
      'email': resolvedEmail.trim(),
      'phone': resolvedPhone,
      'occupation':
          CustomerDetails.valueFrom(data, const ['Occupation', 'occupation']),
      'dob': CustomerDetails.valueFrom(data, const [
        'dob',
        'DOB',
        'DateOfBirth',
        'BirthDate',
        'cust_dob',
      ]),
      'state': CustomerDetails.valueFrom(data, const ['State', 'state']),
      'lga': CustomerDetails.valueFrom(data, const ['LGA', 'Lga', 'lga']),
      'address': CustomerDetails.valueFrom(data, const [
        'Address',
        'ResidentialAddress',
        'cust_address',
      ]),
      'nin': CustomerDetails.ninFrom(data),
      'reference': policyNo,
    };

    await prefs.setString('signup_first_name', accountData['firstName'] ?? '');
    await prefs.setString('signup_last_name', accountData['lastName'] ?? '');
    await prefs.setString('signup_email', accountData['email'] ?? '');
    await prefs.setString('signup_phone', accountData['phone'] ?? '');
    await prefs.setString('signup_dob', accountData['dob'] ?? '');
    await prefs.setString('signup_state', accountData['state'] ?? '');
    await prefs.setString('signup_lga', accountData['lga'] ?? '');
    await prefs.setString('signup_address', accountData['address'] ?? '');
    await prefs.setString('signup_nin', accountData['nin'] ?? '');
    await prefs.setString('signup_policy_no', policyNo);

    return accountData;
  }

  Future<String?> _showEmailAddressDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _EmailAddressDialog(),
    );
  }

  Map<String, String> _namePartsFromInsured(String insuredName) {
    final trimmed = insuredName.trim();
    if (trimmed.isEmpty) return const {};

    if (trimmed.contains(',')) {
      final parts = trimmed.split(',');
      final surname = parts.first.trim();
      final otherNames = parts.skip(1).join(' ').trim().split(RegExp(r'\s+'));
      return {
        'firstName': otherNames.isNotEmpty ? otherNames.first : surname,
        'lastName': surname,
      };
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    return {
      'firstName': parts.first,
      'lastName': parts.length > 1 ? parts.skip(1).join(' ') : '',
    };
  }

  Map<String, dynamic> _flattenPolicyData(Map<String, dynamic> policyData) {
    final flattened = Map<String, dynamic>.from(policyData);
    for (final key in ['Customer', 'customer', 'Client', 'client']) {
      final value = policyData[key];
      if (value is Map) {
        flattened.addAll(Map<String, dynamic>.from(value));
      }
    }
    final policyDetails =
        policyData['PolicyDetails'] ?? policyData['policyDetails'];
    if (policyDetails is Map) {
      final policies = policyDetails['Policy'] ?? policyDetails['policy'];
      if (policies is List && policies.isNotEmpty && policies.first is Map) {
        flattened.addAll(Map<String, dynamic>.from(policies.first as Map));
      } else if (policies is Map) {
        flattened.addAll(Map<String, dynamic>.from(policies));
      }
    }
    return flattened;
  }

  Future<void> _resendCode() async {
    setState(() => _isSendingOtp = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('signup_phone') ?? '';
      var fullPhone = savedPhone.trim();
      if (fullPhone.isEmpty) {
        fullPhone = _phoneNumberForOtpApi(_phoneController.text);
      }
      await _sendOtp(fullPhone);
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Code resent'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorMessages.fromException(e,
              fallback: 'Failed to resend code')),
          backgroundColor: Colors.red));
    }
  }

  String _phoneNumberForOtpApi(String value) {
    var phone = value.trim().replaceAll(RegExp(r'[\s()-]'), '');

    if (phone.startsWith('00')) {
      phone = phone.substring(2);
    }

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    if (_selectedCountryCode == '+234') {
      if (phone.startsWith('234')) {
        phone = phone.substring(3);
      }
      if (!phone.startsWith('0')) {
        phone = '0$phone';
      }
      return phone;
    }

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    final countryDigits = _selectedCountryCode.replaceAll('+', '');
    if (phone.startsWith(countryDigits)) {
      return '+$phone';
    }

    return '$_selectedCountryCode$phone';
  }

  Map<String, dynamic>? _decodeJsonMap(String body) {
    try {
      final decoded = json.decode(body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  bool _isSuccessfulOtpResponse(Map<String, dynamic> data) {
    final values = <String>[
      _field(data, 'Status'),
      _field(data, 'status'),
      _field(data, 'StatusCode'),
      _field(data, 'Statuscode'),
      _field(data, 'statusCode'),
      _field(data, 'statuscode'),
      _field(data, 'message'),
      _field(data, 'Message'),
      _field(data, 'StatusMessage'),
      _field(data, 'statusMessage'),
    ]
        .where((value) => value.isNotEmpty)
        .map((value) => value.toLowerCase())
        .toList();

    if (values.any((value) =>
        value == 'true' ||
        value == '1' ||
        value == '200' ||
        value == '201' ||
        value == 'success' ||
        value == 'successful' ||
        value == 'valid' ||
        value.contains('success') ||
        value.contains('verified'))) {
      return true;
    }

    final nestedData = data['data'] ?? data['Data'];
    if (nestedData is Map) {
      return _isSuccessfulOtpResponse(Map<String, dynamic>.from(nestedData));
    }

    return false;
  }

  String _field(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value?.toString().trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor =
        isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    final inputFillColor = isDark ? const Color(0xFF111827) : Colors.grey[50]!;
    final codeFillColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final inputBorderColor =
        isDark ? const Color(0xFF475569) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final codeTextColor = isDark ? Colors.white : AppTheme.primaryBlue;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () {
            if (_isSubmitted) {
              setState(() {
                _isSubmitted = false;
                for (final controller in _codeControllers) {
                  controller.clear();
                }
              });
              return;
            }
            Navigator.pop(context);
          },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Verify your Phone Number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (!_isSubmitted) ...[
                Text(
                  'Enter your phone number to receive a verification code.',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                ),
                if (_showExistingPolicyPhoneNote) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use the phone number attached to the policy you have with us.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : AppTheme.primaryNavy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                AutofillGroup(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: inputBorderColor),
                            borderRadius: BorderRadius.circular(12),
                            color: inputFillColor,
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedCountryFlag,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedCountryCode,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down,
                                  color: secondaryTextColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.telephoneNumber,
                          ],
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 14,
                          ),
                          cursorColor: onSurface,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(color: hintColor),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: inputBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: inputBorderColor),
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isPhoneValid && !_isSendingOtp ? _submitPhone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPhoneValid
                          ? AppTheme.primaryBlue
                          : AppTheme.disabledButtonColor(context),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.disabledButtonColor(context),
                      disabledForegroundColor:
                          AppTheme.disabledButtonTextColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSendingOtp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Submit',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                          text: 'Please enter the code we have sent to '),
                      TextSpan(
                        text: _phoneController.text.startsWith('0')
                            ? _phoneController.text
                            : '0${_phoneController.text}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AutofillGroup(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 70,
                        height: 70,
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey ==
                                    LogicalKeyboardKey.backspace) {
                              _onBackspace(index);
                            }
                          },
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _codeFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: codeTextColor,
                            ),
                            cursorColor: codeTextColor,
                            autofillHints: index == 0
                                ? const [AutofillHints.oneTimeCode]
                                : null,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: codeFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: inputBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: inputBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => _onCodeChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _codeControllers.every((c) => c.text.isNotEmpty) &&
                                !_isVerifyingOtp
                            ? _verifyCode
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _codeControllers.every((c) => c.text.isNotEmpty)
                              ? AppTheme.primaryBlue
                              : AppTheme.disabledButtonColor(context),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.disabledButtonColor(context),
                      disabledForegroundColor:
                          AppTheme.disabledButtonTextColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isVerifyingOtp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Submit',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: _isVerifyingOtp ? null : _resendCode,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailAddressDialog extends StatefulWidget {
  const _EmailAddressDialog();

  @override
  State<_EmailAddressDialog> createState() => _EmailAddressDialogState();
}

class _EmailAddressDialogState extends State<_EmailAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Email Address'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the email address you want to use for this account.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'name@example.com',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
