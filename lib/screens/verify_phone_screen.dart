import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  void _submitPhone() {
    if (_phoneController.text.isNotEmpty) {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  void _onCodeChanged(int index, String value) {
    setState(() {});
    if (value.isNotEmpty && index < 3) {
      _codeFocusNodes[index + 1].requestFocus();
    }
  }

  void _onBackspace(int index) {
    if (index > 0 && _codeControllers[index].text.isEmpty) {
      _codeFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushNamed(context, '/verification-success');
    }
  }

  Future<void> _resendCode() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              const SizedBox(height: 20),
              
              const Text(
                'Verify your Phone Number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
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
                    onPressed: _isPhoneValid ? _submitPhone : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPhoneValid ? AppTheme.primaryBlue : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                        text: '0${_phoneController.text}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 70,
                      height: 70,
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _codeFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
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
                    );
                  }),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _codeControllers.every((c) => c.text.isNotEmpty)
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
                    child: const Text(
                      'Submit',
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
                        child: const Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
