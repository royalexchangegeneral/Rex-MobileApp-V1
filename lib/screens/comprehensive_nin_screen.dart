import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/customer_details.dart';
import 'comprehensive_summary_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComprehensiveNinScreen extends StatefulWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;
  final Map<String, String> personalInfo;
  final Map<String, dynamic> vehicleData;
  final List<File> imageFiles;
  final bool isLoggedIn;
  final bool isAgent;

  const ComprehensiveNinScreen(
      {super.key,
      required this.vehicleType,
      required this.sumInsured,
      required this.premium,
      required this.regNumber,
      this.personalInfo = const {},
      this.vehicleData = const {},
      this.imageFiles = const [],
      this.isLoggedIn = false,
      this.isAgent = false});
  @override
  State<ComprehensiveNinScreen> createState() => _ComprehensiveNinScreenState();
}

class _ComprehensiveNinScreenState extends State<ComprehensiveNinScreen> {
  final _ninController = TextEditingController();
  bool _isVerifying = false;
  bool _ninVerified = false;
  bool _ninFailed = false;
  bool _isCustomerNinLocked = false;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _dob = '';
  String _gender = '';

  @override
  void initState() {
    super.initState();
    _prefillCustomerNin();
  }

  Future<void> _prefillCustomerNin() async {
    if (!widget.isLoggedIn || widget.isAgent) return;

    final authProvider = context.read<AuthProvider>();
    final nin = await CustomerDetails.ninFromAuth(authProvider);
    if (!mounted || nin.isEmpty) return;

    setState(() {
      _ninController.text = nin;
      _isCustomerNinLocked = true;
    });
  }

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _verifyNin() async {
    if (_ninController.text.trim().length != 11) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('NIN must be 11 digits')));
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final r = await http
          .post(
            Uri.parse('https://eportaltest.rexinsure.com/api/verify/nin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'Intcode': 'TESTCODE',
              'Password': 'royal1234',
              'number': _ninController.text.trim()
            }),
          )
          .timeout(const Duration(seconds: 15));
      setState(() => _isVerifying = false);
      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'success' &&
            d['data']?['data']?['kyc'] != null &&
            d['data']['data']['kyc']['firstname'] != null &&
            (d['data']['data']['kyc']['firstname']?.toString() ?? '')
                .isNotEmpty) {
          final k = d['data']['data']['kyc'];
          setState(() {
            _ninVerified = true;
            _firstName = k['firstname']?.toString() ?? '';
            _lastName = k['surname']?.toString() ?? '';
            _email = k['email']?.toString() ?? '';
            _phone = k['telephoneno']?.toString() ?? '';
            _dob = k['birthdate']?.toString() ?? '';
            _gender = k['gender']?.toString() ?? '';
          });
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('NIN verified'), backgroundColor: Colors.green));
        } else {
          setState(() => _ninFailed = true);
          final kyc = d['data']?['data']?['kyc'];
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(kyc != null
                    ? (kyc['status']?.toString() ?? 'Verification failed')
                    : 'NIN not found. Proceed to continue.')));
        }
      } else {
        setState(() => _ninFailed = true);
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _ninFailed = true;
      });
    }
  }

  Map<String, String> get _mergedPersonalInfo {
    final info = Map<String, String>.from(widget.personalInfo);
    if (_ninVerified) {
      if (_firstName.isNotEmpty) info['ninFirstName'] = _firstName;
      if (_lastName.isNotEmpty) info['ninLastName'] = _lastName;
      if (_email.isNotEmpty && (info['email'] ?? '').isEmpty)
        info['email'] = _email;
      if (_phone.isNotEmpty && (info['phone'] ?? '').isEmpty)
        info['phone'] = _phone;
      if (_dob.isNotEmpty) info['dob'] = _dob;
      if (_gender.isNotEmpty) info['gender'] = _gender;
    }
    return info;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('NIN Verification',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('Step 4 of 5',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Identification',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                      children: List.generate(
                          5,
                          (i) => Expanded(
                              child: Container(
                                  height: 4,
                                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                                  decoration: BoxDecoration(
                                      color: i < 4
                                          ? AppTheme.primaryNavy
                                          : Colors.grey[300],
                                      borderRadius:
                                          BorderRadius.circular(2)))))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('National Identification Number',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _ninController,
                    readOnly: _isCustomerNinLocked,
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your NIN',
                      hintStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: fieldColor,
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: accent, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_ninVerified && !_ninFailed)
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isVerifying ? null : _verifyNin,
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.primaryNavy,
                              side: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppTheme.primaryNavy),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Text('Verify NIN',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                        )),
                  if (_ninVerified) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.green[700]),
                              SizedBox(width: 8),
                              Text('NIN Verified',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700]))
                            ]),
                            SizedBox(height: 8),
                            Text('Name: $_firstName $_lastName',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                            if (_dob.isNotEmpty)
                              Text('DOB: $_dob',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                            if (_gender.isNotEmpty)
                              Text('Gender: $_gender',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                          ]),
                    ),
                  ],
                  if (_ninFailed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                'NIN verification failed. You can still proceed.',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.orange[700]))),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 40, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: Column(children: [
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_ninVerified || _ninFailed)
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ComprehensiveSummaryScreen(
                                            vehicleType: widget.vehicleType,
                                            sumInsured: widget.sumInsured,
                                            premium: widget.premium,
                                            regNumber: widget.regNumber,
                                            personalInfo: _mergedPersonalInfo,
                                            vehicleData: widget.vehicleData,
                                            imageFiles: widget.imageFiles,
                                            isLoggedIn: widget.isLoggedIn,
                                            isAgent: widget.isAgent,
                                          )));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.accentOrange
                                  : AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          disabledBackgroundColor:
                              AppTheme.disabledButtonColor(context),
                          disabledForegroundColor:
                              AppTheme.disabledButtonTextColor(context)),
                      child: const Text('Continue',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppTheme.primaryNavy,
                          side: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.primaryNavy),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Back',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
