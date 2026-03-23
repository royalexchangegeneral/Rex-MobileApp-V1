import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';

class NewClaimsScreen extends StatefulWidget {
  const NewClaimsScreen({super.key});
  @override
  State<NewClaimsScreen> createState() => _NewClaimsScreenState();
}

class _NewClaimsScreenState extends State<NewClaimsScreen> {
  int _currentStep = 0;

  // Step 1
  final _policyNoController = TextEditingController();
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

  final List<String> _stepLabels = ['Claim Details', 'Profile Details', 'Incident Details', 'Claim Details'];
  final List<String> _itemCodes = ['IC-001', 'IC-002', 'IC-003', 'IC-004'];

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
      // Submit — show success
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const _ClaimSuccessScreen()));
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _prevStep),
        title: const Text('New Claims', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {})],
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
      floatingActionButton: SizedBox(
        width: 50, height: 50,
        child: FloatingActionButton(onPressed: () {}, backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), child: const Icon(Icons.add, color: Colors.white, size: 24)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
              _navItem(Icons.description_outlined, 'Policies', false, () {}),
              const SizedBox(width: 40),
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
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E2D64))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    suffixIcon: suffix,
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
  );

  // STEP 1: Enter Policy No
  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Enter Policy No.'),
          TextField(controller: _policyNoController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('enter policy number')),
          const Padding(padding: EdgeInsets.only(top: 280)),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Verify', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Policy Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          _label('Claimant Name'),
          TextField(controller: _claimantNameController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('John Doe')),
          const SizedBox(height: 14),
          _label('Phone Number'),
          TextField(controller: _phoneController, style: const TextStyle(color: Colors.black, fontSize: 12), keyboardType: TextInputType.phone, decoration: _inputDeco('+23481234578')),
          const SizedBox(height: 14),
          _label('Contact Address'),
          TextField(controller: _addressController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('24, upheld street, kingsland')),
          const SizedBox(height: 14),
          _label('Email Address'),
          TextField(controller: _emailController, style: const TextStyle(color: Colors.black, fontSize: 12), keyboardType: TextInputType.emailAddress, decoration: _inputDeco('example@gmail.com')),
          const SizedBox(height: 14),
          _label('Product type'),
          TextField(controller: _productTypeController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('Motor')),
          const SizedBox(height: 14),
          _label('Risk Type'),
          TextField(controller: _riskTypeController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('lorem ipsum')),
          const SizedBox(height: 14),
          _label('Select Item Code'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedItemCode, isExpanded: true,
                hint: Text('select item code', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500], size: 20),
                style: const TextStyle(fontSize: 12, color: Colors.black),
                items: _itemCodes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedItemCode = v),
              ),
            ),
          ),
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

  // STEP 3: Incident Details
  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Incident Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          _label('Incident Date'),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
              if (picked != null) setState(() => _incidentDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}');
            },
            child: AbsorbPointer(child: TextField(controller: _incidentDateController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('dd/mm/yyyy', suffix: Icon(Icons.calendar_today_outlined, color: Colors.grey[400], size: 18)))),
          ),
          const SizedBox(height: 14),
          _label('Incident Subject'),
          TextField(controller: _incidentSubjectController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('enter incident subject')),
          const SizedBox(height: 14),
          _label('Time of Incident / Loss'),
          TextField(controller: _incidentTimeController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('enter time of incident')),
          const SizedBox(height: 14),
          _label('Place of Incident / Loss'),
          TextField(controller: _incidentPlaceController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('enter place the incident')),
          const SizedBox(height: 14),
          _label('Describe your Request'),
          TextField(controller: _descriptionController, style: const TextStyle(color: Colors.black, fontSize: 12), maxLines: 3, decoration: _inputDeco('')),
          const SizedBox(height: 14),
          _label('Witness Name'),
          TextField(controller: _witnessNameController, style: const TextStyle(color: Colors.black, fontSize: 12), maxLines: 2, decoration: _inputDeco('')),
          const SizedBox(height: 14),
          _label('Witness Address'),
          TextField(controller: _witnessAddressController, style: const TextStyle(color: Colors.black, fontSize: 12), decoration: _inputDeco('select item code')),
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
      onTap: () async {
        final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1920, imageQuality: 85);
        if (image != null) setState(() => _photos.add(File(image.path)));
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
            Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 24),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contact Information', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
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
          const SizedBox(height: 16),
          // Incident Details
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Incident Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                _summaryRow('Incident Date', _incidentDateController.text),
                _summaryRow('Incident Subject', _incidentSubjectController.text),
                _summaryRow('Incident Time', _incidentTimeController.text),
                _summaryRow('Incident Location', _incidentPlaceController.text),
                _summaryRow('Description', _descriptionController.text),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Attachments
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Attachments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
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
              onPressed: (_confirmAccuracy && _agreePrivacy) ? _nextStep : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2D64), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Continue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Flexible(child: Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black), textAlign: TextAlign.end)),
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
  const _ClaimSuccessScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  child: const Icon(Icons.check, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Your claim has been received\nand is now under review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black, height: 1.4),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.black),
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
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false),
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
