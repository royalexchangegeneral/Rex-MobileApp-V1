import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
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

class FamilyCarePurchaseScreen extends StatefulWidget {
  final String optionTitle;
  final String price;
  final bool isCustomerFlow;
  const FamilyCarePurchaseScreen(
      {super.key,
      required this.optionTitle,
      required this.price,
      this.isCustomerFlow = false});
  @override
  State<FamilyCarePurchaseScreen> createState() =>
      _FamilyCarePurchaseScreenState();
}

class _FamilyCarePurchaseScreenState extends State<FamilyCarePurchaseScreen> {
  int _currentStep =
      0; // 0=NIN, 1=socioeconomic, 2=next of kin, 3=cover members

  // Step 0: NIN
  final _ninController = TextEditingController();
  bool _isVerifying = false;
  bool _isPayingNow = false;
  bool _ninFailed = false;
  bool _ninVerified = false;
  bool _isCustomerNinLocked = false;

  // Personal info from NIN
  String _firstName = '', _lastName = '', _email = '', _phone = '';
  String _dob = '', _state = '', _lga = '', _address = '', _gender = '';

  // Manual entry controllers
  final _manualFirstNameController = TextEditingController();
  final _manualLastNameController = TextEditingController();
  final _manualEmailController = TextEditingController();
  final _manualPhoneController = TextEditingController();
  final _manualAddressController = TextEditingController();
  String? _selectedManualState;

  final List<String> _nigerianStates = const [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Federal Capital Territory',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  // Step 1: Socioeconomic
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _selectedOccupation;
  String? _selectedBusinessSector;
  final _tinController = TextEditingController();
  String? _selectedQualification;
  final _annualIncomeController = TextEditingController();

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
  final List<String> _qualifications = const [
    'SSCE/WAEC',
    'OND/NCE',
    'HND',
    'BSc/BA',
    'MSc/MA/MBA',
    'PhD',
    'Professional Cert',
    'Others',
  ];

  // Step 2: Next of Kin
  final _nokNameController = TextEditingController();
  final _nokAddressController = TextEditingController();
  final _nokPhoneController = TextEditingController();
  String? _selectedRelationship;

  final List<String> _relationships = const [
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Friend',
    'Others'
  ];

  // Step 3: Cover Members
  final _memberNameController = TextEditingController();
  String? _memberGender;
  final _memberDobController = TextEditingController();
  String? _memberCategory;
  final List<Map<String, String>> _coverMembers = [];
  String? _uploadedFileName;
  bool _consentChecked = false;

  final List<String> _genders = const ['Male', 'Female'];
  final List<String> _categories = const ['Parent', 'Child', 'Spouse'];

  @override
  void initState() {
    super.initState();
    _prefillCustomerNin();
  }

  Future<void> _prefillCustomerNin() async {
    if (!widget.isCustomerFlow) return;

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
    _emailController.dispose();
    _occupationController.dispose();
    _tinController.dispose();
    _annualIncomeController.dispose();
    _nokNameController.dispose();
    _nokAddressController.dispose();
    _nokPhoneController.dispose();
    _memberNameController.dispose();
    _memberDobController.dispose();
    _manualFirstNameController.dispose();
    _manualLastNameController.dispose();
    _manualEmailController.dispose();
    _manualPhoneController.dispose();
    _manualAddressController.dispose();
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
      final response = await http
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
      print('=== NIN VERIFY RESPONSE: ${response.statusCode} ===');
      print('Body: ${response.body}');
      setState(() => _isVerifying = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data']?['data']?['kyc'] != null &&
            responseData['data']['data']['kyc']['firstname'] != null &&
            (responseData['data']['data']['kyc']['firstname']?.toString() ?? '')
                .isNotEmpty) {
          final kyc = responseData['data']['data']['kyc'];
          setState(() {
            _firstName = kyc['firstname']?.toString() ?? '';
            _lastName = kyc['surname']?.toString() ?? '';
            _email = kyc['email']?.toString() ?? '';
            _emailController.text = _email;
            _phone = kyc['telephoneno']?.toString() ?? '';
            _dob = (kyc['birthdate']?.toString() ?? '').replaceAll('-', '/');
            _address = kyc['residence_address']?.toString() ?? '';
            _state = kyc['residence_state']?.toString() ?? '';
            _lga = kyc['residence_lga']?.toString() ?? '';
            _gender = kyc['gender']?.toString() ?? '';
            _ninVerified = true;
            // Pre-fill editable fields with verified data
            _manualFirstNameController.text = _firstName;
            _manualLastNameController.text = _lastName;
            _manualEmailController.text = _email;
            _manualPhoneController.text = _phone;
            _manualAddressController.text = _address;
            final ninState = _state.trim();
            _selectedManualState = _nigerianStates.cast<String?>().firstWhere(
                  (s) => s!.toLowerCase() == ninState.toLowerCase(),
                  orElse: () => null,
                );
          });
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('NIN verified successfully'),
                backgroundColor: Colors.green));
        } else {
          setState(() => _ninFailed = true);
          final kyc = responseData['data']?['data']?['kyc'];
          final msg = kyc != null
              ? (kyc['status']?.toString() ??
                  'Verification failed. Enter details manually.')
              : 'NIN not found. Enter details manually.';
          if (mounted)
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
        }
      } else {
        setState(() => _ninFailed = true);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Verification failed. Enter details manually.')));
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _ninFailed = true;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${ErrorMessages.fromException(e, fallback: 'Verification failed')}. Enter details manually.')));
    }
  }

  double _getBaseAmount() {
    // Handle "Parent: ₦2,625 / Child: ₦1,125" format
    final matches = RegExp(r'[\d,]+\.?\d*').allMatches(widget.price);
    if (matches.isEmpty) return 0;
    // Sum parent price * parents + child price * children from cover members
    final prices = matches
        .map((m) => double.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0)
        .toList();
    if (prices.length >= 2) {
      final parentPrice = prices[0];
      final childPrice = prices[1];
      final parentCount = _coverMembers
          .where((m) =>
              m['category']?.toLowerCase() == 'parent' ||
              m['category']?.toLowerCase() == 'spouse')
          .length;
      final childCount = _coverMembers
          .where((m) => m['category']?.toLowerCase() == 'child')
          .length;
      // At minimum 1 parent if none added
      final pCount = parentCount > 0 ? parentCount : 1;
      return (parentPrice * pCount) + (childPrice * childCount);
    }
    return prices[0];
  }

  double _getPaystackCharge() {
    final base = _getBaseAmount();
    double charge = (base * 0.015) + 100;
    if (charge > 2000) charge = 2000;
    return charge;
  }

  double _getTotalAmount() => _getBaseAmount() + _getPaystackCharge();

  String _formatNaira(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';
  }

  Future<void> _initiatePayment() async {
    final email = _email.isNotEmpty ? _email : 'customer@rexinsure.com';
    final premiumAmount = _getBaseAmount();
    // Extract parent and child premiums separately
    final priceMatches =
        RegExp(r'[\d,]+\.?\d*').allMatches(widget.price).toList();
    final parentPremium = priceMatches.isNotEmpty
        ? (double.tryParse(priceMatches[0].group(0)!.replaceAll(',', '')) ?? 0)
            .toInt()
        : premiumAmount.toInt();
    final childPremium = priceMatches.length >= 2
        ? (double.tryParse(priceMatches[1].group(0)!.replaceAll(',', '')) ?? 0)
            .toInt()
        : 0;

    setState(() => _isPayingNow = true);
    try {
      final result = await PaymentService.initiatePurchase(
        productCode: 'FC',
        names: '$_firstName $_lastName'.trim(),
        email: email,
        mobileno: _phone,
        premium: premiumAmount.toInt(),
        extraFields: {
          'type': 'Individual',
          'agent_code': '',
          'premium2': childPremium,
          'gender': _gender,
          'dob': _dob,
          'occupation': _occupationController.text.trim(),
          'businesssector': _selectedBusinessSector ?? '',
          'tin': _tinController.text.trim(),
          'annualincome': _annualIncomeController.text.trim(),
          'state': _state,
          'nationality': 'Nigerian',
          'nin': _ninController.text.trim(),
          'qualification': _selectedQualification ?? '',
          'hobbies': '',
          'marital': '',
          'address': _address,
          'nok': _nokNameController.text.trim(),
          'nokaddress': _nokAddressController.text.trim(),
          'nokphone': _nokPhoneController.text.trim(),
          'nokrel': _selectedRelationship ?? '',
          'grosspremium': parentPremium,
          'grosspremium2': childPremium,
          'sumassured': 0,
          'pdsumassured': 0,
          'medisumassured': 0,
          'members': _coverMembers
              .map((m) => {
                    'names': m['name'] ?? '',
                    'gender': m['gender'] ?? '',
                    'dob': m['dob'] ?? '',
                    'relationship': m['category'] ?? ''
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
                builder: (_) =>
                    PaystackWebView(url: result.authorizationUrl!)));
        if (res != null && res.success && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PolicyPurchaseSuccessScreen(
                reference: res.reference,
                message: res.message,
                accountData: {
                  'firstName': _firstName,
                  'lastName': _lastName,
                  'email': email,
                  'phone': _phone,
                  'occupation': _occupationController.text.trim(),
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
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                ErrorMessages.fromException(e, fallback: 'Payment failed')),
            backgroundColor: Colors.red));
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
        _memberCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all member fields')));
      return;
    }
    setState(() {
      _coverMembers.add({
        'name': _memberNameController.text.trim(),
        'gender': _memberGender!,
        'dob': _memberDobController.text.trim(),
        'category': _memberCategory!
      });
      _memberNameController.clear();
      _memberGender = null;
      _memberDobController.clear();
      _memberCategory = null;
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
            content: Text(
                'File picker error: $e. Please restart the app after a full rebuild.'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadSampleFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Family-Information-Sample.csv');
      await file.writeAsString(
          'name,gender,dob,category\nkamoru isa,male,1994-04-20,parent\nkil isa,female,1990-04-23,Parent\nJayo,Male,1991-05-30,child\n');
      if (mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sample file saved to: ${file.path}'),
            backgroundColor: Colors.green));
        await Share.shareXFiles([XFile(file.path)],
            subject: 'Family Information Sample', sharePositionOrigin: origin);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorMessages.fromException(e))));
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
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            }),
        title: Text(
            _currentStep == 4 ? 'Royal Family Care' : 'Royal Family Care',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          _buildStepIndicator(),
          const Divider(height: 1),
          if (_currentStep == 0) _buildNinStep(),
          if (_currentStep == 1) _buildSocioeconomicStep(),
          if (_currentStep == 2) _buildNextOfKinStep(),
          if (_currentStep == 3) _buildCoverMembersStep(),
          if (_currentStep == 4) _buildSummaryStep(),
        ]),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final labels = [
      'Mode of Identification',
      'Socioeconomic Information',
      'Next of Kin / Beneficiary Info',
      'Add/Upload Cover Members',
      'Summary'
    ];
    final totalSteps = _currentStep == 4 ? 3 : 4;
    final stepNum = _currentStep == 4 ? 3 : _currentStep + 1;
    final label =
        _currentStep < labels.length ? labels[_currentStep] : 'Summary';
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Step $stepNum of $totalSteps',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryNavy)),
          Flexible(
              child: Text(label,
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
                      margin:
                          EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                          color: i < stepNum
                              ? AppTheme.primaryNavy
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    )))),
      ]),
    );
  }

  // Step 0: NIN
  Widget _buildNinStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
          decoration: InputDecoration(
              hintText: 'Enter your 11-digit NIN',
              hintStyle: TextStyle(color: hintColor, fontSize: 13),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        ),
        if (!_ninFailed && !_ninVerified) ...[
          const SizedBox(height: 40),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _ninController.text.trim().length == 11 && !_isVerifying
                        ? _verifyNin
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
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Continue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              )),
        ],
        if (_ninVerified) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('NIN Verified — review and adjust details below',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700]))),
            ]),
          ),
          const SizedBox(height: 16),
          _label('First Name *'),
          const SizedBox(height: 6),
          _textField('first name', _manualFirstNameController,
              autofillHints: [AutofillHints.givenName]),
          const SizedBox(height: 12),
          _label('Last Name *'),
          const SizedBox(height: 6),
          _textField('last name', _manualLastNameController,
              autofillHints: [AutofillHints.familyName]),
          const SizedBox(height: 12),
          _label('Email *'),
          const SizedBox(height: 6),
          _textField('email', _manualEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 12),
          _label('Phone Number *'),
          const SizedBox(height: 6),
          _textField('phone number', _manualPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label('Address'),
          const SizedBox(height: 6),
          _textField('address', _manualAddressController,
              maxLines: 2, autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 12),
          _label('State'),
          const SizedBox(height: 6),
          SearchableDropdown(
            hint: 'select state',
            value: _selectedManualState,
            items: _nigerianStates,
            onChanged: (v) => setState(() => _selectedManualState = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _manualFirstNameController.text.trim().isNotEmpty &&
                        _manualLastNameController.text.trim().isNotEmpty &&
                        _manualEmailController.text.trim().isNotEmpty &&
                        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(_manualEmailController.text.trim()) &&
                        _manualPhoneController.text.trim().isNotEmpty
                    ? () {
                        setState(() {
                          _firstName = _manualFirstNameController.text.trim();
                          _lastName = _manualLastNameController.text.trim();
                          _email = _manualEmailController.text.trim();
                          _emailController.text = _email;
                          _phone = _manualPhoneController.text.trim();
                          _address = _manualAddressController.text.trim();
                          _state = _selectedManualState ?? '';
                          _currentStep = 1;
                        });
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
        ],
        if (_ninFailed) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'NIN verification failed. Please enter your details manually.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.orange[700]))),
            ]),
          ),
          const SizedBox(height: 16),
          _label('First Name *'),
          const SizedBox(height: 6),
          _textField('enter first name', _manualFirstNameController,
              autofillHints: [AutofillHints.givenName]),
          const SizedBox(height: 12),
          _label('Last Name *'),
          const SizedBox(height: 6),
          _textField('enter last name', _manualLastNameController,
              autofillHints: [AutofillHints.familyName]),
          const SizedBox(height: 12),
          _label('Email *'),
          const SizedBox(height: 6),
          _textField('enter email', _manualEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 12),
          _label('Phone Number *'),
          const SizedBox(height: 6),
          _textField('enter phone number', _manualPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label('Address'),
          const SizedBox(height: 6),
          _textField('enter address', _manualAddressController,
              maxLines: 2, autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 12),
          _label('State'),
          const SizedBox(height: 6),
          SearchableDropdown(
            hint: 'select state',
            value: _selectedManualState,
            items: _nigerianStates,
            onChanged: (v) => setState(() => _selectedManualState = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _manualFirstNameController.text.trim().isNotEmpty &&
                        _manualLastNameController.text.trim().isNotEmpty &&
                        _manualEmailController.text.trim().isNotEmpty &&
                        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(_manualEmailController.text.trim()) &&
                        _manualPhoneController.text.trim().isNotEmpty
                    ? () {
                        setState(() {
                          _firstName = _manualFirstNameController.text.trim();
                          _lastName = _manualLastNameController.text.trim();
                          _email = _manualEmailController.text.trim();
                          _emailController.text = _email;
                          _phone = _manualPhoneController.text.trim();
                          _address = _manualAddressController.text.trim();
                          _state = _selectedManualState ?? '';
                          _currentStep = 1;
                        });
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              )),
        ],
      ]),
    );
  }

  // Step 1: Socioeconomic
  Widget _buildSocioeconomicStep() {
    final needsEmail = _emailController.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (needsEmail) ...[
          _label('Email Address'),
          const SizedBox(height: 6),
          _textField('enter your email address', _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 16),
        ],
        _label('Occupation'),
        const SizedBox(height: 6),
        SearchableDropdown(
          hint: 'select your occupation',
          value: _selectedOccupation,
          items: occupations,
          onChanged: (val) => setState(() {
            _selectedOccupation = val;
            _occupationController.text = val ?? '';
          }),
        ),
        const SizedBox(height: 16),
        _label('Business Sector (optional)'),
        const SizedBox(height: 6),
        _dropdown(
            'select your business sector',
            _selectedBusinessSector,
            _businessSectors,
            (v) => setState(() => _selectedBusinessSector = v)),
        const SizedBox(height: 16),
        _label('Tax Identification No. (optional)'),
        const SizedBox(height: 6),
        _textField('enter your TIN', _tinController),
        const SizedBox(height: 16),
        _label('Highest Academic Qualification'),
        const SizedBox(height: 6),
        _dropdown('select', _selectedQualification, _qualifications,
            (v) => setState(() => _selectedQualification = v)),
        const SizedBox(height: 16),
        _label('Average Annual Income'),
        const SizedBox(height: 6),
        _textField('e.g 23,000,000.00', _annualIncomeController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 40),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _occupationController.text.trim().isNotEmpty &&
                      _selectedQualification != null &&
                      _annualIncomeController.text.trim().isNotEmpty &&
                      _emailController.text.trim().isNotEmpty
                  ? () {
                      _email = _emailController.text.trim();
                      setState(() => _currentStep = 2);
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryNavy,
                  side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryNavy),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
      ]),
    );
  }

  // Step 2: Next of Kin
  Widget _buildNextOfKinStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Name'),
        const SizedBox(height: 6),
        _textField('enter full name', _nokNameController),
        const SizedBox(height: 16),
        _label('Address'),
        const SizedBox(height: 6),
        _textField('enter your address', _nokAddressController, maxLines: 2),
        const SizedBox(height: 16),
        _label('Phone Number'),
        const SizedBox(height: 6),
        _textField('enter phone number', _nokPhoneController,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _label('Relationship'),
        const SizedBox(height: 6),
        _dropdown('select the type of relationship', _selectedRelationship,
            _relationships, (v) => setState(() => _selectedRelationship = v)),
        const SizedBox(height: 40),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nokNameController.text.trim().isNotEmpty &&
                      _nokAddressController.text.trim().isNotEmpty &&
                      _nokPhoneController.text.trim().isNotEmpty &&
                      _selectedRelationship != null
                  ? () => setState(() => _currentStep = 3)
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
              child: const Text('Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryNavy,
                  side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryNavy),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
      ]),
    );
  }

  // Step 3: Cover Members
  Widget _buildCoverMembersStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Add single members
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
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(16)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Add ',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 16)
                ])),
          ),
        ]),
        const SizedBox(height: 16),
        _label('Name'), const SizedBox(height: 6),
        _textField('enter full name', _memberNameController),
        const SizedBox(height: 12),
        _label('Gender'), const SizedBox(height: 6),
        _dropdown('select', _memberGender, _genders,
            (v) => setState(() => _memberGender = v)),
        const SizedBox(height: 12),
        _label('Date of Birth'), const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDob,
          child: AbsorbPointer(
              child: _textField('dd/mm/yyyy', _memberDobController,
                  suffixIcon: Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey))),
        ),
        const SizedBox(height: 12),
        _label('Category'), const SizedBox(height: 6),
        _dropdown('parent', _memberCategory, _categories,
            (v) => setState(() => _memberCategory = v)),
        const SizedBox(height: 12),
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
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: Text('Add',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            )),
        // Cover Members list
        if (_coverMembers.isNotEmpty) ...[
          SizedBox(height: 20),
          Row(children: [
            Text('Cover Members',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            GestureDetector(
                onTap: () => setState(() => _coverMembers.clear()),
                child: const Icon(Icons.cancel, color: Colors.grey, size: 20)),
          ]),
          const SizedBox(height: 8),
          ...List.generate(_coverMembers.length, (i) {
            final m = _coverMembers[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!)),
              child: Column(children: [
                _memberRow('Name', m['name'] ?? ''),
                _memberRow('Gender', m['gender'] ?? ''),
                _memberRow('DOB', m['dob'] ?? ''),
                Row(children: [
                  Expanded(child: _memberRow('Category', m['category'] ?? '')),
                  GestureDetector(
                      onTap: () => setState(() => _coverMembers.removeAt(i)),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18)),
                ]),
              ]),
            );
          }),
        ],
        const SizedBox(height: 24),
        // Bulk upload
        Text('Click to upload bulk members',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _downloadSampleFile,
          icon: Icon(Icons.download, size: 16),
          label: const Text('Download sample file',
              style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.primaryNavy,
              side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.primaryNavy),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(height: 12),
        const Text('Upload a file (Upload an Excel file max 2 MB)',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey[300]!, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 32, color: Colors.grey[400]),
              const SizedBox(height: 4),
              Text('Drop your files here',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text('Browse file from your phone',
                  style: TextStyle(fontSize: 11, color: Colors.blue[400])),
            ]),
          ),
        ),
        if (_uploadedFileName != null) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.insert_drive_file, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                  child: Text(_uploadedFileName!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface))),
              GestureDetector(
                  onTap: () => setState(() => _uploadedFileName = null),
                  child: const Icon(Icons.close, size: 16, color: Colors.red)),
            ]),
          ),
        ],
        const SizedBox(height: 20),
        // Consent
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                  value: _consentChecked,
                  onChanged: (v) =>
                      setState(() => _consentChecked = v ?? false),
                  activeColor: AppTheme.primaryNavy)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            'I hereby consent to the collection, processing, use and the transfer of personal data to third parties (within or outside Nigeria), for the performance of this contract and any other data processing activities which may arise therefrom between myself and Rex Insurance Limited (Rex Insurance). I affirm that I am aware and take cognizance of my rights under the relevant Data Protection Laws in Nigeria and other terms detailed in the Data Protection and Privacy Policy of Rex Insurance available on our policy.\nI authorize and consent that any person who may be in possession of, or hereafter acquire, any information pertaining to my records may disclose such information to Rex Insurance.',
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFCBD5E1)
                    : Colors.grey[700],
                height: 1.4),
          )),
        ]),
        const SizedBox(height: 24),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_coverMembers.isNotEmpty || _uploadedFileName != null) &&
                          _consentChecked
                      ? () => setState(() => _currentStep = 4)
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
              child: const Text('Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 2),
              style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryNavy,
                  side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryNavy),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
      ]),
    );
  }

  Widget _memberRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
        SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: Text(value,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.right)),
      ]),
    );
  }

  // Step 4: Summary
  Widget _buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _summarySection('Payment Information', [
          _summaryRow('Product', 'Royal Family Care ${widget.optionTitle}'),
          _summaryRow('Price', widget.price),
          _summaryRow('Paystack Charges', _formatNaira(_getPaystackCharge())),
          _summaryRow('Total', _formatNaira(_getTotalAmount())),
        ]),
        const SizedBox(height: 20),
        _summarySection('Group & Contact Information', [
          _summaryRow('First Name', _firstName),
          _summaryRow('Last Name', _lastName),
          _summaryRow('Email', _email),
          _summaryRow('Phone Number', _phone),
          _summaryRow('DOB', _dob),
          _summaryRow('Gender', _gender),
          _summaryRow('State', _state),
          _summaryRow('LGA', _lga),
          _summaryRow('Address', _address),
        ]),
        const SizedBox(height: 20),
        _summarySection('Leadership & Risk Details', [
          _summaryRow('Occupation', _occupationController.text),
          _summaryRow('Business Sector', _selectedBusinessSector ?? '-'),
          _summaryRow('Tax Identification No',
              _tinController.text.isNotEmpty ? _tinController.text : '-'),
          _summaryRow(
              'Highest Academic Qualification', _selectedQualification ?? '-'),
          _summaryRow('Average Annual Income', _annualIncomeController.text),
        ]),
        const SizedBox(height: 20),
        _summarySection('Cover Members', [
          _summaryRow('Name', _nokNameController.text),
          _summaryRow('Address', _nokAddressController.text),
          _summaryRow('Phone Number', _nokPhoneController.text),
          _summaryRow('Relationship', _selectedRelationship ?? '-'),
        ]),
        if (_coverMembers.isNotEmpty) ...[
          SizedBox(height: 20),
          _summarySection('Added Members (${_coverMembers.length})', [
            ..._coverMembers.map((m) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(
                        child: Text('${m['name']} (${m['category']})',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onSurface))),
                    Text('${m['gender']} - ${m['dob']}',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ]),
                )),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _summarySection(String title, List<Widget> rows) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.grey[50]!;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[200]!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        ...rows,
      ]),
    );
  }

  Widget _summaryRow(String label, String value) {
    final labelColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFCBD5E1)
        : Colors.grey[600]!;

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child:
                Text(label, style: TextStyle(fontSize: 12, color: labelColor))),
        SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: Text(value.isNotEmpty ? value : '-',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface));

  Widget _textField(String hint, TextEditingController controller,
      {TextInputType? keyboardType,
      int maxLines = 1,
      int? maxLength,
      Widget? suffixIcon,
      List<String>? autofillHints}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;
    String? errorText;
    if (keyboardType == TextInputType.emailAddress &&
        controller.text.trim().isNotEmpty) {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(controller.text.trim()))
        errorText = 'Enter a valid email address';
    }
    if (keyboardType == TextInputType.phone &&
        controller.text.trim().isNotEmpty) {
      final cleaned = controller.text.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.length < 10 || cleaned.length > 15)
        errorText = 'Enter a valid phone number';
    }
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: (_) => setState(() {}),
      autofillHints: autofillHints,
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
        filled: true,
        fillColor: fieldColor,
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
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accent, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final iconColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    return Container(
      decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor)),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: isDark ? const Color(0xFF111827) : Colors.white,
        hint: Text(hint, style: TextStyle(color: hintColor, fontSize: 13)),
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
        icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
        items: items
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
