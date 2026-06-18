import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';
import '../widgets/searchable_dropdown.dart';
import 'private_motor_details_screen.dart';

class VehicleInformationScreen extends StatefulWidget {
  final String vehicleType;
  final String price;
  final Map<String, String> personalInfo;
  final bool isLoggedIn;
  final bool isAgent;
  final String agentCode;
  final bool isExploreFlow;

  const VehicleInformationScreen({
    super.key,
    this.vehicleType = 'Private Car',
    this.price = 'N15,000',
    this.personalInfo = const {},
    this.isLoggedIn = false,
    this.isAgent = false,
    this.agentCode = '',
    this.isExploreFlow = false,
  });

  @override
  State<VehicleInformationScreen> createState() =>
      _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  final _regNumberController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _manualEntry = false;
  Map<String, dynamic>? _vehicleData;

  // Manual entry
  final _vinController = TextEditingController();
  final _engineController = TextEditingController();

  // Vehicle list from API
  bool _loadingVehicleList = false;
  Map<String, List<String>> _makeModelMap = {}; // make -> [models]
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

  @override
  void initState() {
    super.initState();
    _fetchVehicleList();
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _vinController.dispose();
    _engineController.dispose();
    super.dispose();
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
          if (model.isNotEmpty && !map[make]!.contains(model)) {
            map[make]!.add(model);
          }
        }
        // Sort makes and models alphabetically
        final sorted = Map.fromEntries(
          map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        );
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

  Future<void> _handleVerify() async {
    final regNo = _regNumberController.text.trim();
    if (regNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a registration number')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _isVerified = false;
      _vehicleData = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://eportaltest.rexinsure.com/api/vehicleVerification'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'Intcode': 'Testcode',
              'Password': 'royal1234',
              'RegNo': regNo
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'Successful' &&
            data['data'] != null &&
            (data['data'] as List).isNotEmpty) {
          final firstItem = Map<String, dynamic>.from(data['data'][0]);
          final hasRealData =
              (firstItem['vehicleMake']?.toString() ?? '').isNotEmpty &&
                  firstItem['vehiclestatus']?.toString() !=
                      'Non-Existent Registration';
          if (hasRealData) {
            setState(() {
              _isVerifying = false;
              _isVerified = true;
              _vehicleData = firstItem;
            });
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrivateMotorDetailsScreen(
                          vehicleType: widget.vehicleType,
                          price: widget.price,
                          personalInfo: widget.personalInfo,
                          vehicleData: _vehicleData!,
                          isLoggedIn: widget.isLoggedIn,
                          isAgent: widget.isAgent,
                          agentCode: widget.agentCode,
                          isExploreFlow: widget.isExploreFlow)));
            }
          } else {
            setState(() {
              _isVerifying = false;
              _manualEntry = true;
            });
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Vehicle not found. Enter details manually.'),
                  backgroundColor: Colors.orange));
          }
        } else {
          setState(() {
            _isVerifying = false;
            _manualEntry = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message']?.toString() ??
                    'Vehicle not found. Enter details manually.'),
                backgroundColor: Colors.orange),
          );
        }
      } else {
        setState(() {
          _isVerifying = false;
          _manualEntry = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Server error. Enter details manually.'),
            backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _manualEntry = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${ErrorMessages.fromException(e, fallback: 'Verification failed')}. Enter details manually.'),
            backgroundColor: Colors.orange));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final fillColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[400]!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicleType,
            style: TextStyle(
                color: onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
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
                  Row(children: [
                    Text('Step 2 of 3',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    const Spacer(),
                    Text('Vehicle Information',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                      children: List.generate(
                          3,
                          (i) => Expanded(
                                  child: Container(
                                height: 4,
                                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                                decoration: BoxDecoration(
                                    color: i < 2
                                        ? AppTheme.primaryNavy
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2)),
                              )))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reg Number',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: onSurface)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _regNumberController,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(color: onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'enter your reg. no.',
                      hintStyle:
                          TextStyle(color: Colors.grey[400], fontSize: 14),
                      filled: true,
                      fillColor: fillColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: borderColor, width: 1.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: borderColor, width: 1.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryNavy, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 0, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isVerifying || _isVerified ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVerified
                            ? Colors.green
                            : (Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.accentOrange
                                : AppTheme.primaryNavy),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: _isVerifying
                            ? AppTheme.primaryNavy.withValues(alpha: 0.7)
                            : Colors.green,
                        disabledForegroundColor: Colors.white,
                      ),
                      child: _isVerifying
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white))),
                                  SizedBox(width: 12),
                                  Text('Verifying RegNo',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ])
                          : _isVerified
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Registration No Verified',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ])
                              : const Text('Verify',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Manual entry fields when verification fails
                  if (_manualEntry && !_isVerified) ...[
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
                                'Vehicle not found. Enter details manually.',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.orange[700]))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                        'VIN / Chassis Number *', 'enter VIN', _vinController),
                    // Vehicle Make — searchable dropdown from API
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Vehicle Make *'),
                            const SizedBox(height: 6),
                            _loadingVehicleList
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Vehicle Model *'),
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Vehicle Color *'),
                            const SizedBox(height: 6),
                            SearchableDropdown(
                              hint: 'select vehicle color',
                              value: _selectedColor,
                              items: _vehicleColors,
                              onChanged: (v) =>
                                  setState(() => _selectedColor = v),
                            ),
                          ]),
                    ),
                    _buildField('Engine Number *', 'enter engine number',
                        _engineController),
                    // Year of Manufacture dropdown
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Year of Manufacture *'),
                            const SizedBox(height: 6),
                            SearchableDropdown(
                              hint: 'select year',
                              value: _selectedYear,
                              items: _vehicleYears,
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedMake != null &&
                                _selectedModel != null &&
                                _selectedColor != null &&
                                _selectedYear != null &&
                                _vinController.text.trim().isNotEmpty &&
                                _engineController.text.trim().isNotEmpty
                            ? () {
                                final manualData = <String, dynamic>{
                                  'registrationNo':
                                      _regNumberController.text.trim(),
                                  'chassisNo': _vinController.text.trim(),
                                  'vehicleMake': _selectedMake!,
                                  'vehicleModel': _selectedModel!,
                                  'vehicleColor': _selectedColor ?? '',
                                  'vehicleEngineno':
                                      _engineController.text.trim(),
                                  'vehicleEngineCapacity': '',
                                  'vehicleCategory': '',
                                  'ownersName': '',
                                  'Year': _selectedYear ?? '',
                                };
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            PrivateMotorDetailsScreen(
                                                vehicleType: widget.vehicleType,
                                                price: widget.price,
                                                personalInfo:
                                                    widget.personalInfo,
                                                vehicleData: manualData,
                                                isLoggedIn: widget.isLoggedIn,
                                                isAgent: widget.isAgent,
                                                agentCode: widget.agentCode,
                                                isExploreFlow:
                                                    widget.isExploreFlow)));
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
                              AppTheme.disabledButtonTextColor(context),
                        ),
                        child: const Text('Continue',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(
                            color: AppTheme.primaryNavy, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Back',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface),
      );

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 13),
            filled: true,
            fillColor: fieldColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: accent, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ]),
    );
  }
}
