import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/payment_service.dart';
import '../utils/app_theme.dart';
import '../utils/occupations.dart';
import '../widgets/paystack_webview.dart';
import '../widgets/searchable_dropdown.dart';
import 'policy_purchase_success_screen.dart';

class PersonalCarePurchaseScreen extends StatefulWidget {
  final String optionTitle;
  final String price;
  final String productName;
  const PersonalCarePurchaseScreen(
      {super.key,
      required this.optionTitle,
      required this.price,
      this.productName = 'Royal Personal Care'});
  @override
  State<PersonalCarePurchaseScreen> createState() =>
      _PersonalCarePurchaseScreenState();
}

class _PersonalCarePurchaseScreenState
    extends State<PersonalCarePurchaseScreen> {
  int _currentStep =
      0; // 0=NIN verify, 1=socioeconomic, 2=next of kin, 3=summary

  // Step 0: NIN
  final _ninController = TextEditingController();
  bool _isVerifying = false;
  bool _isPayingNow = false;
  bool _ninFailed = false;
  bool _ninVerified = false;
  // Personal info (populated after NIN verify)
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _dob = '';
  String _state = '';
  String _lga = '';
  String _address = '';
  String _gender = '';
  // Manual entry controllers (when NIN fails)
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
  bool _consentChecked = false;

  final List<String> _relationships = const [
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Friend',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
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
    _manualFirstNameController.dispose();
    _manualLastNameController.dispose();
    _manualEmailController.dispose();
    _manualPhoneController.dispose();
    _manualAddressController.dispose();
    super.dispose();
  }

  void _verifyNin() async {
    final nin = _ninController.text.trim();
    if (nin.length != 11 || !RegExp(r'^\d{11}$').hasMatch(nin)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NIN must be exactly 11 digits (numbers only)')));
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
              'number': nin,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('=== NIN VERIFY RESPONSE: ${response.statusCode} ===');
      print('Body: ${response.body}');

      setState(() => _isVerifying = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success' &&
            responseData['data'] != null &&
            responseData['data']['data'] != null &&
            responseData['data']['data']['kyc'] != null &&
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
            // Try to match NIN state to dropdown value
            final ninState = _state.trim();
            _selectedManualState = _nigerianStates.cast<String?>().firstWhere(
                  (s) => s!.toLowerCase() == ninState.toLowerCase(),
                  orElse: () => null,
                );
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('NIN verified successfully'),
                backgroundColor: Colors.green));
          }
        } else {
          setState(() => _ninFailed = true);
          if (mounted) {
            final kyc = responseData['data']?['data']?['kyc'];
            final msg = kyc != null
                ? (kyc['status']?.toString() ??
                    'Verification failed. Enter details manually.')
                : 'NIN not found. Enter details manually.';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        }
      } else {
        setState(() => _ninFailed = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Verification failed. Enter details manually.')));
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _ninFailed = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e. Enter details manually.')));
      }
    }
  }

  double _getBaseAmount() {
    final cleaned = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  double _getPaystackCharge() {
    final base = _getBaseAmount();
    // Paystack: 1.5% + ₦100, capped at ₦2,000
    double charge = (base * 0.015) + 100;
    if (charge > 2000) charge = 2000;
    return charge;
  }

  double _getTotalAmount() {
    return _getBaseAmount() + _getPaystackCharge();
  }

  String _formatNaira(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';
  }

  Future<void> _initiatePayment() async {
    final email = _email.isNotEmpty ? _email : 'customer@rexinsure.com';
    final premiumAmount = _getBaseAmount();
    final productCode =
        widget.productName.toLowerCase().contains('driver') ? 'DP' : 'PC';
    setState(() => _isPayingNow = true);
    try {
      final result = await PaymentService.initiatePurchase(
        productCode: productCode,
        names: '$_firstName $_lastName'.trim(),
        email: email,
        mobileno: _phone,
        premium: premiumAmount.toInt(),
        extraFields: {
          'type': 'Individual',
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
          'address': _address,
          'nok': _nokNameController.text.trim(),
          'nokaddress': _nokAddressController.text.trim(),
          'nokphone': _nokPhoneController.text.trim(),
          'nokrel': _selectedRelationship ?? '',
          'grosspremium': premiumAmount.toInt(),
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
            _currentStep == 3
                ? '${widget.productName} summary'
                : widget.productName,
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
          if (_currentStep == 3) _buildSummaryStep(),
        ]),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const totalSteps = 4;
    final currentStepNum = _currentStep + 1;
    final stepLabel = _currentStep == 0
        ? 'Mode of Identification'
        : _currentStep == 1
            ? 'Socioeconomic Information'
            : _currentStep == 2
                ? 'Next of Kin / Beneficiary Info'
                : 'Summary';
    final filledCount = currentStepNum;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Step $currentStepNum of $totalSteps',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryNavy)),
          Flexible(
              child: Text(stepLabel,
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
                          color: i < filledCount
                              ? AppTheme.primaryNavy
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    )))),
      ]),
    );
  }

  // Step 0: NIN Verification
  Widget _buildNinStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Enter mode of Identification',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(height: 10),
        TextField(
          controller: _ninController,
          keyboardType: TextInputType.number,
          maxLength: 11,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your NIN (11 digits)',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            counterText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppTheme.primaryNavy, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (!_ninFailed && !_ninVerified) ...[
          const SizedBox(height: 40),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isVerifying || _ninController.text.trim().length != 11
                        ? null
                        : _verifyNin,
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
                    : const Text('Verify',
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

  // Step 1: Socioeconomic Information
  Widget _buildSocioeconomicStep() {
    final needsEmail = _emailController.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (needsEmail) ...[
          _label('Email Address *'),
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
        _label('Business Sector'),
        const SizedBox(height: 6),
        _dropdown(
            'select your business sector',
            _selectedBusinessSector,
            _businessSectors,
            (v) => setState(() => _selectedBusinessSector = v)),
        const SizedBox(height: 16),
        _label('Tax Identification No.'),
        const SizedBox(height: 6),
        _textField('enter your TIN', _tinController),
        const SizedBox(height: 16),
        _label('Highest Academic Qualification *'),
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
              onPressed: _selectedQualification != null &&
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

  // Step 2: Next of Kin / Beneficiary Info
  Widget _buildNextOfKinStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Name *'),
        const SizedBox(height: 6),
        _textField('enter full name', _nokNameController),
        const SizedBox(height: 16),
        _label('Address *'),
        const SizedBox(height: 6),
        _textField('enter your address', _nokAddressController, maxLines: 2),
        const SizedBox(height: 16),
        _label('Phone Number *'),
        const SizedBox(height: 6),
        _textField('enter phone number', _nokPhoneController,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _label('Relationship *'),
        const SizedBox(height: 6),
        _dropdown('select the type of relationship', _selectedRelationship,
            _relationships, (v) => setState(() => _selectedRelationship = v)),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _consentChecked,
                onChanged: (v) => setState(() => _consentChecked = v ?? false),
                activeColor: AppTheme.primaryNavy,
              )),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
            'I hereby consent to the collection, processing, use and the transfer of personal data to third parties (within or outside Nigeria), for the performance of this contract and any other data processing activities which may arise therefrom between myself and Rex Insurance Limited (Rex Insurance). I affirm that I am aware and take cognizance of my rights under the relevant Data Protection Laws in Nigeria and other terms detailed in the Data Protection and Privacy Policy of Rex Insurance available on our policy.\nI authorize and consent that any person who may be in possession of, or hereafter acquire, any information pertaining to my records may disclose such information to Rex Insurance.',
            style:
                TextStyle(fontSize: 10, color: Colors.grey[700], height: 1.4),
          )),
        ]),
        const SizedBox(height: 30),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nokNameController.text.trim().isNotEmpty &&
                      _nokAddressController.text.trim().isNotEmpty &&
                      _nokPhoneController.text.trim().isNotEmpty &&
                      _selectedRelationship != null &&
                      _consentChecked
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
              child: const Text('Submit',
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

  // Step 3: Summary
  Widget _buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _summarySection('Payment Information', [
          _summaryRow('Product', '${widget.productName} ${widget.optionTitle}',
              singleLine: true),
          _summaryRow('Price', widget.price),
          _summaryRow('Paystack Charges', _formatNaira(_getPaystackCharge())),
          _summaryRow('Total', _formatNaira(_getTotalAmount())),
        ]),
        const SizedBox(height: 20),
        _summarySection('Personal Information', [
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
        _summarySection('Socioeconomic Information', [
          _summaryRow('Occupation', _occupationController.text),
          _summaryRow('Business Sector', _selectedBusinessSector ?? ''),
          _summaryRow('Tax Identification No', _tinController.text),
          _summaryRow(
              'Highest Academic Qualification', _selectedQualification ?? ''),
          _summaryRow('Average Annual Income', _annualIncomeController.text),
        ]),
        const SizedBox(height: 20),
        _summarySection('Next of Kin / Beneficiary Info', [
          _summaryRow('Name', _nokNameController.text),
          _summaryRow('Address', _nokAddressController.text),
          _summaryRow('Phone Number', _nokPhoneController.text),
          _summaryRow('Relationship', _selectedRelationship ?? ''),
        ]),
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

  Widget _summaryRow(String label, String value, {bool singleLine = false}) {
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

  Widget _label(String text) {
    if (text.endsWith('*')) {
      final clean = text.substring(0, text.length - 1).trimRight();
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
    return Text(text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface));
  }

  Widget _textField(String hint, TextEditingController controller,
      {TextInputType? keyboardType,
      int maxLines = 1,
      List<String>? autofillHints}) {
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
      onChanged: (_) => setState(() {}),
      autofillHints: autofillHints,
      style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        errorText: errorText,
        errorStyle: TextStyle(fontSize: 11),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppTheme.primaryNavy, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _dropdown(String hint, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!)),
      child: DropdownButtonFormField<String>(
        value: value,
        hint:
            Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        items: items
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
