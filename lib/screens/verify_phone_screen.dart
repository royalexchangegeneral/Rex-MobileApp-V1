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

  Future<bool> _sendOtp(String phone) async {
    final payload = {'mobileNo': phone};

    debugPrint('=== SEND PHONE OTP REQUEST ===');
    debugPrint('URL: https://eportartaltest.rexinsure.com/api/send-otp');
    debugPrint('Payload: ${json.encode(payload)}');

    final response = await http
        .post(
          Uri.parse('https://eportartaltest.rexinsure.com/api/send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('=== SEND PHONE OTP RESPONSE ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Failed to send OTP';
      try {
        final data = json.decode(response.body);
        message = data['message']?.toString() ??
            data['Message']?.toString() ??
            message;
      } catch (_) {}
      throw Exception(message);
    }

    return true;
  }

  Future<void> _submitPhone() async {
    if (_phoneController.text.isEmpty) return;
    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    final fullPhone = '$_selectedCountryCode$phone';
    setState(() => _isSendingOtp = true);

    try {
      await _sendOtp(fullPhone);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_phone', fullPhone);
      if ((prefs.getString('signup_email') ?? '').isEmpty &&
          widget.email.trim().isNotEmpty) {
        await prefs.setString('signup_email', widget.email.trim());
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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

  Future<void> _verifyCode() async {
    final otp = _codeControllers.map((c) => c.text).join();
    if (otp.length != 4) return;

    setState(() => _isVerifyingOtp = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isVerifyingOtp = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Phone verified successfully'),
        backgroundColor: Colors.green));
    Navigator.pushNamed(context, '/create-password');
  }

  Future<void> _resendCode() async {
    var phone = _phoneController.text.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    final fullPhone = '$_selectedCountryCode$phone';

    setState(() => _isSendingOtp = true);
    try {
      await _sendOtp(fullPhone);
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Code resent'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
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
