import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/customer_details.dart';
import '../utils/error_messages.dart';
import '../services/payment_service.dart';
import '../widgets/paystack_webview.dart';
import '../widgets/searchable_dropdown.dart';
import 'policy_purchase_success_screen.dart';

class RoyalAutoPurchaseScreen extends StatefulWidget {
  final String productName; // Royal Auto Bronze or Royal Auto Silver
  final String price;
  final bool isCustomerFlow;
  final bool isAgent;
  final Map<String, dynamic>? clientData;
  final bool isExploreFlow;
  const RoyalAutoPurchaseScreen({
    super.key,
    required this.productName,
    required this.price,
    this.isCustomerFlow = false,
    this.isAgent = false,
    this.clientData,
    this.isExploreFlow = false,
  });
  @override
  State<RoyalAutoPurchaseScreen> createState() =>
      _RoyalAutoPurchaseScreenState();
}

class _RoyalAutoPurchaseScreenState extends State<RoyalAutoPurchaseScreen> {
  int _step = 0; // 0=NIN,1=employment,2=vehicle,3=imageUpload,4=summary
  bool _isVerifying = false, _isPayingNow = false;

  // Step 0: NIN
  String? _selectedIdType;
  final _ninController = TextEditingController();
  bool _isCustomerNinLocked = false;
  String _firstName = '',
      _lastName = '',
      _email = '',
      _phone = '',
      _dob = '',
      _state = '',
      _lga = '',
      _address = '';
  bool _ninFailed = false;
  // Manual personal info controllers
  final _manualFirstNameController = TextEditingController();
  final _manualLastNameController = TextEditingController();
  final _manualEmailController = TextEditingController();
  final _manualPhoneController = TextEditingController();

  // Step 1: Employment
  String? _selectedEmployment;
  final _employerNameController = TextEditingController();
  final _employerBusinessController = TextEditingController();
  final _employerAddressController = TextEditingController();
  final _employerPhoneController = TextEditingController();
  final _employerEmailController = TextEditingController();
  final List<String> _employmentTypes = const [
    'Self-employed',
    'Employed',
    'Unemployed'
  ];

  // Step 2: Vehicle
  final _regNumberController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  String? _selectedVehiclePurpose;
  final _inspectionAddressController = TextEditingController();
  String? _selectedLicenseType;
  final _drivingYearsController = TextEditingController();
  final List<String> _vehiclePurposes = const [
    'Private',
    'Commercial',
    'Official',
    'Others'
  ];
  final List<String> _licenseTypes = const [
    "Driver's License",
    "Learner's Permit",
    'None'
  ];
  bool _isVerifyingReg = false;
  String _regVerifyStatus = '';
  bool _manualVehicleEntry = false;
  Map<String, dynamic>? _vehicleData;
  // Manual entry controllers
  final _vinController = TextEditingController();
  final _engineNumberController = TextEditingController();

  // Vehicle list from API
  bool _loadingVehicleList = false;
  Map<String, List<String>> _makeModelMap = {};
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedColor;
  String? _selectedYear;

  static const List<String> _vehicleColors = [
    'Red',
    'Silver',
    'Pink',
    'White',
    'Yellow',
    'Brown',
    'Grey',
    'Green',
    'Orange',
    'Indigo',
    'Violet',
    'Corporate',
    'Custom',
    'Gold',
    'Commercial',
    'Cream',
    'Blue',
    'Ash',
    'Wine',
    'Purple',
    'Black',
    'Other',
  ];

  static final List<String> _vehicleYears = List.generate(
    DateTime.now().year - 1980 + 1,
    (i) => (DateTime.now().year - i).toString(),
  );

  // Step 3: Image Upload
  final ImagePicker _picker = ImagePicker();
  File? _frontView,
      _backView,
      _rightView,
      _leftView,
      _dashboardView,
      _selfieView;

  @override
  void dispose() {
    _ninController.dispose();
    _manualFirstNameController.dispose();
    _manualLastNameController.dispose();
    _manualEmailController.dispose();
    _manualPhoneController.dispose();
    _employerNameController.dispose();
    _employerBusinessController.dispose();
    _employerAddressController.dispose();
    _employerPhoneController.dispose();
    _employerEmailController.dispose();
    _regNumberController.dispose();
    _estimatedValueController.dispose();
    _inspectionAddressController.dispose();
    _drivingYearsController.dispose();
    _vinController.dispose();
    _engineNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _prefillAgentClientDetails();
    if (widget.isExploreFlow) {
      _prefillExploreKyc();
    } else {
      _prefillCustomerNin();
    }
    _fetchVehicleList();
  }

  String get _productCode =>
      widget.productName.toLowerCase().contains('bronze') ? 'RAB' : 'RAS';

  String _clientValue(List<String> keys) {
    final data = widget.clientData;
    if (data == null) return '';
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _prefillAgentClientDetails() {
    if (!widget.isAgent || widget.clientData == null) return;

    _ninController.text = _clientValue(
      ['nin', 'NIN', 'cust_national_id_no', 'cust_national_id'],
    );
    _firstName = _clientValue(['firstName', 'cust_first_name']);
    _lastName = _clientValue(['lastName', 'cust_last_name']);
    _email = _clientValue(['email', 'cust_email']);
    _phone = _clientValue(['phone', 'cust_phone', 'cust_phone_no']);
    _dob = _clientValue(['dob', 'cust_dob']);
    _state = _clientValue(['state', 'cust_state']);
    _lga = _clientValue(['lga', 'cust_lga']);
    _address = _clientValue(['address', 'cust_address']);
    _manualFirstNameController.text = _firstName;
    _manualLastNameController.text = _lastName;
    _manualEmailController.text = _email;
    _manualPhoneController.text = _phone;

    if (_ninController.text.trim().length == 11) {
      _selectedIdType = 'NIN';
    }
  }

  Future<void> _prefillCustomerNin() async {
    if (!widget.isCustomerFlow) return;

    final authProvider = context.read<AuthProvider>();
    final nin = await CustomerDetails.ninFromAuth(authProvider);
    if (!mounted || nin.isEmpty) return;

    setState(() {
      _selectedIdType = 'NIN';
      _ninController.text = nin;
      _isCustomerNinLocked = true;
    });
  }

  Future<void> _prefillExploreKyc() async {
    final details = await CustomerDetails.signupKycDetails();
    if (!mounted) return;

    setState(() {
      _selectedIdType = 'NIN';
      _ninController.text = details['nin'] ?? '';
      _firstName = details['firstName'] ?? '';
      _lastName = details['lastName'] ?? '';
      _email = details['email'] ?? '';
      _phone = details['phone'] ?? '';
      _dob = details['dob'] ?? '';
      _state = details['state'] ?? '';
      _lga = details['lga'] ?? '';
      _address = details['address'] ?? '';
      _manualFirstNameController.text = _firstName;
      _manualLastNameController.text = _lastName;
      _manualEmailController.text = _email;
      _manualPhoneController.text = _phone;
      _step = 1;
    });
  }

  Future<void> _fetchVehicleList() async {
    setState(() => _loadingVehicleList = true);
    try {
      final response = await http.get(
        Uri.parse('https://eportaltest.rexinsure.com/api/vehicleList'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, List<String>> map = {};
        for (final item in data) {
          final make = item['VehicleMake']?.toString().trim() ?? '';
          final model = item['VehicleModel']?.toString().trim() ?? '';
          if (make.isEmpty) continue;
          map.putIfAbsent(make, () => []);
          if (model.isNotEmpty && !map[make]!.contains(model))
            map[make]!.add(model);
        }
        final sorted = Map.fromEntries(
            map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
        for (final models in sorted.values) {
          models.sort();
        }
        if (mounted)
          setState(() {
            _makeModelMap = sorted;
            _loadingVehicleList = false;
          });
      } else {
        if (mounted) setState(() => _loadingVehicleList = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingVehicleList = false);
    }
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
            _phone = k['telephoneno']?.toString() ?? '';
            _dob = (k['birthdate']?.toString() ?? '').replaceAll('-', '/');
            _address = k['residence_address']?.toString() ?? '';
            _state = k['residence_state']?.toString() ?? '';
            _lga = k['residence_lga']?.toString() ?? '';
            _step = 1;
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
                    ? (kyc['status']?.toString() ??
                        'Verification failed. Enter details manually.')
                    : 'NIN not found. Enter details manually.')));
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

  Future<void> _verifyRegNo() async {
    if (_regNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter registration number')));
      return;
    }
    setState(() {
      _isVerifyingReg = true;
      _vehicleData = null;
    });
    try {
      final r = await http
          .post(
              Uri.parse(
                  'https://eportaltest.rexinsure.com/api/vehicleVerification'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'Intcode': 'Testcode',
                'Password': 'royal1234',
                'RegNo': _regNumberController.text.trim()
              }))
          .timeout(const Duration(seconds: 15));
      print('=== VEHICLE VERIFY: ${r.statusCode} ===');
      print('Body: ${r.body}');
      setState(() => _isVerifyingReg = false);
      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'Successful' &&
            d['data'] != null &&
            (d['data'] as List).isNotEmpty) {
          final firstItem = Map<String, dynamic>.from(d['data'][0]);
          // Check if actual vehicle data exists (not just empty/non-existent)
          final hasRealData =
              (firstItem['vehicleMake']?.toString() ?? '').isNotEmpty &&
                  firstItem['vehiclestatus']?.toString() !=
                      'Non-Existent Registration';
          if (hasRealData) {
            setState(() {
              _regVerifyStatus = 'verified';
              _vehicleData = firstItem;
            });
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Vehicle verified'),
                  backgroundColor: Colors.green));
          } else {
            setState(() {
              _regVerifyStatus = '';
              _manualVehicleEntry = true;
              _vehicleData = null;
            });
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Vehicle not found. Enter details manually.'),
                  backgroundColor: Colors.orange));
          }
        } else {
          setState(() {
            _regVerifyStatus = '';
            _manualVehicleEntry = true;
            _vehicleData = null;
          });
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(d['message']?.toString() ?? 'Vehicle not found'),
                backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      setState(() {
        _isVerifyingReg = false;
        _manualVehicleEntry = true;
        _vehicleData = null;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorMessages.fromException(e))));
    }
  }

  int _getEstimatedValue() =>
      int.tryParse(
          _estimatedValueController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
      0;

  double _getBase() => (_getEstimatedValue() * 0.03) + 15000;

  double _getCharge() {
    double c = (_getBase() * 0.015) + 100;
    return c > 2000 ? 2000 : c;
  }

  double _getTotal() => _getBase() + _getCharge();
  String _fmtN(double a) =>
      '₦${a.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

  Future<void> _pay() async {
    setState(() => _isPayingNow = true);
    final email = _email.isNotEmpty ? _email : 'customer@rexinsure.com';

    final result = await PaymentService.initiatePurchase(
      productCode: _productCode,
      names: '$_firstName $_lastName'.trim(),
      email: email,
      mobileno: _phone,
      premium: _getBase().round(),
      includeCredentials: false,
      extraFields: {
        'type': 'Individual',
        'vehregno': _regNumberController.text.trim(),
        'vehmake':
            _vehicleData?['VehicleMake']?.toString() ?? _selectedMake ?? '',
        'vehmodel':
            _vehicleData?['VehicleModel']?.toString() ?? _selectedModel ?? '',
        'vehcolor':
            _vehicleData?['VehicleColor']?.toString() ?? _selectedColor ?? '',
        'vehchasisno':
            _vehicleData?['VIN']?.toString() ?? _vinController.text.trim(),
        'engnumb': _vehicleData?['EngineNumber']?.toString() ??
            _engineNumberController.text.trim(),
        'vehyear': _vehicleData?['Year']?.toString() ?? _selectedYear ?? '',
        'estimatedvalue': _getEstimatedValue(),
        'vehiclepurpose': _selectedVehiclePurpose ?? '',
        'employment': _selectedEmployment ?? '',
      },
      isExploreFlow: widget.isExploreFlow,
    );

    setState(() => _isPayingNow = false);
    if (!mounted) return;

    if (result.success && result.authorizationUrl != null) {
      final res = await Navigator.push<PaymentVerifyResult>(
          context,
          MaterialPageRoute(
              builder: (_) => PaystackWebView(url: result.authorizationUrl!)));
      if (res != null && res.success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PolicyPurchaseSuccessScreen(
              reference: res.reference,
              message: res.message,
              isExploreFlow: widget.isExploreFlow,
              accountData: {
                'firstName': _firstName,
                'lastName': _lastName,
                'email': email,
                'phone': _phone,
                'occupation': _selectedEmployment ?? 'Business',
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
  }

  Future<void> _pickImage(String type) async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (_) => SafeArea(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera)),
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery)),
              ])));
      if (source == null) return;
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1024, imageQuality: 80);
      if (picked != null) {
        setState(() {
          final file = File(picked.path);
          switch (type) {
            case 'front':
              _frontView = file;
            case 'back':
              _backView = file;
            case 'right':
              _rightView = file;
            case 'left':
              _leftView = file;
            case 'dashboard':
              _dashboardView = file;
            case 'selfie':
              _selfieView = file;
          }
        });
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
                  if (_step > 0)
                    setState(() => _step--);
                  else
                    Navigator.pop(context);
                }),
            title: Text(
                _step == 4
                    ? '${widget.productName} Summary'
                    : widget.productName,
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
              if (_step == 0) _ninStep(),
              if (_step == 1) _employmentStep(),
              if (_step == 2) _vehicleStep(),
              if (_step == 3) _imageStep(),
              if (_step == 4) _summaryStep(),
            ])));
  }

  Widget _si() {
    final labels = [
      'Mode of Identification',
      'Employment Status',
      'Vehicle Information',
      'Image Upload',
      'Summary'
    ];
    final total = 5;
    final num = _step + 1;
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
                child: Text(labels[_step],
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
  Widget _ninStep() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Select mode of Identification',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _dd('select', _selectedIdType, const ['NIN'],
            (v) => setState(() => _selectedIdType = v)),
        if (_selectedIdType != null) ...[
          const SizedBox(height: 20),
          const Text('National Identification Number',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _tf('enter your NIN', _ninController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              readOnly: _isCustomerNinLocked)
        ],
        if (!_ninFailed) ...[
          const SizedBox(height: 40),
          _btn(
              'Continue',
              _selectedIdType != null &&
                      _ninController.text.trim().length == 11 &&
                      !_isVerifying
                  ? _verifyNin
                  : null,
              loading: _isVerifying),
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
                            TextStyle(fontSize: 11, color: Colors.orange[700])))
              ])),
          const SizedBox(height: 16),
          _label('First Name'),
          const SizedBox(height: 6),
          _tf('enter first name', _manualFirstNameController,
              autofillHints: [AutofillHints.givenName]),
          const SizedBox(height: 12),
          _label('Last Name'),
          const SizedBox(height: 6),
          _tf('enter last name', _manualLastNameController,
              autofillHints: [AutofillHints.familyName]),
          const SizedBox(height: 12),
          _label('Email'),
          const SizedBox(height: 6),
          _tf('enter email', _manualEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
          const SizedBox(height: 12),
          _label('Phone Number'),
          const SizedBox(height: 6),
          _tf('enter phone number', _manualPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 24),
          _btn(
              'Continue',
              _manualFirstNameController.text.trim().isNotEmpty &&
                      _manualLastNameController.text.trim().isNotEmpty &&
                      _manualEmailController.text.trim().isNotEmpty &&
                      _manualPhoneController.text.trim().isNotEmpty
                  ? () {
                      setState(() {
                        _firstName = _manualFirstNameController.text.trim();
                        _lastName = _manualLastNameController.text.trim();
                        _email = _manualEmailController.text.trim();
                        _phone = _manualPhoneController.text.trim();
                        _step = 1;
                      });
                    }
                  : null),
        ],
      ]));

  // Step 1: Employment
  Widget _employmentStep() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Type of Employment'),
        const SizedBox(height: 8),
        _dd('select type of employment', _selectedEmployment, _employmentTypes,
            (v) => setState(() => _selectedEmployment = v)),
        if (_selectedEmployment == 'Employed') ...[
          const SizedBox(height: 16),
          _label('Name of Employer *'),
          const SizedBox(height: 6),
          _tf("enter your employer's name", _employerNameController,
              autofillHints: [AutofillHints.name]),
          const SizedBox(height: 14),
          _label("Employer's Business *"),
          const SizedBox(height: 6),
          _tf('enter the type of work you do', _employerBusinessController),
          const SizedBox(height: 14),
          _label("Employer's Address*"),
          const SizedBox(height: 6),
          _tf("enter your employer's address", _employerAddressController,
              maxLines: 2, autofillHints: [AutofillHints.streetAddressLine1]),
          const SizedBox(height: 14),
          _label("Employer's Phone Number*"),
          const SizedBox(height: 6),
          _tf("enter your employer's phone number", _employerPhoneController,
              keyboardType: TextInputType.phone,
              autofillHints: [AutofillHints.telephoneNumber]),
          const SizedBox(height: 14),
          _label("Employer's Email Address *"),
          const SizedBox(height: 6),
          _tf("enter your employer's email address", _employerEmailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email]),
        ],
        const SizedBox(height: 40),
        _btn(
            'Continue',
            _selectedEmployment != null &&
                    (_selectedEmployment != 'Employed' ||
                        (_employerNameController.text.trim().isNotEmpty &&
                            _employerBusinessController.text
                                .trim()
                                .isNotEmpty &&
                            _employerAddressController.text.trim().isNotEmpty &&
                            _employerPhoneController.text.trim().isNotEmpty &&
                            _employerEmailController.text.trim().isNotEmpty))
                ? () => setState(() => _step = 2)
                : null),
        const SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _step = 0)),
      ]));

  // Step 2: Vehicle Information
  Widget _vehicleStep() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Reg Number'), const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child:
                  _tf('enter vehicle registration no.', _regNumberController)),
          const SizedBox(width: 8),
          SizedBox(
              width: 80,
              height: 48,
              child: ElevatedButton(
                onPressed: _isVerifyingReg ? null : _verifyRegNo,
                style: ElevatedButton.styleFrom(
                    backgroundColor: _regVerifyStatus == 'verified'
                        ? Colors.green
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: _isVerifyingReg
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_regVerifyStatus == 'verified' ? '✓' : 'Verify',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
              )),
        ]),
        // Manual vehicle entry fields (shown when verification fails)
        if (_manualVehicleEntry && _vehicleData == null) ...[
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
                        'Vehicle not found. Please enter details manually.',
                        style:
                            TextStyle(fontSize: 11, color: Colors.orange[700])))
              ])),
          const SizedBox(height: 12),
          _label('VIN / Chassis Number *'), const SizedBox(height: 6),
          _tf('enter VIN', _vinController),
          const SizedBox(height: 12),
          // Vehicle Make — searchable dropdown from API
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Vehicle Make *'),
              const SizedBox(height: 6),
              _loadingVehicleList
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : SearchableDropdown(
                      hint: 'select vehicle make',
                      value: _selectedMake,
                      items: _makeModelMap.keys.toList(),
                      onChanged: (v) => setState(() {
                        _selectedMake = v;
                        _selectedModel = null;
                      }),
                    ),
            ]),
          ),
          // Vehicle Model — filtered by selected make
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Vehicle Model *'),
              const SizedBox(height: 6),
              SearchableDropdown(
                hint: _selectedMake == null
                    ? 'select make first'
                    : 'select vehicle model',
                value: _selectedModel,
                items: _selectedMake != null
                    ? (_makeModelMap[_selectedMake] ?? [])
                    : [],
                onChanged: _selectedMake != null
                    ? (v) => setState(() => _selectedModel = v)
                    : (_) {},
              ),
            ]),
          ),
          // Vehicle Color dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Vehicle Color *'),
              const SizedBox(height: 6),
              SearchableDropdown(
                hint: 'select vehicle color',
                value: _selectedColor,
                items: _vehicleColors,
                onChanged: (v) => setState(() => _selectedColor = v),
              ),
            ]),
          ),
          _label('Engine Number *'), const SizedBox(height: 6),
          _tf('enter engine number', _engineNumberController),
          const SizedBox(height: 12),
          // Year of Manufacture dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Year of Manufacture *'),
              const SizedBox(height: 6),
              SearchableDropdown(
                hint: 'select year',
                value: _selectedYear,
                items: _vehicleYears,
                onChanged: (v) => setState(() => _selectedYear = v),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        _label('Estimated Value of vehicle'),
        const SizedBox(height: 6),
        _tf('value of vehicle', _estimatedValueController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _label('Vehicle Purpose'),
        const SizedBox(height: 6),
        _dd(
            'select purpose of vehicle',
            _selectedVehiclePurpose,
            _vehiclePurposes,
            (v) => setState(() => _selectedVehiclePurpose = v)),
        const SizedBox(height: 16),
        _label('Where can the vehicle be inspected?'),
        const SizedBox(height: 6),
        _tf('enter the address for vehicle inspection',
            _inspectionAddressController,
            autofillHints: [AutofillHints.streetAddressLine1]),
        const SizedBox(height: 16),
        _label("Driver's License or Learner's Permit?"),
        const SizedBox(height: 6),
        _dd('select the option you have', _selectedLicenseType, _licenseTypes,
            (v) => setState(() => _selectedLicenseType = v)),
        const SizedBox(height: 16),
        _label('How long have you been driving'),
        const SizedBox(height: 6),
        _tf('enter number', _drivingYearsController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 40),
        _btn(
            'Continue',
            _regNumberController.text.trim().isNotEmpty &&
                    _estimatedValueController.text.trim().isNotEmpty &&
                    _selectedVehiclePurpose != null &&
                    _inspectionAddressController.text.trim().isNotEmpty &&
                    _selectedLicenseType != null &&
                    _drivingYearsController.text.trim().isNotEmpty &&
                    (_vehicleData != null ||
                        !_manualVehicleEntry ||
                        (_selectedMake != null &&
                            _selectedModel != null &&
                            _selectedColor != null &&
                            _selectedYear != null &&
                            _vinController.text.trim().isNotEmpty &&
                            _engineNumberController.text.trim().isNotEmpty))
                ? () => setState(() => _step = 3)
                : null),
        const SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _step = 1)),
      ]));

  // Step 3: Image Upload
  Widget _imageStep() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF111827)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.camera_alt_outlined, size: 18),
                SizedBox(width: 8),
                Text('Upload Tips:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 8),
              Text(
                  '• Take pictures in daylight for better clarity and good lighting\n• Avoid glare or shadows covering details\n• Make sure vehicle is clean and plates readable\n• Required Photo Angles: Front View (Make sure the number plate is clearly visible), Left and Right side View, Back View (Ensure the rear of the car is fully visible) Dashboard View (Take a clear photo of the dashboard)',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFCBD5E1)
                          : Colors.grey[700],
                      height: 1.5)),
            ])),
        const SizedBox(height: 20),
        const Text('Upload a file (max file 2MB)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        _uploadRow(
            'Upload the front view', _frontView, () => _pickImage('front')),
        const SizedBox(height: 10),
        _uploadRow('Upload the back view', _backView, () => _pickImage('back')),
        const SizedBox(height: 10),
        _uploadRow(
            'Upload the right view', _rightView, () => _pickImage('right')),
        const SizedBox(height: 10),
        _uploadRow('Upload the left view', _leftView, () => _pickImage('left')),
        const SizedBox(height: 10),
        _uploadRow('Upload the dashboard view', _dashboardView,
            () => _pickImage('dashboard')),
        const SizedBox(height: 10),
        _uploadRow('take a selfie with the car', _selfieView,
            () => _pickImage('selfie')),
        const SizedBox(height: 40),
        _btn(
            'Continue',
            _frontView != null &&
                    _backView != null &&
                    _rightView != null &&
                    _leftView != null
                ? () => setState(() => _step = 4)
                : null),
        const SizedBox(height: 12),
        _outBtn('Back', () => setState(() => _step = 2)),
      ]));

  Widget _uploadRow(String label, File? file, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFile = file != null;
    final borderColor = hasFile
        ? (isDark ? const Color(0xFF22C55E) : Colors.green)
        : (isDark ? const Color(0xFF334155) : Colors.grey[300]!);
    final backgroundColor = hasFile
        ? (isDark ? const Color(0xFF052E16) : Colors.green[50]!)
        : (isDark ? const Color(0xFF111827) : Colors.white);
    final textColor = hasFile
        ? (isDark ? const Color(0xFF86EFAC) : Colors.green[800]!)
        : (isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!);
    final uploadButtonColor =
        isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Row(children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                  color: backgroundColor),
              child: Text(hasFile ? '✓ $label' : label,
                  style: TextStyle(fontSize: 12, color: textColor)))),
      const SizedBox(width: 8),
      GestureDetector(
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: uploadButtonColor,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.upload_file,
                  color: Colors.white, size: 20))),
    ]);
  }

  // Step 4: Summary
  Widget _summaryStep() => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec('Payment Information', [
          _sRow('Product', widget.productName),
          _sRow('Price', widget.price),
          _sRow('Premium', _fmtN(_getBase())),
          _sRow('Paystack Charges', _fmtN(_getCharge())),
          _sRow('Total', _fmtN(_getTotal()))
        ]),
        const SizedBox(height: 20),
        _sec('Vehicle Information', [
          _sRow('Reg No.', _regNumberController.text),
          if (_vehicleData != null) ...[
            _sRow(
                'VIN',
                _vehicleData!['VIN']?.toString() ??
                    _vehicleData!['vin']?.toString() ??
                    '-'),
            _sRow(
                'Vehicle Type',
                _vehicleData!['VehicleType']?.toString() ??
                    _vehicleData!['vehicletype']?.toString() ??
                    '-'),
            _sRow(
                'Vehicle Make',
                _vehicleData!['VehicleMake']?.toString() ??
                    _vehicleData!['vehiclemake']?.toString() ??
                    '-'),
            _sRow(
                'Vehicle Model',
                _vehicleData!['VehicleModel']?.toString() ??
                    _vehicleData!['vehiclemodel']?.toString() ??
                    '-'),
            _sRow(
                'Vehicle Color',
                _vehicleData!['VehicleColor']?.toString() ??
                    _vehicleData!['vehiclecolor']?.toString() ??
                    '-'),
            _sRow(
                'Engine Number',
                _vehicleData!['EngineNumber']?.toString() ??
                    _vehicleData!['enginenumber']?.toString() ??
                    '-'),
            _sRow(
                'Year',
                _vehicleData!['Year']?.toString() ??
                    _vehicleData!['year']?.toString() ??
                    '-'),
          ] else if (_manualVehicleEntry) ...[
            _sRow('VIN', _vinController.text),
            _sRow('Vehicle Make', _selectedMake ?? '-'),
            _sRow('Vehicle Model', _selectedModel ?? '-'),
            _sRow('Vehicle Color', _selectedColor ?? '-'),
            _sRow('Engine Number', _engineNumberController.text),
            _sRow('Year', _selectedYear ?? '-'),
          ],
          _sRow('Estimated Value', _estimatedValueController.text),
          _sRow('Vehicle Purpose', _selectedVehiclePurpose ?? '-'),
          _sRow('Inspection Address', _inspectionAddressController.text),
          _sRow('License Type', _selectedLicenseType ?? '-'),
          _sRow('Driving Years', _drivingYearsController.text),
        ]),
        if (!widget.isExploreFlow) ...[
          const SizedBox(height: 20),
          _sec('Personal Information', [
            _sRow('First Name', _firstName),
            _sRow('Last Name', _lastName),
            _sRow('Email', _email),
            _sRow('Phone Number', _phone),
            _sRow('DOB', _dob),
            _sRow('State', _state),
            _sRow('LGA', _lga),
            _sRow('Address', _address)
          ]),
        ],
        if (_selectedEmployment == 'Employed') ...[
          const SizedBox(height: 20),
          _sec('Employment Details', [
            _sRow('Type', _selectedEmployment ?? '-'),
            _sRow('Employer', _employerNameController.text),
            _sRow('Business', _employerBusinessController.text),
            _sRow('Address', _employerAddressController.text),
            _sRow('Phone', _employerPhoneController.text),
            _sRow('Email', _employerEmailController.text)
          ]),
        ],
        if (_selectedEmployment != null &&
            _selectedEmployment != 'Employed') ...[
          const SizedBox(height: 20),
          _sec('Employment', [_sRow('Type', _selectedEmployment ?? '-')]),
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
  Widget _label(String t) => Text(t,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface));
  Widget _tf(String h, TextEditingController c,
      {TextInputType? keyboardType,
      int maxLines = 1,
      int? maxLength,
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
            onChanged: (value) {
              FocusManager.instance.primaryFocus?.unfocus();
              onChanged(value);
            }));
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
