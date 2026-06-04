import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/occupations.dart';
import '../providers/auth_provider.dart';
import '../widgets/searchable_dropdown.dart';
import 'comprehensive_vehicle_info_screen.dart';

class ComprehensivePersonalInfoScreen extends StatefulWidget {
  final String vehicleType;
  final bool isLoggedIn;
  final bool isAgent;
  const ComprehensivePersonalInfoScreen(
      {super.key,
      this.vehicleType = 'Comprehensive Motor',
      this.isLoggedIn = false,
      this.isAgent = false});
  @override
  State<ComprehensivePersonalInfoScreen> createState() =>
      _ComprehensivePersonalInfoScreenState();
}

class _ComprehensivePersonalInfoScreenState
    extends State<ComprehensivePersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  String? _selectedOccupation;
  final _addressController = TextEditingController();

  String? _selectedState;
  String? _selectedLGA;
  List<Map<String, dynamic>> _lgaList = [];
  bool _isLoadingLgas = false;

  bool get _lockCustomerContactFields => widget.isLoggedIn && !widget.isAgent;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userData = auth.userData;
      if (userData != null) {
        _firstNameController.text = userData['FirstName']?.toString() ?? '';
        _lastNameController.text = userData['LastName']?.toString() ??
            userData['Lastname']?.toString() ??
            userData['Surname']?.toString() ??
            '';
        _emailController.text = userData['Email']?.toString() ?? '';
        _phoneController.text = userData['Phone']?.toString() ??
            userData['PhoneNo']?.toString() ??
            userData['Phoneno']?.toString() ??
            userData['MobileNo']?.toString() ??
            userData['Mobile']?.toString() ??
            userData['PhoneNumber']?.toString() ??
            userData['Telephone']?.toString() ??
            '';
        _occupationController.text = userData['Occupation']?.toString() ?? '';
        _selectedOccupation = _occupationController.text.isNotEmpty
            ? _occupationController.text
            : null;
        _addressController.text = userData['Address']?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchLgas(String stateName) async {
    final stateId = _stateIdMap[stateName];
    if (stateId == null) return;
    setState(() {
      _isLoadingLgas = true;
      _lgaList = [];
      _selectedLGA = null;
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
          _lgaList = lgaList;
          _isLoadingLgas = false;
        });
      } else {
        setState(() => _isLoadingLgas = false);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to load LGAs: ${response.statusCode}')));
      }
    } catch (e) {
      setState(() => _isLoadingLgas = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading LGAs: $e')));
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
        title: Text(widget.vehicleType,
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
                    Text('Step 1 of 5',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Personal information',
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
                                      color: i < 1
                                          ? AppTheme.primaryNavy
                                          : Colors.grey[300],
                                      borderRadius:
                                          BorderRadius.circular(2)))))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        'First Name', _firstNameController, 'enter first name',
                        autofillHints: [AutofillHints.givenName]),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Last Name', _lastNameController, 'enter last name',
                        autofillHints: [AutofillHints.familyName]),
                    const SizedBox(height: 16),
                    _buildTextField('Email Address', _emailController,
                        'enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email],
                        readOnly: _lockCustomerContactFields),
                    const SizedBox(height: 16),
                    _buildTextField('Phone Number', _phoneController,
                        'enter your phone number',
                        keyboardType: TextInputType.phone,
                        autofillHints: [AutofillHints.telephoneNumber],
                        readOnly: _lockCustomerContactFields),
                    const SizedBox(height: 16),
                    Text('Occupation',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    SearchableDropdown(
                      hint: 'select your occupation',
                      value: _selectedOccupation,
                      items: occupations,
                      fontSize: 14,
                      onChanged: (val) => setState(() {
                        _selectedOccupation = val;
                        _occupationController.text = val ?? '';
                      }),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Address', _addressController, 'enter your address',
                        maxLines: 3,
                        autofillHints: [AutofillHints.streetAddressLine1]),
                    const SizedBox(height: 16),
                    Text('State',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    SearchableDropdown(
                      hint: 'select your state',
                      value: _selectedState,
                      items: _nigerianStates,
                      fontSize: 14,
                      onChanged: (val) {
                        setState(() => _selectedState = val);
                        if (val != null) _fetchLgas(val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('LGA',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8)),
                      child: _isLoadingLgas
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: Center(
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))))
                          : SearchableDropdown(
                              hint: _selectedState == null
                                  ? 'select state first'
                                  : 'select your LGA',
                              value: _selectedLGA,
                              items: _lgaList
                                  .map((lga) =>
                                      lga['name']?.toString() ??
                                      lga['lga_name']?.toString() ??
                                      lga['LGA']?.toString() ??
                                      '')
                                  .where((s) => s.isNotEmpty)
                                  .toList(),
                              fontSize: 14,
                              onChanged: (val) =>
                                  setState(() => _selectedLGA = val),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final personalInfo = {
                          'firstName': _firstNameController.text.trim(),
                          'lastName': _lastNameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'occupation': _occupationController.text.trim(),
                          'address': _addressController.text.trim(),
                          'state': _selectedState ?? '',
                          'lga': _selectedLGA ?? '',
                        };
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ComprehensiveVehicleInfoScreen(
                                    vehicleType: widget.vehicleType,
                                    personalInfo: personalInfo,
                                    isLoggedIn: widget.isLoggedIn,
                                    isAgent: widget.isAgent)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('Continue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {TextInputType? keyboardType,
      int maxLines = 1,
      List<String>? autofillHints,
      bool readOnly = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey[300]!;
    final hintColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[400]!;
    final accent = isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autofillHints: autofillHints,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: fieldColor,
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
