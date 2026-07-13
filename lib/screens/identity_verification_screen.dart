import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final _ninController = TextEditingController();
  bool _isVerifying = false;
  bool _ninVerified = false;
  Map<String, dynamic>? _kycData;

  @override
  void initState() {
    super.initState();
    _ninController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _verifyNin() async {
    final nin = _ninController.text.trim();
    if (nin.length != 11 || !RegExp(r'^\d{11}$').hasMatch(nin)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NIN must be exactly 11 digits')));
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final payload = {
        'IntCode': 'Kissflow',
        'Password': '1lovetoeatcook1es',
        'number': nin,
      };

      debugPrint('=== VERIFY NIN REQUEST ===');
      debugPrint('URL: https://eportal.rexinsure.com/api/mobile/verify/nin');
      debugPrint('Payload: ${json.encode(payload)}');

      final response = await http
          .post(
            Uri.parse('https://eportal.rexinsure.com/api/mobile/verify/nin'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('=== VERIFY NIN RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      setState(() => _isVerifying = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' &&
            data['data']?['data']?['kyc'] != null &&
            data['data']['data']['kyc']['firstname'] != null &&
            (data['data']['data']['kyc']['firstname']?.toString() ?? '')
                .isNotEmpty) {
          setState(() {
            _ninVerified = true;
            _kycData = data['data']['data']['kyc'];
          });
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('NIN verified successfully'),
                backgroundColor: Colors.green));
        } else {
          setState(() => _ninVerified = false);
          final kyc = data['data']?['data']?['kyc'];
          final msg = kyc != null
              ? (kyc['status']?.toString() ?? 'Verification failed')
              : 'NIN not found. You can still continue.';
          if (mounted)
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorMessages.fromException(e))));
    }
  }

  Future<void> _continue() async {
    if (_ninController.text.length == 11) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_nin', _ninController.text.trim());
      if (_kycData != null) {
        await prefs.setString(
            'signup_dob', _kycData!['birthdate']?.toString() ?? '');
        await prefs.setString(
            'signup_state', _kycData!['residence_state']?.toString() ?? '');
        await prefs.setString(
            'signup_lga', _kycData!['residence_lga']?.toString() ?? '');
        await prefs.setString(
            'signup_address', _kycData!['residence_address']?.toString() ?? '');
      }
      if (mounted) Navigator.pushNamed(context, '/create-password');
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
        title: Text('Identity Verification',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Center(
                  child: SvgPicture.asset('assets/icons/top.svg',
                      width: 110, height: 110)),
              SizedBox(height: 16),
              Text('Before you continue, we need to finish your KYC.',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: 8),
              Text(
                  'To ensure the security of your account and protect against fraud, we require you to complete our identity verification process.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600], height: 1.4)),
              SizedBox(height: 24),

              // NIN Entry
              Text('Enter your NIN',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: _ninController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter your 11-digit NIN',
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
                                    : Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryBlue, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)
                  ],
                )),
                const SizedBox(width: 8),
                SizedBox(
                    height: 52,
                    width: 90,
                    child: ElevatedButton(
                      onPressed:
                          _ninController.text.length == 11 && !_isVerifying
                              ? _verifyNin
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _ninVerified ? Colors.green : AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor:
                            AppTheme.disabledButtonColor(context),
                        disabledForegroundColor:
                            AppTheme.disabledButtonTextColor(context),
                        padding: EdgeInsets.zero,
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_ninVerified ? '✓ Verified' : 'Verify',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                    )),
              ]),

              // Verified details card
              if (_ninVerified && _kycData != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green[700]),
                          const SizedBox(width: 6),
                          Text('Verified Details',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700])),
                        ]),
                        const SizedBox(height: 10),
                        _infoRow(
                            'Name',
                            '${_kycData!['firstname'] ?? ''} ${_kycData!['surname'] ?? ''}'
                                .trim()),
                        _infoRow('Phone',
                            _kycData!['telephoneno']?.toString() ?? '-'),
                        _infoRow(
                            'DOB', _kycData!['birthdate']?.toString() ?? '-'),
                        _infoRow(
                            'Email', _kycData!['email']?.toString() ?? '-'),
                        _infoRow('State',
                            _kycData!['residence_state']?.toString() ?? '-'),
                      ]),
                ),
              ],

              SizedBox(height: 24),

              // Continue button
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _ninController.text.length == 11 ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ninController.text.length == 11
                          ? AppTheme.primaryBlue
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Continue',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  )),

              const SizedBox(height: 16),
              Center(
                  child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/create-password'),
                child: Text('Skip, I will do this later',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Row(children: [
          SizedBox(
              width: 60,
              child: Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface))),
        ]),
      );
}
