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

class StudentProtectionPurchaseScreen extends StatefulWidget {
  final String optionTitle;
  final String price;
  const StudentProtectionPurchaseScreen(
      {super.key, required this.optionTitle, required this.price});
  @override
  State<StudentProtectionPurchaseScreen> createState() =>
      _StudentProtectionPurchaseScreenState();
}

class _StudentProtectionPurchaseScreenState
    extends State<StudentProtectionPurchaseScreen> {
  int _currentStep = 0; // 0=NIN,1=socio,2=beneficiaries,3=summary
  bool _isVerifying = false, _isPayingNow = false;
  bool _ninFailed = false;
  bool _ninVerified = false;

  final _ninController = TextEditingController();
  String _firstName = '',
      _lastName = '',
      _email = '',
      _phone = '',
      _dob = '',
      _state = '',
      _lga = '',
      _address = '',
      _gender = '';

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

  // Step 1
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _selectedOccupation;
  String? _selectedBusinessSector;
  final _tinController = TextEditingController();
  final _annualIncomeController = TextEditingController();
  String? _selectedQualification;
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
    'Others'
  ];
  final List<String> _qualifications = const [
    'SSCE/WAEC',
    'OND/NCE',
    'HND',
    'BSc/BA',
    'MSc/MA/MBA',
    'PhD',
    'Professional Cert',
    'Others'
  ];

  // Step 2: Beneficiaries
  final _bNameController = TextEditingController();
  String? _bGender;
  final _bDobController = TextEditingController();
  final _bShareController = TextEditingController();
  final List<Map<String, String>> _beneficiaries = [];
  bool _consentChecked = false;
  final List<String> _genders = const ['Male', 'Female'];

  @override
  void dispose() {
    _ninController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _tinController.dispose();
    _annualIncomeController.dispose();
    _bNameController.dispose();
    _bDobController.dispose();
    _bShareController.dispose();
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
      final r = await http
          .post(Uri.parse('https://eportaltest.rexinsure.com/api/verify/nin'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'Intcode': 'TESTCODE',
                'Password': 'royal1234',
                'number': _ninController.text.trim()
              }))
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
            _firstName = k['firstname']?.toString() ?? '';
            _lastName = k['surname']?.toString() ?? '';
            _email = k['email']?.toString() ?? '';
            _emailController.text = _email;
            _phone = k['telephoneno']?.toString() ?? '';
            _dob = (k['birthdate']?.toString() ?? '').replaceAll('-', '/');
            _address = k['residence_address']?.toString() ?? '';
            _state = k['residence_state']?.toString() ?? '';
            _lga = k['residence_lga']?.toString() ?? '';
            _gender = k['gender']?.toString() ?? '';
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
                content: Text('NIN verified'), backgroundColor: Colors.green));
        } else {
          setState(() => _ninFailed = true);
          final kyc = d['data']?['data']?['kyc'];
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e. Enter details manually.')));
    }
  }

  double _getBase() {
    final m = RegExp(r'[\d,]+\.?\d*').firstMatch(widget.price);
    return m != null
        ? (double.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0)
        : 0;
  }

  double _getCharge() {
    double c = (_getBase() * 0.015) + 100;
    return c > 2000 ? 2000 : c;
  }

  double _getTotal() => _getBase() + _getCharge();
  String _fmtN(double a) =>
      '₦${a.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

  Future<void> _pay() async {
    final email = _email.isNotEmpty ? _email : 'customer@rexinsure.com';
    final premiumAmount = _getBase();
    setState(() => _isPayingNow = true);
    try {
      final result = await PaymentService.initiatePurchase(
        productCode: 'SP',
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
          'grosspremium': premiumAmount.toInt(),
          'beneficials': _beneficiaries
              .map((b) => {
                    'prodcode': 'SP',
                    'names': b['name'] ?? '',
                    'gender': b['gender'] ?? '',
                    'dob': b['dob'] ?? '',
                    'share': int.tryParse(b['share'] ?? '0') ?? 0
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickDob() async {
    final p = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1920),
        lastDate: DateTime.now());
    if (p != null)
      setState(() => _bDobController.text =
          '${p.day.toString().padLeft(2, '0')}/${p.month.toString().padLeft(2, '0')}/${p.year}');
  }

  void _addBeneficiary() {
    if (_bNameController.text.trim().isEmpty ||
        _bGender == null ||
        _bDobController.text.trim().isEmpty ||
        _bShareController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all beneficiary fields')));
      return;
    }
    setState(() {
      _beneficiaries.add({
        'name': _bNameController.text.trim(),
        'gender': _bGender!,
        'dob': _bDobController.text.trim(),
        'share': _bShareController.text.trim()
      });
      _bNameController.clear();
      _bGender = null;
      _bDobController.clear();
      _bShareController.clear();
    });
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
                  if (_currentStep > 0)
                    setState(() => _currentStep--);
                  else
                    Navigator.pop(context);
                }),
            title: Text('Student Protection Plan',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            centerTitle: true),
        body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              _si(),
              const Divider(height: 1),
              if (_currentStep == 0) _s0(),
              if (_currentStep == 1) _s1(),
              if (_currentStep == 2) _s2(),
              if (_currentStep == 3) _s3(),
            ])));
  }

  Widget _si() {
    final labels = [
      'Mode of Identification',
      'Socioeconomic Information',
      'Beneficiaries',
      'Summary'
    ];
    final total = _currentStep == 3 ? 3 : 4;
    final num = _currentStep == 3 ? 3 : _currentStep + 1;
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Step $num of $total',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy)),
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
                  total,
                  (i) => Expanded(
                      child: Container(
                          height: 3,
                          margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                          decoration: BoxDecoration(
                              color: i < num
                                  ? AppTheme.primaryNavy
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2)))))),
        ]));
  }

  Widget _s0() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Enter mode of Identification',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _tf('Enter your NIN (11 digits)', _ninController,
            keyboardType: TextInputType.number, maxLength: 11),
        if (!_ninFailed && !_ninVerified) ...[
          const SizedBox(height: 40),
          _btn(
              'Verify',
              _ninController.text.trim().length == 11 && !_isVerifying
                  ? _verifyNin
                  : null,
              loading: _isVerifying),
        ],
        if (_ninVerified) ...[
          const SizedBox(height: 16),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'NIN Verified — review and adjust details below',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700])))
              ])),
          const SizedBox(height: 16),
          _label('First Name *'),
          const SizedBox(height: 6),
          _tf('first name', _manualFirstNameController,
              autofillHints: [AutofillHints.givenName]),
          const SizedBox(height: 12),
          _label('Last Name *'),
          const SizedBox(height: 6),
          _tf('last name', _manualLastNameController,
              autofillHints: [AutofillHints.familyName]),
          const SizedBox(height: 12),
          _label('Email *'),
          const SizedBox(height: 6),
          _tf('email', _manualEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 12),
          _label('Phone Number *'),
          const SizedBox(height: 6),
          _tf('phone number', _manualPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label('Address'),
          const SizedBox(height: 6),
          _tf('address', _manualAddressController,
              maxLines: 2, autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 12),
          _label('State'),
          const SizedBox(height: 6),
          SearchableDropdown(
              hint: 'select state',
              value: _selectedManualState,
              items: _nigerianStates,
              onChanged: (v) => setState(() => _selectedManualState = v)),
          const SizedBox(height: 24),
          _btn(
              'Continue',
              _manualFirstNameController.text.trim().isNotEmpty &&
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
                  : null),
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
                            TextStyle(fontSize: 12, color: Colors.orange[700])))
              ])),
          const SizedBox(height: 16),
          _label('First Name *'),
          const SizedBox(height: 6),
          _tf('enter first name', _manualFirstNameController,
              autofillHints: [AutofillHints.givenName]),
          const SizedBox(height: 12),
          _label('Last Name *'),
          const SizedBox(height: 6),
          _tf('enter last name', _manualLastNameController,
              autofillHints: [AutofillHints.familyName]),
          const SizedBox(height: 12),
          _label('Email *'),
          const SizedBox(height: 6),
          _tf('enter email', _manualEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 12),
          _label('Phone Number *'),
          const SizedBox(height: 6),
          _tf('enter phone number', _manualPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 12),
          _label('Address'),
          const SizedBox(height: 6),
          _tf('enter address', _manualAddressController,
              maxLines: 2, autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 12),
          _label('State'),
          const SizedBox(height: 6),
          SearchableDropdown(
              hint: 'select state',
              value: _selectedManualState,
              items: _nigerianStates,
              onChanged: (v) => setState(() => _selectedManualState = v)),
          const SizedBox(height: 24),
          _btn(
              'Continue',
              _manualFirstNameController.text.trim().isNotEmpty &&
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
                  : null),
        ],
        const SizedBox(height: 12),
        _outBtn('Back', () => Navigator.pop(context)),
      ]));

  Widget _s1() {
    final ne = _emailController.text.trim().isEmpty;
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (ne) ...[
            _label('Email'),
            const SizedBox(height: 6),
            _tf('enter your email', _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email]),
            const SizedBox(height: 16)
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
          _dd(
              'select your business sector',
              _selectedBusinessSector,
              _businessSectors,
              (v) => setState(() => _selectedBusinessSector = v)),
          const SizedBox(height: 16),
          _label('Tax Identification No (TIN) (optional)'),
          const SizedBox(height: 6),
          _tf('enter your TIN', _tinController),
          const SizedBox(height: 16),
          _label('Average Annual Income'),
          const SizedBox(height: 6),
          _tf('e.g 23,000,000.00', _annualIncomeController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _label('Highest Academic Qualification'),
          const SizedBox(height: 6),
          _dd('select', _selectedQualification, _qualifications,
              (v) => setState(() => _selectedQualification = v)),
          const SizedBox(height: 40),
          _btn(
              'Continue',
              _occupationController.text.trim().isNotEmpty &&
                      _selectedQualification != null &&
                      _annualIncomeController.text.trim().isNotEmpty &&
                      _emailController.text.trim().isNotEmpty
                  ? () {
                      _email = _emailController.text.trim();
                      setState(() => _currentStep = 2);
                    }
                  : null),
          const SizedBox(height: 12),
          _outBtn('Back', () => setState(() => _currentStep = 0)),
        ]));
  }

  // Step 2: Beneficiaries
  Widget _s2() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('BENEFICIARY(ES)',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const Spacer(),
          GestureDetector(
              onTap: _addBeneficiary,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
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
        Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BENEFICIARY ${_beneficiaries.length + 1}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              _label('Name'),
              const SizedBox(height: 6),
              _tf('enter name', _bNameController,
                  autofillHints: [AutofillHints.name]),
              const SizedBox(height: 12),
              _label('Gender'),
              const SizedBox(height: 6),
              _dd('select', _bGender, _genders,
                  (v) => setState(() => _bGender = v)),
              const SizedBox(height: 12),
              _label('Date of Birth'),
              const SizedBox(height: 6),
              GestureDetector(
                  onTap: _pickDob,
                  child: AbsorbPointer(
                      child: _tf('dd/mm/yyyy', _bDobController,
                          suffixIcon: const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey)))),
              const SizedBox(height: 12),
              _label('Beneficiary share (%)'),
              const SizedBox(height: 6),
              _tf('enter share', _bShareController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _addBeneficiary,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Add',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)))),
            ])),
        if (_beneficiaries.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...List.generate(_beneficiaries.length, (i) {
            final b = _beneficiaries[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!)),
              child: Column(children: [
                Row(children: [
                  Text('BENEFICIARY ${i + 1}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const Spacer(),
                  GestureDetector(
                      onTap: () => setState(() => _beneficiaries.removeAt(i)),
                      child: const Icon(Icons.cancel,
                          color: Colors.grey, size: 20))
                ]),
                const SizedBox(height: 8),
                _bRow('Name', b['name'] ?? ''),
                _bRow('Gender', b['gender'] ?? ''),
                _bRow('Date of Birth', b['dob'] ?? ''),
                _bRow('Beneficiary Share', '${b['share']}%'),
              ]),
            );
          }),
          const SizedBox(height: 8),
          // Remove last button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => setState(() {
                        if (_beneficiaries.isNotEmpty)
                          _beneficiaries.removeLast();
                      }),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Remove',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)))),
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
                  activeColor: AppTheme.primaryNavy)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  'I hereby consent to the collection, processing, use and the transfer of personal data to third parties (within or outside Nigeria), for the performance of this contract and any other data processing activities which may arise therefrom between myself and Rex Insurance Limited (Rex Insurance). I affirm that I am aware and take cognizance of my rights under the relevant Data Protection Laws in Nigeria and other terms detailed in the Data Protection and Privacy Policy of Rex Insurance available on our policy.\nI authorize and consent that any person who may be in possession of, or hereafter acquire, any information pertaining to my records may disclose such information to Rex Insurance.',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey[700], height: 1.4))),
        ]),
        SizedBox(height: 24),
        _btn(
            'Continue',
            _beneficiaries.isNotEmpty && _consentChecked
                ? () => setState(() => _currentStep = 3)
                : null),
        SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _currentStep = 1)),
      ]));

  Widget _bRow(String l, String v) => Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(l,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
        SizedBox(width: 8),
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
  Widget _s3() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec('Payment Information', [
          _sRow('Product', 'Student Protection Plan ${widget.optionTitle}'),
          _sRow('Price', widget.price),
          _sRow('Paystack Charges', _fmtN(_getCharge())),
          _sRow('Total', _fmtN(_getTotal()))
        ]),
        const SizedBox(height: 20),
        _sec('Personal Information', [
          _sRow('First Name', _firstName),
          _sRow('Last Name', _lastName),
          _sRow('Email', _email),
          _sRow('Phone Number', _phone),
          _sRow('DOB', _dob),
          _sRow('Gender', _gender),
          _sRow('Occupation', _occupationController.text),
          _sRow('State', _state),
          _sRow('LGA', _lga),
          _sRow('Address', _address)
        ]),
        const SizedBox(height: 20),
        _sec('Socioeconomic Information', [
          _sRow('Occupation', _occupationController.text),
          _sRow('Business Sector', _selectedBusinessSector ?? '-'),
          _sRow('TIN',
              _tinController.text.isNotEmpty ? _tinController.text : '-'),
          _sRow('Annual Income', _annualIncomeController.text),
          _sRow('Qualification', _selectedQualification ?? '-')
        ]),
        if (_beneficiaries.isNotEmpty) ...[
          const SizedBox(height: 20),
          ..._beneficiaries.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _sec('Beneficiary ${e.key + 1}', [
                _sRow('Name', e.value['name'] ?? ''),
                _sRow('Gender', e.value['gender'] ?? ''),
                _sRow('Date of Birth', e.value['dob'] ?? ''),
                _sRow('Beneficiary Share', '${e.value['share']}%')
              ]))),
        ],
        SizedBox(height: 30),
        _btn('Pay Now', _isPayingNow ? null : _pay, loading: _isPayingNow),
        SizedBox(height: 20),
      ]));

  // Helpers
  Widget _sec(String t, List<Widget> r) => Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF111827)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(height: 12),
        ...r
      ]));
  Widget _sRow(String l, String v) => Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: Text(l,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFCBD5E1)
                        : Colors.grey[600]))),
        SizedBox(width: 8),
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
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600))
          ]));
    }
    return Text(t,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface));
  }

  Widget _tf(String h, TextEditingController c,
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
      if (!emailRegex.hasMatch(c.text.trim()))
        errorText = 'Enter a valid email address';
    }
    if (keyboardType == TextInputType.phone && c.text.trim().isNotEmpty) {
      final cleaned = c.text.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.length < 10 || cleaned.length > 15)
        errorText = 'Enter a valid phone number';
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
            hintText: h,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            counterText: '',
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: TextStyle(fontSize: 11),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 2)),
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
                borderSide: BorderSide(color: AppTheme.primaryNavy, width: 2)),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
  }

  Widget _dd(String h, String? v, List<String> items,
          ValueChanged<String?> onChanged) =>
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!)),
          child: DropdownButtonFormField<String>(
              value: v,
              hint: Text(h,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged));
  Widget _btn(String t, VoidCallback? onPressed, {bool loading = false}) => SizedBox(
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
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(t,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600))));
  Widget _outBtn(String t, VoidCallback onPressed) => SizedBox(
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
          child: Text(t,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))));
}
