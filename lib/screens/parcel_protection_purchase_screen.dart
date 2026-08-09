import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import '../utils/app_theme.dart';
import '../utils/customer_details.dart';
import '../utils/error_messages.dart';
import '../utils/occupations.dart';
import '../widgets/paystack_webview.dart';
import '../widgets/searchable_dropdown.dart';
import 'policy_purchase_success_screen.dart';

class ParcelProtectionPurchaseScreen extends StatefulWidget {
  final String optionTitle;
  final String price;
  final bool isCustomerFlow;
  final bool isExploreFlow;
  final Map<String, dynamic>? clientData;
  const ParcelProtectionPurchaseScreen(
      {super.key,
      required this.optionTitle,
      required this.price,
      this.isCustomerFlow = false,
      this.isExploreFlow = false,
      this.clientData});
  @override
  State<ParcelProtectionPurchaseScreen> createState() =>
      _ParcelProtectionPurchaseScreenState();
}

class _ParcelProtectionPurchaseScreenState
    extends State<ParcelProtectionPurchaseScreen> {
  int _currentStep = 0; // 0=NIN,1=socio,2=risk,3=transit,4=transport,5=summary
  bool _isVerifying = false, _isPayingNow = false;
  bool _ninFailed = false;
  bool _ninVerified = false;
  bool _returnToSummaryAfterNin = false;
  bool _ninWasSkipped = false;
  bool _isCustomerNinLocked = false;
  int? _agentSellingPremium;
  bool _isLoadingAgentSellingPrice = false;

  // Step 0
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

  // Step 1
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _selectedOccupation;
  final _tinController = TextEditingController();
  String? _selectedBusinessSector;
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

  // Step 2: Risk
  final _goodsTypeController = TextEditingController();
  final _goodsQtyController = TextEditingController();
  final _goodsValueController = TextEditingController();
  final _goodsNatureController = TextEditingController();

  // Step 3: Transit
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  String? _selectedGoodsLocation, _selectedGoodsDestination;
  final _commenceDateController = TextEditingController();
  final _deliveryDateController = TextEditingController();
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
    'Zamfara'
  ];

  // Step 4: Transport
  final _conveyerNameController = TextEditingController();
  String? _selectedShipmentMode;
  final _vehicleRegController = TextEditingController();
  String? _selectedVehicleType;
  final _trackingNoController = TextEditingController();
  bool _consentChecked = false;
  final List<String> _shipmentModes = const [
    'Road',
    'Rail',
    'Air',
    'Sea',
    'Inland Waterway'
  ];
  final List<String> _vehicleTypes = const [
    'Truck',
    'Van',
    'Motorcycle',
    'Tricycle',
    'Bus',
    'Car',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isExploreFlow) {
      _prefillExploreKyc();
    } else if (!widget.isCustomerFlow && widget.clientData != null) {
      _prefillAgentClientDetails();
    } else {
      _prefillCustomerNin();
    }
    _loadAgentSellingPrice();
  }

  String get _productCode => 'PP';

  String get _subProductCode =>
      PaymentService.subProductCodeForOption(_productCode, widget.optionTitle);

  Future<void> _loadAgentSellingPrice() async {
    if (widget.isCustomerFlow || widget.isExploreFlow) return;

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

  void _prefillAgentClientDetails() {
    final details = CustomerDetails.fromClientData(widget.clientData);
    setState(() {
      _ninController.text = details['nin'] ?? '';
      _firstName = details['firstName'] ?? '';
      _lastName = details['lastName'] ?? '';
      _email = details['email'] ?? '';
      _emailController.text = _email;
      _phone = details['phone'] ?? '';
      _dob = details['dob'] ?? '';
      _state = details['state'] ?? '';
      _lga = details['lga'] ?? '';
      _address = details['address'] ?? '';
      _gender = details['gender'] ?? '';
      _ninVerified = _ninController.text.trim().length == 11;
      _isCustomerNinLocked = _ninVerified;
      _manualFirstNameController.text = _firstName;
      _manualLastNameController.text = _lastName;
      _manualEmailController.text = _email;
      _manualPhoneController.text = _phone;
      _manualAddressController.text = _address;
      _selectedManualState = _nigerianStates.cast<String?>().firstWhere(
            (s) => s!.toLowerCase() == _state.trim().toLowerCase(),
            orElse: () => null,
          );
      _occupationController.text = details['occupation'] ?? '';
      _currentStep = 1;
    });
  }

  Future<void> _prefillExploreKyc() async {
    final details = await CustomerDetails.signupKycDetails();
    final ninWasSkipped = await CustomerDetails.signupNinWasSkipped();
    if (!mounted) return;

    setState(() {
      _ninController.text = details['nin'] ?? '';
      _firstName = details['firstName'] ?? '';
      _lastName = details['lastName'] ?? '';
      _email = details['email'] ?? '';
      _emailController.text = _email;
      _phone = details['phone'] ?? '';
      _dob = details['dob'] ?? '';
      _address = details['address'] ?? '';
      _state = details['state'] ?? '';
      _lga = details['lga'] ?? '';
      _ninVerified = _ninController.text.trim().length == 11;
      _ninWasSkipped = ninWasSkipped;
      _manualFirstNameController.text = _firstName;
      _manualLastNameController.text = _lastName;
      _manualEmailController.text = _email;
      _manualPhoneController.text = _phone;
      _manualAddressController.text = _address;
      _selectedManualState = _nigerianStates.cast<String?>().firstWhere(
            (s) => s!.toLowerCase() == _state.trim().toLowerCase(),
            orElse: () => null,
          );
      _currentStep = 1;
    });
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
    _goodsTypeController.dispose();
    _goodsQtyController.dispose();
    _goodsValueController.dispose();
    _goodsNatureController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _commenceDateController.dispose();
    _deliveryDateController.dispose();
    _conveyerNameController.dispose();
    _vehicleRegController.dispose();
    _trackingNoController.dispose();
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
          .post(
              Uri.parse('https://eportaltest.rexinsure.com/api/mobile/verify/nin'),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${ErrorMessages.fromException(e, fallback: 'Verification failed')}. Enter details manually.')));
    }
  }

  double _getBase() {
    final m = RegExp(r'[\d,]+\.?\d*').firstMatch(widget.price);
    return m != null
        ? (double.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0)
        : 0;
  }

  double _getSummaryBase() => (_agentSellingPremium ?? _getBase()).toDouble();

  String _summaryPriceText() =>
      _isLoadingAgentSellingPrice ? 'Loading...' : _fmtN(_getSummaryBase());

  double _getCharge() {
    double c = (_getSummaryBase() * 0.015) + 100;
    return c > 2000 ? 2000 : c;
  }

  double _getTotal() => _getSummaryBase() + _getCharge();
  String _fmtN(double a) =>
      '₦${a.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

  Future<void> _pay() async {
    final email = _email.isNotEmpty ? _email : 'customer@rexinsure.com';
    final premiumAmount = _getBase();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final agentCode = (!widget.isCustomerFlow && !widget.isExploreFlow)
        ? (authProvider.userCode?.toString() ?? '')
        : '';
    final agentUserType = agentCode.isNotEmpty
        ? (authProvider.userTypeCode?.toString() ?? '')
        : '';
    final payerEmail = agentCode.isNotEmpty
        ? (authProvider.userEmail ?? authProvider.loginEmail ?? '')
        : '';
    setState(() => _isPayingNow = true);
    try {
      final result = await PaymentService.initiatePurchase(
        productCode: 'PP',
        names: '$_firstName $_lastName'.trim(),
        email: email,
        mobileno: _phone,
        premium: premiumAmount.toInt(),
        agentCode: agentCode,
        agentUserType: agentUserType,
        payerEmail: payerEmail,
        subProductCode: _subProductCode,
        extraFields: {
          'type': 'Individual',
          'gender': _gender,
          'dob': CustomerDetails.normalizeApiDate(_dob),
          'occupation': _occupationController.text.trim(),
          'businesssector': _selectedBusinessSector ?? '',
          'tin': _tinController.text.trim(),
          'annualincome': _annualIncomeController.text.trim(),
          'state': _state,
          'nationality': 'Nigerian',
          'nin': _ninController.text.trim(),
          'qualification': _selectedQualification ?? '',
          'address': _address,
          'qtygoods': _goodsQtyController.text.trim(),
          'tolvalgoods': _goodsValueController.text.trim(),
          'descgoods': _goodsNatureController.text.trim(),
          'locgoods': _selectedGoodsLocation ?? '',
          'destgoods': _selectedGoodsDestination ?? '',
          'recvname': _receiverNameController.text.trim(),
          'recvaddress': _receiverAddressController.text.trim(),
          'recvphone': _receiverPhoneController.text.trim(),
          'commdate': _commenceDateController.text.trim(),
          'delvdate': _deliveryDateController.text.trim(),
          'shipmode': _selectedShipmentMode ?? '',
          'conveyer': _conveyerNameController.text.trim(),
          'vehregno': _vehicleRegController.text.trim(),
          'vehtype': _selectedVehicleType ?? '',
          'trackno': _trackingNoController.text.trim(),
          'grosspremium': premiumAmount.toInt(),
        },
        isExploreFlow: widget.isExploreFlow,
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
                isLoggedIn: !widget.isExploreFlow,
                isAgent: !widget.isCustomerFlow && !widget.isExploreFlow,
                reference: res.reference,
                message: res.message,
                isExploreFlow: widget.isExploreFlow,
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

  Future<void> _pickDate(TextEditingController c) async {
    final p = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (p != null)
      setState(() => c.text =
          '${p.day.toString().padLeft(2, '0')}/${p.month.toString().padLeft(2, '0')}/${p.year}');
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
            title: Text('Parcel Protection Plan',
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
              if (_currentStep == 4) _s4(),
              if (_currentStep == 5) _s5(),
            ])));
  }

  Widget _si() {
    final labels = [
      'Mode of Identification',
      'Socioeconomic Information',
      'Risk Information',
      'Transit Details',
      'Transport / Vehicle Information',
      'Summary'
    ];
    final total = _currentStep == 5 ? 6 : 6;
    final num = _currentStep + 1;
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

  // Step 0: NIN
  Widget _s0() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Enter mode of Identification',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _tf('Enter your NIN (11 digits)', _ninController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            readOnly: _isCustomerNinLocked),
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
                        _currentStep = _returnToSummaryAfterNin ? 5 : 1;
                        _returnToSummaryAfterNin = false;
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
                        _currentStep = _returnToSummaryAfterNin ? 5 : 1;
                        _returnToSummaryAfterNin = false;
                      });
                    }
                  : null),
        ],
        const SizedBox(height: 12),
        _outBtn('Back', () => Navigator.pop(context)),
      ]));

  // Step 1: Socioeconomic
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
          _label('Tax Identification No. (optional)'),
          const SizedBox(height: 6),
          _tf('enter your TIN', _tinController),
          const SizedBox(height: 16),
          _label('Business Sector (optional)'),
          const SizedBox(height: 6),
          _dd(
              'select your business sector',
              _selectedBusinessSector,
              _businessSectors,
              (v) => setState(() => _selectedBusinessSector = v)),
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

  // Step 2: Risk
  Widget _s2() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Type of Goods'),
        const SizedBox(height: 6),
        _tf('enter goods type', _goodsTypeController),
        const SizedBox(height: 16),
        _label('Quantity of Goods'),
        const SizedBox(height: 6),
        _tf('enter goods quantity', _goodsQtyController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _label('Total Value of Goods'),
        const SizedBox(height: 6),
        _tf('enter value of goods', _goodsValueController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _label('Describe the Nature of the Goods'),
        const SizedBox(height: 6),
        _tf('describe the goods', _goodsNatureController, maxLines: 3),
        const SizedBox(height: 40),
        _btn(
            'Continue',
            _goodsTypeController.text.trim().isNotEmpty &&
                    _goodsQtyController.text.trim().isNotEmpty &&
                    _goodsValueController.text.trim().isNotEmpty &&
                    _goodsNatureController.text.trim().isNotEmpty
                ? () => setState(() => _currentStep = 3)
                : null),
        const SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _currentStep = 1)),
      ]));

  // Step 3: Transit Details
  Widget _s3() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Name of Receiver'),
        const SizedBox(height: 6),
        _tf('enter name of receiver', _receiverNameController,
            autofillHints: [AutofillHints.name]),
        const SizedBox(height: 16),
        _label('Phone Number of Receiver'),
        const SizedBox(height: 6),
        _tf('+234894785', _receiverPhoneController,
            keyboardType: TextInputType.phone,
            autofillHints: [AutofillHints.telephoneNumber]),
        const SizedBox(height: 16),
        _label('Address of Receiver'),
        const SizedBox(height: 6),
        _tf('enter your address', _receiverAddressController,
            maxLines: 2, autofillHints: [AutofillHints.streetAddressLine1]),
        const SizedBox(height: 16),
        _label('Goods Location'),
        const SizedBox(height: 6),
        SearchableDropdown(
            hint: 'select good location',
            value: _selectedGoodsLocation,
            items: _nigerianStates,
            onChanged: (v) => setState(() => _selectedGoodsLocation = v)),
        const SizedBox(height: 16),
        _label('Goods Destination'),
        const SizedBox(height: 6),
        SearchableDropdown(
            hint: 'select good destination',
            value: _selectedGoodsDestination,
            items: _nigerianStates,
            onChanged: (v) => setState(() => _selectedGoodsDestination = v)),
        const SizedBox(height: 16),
        _label('Date of Commencement'),
        const SizedBox(height: 6),
        GestureDetector(
            onTap: () => _pickDate(_commenceDateController),
            child: AbsorbPointer(
                child: _tf('dd/mm/yy', _commenceDateController,
                    suffixIcon: const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey)))),
        const SizedBox(height: 16),
        _label('Date of Delivery'),
        const SizedBox(height: 6),
        GestureDetector(
            onTap: () => _pickDate(_deliveryDateController),
            child: AbsorbPointer(
                child: _tf('Date of Delivery', _deliveryDateController,
                    suffixIcon: const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey)))),
        const SizedBox(height: 40),
        _btn(
            'Continue',
            _receiverNameController.text.trim().isNotEmpty &&
                    _receiverPhoneController.text.trim().isNotEmpty &&
                    _receiverAddressController.text.trim().isNotEmpty &&
                    _selectedGoodsLocation != null &&
                    _selectedGoodsDestination != null &&
                    _commenceDateController.text.trim().isNotEmpty &&
                    _deliveryDateController.text.trim().isNotEmpty
                ? () => setState(() => _currentStep = 4)
                : null),
        const SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _currentStep = 2)),
      ]));

  // Step 4: Transport / Vehicle
  Widget _s4() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Name of the Conveyer'),
        const SizedBox(height: 6),
        _tf('enter name of conveyer', _conveyerNameController,
            autofillHints: [AutofillHints.name]),
        const SizedBox(height: 16),
        _label('Mode of Shipment'),
        const SizedBox(height: 6),
        _dd('select shipment mode', _selectedShipmentMode, _shipmentModes,
            (v) => setState(() => _selectedShipmentMode = v)),
        const SizedBox(height: 16),
        _label('Vehicle registration No.'),
        const SizedBox(height: 6),
        _tf('enter reg number', _vehicleRegController),
        const SizedBox(height: 16),
        _label('Vehicle Type'),
        const SizedBox(height: 6),
        _dd('select vehicle type', _selectedVehicleType, _vehicleTypes,
            (v) => setState(() => _selectedVehicleType = v)),
        const SizedBox(height: 16),
        _label('Tracking No. (if any)'),
        const SizedBox(height: 6),
        _tf('enter tracking no.', _trackingNoController),
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
                      fontSize: 10,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFCBD5E1)
                          : Colors.grey[700],
                      height: 1.4))),
        ]),
        const SizedBox(height: 24),
        _btn(
            'Continue',
            _conveyerNameController.text.trim().isNotEmpty &&
                    _selectedShipmentMode != null &&
                    _vehicleRegController.text.trim().isNotEmpty &&
                    _selectedVehicleType != null &&
                    _consentChecked
                ? () => setState(() {
                      if (widget.isExploreFlow &&
                          _ninWasSkipped &&
                          _ninController.text.trim().length != 11) {
                        _returnToSummaryAfterNin = true;
                        _currentStep = 0;
                      } else {
                        _currentStep = 5;
                      }
                    })
                : null),
        const SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _currentStep = 3)),
      ]));

  // Step 5: Summary
  Widget _s5() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec('Payment Information', [
          _sRow('Product', 'Parcel Protection Plan ${widget.optionTitle}'),
          _sRow('Price', _summaryPriceText()),
          _sRow('Paystack Charges', _fmtN(_getCharge())),
          _sRow('Total', _fmtN(_getTotal()))
        ]),
        if (!widget.isExploreFlow) ...[
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
        ],
        const SizedBox(height: 20),
        _sec('Socioeconomic Information', [
          _sRow('Occupation', _occupationController.text),
          _sRow('TIN',
              _tinController.text.isNotEmpty ? _tinController.text : '-'),
          _sRow('Business Sector', _selectedBusinessSector ?? '-'),
          _sRow('Annual Income', _annualIncomeController.text),
          _sRow('Qualification', _selectedQualification ?? '-')
        ]),
        const SizedBox(height: 20),
        _sec('Risk Information', [
          _sRow('Type of Goods', _goodsTypeController.text),
          _sRow('Quantity', _goodsQtyController.text),
          _sRow('Total Value', _goodsValueController.text),
          _sRow('Nature', _goodsNatureController.text)
        ]),
        const SizedBox(height: 20),
        _sec('Transit Details', [
          _sRow('Receiver', _receiverNameController.text),
          _sRow('Receiver Phone', _receiverPhoneController.text),
          _sRow('Receiver Address', _receiverAddressController.text),
          _sRow('From', _selectedGoodsLocation ?? '-'),
          _sRow('To', _selectedGoodsDestination ?? '-'),
          _sRow('Commencement', _commenceDateController.text),
          _sRow('Delivery', _deliveryDateController.text)
        ]),
        SizedBox(height: 20),
        _sec('Transport / Vehicle', [
          _sRow('Conveyer', _conveyerNameController.text),
          _sRow('Shipment Mode', _selectedShipmentMode ?? '-'),
          _sRow('Vehicle Reg No.', _vehicleRegController.text),
          _sRow('Vehicle Type', _selectedVehicleType ?? '-'),
          _sRow(
              'Tracking No.',
              _trackingNoController.text.isNotEmpty
                  ? _trackingNoController.text
                  : '-')
        ]),
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
      List<String>? autofillHints,
      bool readOnly = false}) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;
    return TextField(
        controller: c,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: (_) => setState(() {}),
        autofillHints: autofillHints,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
        decoration: InputDecoration(
            hintText: h,
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
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
  }

  Widget _dd(String h, String? v, List<String> items,
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
            initialValue: v,
            dropdownColor: isDark ? const Color(0xFF111827) : Colors.white,
            hint: Text(h, style: TextStyle(color: hintColor, fontSize: 13)),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
            decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
            icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
            items: items
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onChanged));
  }

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
