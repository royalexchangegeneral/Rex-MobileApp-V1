import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';

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

  Future<void> _submitPhone() async {
    if (_phoneController.text.isEmpty) return;
    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    final fullPhone = '$_selectedCountryCode$phone';
    setState(() => _isSendingOtp = true);
    try {
      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobileNo': fullPhone, 'email': widget.email}),
      ).timeout(const Duration(seconds: 15));
      print('=== SEND OTP: ${response.statusCode} ===');
      print('Payload: {"mobileNo": "$fullPhone", "email": "${widget.email}"}');
      print('Body: ${response.body}');
      setState(() => _isSendingOtp = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signup_phone', fullPhone);
        setState(() => _isSubmitted = true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent successfully'), backgroundColor: Colors.green));
      } else {
        String errorMsg = 'Failed to send OTP';
        try { final d = json.decode(response.body); errorMsg = d['Message']?.toString() ?? d['message']?.toString() ?? errorMsg; } catch (_) {}
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isSendingOtp = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
            TextPosition(offset: 1),
          );
        }
      }
      // Move focus to last filled field or the 4th field
      final lastIndex = (digits.length - 1).clamp(0, 3);
      _codeFocusNodes[lastIndex].requestFocus();
      setState(() {});
      // Auto-verify if all 4 digits are filled
      if (digits.length >= 4 && _codeControllers.every((c) => c.text.isNotEmpty)) {
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
          TextPosition(offset: 1),
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

  Future<void> _verifyCode() async {
    final otp = _codeControllers.map((c) => c.text).join();
    if (otp.length != 4) return;

    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    final fullPhone = '$_selectedCountryCode$phone';

    setState(() => _isVerifyingOtp = true);
    try {
      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobileNo': fullPhone, 'otp': otp}),
      ).timeout(const Duration(seconds: 15));

      print('=== VERIFY OTP: ${response.statusCode} ===');
      print('Payload: {"mobileNo": "$fullPhone", "otp": "$otp"}');
      print('Body: ${response.body}');

      setState(() => _isVerifyingOtp = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == true || data['Status']?.toString().toLowerCase() == 'success') {
          final prefs = await SharedPreferences.getInstance();
          final isSignupFlow = prefs.getBool('is_signup_flow') ?? false;
          final hasExistingPolicy = prefs.getBool('has_existing_policy') ?? false;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone verified successfully'), backgroundColor: Colors.green));
          Navigator.pushNamed(
            context,
            isSignupFlow && hasExistingPolicy
                ? '/create-password'
                : '/verification-success',
          );
        } else {
          final msg = data['message']?.toString() ?? data['Message']?.toString() ?? 'Invalid OTP';
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        }
      } else {
        String errorMsg = 'OTP verification failed';
        try { final d = json.decode(response.body); errorMsg = d['message']?.toString() ?? d['Message']?.toString() ?? errorMsg; } catch (_) {}
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isVerifyingOtp = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _resendCode() async {
    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    final fullPhone = '$_selectedCountryCode$phone';
    try {
      await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobileNo': fullPhone, 'email': widget.email}),
      ).timeout(const Duration(seconds: 15));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code resent'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              
              Text(
                'Verify your Phone Number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 12),
              
              if (!_isSubmitted) ...[
                Text(
                  'Enter your phone number to receive a verification code.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    InkWell(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountryFlag,
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _selectedCountryCode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
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
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isPhoneValid && !_isSendingOtp ? _submitPhone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPhoneValid ? AppTheme.primaryBlue : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSendingOtp
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Submit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Please enter the code we have sent to '),
                      TextSpan(
                        text: _phoneController.text.startsWith('0') ? _phoneController.text : '0${_phoneController.text}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
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
                                event.logicalKey == LogicalKeyboardKey.backspace) {
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            autofillHints: index == 0
                                ? const [AutofillHints.oneTimeCode]
                                : null,
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
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
                    onPressed: _codeControllers.every((c) => c.text.isNotEmpty) && !_isVerifyingOtp
                        ? _verifyCode
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _codeControllers.every((c) => c.text.isNotEmpty)
                          ? AppTheme.primaryBlue
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isVerifyingOtp
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Submit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: _resendCode,
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
                            color: Theme.of(context).colorScheme.onSurface,
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
