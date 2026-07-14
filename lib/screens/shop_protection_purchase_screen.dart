import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
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

class ShopProtectionPurchaseScreen extends StatefulWidget {
  final String optionTitle;
  final String price;
  final String productName;
  final bool isCustomerFlow;
  final bool isExploreFlow;
  final Map<String, dynamic>? clientData;
  const ShopProtectionPurchaseScreen(
      {super.key,
      required this.optionTitle,
      required this.price,
      this.productName = 'Shop Protection Plan',
      this.isCustomerFlow = false,
      this.isExploreFlow = false,
      this.clientData});
  @override
  State<ShopProtectionPurchaseScreen> createState() =>
      _ShopProtectionPurchaseScreenState();
}

class _ShopProtectionPurchaseScreenState
    extends State<ShopProtectionPurchaseScreen> {
  int _currentStep = 0; // 0=NIN, 1=socioeconomic, 2=risk info, 3=summary
  bool _isVerifying = false;
  bool _isPayingNow = false;

  // Step 0: NIN
  final _ninController = TextEditingController();
  bool _ninFailed = false;
  bool _ninVerified = false;
  bool _isCustomerNinLocked = false;
  bool _returnToSummaryAfterNin = false;
  bool _ninWasSkipped = false;
  int? _agentSellingPremium;
  bool _isLoadingAgentSellingPrice = false;

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

  final Map<String, int> _stateIdMap = {
    'Abia': 1,
    'Adamawa': 2,
    'Akwa Ibom': 3,
    'Anambra': 4,
    'Bauchi': 5,
    'Bayelsa': 6,
    'Benue': 7,
    'Borno': 8,
    'Cross River': 9,
    'Delta': 10,
    'Ebonyi': 11,
    'Edo': 12,
    'Ekiti': 13,
    'Enugu': 14,
    'Federal Capital Territory': 15,
    'Gombe': 16,
    'Imo': 17,
    'Jigawa': 18,
    'Kaduna': 19,
    'Kano': 20,
    'Katsina': 21,
    'Kebbi': 22,
    'Kogi': 23,
    'Kwara': 24,
    'Lagos': 25,
    'Nasarawa': 26,
    'Niger': 27,
    'Ogun': 28,
    'Ondo': 29,
    'Osun': 30,
    'Oyo': 31,
    'Plateau': 32,
    'Rivers': 33,
    'Sokoto': 34,
    'Taraba': 35,
    'Yobe': 36,
    'Zamfara': 37,
  };

  // Step 1: Socioeconomic
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _selectedOccupation;
  String? _selectedBusinessSector;
  final _tinController = TextEditingController();
  final _ninDisplayController = TextEditingController();
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

  // Step 2: Risk Information
  final _shopAddressController = TextEditingController();
  final _shopStateController = TextEditingController();
  String? _selectedShopState;
  String? _selectedShopLga;
  List<Map<String, dynamic>> _shopLgaList = [];
  bool _isLoadingShopLgas = false;
  String? _selectedShopDesc;
  String? _selectedRoofing;
  String? _selectedConstruction;
  final List<Map<String, String>> _itemCategories = [];
  // Temp for adding
  String? _tempCategory;
  final _tempAmountController = TextEditingController();
  bool _consentChecked = false;

  final List<String> _shopDescriptions = const [
    'Detached',
    'Semi-Detached',
    'Flat',
    'Bungalow',
    'Duplex',
    'Shop',
    'Warehouse',
    'Others'
  ];
  final List<String> _categoryOptions = const [
    'Furniture',
    'Electronics',
    'Clothing',
    'Food Items',
    'Building Materials',
    'Machinery',
    'Stationery',
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

  String get _productCode =>
      widget.productName.toLowerCase().contains('home') ? 'HP' : 'SH';

  String get _subProductCode =>
      PaymentService.subProductCodeForOption(_productCode, widget.optionTitle);

  Future<void> _loadAgentSellingPrice() async {
    if (widget.isCustomerFlow ||
        widget.isExploreFlow ||
        PaymentService.usesCalculatedAgentPremium(_productCode)) {
      return;
    }

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
      _ninDisplayController.text = _ninController.text;
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
      _ninDisplayController.text = _ninController.text;
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
    _ninDisplayController.dispose();
    _annualIncomeController.dispose();
    _shopAddressController.dispose();
    _shopStateController.dispose();
    _tempAmountController.dispose();
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
            Uri.parse('https://eportal.rexinsure.com/api/mobile/verify/nin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'IntCode': 'Kissflow',
              'Password': '1lovetoeatcook1es',
              'number': _ninController.text.trim()
            }),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('=== NIN VERIFY: ${response.statusCode} ===');
      debugPrint('Body: ${response.body}');
      setState(() => _isVerifying = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' &&
            data['data']?['data']?['kyc'] != null &&
            data['data']['data']['kyc']['firstname'] != null &&
            (data['data']['data']['kyc']['firstname']?.toString() ?? '')
                .isNotEmpty) {
          final kyc = data['data']['data']['kyc'];
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
            _ninDisplayController.text = _ninController.text.trim();
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
          final kyc = data['data']?['data']?['kyc'];
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

  Future<void> _fetchShopLgas(String stateName) async {
    final stateId = _stateIdMap[stateName];
    if (stateId == null) return;
    setState(() {
      _isLoadingShopLgas = true;
      _shopLgaList = [];
      _selectedShopLga = null;
    });
    try {
      final response = await http
          .get(
            Uri.parse(
                'https://eportal.rexinsure.com/api/get-lga?state_id=$stateId'),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> lgaList = [];
        if (data is List) {
          lgaList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          lgaList = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['lgas'] is List) {
          lgaList = List<Map<String, dynamic>>.from(data['lgas']);
        }
        setState(() {
          _shopLgaList = lgaList;
          _isLoadingShopLgas = false;
        });
      } else {
        setState(() => _isLoadingShopLgas = false);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ErrorMessages.fromResponse(response,
                  fallback: 'Failed to load LGAs'))));
      }
    } catch (e) {
      setState(() => _isLoadingShopLgas = false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ErrorMessages.fromException(e,
                fallback: 'Failed to load LGAs'))));
    }
  }

  double _getBaseAmount() {
    final m = RegExp(r'[\d,]+\.?\d*').firstMatch(widget.price);
    return m != null
        ? (double.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0)
        : 0;
  }

  double _getSummaryBaseAmount() =>
      (_agentSellingPremium ?? _getBaseAmount()).toDouble();

  String _summaryPriceText() => _isLoadingAgentSellingPrice
      ? 'Loading...'
      : _formatNaira(_getSummaryBaseAmount());

  double _getPaystackCharge() {
    double c = (_getSummaryBaseAmount() * 0.015) + 100;
    return c > 2000 ? 2000 : c;
  }

  double _getTotalAmount() => _getSummaryBaseAmount() + _getPaystackCharge();
  String _formatNaira(double a) =>
      '₦${a.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

  Future<void> _initiatePayment() async {
    final email = _email.isNotEmpty ? _email : 'customer@rexinsure.com';
    final premiumAmount = _getBaseAmount();
    final productCode = _productCode;
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
        productCode: productCode,
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
          'insuredaddress':
              '${_shopAddressController.text.trim()}, ${_selectedShopState ?? ''}, ${_selectedShopLga ?? ''}',
          'insureddesc': _selectedShopDesc ?? '',
          'roofingmat': _selectedRoofing ?? '',
          'constructionmat': _selectedConstruction ?? '',
          'grosspremium': premiumAmount.toInt(),
          'items': _itemCategories
              .map((item) => {
                    'name': item['category'] ?? '',
                    'amount': int.tryParse(
                            item['amount']?.replaceAll(',', '') ?? '0') ??
                        0
                  })
              .toList(),
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

  void _addCategory() {
    if (_tempCategory == null || _tempAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select category and enter amount')));
      return;
    }
    setState(() {
      _itemCategories.add({
        'category': _tempCategory!,
        'amount': _tempAmountController.text.trim()
      });
      _tempCategory = null;
      _tempAmountController.clear();
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
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.pop(context);
                }
              }),
          title: Text(widget.productName,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          centerTitle: true),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            _stepIndicator(),
            const Divider(height: 1),
            if (_currentStep == 0) _ninStep(),
            if (_currentStep == 1) _socioStep(),
            if (_currentStep == 2) _riskStep(),
            if (_currentStep == 3) _summaryStep(),
          ])),
    );
  }

  Widget _stepIndicator() {
    final labels = [
      'Mode of Identification',
      'Socioeconomic Information',
      'Risk Information',
      'Summary'
    ];
    final stepNum = _currentStep + 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;
    final inactiveTrack = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Step $stepNum of 4',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
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
                  4,
                  (i) => Expanded(
                      child: Container(
                          height: 3,
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          decoration: BoxDecoration(
                              color: i < stepNum ? accent : inactiveTrack,
                              borderRadius: BorderRadius.circular(2)))))),
        ]));
  }

  Widget _ninStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('National Identification Number *',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
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
            _btn(
                'Continue',
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
                            color: Colors.green[700]))),
              ]),
            ),
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
              onChanged: (v) => setState(() => _selectedManualState = v),
            ),
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
                          _currentStep = _returnToSummaryAfterNin ? 3 : 1;
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
                        style: TextStyle(
                            fontSize: 12, color: Colors.orange[700]))),
              ]),
            ),
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
              onChanged: (v) => setState(() => _selectedManualState = v),
            ),
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
                          _currentStep = _returnToSummaryAfterNin ? 3 : 1;
                          _returnToSummaryAfterNin = false;
                        });
                      }
                    : null),
          ],
        ]));
  }

  Widget _socioStep() {
    final needsEmail = _emailController.text.trim().isEmpty;
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (needsEmail) ...[
            _label('Email *'),
            const SizedBox(height: 6),
            _tf('enter your email', _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email]),
            const SizedBox(height: 16)
          ],
          _label('Occupation *'),
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
          _label('Business Sector *'),
          const SizedBox(height: 6),
          _dd(
              'select your business sector',
              _selectedBusinessSector,
              _businessSectors,
              (v) => setState(() => _selectedBusinessSector = v)),
          const SizedBox(height: 16),
          _label('Tax Identification No (TIN)'),
          const SizedBox(height: 6),
          _tf('enter your TIN', _tinController),
          const SizedBox(height: 16),
          _label('Average Annual Income *'),
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

  Widget _riskStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.grey[50]!;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[200]!;
    final primaryText = Theme.of(context).colorScheme.onSurface;
    final secondaryText = isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Address of the Shop to be Insured *'),
          const SizedBox(height: 6),
          _tf('enter shop address', _shopAddressController,
              autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 16),
          _label('State *'),
          const SizedBox(height: 6),
          _dd('select state', _selectedShopState, _nigerianStates, (v) {
            setState(() => _selectedShopState = v);
            if (v != null) _fetchShopLgas(v);
          }),
          const SizedBox(height: 16),
          _label('LGA *'),
          const SizedBox(height: 6),
          _isLoadingShopLgas
              ? const SizedBox(
                  height: 48, child: Center(child: CircularProgressIndicator()))
              : _dd(
                  'select LGA',
                  _selectedShopLga,
                  _shopLgaList
                      .map((lga) => lga['name']?.toString() ?? '')
                      .where((name) => name.isNotEmpty)
                      .toList(),
                  (v) => setState(() => _selectedShopLga = v)),
          const SizedBox(height: 16),
          _label('Shop Description *'),
          const SizedBox(height: 6),
          _dd('select the type of shop', _selectedShopDesc, _shopDescriptions,
              (v) => setState(() => _selectedShopDesc = v)),
          const SizedBox(height: 16),
          _label('Type of Material - Roofing *'),
          const SizedBox(height: 6),
          _dd(
              'select roofing material',
              _selectedRoofing,
              const ['Zinc', 'Aluminum', 'Concrete/Slab', 'Tiles'],
              (v) => setState(() => _selectedRoofing = v)),
          const SizedBox(height: 16),
          _label('Construction Material *'),
          const SizedBox(height: 6),
          _dd(
              'select construction material',
              _selectedConstruction,
              const ['Metal', 'Brick/Concrete'],
              (v) => setState(() => _selectedConstruction = v)),
          const SizedBox(height: 20),
          Row(children: [
            Text('ADD CATEGORIES OF ITEMS\nFOR INSURANCE *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            GestureDetector(
                onTap: _addCategory,
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
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CATEGORY ${_itemCategories.length + 1}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                            letterSpacing: 1)),
                    const SizedBox(height: 8),
                    _label('Categories *'),
                    const SizedBox(height: 6),
                    _dd('furniture', _tempCategory, _categoryOptions,
                        (v) => setState(() => _tempCategory = v)),
                    const SizedBox(height: 12),
                    _label('Total Amount *'),
                    const SizedBox(height: 6),
                    _tf('enter price', _tempAmountController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _addCategory,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentOrange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: const Text('Add',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)))),
                  ])),
          if (_itemCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(_itemCategories.length, (i) {
              final item = _itemCategories[i];
              return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor)),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('ITEMS CATEGORY ${i + 1}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                  letterSpacing: 1)),
                          const SizedBox(height: 6),
                          Row(children: [
                            Expanded(
                                flex: 2,
                                child: Text('Category',
                                    style: TextStyle(
                                        fontSize: 11, color: secondaryText))),
                            Expanded(
                                flex: 3,
                                child: Text(item['category']!,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: primaryText),
                                    textAlign: TextAlign.right))
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Expanded(
                                flex: 2,
                                child: Text('Total Amount',
                                    style: TextStyle(
                                        fontSize: 11, color: secondaryText))),
                            Expanded(
                                flex: 3,
                                child: Text('₦${item['amount']}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: primaryText),
                                    textAlign: TextAlign.right))
                          ]),
                        ])),
                    GestureDetector(
                        onTap: () =>
                            setState(() => _itemCategories.removeAt(i)),
                        child: const Icon(Icons.cancel,
                            color: Colors.grey, size: 20)),
                  ]));
            }),
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
                    activeColor: accent)),
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
              _shopAddressController.text.trim().isNotEmpty &&
                      _selectedShopState != null &&
                      _selectedShopLga != null &&
                      _selectedShopDesc != null &&
                      _selectedRoofing != null &&
                      _selectedConstruction != null &&
                      _itemCategories.isNotEmpty &&
                      _consentChecked
                  ? () => setState(() {
                        if (widget.isExploreFlow &&
                            _ninWasSkipped &&
                            _ninController.text.trim().length != 11) {
                          _returnToSummaryAfterNin = true;
                          _currentStep = 0;
                        } else {
                          _currentStep = 3;
                        }
                      })
                  : null),
          const SizedBox(height: 12),
          _outBtn('Back', () => setState(() => _currentStep = 1)),
        ]));
  }

  Widget _summaryStep() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec('Payment Information', [
          _sRow('Product', '${widget.productName} ${widget.optionTitle}'),
          _sRow('Price', _summaryPriceText()),
          _sRow('Paystack Charges', _formatNaira(_getPaystackCharge())),
          _sRow('Total', _formatNaira(_getTotalAmount()))
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
          _sRow('Business Sector', _selectedBusinessSector ?? '-'),
          _sRow('Tax Identification No',
              _tinController.text.isNotEmpty ? _tinController.text : '-'),
          _sRow(
              'Highest Academic Qualification', _selectedQualification ?? '-'),
          _sRow('Average Annual Income', _annualIncomeController.text)
        ]),
        const SizedBox(height: 20),
        _sec('Risk Information', [
          _sRow('Shop Address',
              '${_shopAddressController.text.trim()}, ${_selectedShopState ?? ''}, ${_selectedShopLga ?? ''}'),
          _sRow('Shop Description', _selectedShopDesc ?? '-'),
          _sRow('Roofing Material', _selectedRoofing ?? '-'),
          _sRow('Construction Material', _selectedConstruction ?? '-'),
          ..._itemCategories
              .map((item) => _sRow(item['category']!, '₦${item['amount']}')),
        ]),
        const SizedBox(height: 30),
        _btn('Pay Now', _isPayingNow ? null : _initiatePayment,
            loading: _isPayingNow),
        const SizedBox(height: 20),
      ]));

  // Helpers
  Widget _sec(String t, List<Widget> r) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 12),
        ...r
      ]));

  Widget _sRow(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: Text(l,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFCBD5E1)
                        : Colors.grey[600]))),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;
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
            hint: Text(h, style: TextStyle(color: hintColor, fontSize: 13)),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
            dropdownColor: isDark ? const Color(0xFF111827) : Colors.white,
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
