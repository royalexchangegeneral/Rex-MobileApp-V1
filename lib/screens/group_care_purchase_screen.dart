import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import '../utils/app_theme.dart';
import '../utils/customer_details.dart';
import '../utils/error_messages.dart';
import '../utils/occupations.dart';
import '../widgets/paystack_webview.dart';
import '../widgets/searchable_dropdown.dart';
import 'policy_purchase_success_screen.dart';

class GroupCarePurchaseScreen extends StatefulWidget {
  final String optionTitle;
  final String price;
  const GroupCarePurchaseScreen(
      {super.key, required this.optionTitle, required this.price});
  @override
  State<GroupCarePurchaseScreen> createState() =>
      _GroupCarePurchaseScreenState();
}

class _GroupCarePurchaseScreenState extends State<GroupCarePurchaseScreen> {
  int _currentStep = 0; // 0=group info, 1=leadership, 2=risk/members, 3=summary

  bool _isPayingNow = false;
  int? _agentSellingPremium;
  bool _isLoadingAgentSellingPrice = false;
  bool _didLoadAgentSellingPrice = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardColor => _isDark ? const Color(0xFF111827) : Colors.grey[50]!;

  Color get _fieldColor => _isDark ? const Color(0xFF111827) : Colors.white;

  Color get _sectionColor =>
      _isDark ? const Color(0xFF111827) : Colors.grey[100]!;

  Color get _borderColor =>
      _isDark ? const Color(0xFF334155) : Colors.grey[300]!;

  Color get _secondaryTextColor =>
      _isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color get _mutedTextColor =>
      _isDark ? const Color(0xFF94A3B8) : Colors.grey[500]!;

  Color get _agentAccent =>
      _isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

  String get _productCode => 'GC';

  String get _subProductCode =>
      PaymentService.subProductCodeForOption(_productCode, widget.optionTitle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadAgentSellingPrice) return;
    _didLoadAgentSellingPrice = true;
    _loadAgentSellingPrice();
  }

  Future<void> _loadAgentSellingPrice() async {
    final authProvider = context.read<AuthProvider>();
    final agentCode = authProvider.userCode?.toString() ?? '';
    if (agentCode.isEmpty) return;

    setState(() => _isLoadingAgentSellingPrice = true);
    final premium = await PaymentService.agentSellingNetPremium(
      agentCode: agentCode,
      productCode: _productCode,
      subProductCode: _subProductCode,
    );
    if (!mounted) return;
    setState(() {
      _agentSellingPremium = premium;
      _isLoadingAgentSellingPrice = false;
    });
  }

  // Step 0: Group & Contact
  final _groupNameController = TextEditingController();
  final _groupEmailController = TextEditingController();
  final _groupAddressController = TextEditingController();
  String? _selectedBusinessSector;
  final _websiteController = TextEditingController();

  final List<String> _businessSectors = const [
    'Agriculture',
    'Banking & Finance',
    'Construction',
    'Education',
    'Energy',
    'Healthcare',
    'ICT',
    'Manufacturing',
    'Mining',
    'Oil & Gas',
    'Real Estate',
    'Retail',
    'Telecommunications',
    'Transportation',
    'Others',
  ];

  // Step 1: Leadership
  final _chairNameController = TextEditingController();
  final _chairPhoneController = TextEditingController();
  final _chairNinController = TextEditingController();
  final _secNameController = TextEditingController();
  final _secPhoneController = TextEditingController();
  final _secNinController = TextEditingController();
  bool _isVerifyingChairNin = false;
  bool _isVerifyingSecNin = false;
  String _chairNinStatus = ''; // 'verified' or ''
  String _secNinStatus = '';

  // Step 2: Members
  final _memberNameController = TextEditingController();
  String? _memberGender;
  final _memberDobController = TextEditingController();
  final _memberOccupationController = TextEditingController();
  String? _selectedMemberOccupation;
  final _memberPhoneController = TextEditingController();
  final _memberEmailController = TextEditingController();
  // Next of Kin per member
  final _nokNameController = TextEditingController();
  final _nokPhoneController = TextEditingController();
  String? _nokRelationship;

  final List<Map<String, String>> _coverMembers = [];
  String? _uploadedFileName;
  bool _consentChecked = false;

  final List<String> _genders = const ['Male', 'Female'];
  final List<String> _relationships = const [
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Friend',
    'Others'
  ];

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupEmailController.dispose();
    _groupAddressController.dispose();
    _websiteController.dispose();
    _chairNameController.dispose();
    _chairPhoneController.dispose();
    _chairNinController.dispose();
    _secNameController.dispose();
    _secPhoneController.dispose();
    _secNinController.dispose();
    _memberNameController.dispose();
    _memberDobController.dispose();
    _memberOccupationController.dispose();
    _memberPhoneController.dispose();
    _memberEmailController.dispose();
    _nokNameController.dispose();
    _nokPhoneController.dispose();
    super.dispose();
  }

  double _getBaseAmount() {
    final matches = RegExp(r'[\d,]+\.?\d*').allMatches(widget.price);
    if (matches.isEmpty) return 0;
    final first = matches.first.group(0)!.replaceAll(',', '');
    return double.tryParse(first) ?? 0;
  }

  double _getPaystackCharge() {
    final base = _getSummaryBaseAmount();
    double charge = (base * 0.015) + 100;
    if (charge > 2000) charge = 2000;
    return charge;
  }

  double _getSummaryBaseAmount() =>
      (_agentSellingPremium ?? _getBaseAmount()).toDouble();

  double _getTotalAmount() => _getSummaryBaseAmount() + _getPaystackCharge();

  String _formatNaira(double amount) =>
      '₦${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

  String _summaryPriceText() => _isLoadingAgentSellingPrice
      ? 'Loading...'
      : _formatNaira(_getSummaryBaseAmount());

  Future<void> _verifyNin(
      TextEditingController ninController,
      TextEditingController nameController,
      TextEditingController phoneController,
      {required bool isChairman}) async {
    final nin = ninController.text.trim();
    if (nin.length != 11) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('NIN must be 11 digits')));
      return;
    }
    setState(() {
      if (isChairman) {
        _isVerifyingChairNin = true;
      } else {
        _isVerifyingSecNin = true;
      }
    });
    try {
      final response = await http
          .post(
            Uri.parse('https://eportaltest.rexinsure.com/api/mobile/verify/nin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'Intcode': 'TESTCODE',
              'Password': 'royal1234',
              'number': nin
            }),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint(
          '=== NIN VERIFY (${isChairman ? "Chairman" : "Secretary"}): ${response.statusCode} ===');
      debugPrint('Body: ${response.body}');
      setState(() {
        if (isChairman) {
          _isVerifyingChairNin = false;
        } else {
          _isVerifyingSecNin = false;
        }
      });
      if ((response.statusCode == 200 || response.statusCode == 201)) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' &&
            data['data']?['data']?['kyc'] != null &&
            data['data']['data']['kyc']['firstname'] != null &&
            (data['data']['data']['kyc']['firstname']?.toString() ?? '')
                .isNotEmpty) {
          final kyc = data['data']['data']['kyc'];
          setState(() {
            nameController.text =
                '${kyc['firstname'] ?? ''} ${kyc['surname'] ?? ''}'.trim();
            phoneController.text = kyc['telephoneno']?.toString() ?? '';
            if (isChairman) {
              _chairNinStatus = 'verified';
            } else {
              _secNinStatus = 'verified';
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${isChairman ? "Chairman" : "Secretary"} NIN verified'),
                backgroundColor: Colors.green));
          }
        } else {
          final kyc = data['data']?['data']?['kyc'];
          final msg = kyc != null
              ? (kyc['status']?.toString() ?? 'Verification failed')
              : 'No data found for this NIN';
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        }
      }
    } catch (e) {
      setState(() {
        if (isChairman) {
          _isVerifyingChairNin = false;
        } else {
          _isVerifyingSecNin = false;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorMessages.fromException(e))));
      }
    }
  }

  Future<void> _initiatePayment() async {
    final email = _groupEmailController.text.trim().isNotEmpty
        ? _groupEmailController.text.trim()
        : 'customer@rexinsure.com';
    final premiumAmount = _getBaseAmount();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final agentCode = authProvider.userCode?.toString() ?? '';
    final agentUserType = agentCode.isNotEmpty
        ? (authProvider.userTypeCode?.toString() ?? '')
        : '';
    final payerEmail = agentCode.isNotEmpty
        ? (authProvider.userEmail ?? authProvider.loginEmail ?? '')
        : '';
    setState(() => _isPayingNow = true);
    try {
      final result = await PaymentService.initiatePurchase(
        productCode: 'GC',
        names: _groupNameController.text.trim(),
        email: email,
        mobileno: _chairPhoneController.text.trim(),
        premium: premiumAmount.toInt(),
        agentCode: agentCode,
        agentUserType: agentUserType,
        payerEmail: payerEmail,
        subProductCode: _subProductCode,
        extraFields: {
          'type': 'Corporate',
          'address': _groupAddressController.text.trim(),
          'bussector': _selectedBusinessSector ?? '',
          'website': _websiteController.text.trim(),
          'chairman': _chairNameController.text.trim(),
          'chairphone': _chairPhoneController.text.trim(),
          'chairnin': _chairNinController.text.trim(),
          'secname': _secNameController.text.trim(),
          'secno': _secPhoneController.text.trim(),
          'secnin': _secNinController.text.trim(),
          'grosspremium': premiumAmount.toInt(),
          'members': _coverMembers
              .map((m) => {
                    'names': m['name'] ?? '',
                    'gender': m['gender'] ?? '',
                    'mobileno': m['phone'] ?? '',
                    'email': m['email'] ?? '',
                    'dob': CustomerDetails.normalizeApiDate(m['dob']),
                    'nok': m['nokName'] ?? '',
                    'nokphone': m['nokPhone'] ?? ''
                  })
              .toList(),
        },
      );
      setState(() => _isPayingNow = false);
      if (!mounted) return;
      if (result.success && result.authorizationUrl != null) {
        final res = await Navigator.push<PaymentVerifyResult>(
            context,
            MaterialPageRoute(
                builder: (_) => PaystackWebView(
                    url: result.authorizationUrl!,
                    reference: result.reference)));
        if (res != null && res.success && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PolicyPurchaseSuccessScreen(
                isLoggedIn: true,
                isAgent: true,
                reference: res.reference,
                message: res.message,
                accountData: {
                  'firstName':
                      _chairNameController.text.trim().split(' ').first,
                  'lastName': _chairNameController.text
                      .trim()
                      .split(' ')
                      .skip(1)
                      .join(' '),
                  'email': email,
                  'phone': _chairPhoneController.text.trim(),
                  'occupation': 'Business',
                },
              ),
            ),
          );
        } else if (res != null && !res.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(res.message ?? 'Payment verification failed'),
              backgroundColor: Colors.red));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.message ?? 'Payment failed'),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      setState(() => _isPayingNow = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                ErrorMessages.fromException(e, fallback: 'Payment failed')),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1920),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() => _memberDobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}');
    }
  }

  void _addMember() {
    if (_memberNameController.text.trim().isEmpty ||
        _memberGender == null ||
        _memberDobController.text.trim().isEmpty ||
        _memberOccupationController.text.trim().isEmpty ||
        _memberPhoneController.text.trim().isEmpty ||
        _memberEmailController.text.trim().isEmpty ||
        _nokNameController.text.trim().isEmpty ||
        _nokPhoneController.text.trim().isEmpty ||
        _nokRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all fields including Next of Kin')));
      return;
    }
    setState(() {
      _coverMembers.add({
        'name': _memberNameController.text.trim(),
        'gender': _memberGender!,
        'dob': CustomerDetails.normalizeApiDate(_memberDobController.text),
        'occupation': _memberOccupationController.text.trim(),
        'phone': _memberPhoneController.text.trim(),
        'email': _memberEmailController.text.trim(),
        'nokName': _nokNameController.text.trim(),
        'nokPhone': _nokPhoneController.text.trim(),
        'nokRelationship': _nokRelationship ?? '',
      });
      _memberNameController.clear();
      _memberGender = null;
      _memberDobController.clear();
      _memberOccupationController.clear();
      _memberPhoneController.clear();
      _memberEmailController.clear();
      _nokNameController.clear();
      _nokPhoneController.clear();
      _nokRelationship = null;
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['xlsx', 'xls', 'csv']);
      if (result != null && result.files.isNotEmpty) {
        setState(() => _uploadedFileName = result.files.first.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File picker error: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadSampleFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Group-Members-Sample.csv');
      await file.writeAsString(
          'name,gender,dob,address,mobileno,next_of_kin,next_of_kin_number,next_of_kin_address\nJoko,Female,1994-04-20,Baruwa Ets,80887766777,Haye,99897998989,Shunbi Ets\nJayo,Male,1991-05-30,Baruwa Ets,80887766777,Bisi,99897998989,Shunbi Ets\nJayjay,Female,2001-02-09,Baruwa Ets,80887766777,Kamo,99897998989,Shunbi Ets\n');
      if (mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100);
        await Share.shareXFiles([XFile(file.path)],
            subject: 'Group Members Sample', sharePositionOrigin: origin);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorMessages.fromException(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.pop(context);
                }
              }),
          title: Text(
              _currentStep == 3
                  ? 'Royal Group Care summary'
                  : 'Royal Group Care',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          centerTitle: true),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            _buildStepIndicator(),
            const Divider(height: 1),
            if (_currentStep == 0) _buildGroupInfoStep(),
            if (_currentStep == 1) _buildLeadershipStep(),
            if (_currentStep == 2) _buildMembersStep(),
            if (_currentStep == 3) _buildSummaryStep(),
          ])),
    );
  }

  Widget _buildStepIndicator() {
    final labels = [
      'Group & Contact Information',
      'Leadership & Risk Details',
      'Risk Information',
      'Summary'
    ];
    final totalSteps = _currentStep == 3 ? 3 : 4;
    final stepNum = _currentStep == 3 ? 3 : _currentStep + 1;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Step $stepNum of $totalSteps',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _agentAccent)),
            Flexible(
                child: Text(labels[_currentStep],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface),
                    textAlign: TextAlign.right)),
          ]),
          const SizedBox(height: 8),
          Row(
              children: List.generate(
                  totalSteps,
                  (i) => Expanded(
                      child: Container(
                          height: 3,
                          margin: EdgeInsets.only(
                              right: i < totalSteps - 1 ? 4 : 0),
                          decoration: BoxDecoration(
                              color: i < stepNum ? _agentAccent : _borderColor,
                              borderRadius: BorderRadius.circular(2)))))),
        ]));
  }

  // Step 0: Group & Contact
  Widget _buildGroupInfoStep() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Name of Group *'),
          const SizedBox(height: 6),
          _tf('Enter your group name', _groupNameController,
              autofillHints: [AutofillHints.name]),
          const SizedBox(height: 16),
          _label('Email *'),
          const SizedBox(height: 6),
          _tf('Enter your email', _groupEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 16),
          _label('Address *'),
          const SizedBox(height: 6),
          _tf('Enter your address', _groupAddressController,
              autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 16),
          _label('Business Sector *'),
          const SizedBox(height: 6),
          _dd(
              'Select your business sector',
              _selectedBusinessSector,
              _businessSectors,
              (v) => setState(() => _selectedBusinessSector = v)),
          const SizedBox(height: 16),
          _label('Website'),
          const SizedBox(height: 6),
          _tf('Enter your company website', _websiteController),
          const SizedBox(height: 40),
          _btn(
              'Next',
              _groupNameController.text.trim().isNotEmpty &&
                      _groupEmailController.text.trim().isNotEmpty &&
                      _groupAddressController.text.trim().isNotEmpty &&
                      _selectedBusinessSector != null &&
                      _websiteController.text.trim().isNotEmpty
                  ? () => setState(() => _currentStep = 1)
                  : null),
          const SizedBox(height: 12),
          _outlineBtn('Back', () => Navigator.pop(context)),
        ]));
  }

  // Step 1: Leadership
  Widget _buildLeadershipStep() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Chairman's Details"),
          const SizedBox(height: 12),
          _label("Chairman's Name"),
          const SizedBox(height: 6),
          _tf('', _chairNameController, autofillHints: [AutofillHints.name]),
          const SizedBox(height: 12),
          _label("Chairman's Phone Number"),
          const SizedBox(height: 6),
          _tf('', _chairPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label("Chairman's NIN"),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
                child: _tf('', _chairNinController,
                    keyboardType: TextInputType.number, maxLength: 11)),
            const SizedBox(width: 8),
            SizedBox(
                width: 80,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isVerifyingChairNin
                      ? null
                      : () => _verifyNin(_chairNinController,
                          _chairNameController, _chairPhoneController,
                          isChairman: true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _chairNinStatus == 'verified'
                          ? Colors.green
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.accentOrange
                              : AppTheme.primaryNavy),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: _isVerifyingChairNin
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_chairNinStatus == 'verified' ? '✓' : 'Verify',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                )),
          ]),
          const SizedBox(height: 24),
          _sectionHeader("Secretary's Details"),
          const SizedBox(height: 12),
          _label("Secretary's Name"),
          const SizedBox(height: 6),
          _tf('', _secNameController, autofillHints: [AutofillHints.name]),
          const SizedBox(height: 12),
          _label("Secretary's Phone Number"),
          const SizedBox(height: 6),
          _tf('', _secPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label("Secretary's NIN"),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
                child: _tf('', _secNinController,
                    keyboardType: TextInputType.number, maxLength: 11)),
            const SizedBox(width: 8),
            SizedBox(
                width: 80,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isVerifyingSecNin
                      ? null
                      : () => _verifyNin(_secNinController, _secNameController,
                          _secPhoneController,
                          isChairman: false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _secNinStatus == 'verified'
                          ? Colors.green
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.accentOrange
                              : AppTheme.primaryNavy),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: _isVerifyingSecNin
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_secNinStatus == 'verified' ? '✓' : 'Verify',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                )),
          ]),
          const SizedBox(height: 40),
          _btn(
              'Continue',
              _chairNameController.text.trim().isNotEmpty &&
                      _chairPhoneController.text.trim().isNotEmpty &&
                      _chairNinController.text.trim().isNotEmpty &&
                      _secNameController.text.trim().isNotEmpty &&
                      _secPhoneController.text.trim().isNotEmpty &&
                      _secNinController.text.trim().isNotEmpty
                  ? () => setState(() => _currentStep = 2)
                  : null),
          const SizedBox(height: 12),
          _outlineBtn('Back', () => setState(() => _currentStep = 0)),
        ]));
  }

  Widget _sectionHeader(String title) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: _sectionColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor)),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface))),
          Icon(Icons.remove, size: 18, color: _secondaryTextColor)
        ]));
  }

  // Step 2: Members + Risk
  Widget _buildMembersStep() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Click to add single members',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: _addMember,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: _agentAccent,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Add ',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 16)
                    ]))),
          ]),
          const SizedBox(height: 16),
          _label('Name *'),
          const SizedBox(height: 6),
          _tf('enter full name', _memberNameController,
              autofillHints: [AutofillHints.name]),
          const SizedBox(height: 12),
          _label('Gender *'),
          const SizedBox(height: 6),
          _dd('select', _memberGender, _genders,
              (v) => setState(() => _memberGender = v)),
          const SizedBox(height: 12),
          _label('Date of Birth *'),
          const SizedBox(height: 6),
          GestureDetector(
              onTap: _pickDob,
              child: AbsorbPointer(
                  child: _tf('dd/mm/yyyy', _memberDobController,
                      suffixIcon: Icon(Icons.calendar_today,
                          size: 18, color: _secondaryTextColor)))),
          const SizedBox(height: 12),
          _label('Occupation'),
          const SizedBox(height: 6),
          SearchableDropdown(
            hint: 'select occupation',
            value: _selectedMemberOccupation,
            items: occupations,
            onChanged: (val) => setState(() {
              _selectedMemberOccupation = val;
              _memberOccupationController.text = val ?? '';
            }),
          ),
          const SizedBox(height: 12),
          _label('Phone Number *'),
          const SizedBox(height: 6),
          _tf('enter phone number', _memberPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label('Email *'),
          const SizedBox(height: 6),
          _tf('email', _memberEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 16),
          _sectionHeader('Next of Kin Information'),
          const SizedBox(height: 12),
          _label('Name *'),
          const SizedBox(height: 6),
          _tf('enter full name', _nokNameController,
              autofillHints: [AutofillHints.name]),
          const SizedBox(height: 12),
          _label('Phone Number *'),
          const SizedBox(height: 6),
          _tf('enter phone number', _nokPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label('Relationship *'),
          const SizedBox(height: 6),
          _dd('select the type of relationship', _nokRelationship,
              _relationships, (v) => setState(() => _nokRelationship = v)),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _addMember,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.accentOrange
                              : AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Add',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)))),
          if (_coverMembers.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => setState(() {
                          if (_coverMembers.isNotEmpty) {
                            _coverMembers.removeLast();
                          }
                        }),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('Remove',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)))),
            const SizedBox(height: 12),
            ...List.generate(_coverMembers.length, (i) {
              final m = _coverMembers[i];
              return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderColor)),
                  child: Column(children: [
                    _mRow('Name', m['name'] ?? ''),
                    _mRow('Gender', m['gender'] ?? ''),
                    _mRow('DOB', m['dob'] ?? ''),
                    _mRow('Phone', m['phone'] ?? ''),
                    _mRow('NOK', m['nokName'] ?? '')
                  ]));
            }),
          ],
          const SizedBox(height: 20),
          Text('Click to upload bulk members',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Row(children: [
            OutlinedButton.icon(
                onPressed: _downloadSampleFile,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download sample file',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy,
                    side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)))),
            const SizedBox(width: 8),
            ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload, size: 16),
                label: const Text('upload', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)))),
          ]),
          const SizedBox(height: 8),
          Text('Upload a file (Upload an Excel file max 2 MB)',
              style: TextStyle(fontSize: 11, color: _mutedTextColor)),
          const SizedBox(height: 8),
          GestureDetector(
              onTap: _pickFile,
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                      color: _isDark ? _cardColor : Colors.transparent,
                      border: Border.all(color: _borderColor),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 32, color: _mutedTextColor),
                    Text('Drop your files here',
                        style: TextStyle(fontSize: 12, color: _mutedTextColor)),
                    Text('Browse file from your phone',
                        style: TextStyle(fontSize: 11, color: Colors.blue[400]))
                  ]))),
          if (_uploadedFileName != null) ...[
            const SizedBox(height: 8),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: _sectionColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderColor)),
                child: Row(children: [
                  Icon(Icons.insert_drive_file,
                      size: 16, color: _secondaryTextColor),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_uploadedFileName!,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface))),
                  GestureDetector(
                      onTap: () => setState(() => _uploadedFileName = null),
                      child:
                          const Icon(Icons.close, size: 16, color: Colors.red))
                ])),
          ],
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                    value: _consentChecked,
                    onChanged: (v) =>
                        setState(() => _consentChecked = v ?? false),
                    activeColor: _agentAccent)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    'I hereby consent to the collection, processing, use and the transfer of personal data to third parties (within or outside Nigeria), for the performance of this contract and any other data processing activities which may arise therefrom between myself and Rex Insurance Limited (Rex Insurance). I affirm that I am aware and take cognizance of my rights under the relevant Data Protection Laws in Nigeria and other terms detailed in the Data Protection and Privacy Policy of Rex Insurance available on our policy.\nI authorize and consent that any person who may be in possession of, or hereafter acquire, any information pertaining to my records may disclose such information to Rex Insurance.',
                    style: TextStyle(
                        fontSize: 10,
                        color: _secondaryTextColor,
                        height: 1.4))),
          ]),
          const SizedBox(height: 24),
          _btn(
              'Submit',
              (_coverMembers.isNotEmpty || _uploadedFileName != null) &&
                      _consentChecked
                  ? () => setState(() => _currentStep = 3)
                  : null),
          const SizedBox(height: 12),
          _outlineBtn('Back', () => setState(() => _currentStep = 1)),
        ]));
  }

  Widget _mRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(l,
                style: TextStyle(fontSize: 11, color: _secondaryTextColor))),
        const SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: Text(v,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.right))
      ]));

  // Step 3: Summary
  Widget _buildSummaryStep() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sec('Payment Information', [
            _sRow('Product', 'Royal Group Care ${widget.optionTitle}'),
            _sRow('Price', _summaryPriceText()),
            _sRow('Paystack Charges', _formatNaira(_getPaystackCharge())),
            _sRow('Total', _formatNaira(_getTotalAmount()))
          ]),
          const SizedBox(height: 20),
          _sec('Group & Contact Information', [
            _sRow('Name of Group', _groupNameController.text),
            _sRow('Email', _groupEmailController.text),
            _sRow('Address', _groupAddressController.text),
            _sRow('Business Sector', _selectedBusinessSector ?? '-'),
            _sRow('Website', _websiteController.text)
          ]),
          const SizedBox(height: 20),
          _sec('Leadership & Risk Details', [
            _sRow("Chairman's Name", _chairNameController.text),
            _sRow("Chairman's Phone", _chairPhoneController.text),
            _sRow("Chairman's NIN", _chairNinController.text),
            _sRow("Secretary's Name", _secNameController.text),
            _sRow("Secretary's Phone", _secPhoneController.text),
            _sRow("Secretary's NIN", _secNinController.text)
          ]),
          if (_coverMembers.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sec('Cover Members (${_coverMembers.length})', [
              ..._coverMembers.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(children: [
                    _sRow('Name', m['name'] ?? ''),
                    _sRow('Phone', m['phone'] ?? ''),
                    _sRow('NOK', m['nokName'] ?? ''),
                    _sRow('Relationship', m['nokRelationship'] ?? ''),
                    if (_coverMembers.indexOf(m) < _coverMembers.length - 1)
                      Divider(color: _borderColor),
                  ]))),
            ]),
          ],
          const SizedBox(height: 30),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPayingNow ? null : _initiatePayment,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: _isPayingNow
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Pay Now',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              )),
          const SizedBox(height: 20),
        ]));
  }

  Widget _sec(String title, List<Widget> rows) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        ...rows
      ]));

  Widget _sRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: Text(l,
                style: TextStyle(fontSize: 12, color: _secondaryTextColor))),
        const SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: Text(v.isNotEmpty ? v : '-',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.right))
      ]));

  Widget _label(String t) {
    if (t.endsWith('*')) {
      final clean = t.substring(0, t.length - 1).trimRight();
      return RichText(
          text: TextSpan(
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface),
              children: [
            TextSpan(text: clean),
            const TextSpan(
                text: ' *',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ]));
    }
    return Text(t,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface));
  }

  Widget _tf(String hint, TextEditingController c,
      {TextInputType? keyboardType,
      int maxLines = 1,
      int? maxLength,
      Widget? suffixIcon,
      List<String>? autofillHints}) {
    String? errorText;
    if (keyboardType == TextInputType.emailAddress &&
        c.text.trim().isNotEmpty) {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(c.text.trim())) {
        errorText = 'Enter a valid email address';
      }
    }
    if (keyboardType == TextInputType.phone && c.text.trim().isNotEmpty) {
      final cleaned = c.text.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.length < 10 || cleaned.length > 15) {
        errorText = 'Enter a valid phone number';
      }
    }
    return TextField(
        controller: c,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: (_) => setState(() {}),
        autofillHints: autofillHints,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _mutedTextColor, fontSize: 13),
            filled: true,
            fillColor: _fieldColor,
            counterText: '',
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 11),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _agentAccent, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
  }

  Widget _dd(String hint, String? value, List<String> items,
          ValueChanged<String?> onChanged) =>
      Container(
          decoration: BoxDecoration(
              color: _fieldColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor)),
          child: DropdownButtonFormField<String>(
              initialValue: value,
              hint: Text(hint,
                  style: TextStyle(color: _mutedTextColor, fontSize: 13)),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              dropdownColor: _isDark ? const Color(0xFF111827) : Colors.white,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              icon: Icon(Icons.keyboard_arrow_down, color: _secondaryTextColor),
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged));

  Widget _btn(String text, VoidCallback? onPressed) => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.accentOrange
                  : AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              disabledBackgroundColor: AppTheme.disabledButtonColor(context),
              disabledForegroundColor:
                  AppTheme.disabledButtonTextColor(context)),
          child: Text(text,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))));

  Widget _outlineBtn(String text, VoidCallback onPressed) => SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.primaryNavy,
              side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.primaryNavy),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Text(text,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))));
}
