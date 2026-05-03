import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
import '../providers/auth_provider.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'agent_dashboard_screen.dart';

class NewClaimsScreen extends StatefulWidget {
  final String? policyNumber;
  final bool isAgentFlow;
  const NewClaimsScreen({super.key, this.policyNumber, this.isAgentFlow = false});
  @override
  State<NewClaimsScreen> createState() => _NewClaimsScreenState();
}

class _NewClaimsScreenState extends State<NewClaimsScreen> {
  int _currentStep = 0;

  // Step 1
  final _policyNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.policyNumber != null) _policyNoController.text = widget.policyNumber!;
  }
  // Step 2
  final _claimantNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _riskTypeController = TextEditingController();
  String? _selectedItemCode;
  // Step 3
  final _incidentDateController = TextEditingController();
  final _incidentSubjectController = TextEditingController();
  final _incidentTimeController = TextEditingController();
  final _incidentPlaceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _witnessNameController = TextEditingController();
  final _witnessAddressController = TextEditingController();
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  // Step 4
  bool _confirmAccuracy = false;
  bool _agreePrivacy = false;
  bool _verifying = false;
  bool _submitting = false;

  final List<String> _stepLabels = ['Claim Details', 'Profile Details', 'Incident Details', 'Claim Details'];
  List<String> _itemCodes = [];

  @override
  void dispose() {
    _policyNoController.dispose();
    _claimantNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _productTypeController.dispose();
    _riskTypeController.dispose();
    _incidentDateController.dispose();
    _incidentSubjectController.dispose();
    _incidentTimeController.dispose();
    _incidentPlaceController.dispose();
    _descriptionController.dispose();
    _witnessNameController.dispose();
    _witnessAddressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitClaim();
    }
  }

  Future<void> _submitClaim() async {
    setState(() => _submitting = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userData = auth.userData;
      final userName = '${userData?['FirstName'] ?? ''} ${userData?['LastName'] ?? userData?['Lastname'] ?? ''}'.trim();

      final request = http.MultipartRequest('POST', Uri.parse('https://eportaltest.rexinsure.com/api/claim_notification'));
      request.headers['Accept'] = 'application/json';

      request.fields['Address'] = _addressController.text;
      request.fields['Email'] = _emailController.text;
      request.fields['MobileNo'] = _phoneController.text;
      request.fields['LossDate'] = _incidentDateController.text;
      request.fields['Subject'] = _incidentSubjectController.text;
      request.fields['Description'] = _descriptionController.text;
      request.fields['PolicyNo'] = _policyNoController.text;
      request.fields['Insured'] = _claimantNameController.text.isNotEmpty ? _claimantNameController.text : userName;
      request.fields['ProductClass'] = _productTypeController.text;
      request.fields['ProductCover'] = _riskTypeController.text;
      request.fields['Claimant'] = _claimantNameController.text.isNotEmpty ? _claimantNameController.text : userName;

      for (final photo in _photos) {
        request.files.add(await http.MultipartFile.fromPath('Files[]', photo.path));
      }

      print('=== CLAIM SUBMISSION ===');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length}');

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);

      print('=== CLAIM RESPONSE: ${response.statusCode} ===');
      print('Body: ${response.body}');

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _ClaimSuccessScreen(isAgentFlow: widget.isAgentFlow)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit claim: ${response.statusCode}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      print('Claim submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _verifyPolicy() async {
    final policyNo = _policyNoController.text.trim();
    if (policyNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a policy number'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _verifying = true);
    try {
      final url = 'https://eportaltest.rexinsure.com/api/getpolicy?IntCode=TESTCODE&Password=royal1234&PolicyNo=$policyNo';
      print('=== VERIFY POLICY: $url ===');
      final r = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 15));
      print('=== POLICY RESPONSE: ${r.statusCode} ===');
      print('Body: ${r.body}');

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        // Response: {"Status":"success","Data":[{Insured, PolicyNo, ProductClass, ProductCover, items:[{item_code}]}]}
        Map<String, dynamic> pd = {};
        if (d is Map) {
          // Data is capital D, and it's a List
          if (d['Data'] is List && (d['Data'] as List).isNotEmpty) {
            pd = Map<String, dynamic>.from((d['Data'] as List).first);
          } else if (d['data'] is List && (d['data'] as List).isNotEmpty) {
            pd = Map<String, dynamic>.from((d['data'] as List).first);
          } else if (d['Data'] is Map) {
            pd = Map<String, dynamic>.from(d['Data']);
          } else if (d['data'] is Map) {
            pd = Map<String, dynamic>.from(d['data']);
          } else {
            pd = Map<String, dynamic>.from(d);
          }
        }

        print('=== POLICY KEYS: ${pd.keys.toList()} ===');
        print('=== Insured: ${pd['Insured']}, ProductClass: ${pd['ProductClass']}, ProductCover: ${pd['ProductCover']} ===');

        _claimantNameController.text = (pd['Insured'] ?? '').toString();
        _emailController.text = (pd['Email'] ?? pd['email'] ?? '').toString();
        _phoneController.text = (pd['MobileNo'] ?? pd['Phone'] ?? pd['PhoneNumber'] ?? '').toString();
        _addressController.text = (pd['Address'] ?? pd['address'] ?? '').toString();
        _productTypeController.text = (pd['ProductClass'] ?? '').toString();
        _riskTypeController.text = (pd['ProductCover'] ?? '').toString();

        // Extract item codes from items array: [{item_code: "AGL355BT", desc: "Motor Insurance", ...}]
        final items = <String>[];
        if (pd['items'] is List) {
          for (final item in pd['items']) {
            if (item is Map) {
              final code = item['item_code']?.toString() ?? '';
              final desc = item['desc']?.toString() ?? '';
              if (code.isNotEmpty) items.add(code);
            }
          }
        }
        if (items.isNotEmpty) {
          _itemCodes = items;
          _selectedItemCode = items.first;
        }
        print('=== ITEM CODES: $_itemCodes ===');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Policy verified successfully'), backgroundColor: Colors.green));
          setState(() => _currentStep = 1);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Policy not found: ${r.statusCode}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      print('Verify policy error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error verifying policy: $e'), backgroundColor: Colors.red));
    }
    setState(() => _verifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: _prevStep),
        title: Text('New Claims', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Step ${_currentStep + 1} of 4', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E2D64))),
                    Text(_stepLabels[_currentStep], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (i) => Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentStep ? const Color(0xFF1E2D64) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4()],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAgentFlow ? null : SizedBox(
        width: 60, height: 60,
        child: FloatingActionButton(onPressed: () {}, backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), elevation: 1, child: const Icon(Icons.add, color: Colors.white, size: 30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.isAgentFlow ? buildAgentBottomNav(context, currentIndex: 1) : BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin: 4,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
              _navItem(Icons.description_outlined, 'Policies', false, () {}),
              const SizedBox(width: 48),
              _navItem(Icons.assignment_outlined, 'Claims', true, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
              _navItem(Icons.person_outline, 'Profile', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, {Widget? suffix}) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
    filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E2D64))),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    suffixIcon: suffix,
  );

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
  );

  // STEP 1: Enter Policy No
  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Enter Policy No.'),
          TextField(controller: _policyNoController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('enter policy number')),
          const Padding(padding: EdgeInsets.only(top: 280)),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _verifying ? null : _verifyPolicy,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: _verifying
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Verify', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 46,
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1E2D64)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E2D64))),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Profile Details
  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Policy Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 16),
          _label('Claimant Name'),
          TextField(controller: _claimantNameController, autofillHints: const [AutofillHints.name], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('John Doe')),
          SizedBox(height: 14),
          _label('Phone Number'),
          TextField(controller: _phoneController, autofillHints: const [AutofillHints.telephoneNumber], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), keyboardType: TextInputType.phone, decoration: _inputDeco('+23481234578')),
          SizedBox(height: 14),
          _label('Contact Address'),
          TextField(controller: _addressController, autofillHints: const [AutofillHints.streetAddressLine1], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('24, upheld street, kingsland')),
          SizedBox(height: 14),
          _label('Email Address'),
          TextField(controller: _emailController, autofillHints: const [AutofillHints.email], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), keyboardType: TextInputType.emailAddress, decoration: _inputDeco('example@gmail.com')),
          SizedBox(height: 14),
          _label('Product type'),
          TextField(controller: _productTypeController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('Motor')),
          SizedBox(height: 14),
          _label('Risk Type'),
          TextField(controller: _riskTypeController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('lorem ipsum')),
          const SizedBox(height: 14),
          _label('Select Item Code'),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedItemCode, isExpanded: true,
                hint: Text('select item code', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500], size: 20),
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                items: _itemCodes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedItemCode = v),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: () {
                if (_claimantNameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty || _emailController.text.isEmpty || _productTypeController.text.isEmpty || _riskTypeController.text.isEmpty || _selectedItemCode == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are compulsory'), backgroundColor: Colors.red));
                  return;
                }
                _nextStep();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Continue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // STEP 3: Incident Details
  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Incident Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 16),
          _label('Incident Date'),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
              if (picked != null) setState(() => _incidentDateController.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}');
            },
            child: AbsorbPointer(child: TextField(controller: _incidentDateController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('dd-mm-yyyy', suffix: Icon(Icons.calendar_today_outlined, color: Colors.grey[400], size: 18)))),
          ),
          SizedBox(height: 14),
          _label('Incident Subject'),
          TextField(controller: _incidentSubjectController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('enter incident subject')),
          SizedBox(height: 14),
          _label('Time of Incident / Loss'),
          TextField(controller: _incidentTimeController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('enter time of incident')),
          SizedBox(height: 14),
          _label('Place of Incident / Loss'),
          TextField(controller: _incidentPlaceController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('enter place the incident')),
          SizedBox(height: 14),
          _label('Describe your Request'),
          TextField(controller: _descriptionController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), maxLines: 3, decoration: _inputDeco('')),
          SizedBox(height: 14),
          _label('Witness Name'),
          TextField(controller: _witnessNameController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), maxLines: 2, decoration: _inputDeco('')),
          SizedBox(height: 14),
          _label('Witness Address'),
          TextField(controller: _witnessAddressController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12), decoration: _inputDeco('select item code')),
          const SizedBox(height: 18),
          _label('Upload Supporting Document'),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ..._photos.map((f) => _buildPhotoTile(f)),
              if (_photos.length < 5) _buildPhotoBox(),
              if (_photos.length < 5 && _photos.isEmpty) _buildPhotoBox(),
            ],
          ),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._photos.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: Colors.grey[500], size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(f.path.split('/').last, style: TextStyle(fontSize: 10, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
                  GestureDetector(
                    onTap: () => setState(() => _photos.remove(f)),
                    child: const Icon(Icons.close, color: Colors.red, size: 16),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 6),
          Text('Upload up to 5 photos (Max 5MB each)', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Continue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(File photo) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(photo, width: 120, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _photos.remove(photo)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoBox() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (ctx) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1E2D64)),
                title: const Text('Take Photo', style: TextStyle(fontSize: 14)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1920, imageQuality: 85);
                    if (image != null) setState(() => _photos.add(File(image.path)));
                  } catch (e) { print('Camera error: $e'); }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1E2D64)),
                title: const Text('Choose from Gallery', style: TextStyle(fontSize: 14)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
                    if (image != null) setState(() => _photos.add(File(image.path)));
                  } catch (e) { print('Gallery error: $e'); }
                },
              ),
              const SizedBox(height: 12),
            ]),
          ),
        );
      },
      child: Container(
        width: 120, height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 24),
            const SizedBox(height: 4),
            Text('Add Photo', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  // STEP 4: Review & Confirm
  Widget _buildStep4() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact Information', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                _summaryRow('Claimant Name', _claimantNameController.text),
                _summaryRow('Phone Number', _phoneController.text),
                _summaryRow('Contact Number', _phoneController.text),
                _summaryRow('Email Address', _emailController.text),
                _summaryRow('Product Type', _productTypeController.text),
                _summaryRow('Risk Type', _riskTypeController.text),
                _summaryRow('Item Code', _selectedItemCode ?? ''),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Incident Details
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Incident Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                _summaryRow('Incident Date', _incidentDateController.text),
                _summaryRow('Incident Subject', _incidentSubjectController.text),
                _summaryRow('Incident Time', _incidentTimeController.text),
                _summaryRow('Incident Location', _incidentPlaceController.text),
                _summaryRow('Description', _descriptionController.text),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Attachments
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attachments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                if (_photos.isEmpty)
                  Text('No attachments', style: TextStyle(fontSize: 11, color: Colors.grey[500]))
                else
                  ..._photos.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _attachmentRow(f.path.split('/').last),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Checkboxes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 24, height: 24, child: Checkbox(value: _confirmAccuracy, onChanged: (v) => setState(() => _confirmAccuracy = v!), activeColor: const Color(0xFF1E2D64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
              const SizedBox(width: 8),
              const Expanded(child: Text('I confirm that all information provided is accurate and complete. I understand that providing false information may result in denial of my claim', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 24, height: 24, child: Checkbox(value: _agreePrivacy, onChanged: (v) => setState(() => _agreePrivacy = v!), activeColor: const Color(0xFF1E2D64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
              const SizedBox(width: 8),
              const Expanded(child: Text('I agree to the processing of my personal data in accordance with the Privacy Policy and Terms of Service', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: (_confirmAccuracy && _agreePrivacy && !_submitting) ? _nextStep : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Claim', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Flexible(child: Text(value.isNotEmpty ? value : '-', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _attachmentRow(String name) {
    return Row(
      children: [
        Icon(Icons.image_outlined, color: Colors.grey[500], size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(name, style: TextStyle(fontSize: 11, color: Colors.grey[700]))),
        const Icon(Icons.check, color: Colors.green, size: 18),
      ],
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
      ]),
    );
  }
}

// Success Screen
class _ClaimSuccessScreen extends StatelessWidget {
  final bool isAgentFlow;
  const _ClaimSuccessScreen({this.isAgentFlow = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Check icon
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2D64),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1E2D64).withValues(alpha: 0.3), width: 8),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 44),
                ),
                SizedBox(height: 28),
                Text(
                  'Your claim has been received\nand is now under review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, height: 1.4),
                ),
                SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      TextSpan(text: 'Claim Number: '),
                      TextSpan(text: '#CLM-203874', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text('Thank you for trusting us, your coverage\nbegins immediately', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4)),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity, height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => isAgentFlow ? const AgentDashboardScreen() : const CustomerDashboardScreen()), (r) => false),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: const Text('Homepage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen())),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1E2D64)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Track Claim', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E2D64))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
