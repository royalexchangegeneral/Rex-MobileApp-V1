import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'vehicle_information_screen.dart';
import 'comprehensive_personal_info_screen.dart';

class PrivateCarPurchaseScreen extends StatefulWidget {
  final String vehicleType;
  final String price;
  
  const PrivateCarPurchaseScreen({
    super.key,
    this.vehicleType = 'Private Car',
    this.price = 'N15,000',
  });

  @override
  State<PrivateCarPurchaseScreen> createState() => _PrivateCarPurchaseScreenState();
}

class _PrivateCarPurchaseScreenState extends State<PrivateCarPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedState;
  String? _selectedLGA;
  List<Map<String, dynamic>> _lgaList = [];
  bool _isLoadingLgas = false;

  final Map<String, int> _stateIdMap = {
    'Abia': 1, 'Adamawa': 2, 'Akwa Ibom': 3, 'Anambra': 4, 'Bauchi': 5,
    'Bayelsa': 6, 'Benue': 7, 'Borno': 8, 'Cross River': 9, 'Delta': 10,
    'Ebonyi': 11, 'Edo': 12, 'Ekiti': 13, 'Enugu': 14, 'Federal Capital Territory': 15,
    'Gombe': 16, 'Imo': 17, 'Jigawa': 18, 'Kaduna': 19, 'Kano': 20,
    'Katsina': 21, 'Kebbi': 22, 'Kogi': 23, 'Kwara': 24, 'Lagos': 25,
    'Nasarawa': 26, 'Niger': 27, 'Ogun': 28, 'Ondo': 29, 'Osun': 30,
    'Oyo': 31, 'Plateau': 32, 'Rivers': 33, 'Sokoto': 34, 'Taraba': 35,
    'Yobe': 36, 'Zamfara': 37,
  };

  final List<String> _nigerianStates = const [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
    'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu',
    'Federal Capital Territory', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano',
    'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun',
    'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userData = auth.userData;
      if (userData != null) {
        print('=== USER DATA KEYS ===');
        userData.forEach((key, value) => print('  $key: $value'));
        print('======================');
        _firstNameController.text = userData['FirstName']?.toString() ?? '';
        _lastNameController.text = userData['LastName']?.toString() ?? userData['Lastname']?.toString() ?? userData['Surname']?.toString() ?? '';
        _emailController.text = userData['Email']?.toString() ?? '';
        _phoneController.text = userData['Phone']?.toString() ?? userData['PhoneNo']?.toString() ?? userData['Phoneno']?.toString() ?? userData['MobileNo']?.toString() ?? userData['Mobile']?.toString() ?? userData['PhoneNumber']?.toString() ?? userData['Telephone']?.toString() ?? '';
        _occupationController.text = userData['Occupation']?.toString() ?? '';
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

    setState(() { _isLoadingLgas = true; _lgaList = []; _selectedLGA = null; });

    try {
      final response = await http.get(
        Uri.parse('https://eportal.rexinsure.com/api/get-lga?state_id=$stateId'),
      ).timeout(const Duration(seconds: 10));

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
        setState(() { _lgaList = lgaList; _isLoadingLgas = false; });
      } else {
        setState(() => _isLoadingLgas = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load LGAs: ${response.statusCode}')));
      }
    } catch (e) {
      setState(() => _isLoadingLgas = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading LGAs: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicleType, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('Step 1 of 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Personal information', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: List.generate(3, (i) => Expanded(child: Container(
                    height: 3, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    decoration: BoxDecoration(color: i == 0 ? AppTheme.primaryNavy : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  )))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('First Name*', 'enter first name', _firstNameController),
                    const SizedBox(height: 14),
                    _buildTextField('Last Name*', 'enter last name', _lastNameController),
                    const SizedBox(height: 14),
                    _buildTextField('Email Address*', 'enter your email address', _emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildTextField('Phone Number*', 'enter your phone number', _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),
                    _buildTextField('Occupation', 'enter your occupation', _occupationController),
                    const SizedBox(height: 14),
                    _buildTextField('Address*', 'enter your address', _addressController, maxLines: 3),
                    const SizedBox(height: 14),
                    _buildLabel('State*'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[400]!, width: 1.5)),
                      child: DropdownButtonFormField<String>(
                        value: _selectedState,
                        hint: Text('select your state', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        style: const TextStyle(color: Colors.black, fontSize: 13),
                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                        validator: (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
                        items: _nigerianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) { setState(() => _selectedState = val); if (val != null) _fetchLgas(val); },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('LGA*'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[400]!, width: 1.5)),
                      child: _isLoadingLgas
                          ? const Padding(padding: EdgeInsets.all(14), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
                          : DropdownButtonFormField<String>(
                              value: _selectedLGA,
                              hint: Text(_selectedState == null ? 'select state first' : 'select your LGA', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                              style: const TextStyle(color: Colors.black, fontSize: 13),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                              validator: (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
                              items: _lgaList.map((lga) {
                                final name = lga['name']?.toString() ?? lga['lga_name']?.toString() ?? lga['LGA']?.toString() ?? '';
                                return DropdownMenuItem(value: name, child: Text(name));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedLGA = val),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 32 + MediaQuery.of(context).padding.bottom),
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
                      if (widget.vehicleType.toLowerCase().contains('comprehensive')) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ComprehensivePersonalInfoScreen(vehicleType: widget.vehicleType)));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleInformationScreen(vehicleType: widget.vehicleType, price: widget.price, personalInfo: personalInfo)));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87));
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    final isRequired = label.contains('*');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller, keyboardType: keyboardType, maxLines: maxLines,
          style: const TextStyle(color: Colors.black, fontSize: 13),
          validator: isRequired ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null : null,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
