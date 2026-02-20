import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'comprehensive_vehicle_info_screen.dart';

class ComprehensivePersonalInfoScreen extends StatefulWidget {
  final String vehicleType;
  const ComprehensivePersonalInfoScreen({super.key, this.vehicleType = 'Comprehensive Motor'});
  @override
  State<ComprehensivePersonalInfoScreen> createState() => _ComprehensivePersonalInfoScreenState();
}

class _ComprehensivePersonalInfoScreenState extends State<ComprehensivePersonalInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedState;
  String? _selectedLGA;

  final List<String> _states = ['Lagos', 'Abuja', 'Rivers', 'Kano', 'Oyo', 'Kaduna', 'Enugu', 'Delta', 'Ogun', 'Edo'];
  final Map<String, List<String>> _lgas = {
    'Lagos': ['Kosofe', 'Ikeja', 'Surulere', 'Eti-Osa', 'Alimosho', 'Agege'],
    'Abuja': ['Abaji', 'Bwari', 'Gwagwalada', 'Kuje', 'Kwali', 'Municipal'],
    'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Eleme', 'Oyigbo'],
    'Kano': ['Kano Municipal', 'Fagge', 'Dala', 'Gwale'],
    'Oyo': ['Ibadan North', 'Ibadan South', 'Ogbomoso', 'Oyo East'],
    'Kaduna': ['Kaduna North', 'Kaduna South', 'Zaria', 'Chikun'],
    'Enugu': ['Enugu East', 'Enugu North', 'Enugu South', 'Nsukka'],
    'Delta': ['Warri', 'Asaba', 'Ughelli', 'Sapele'],
    'Ogun': ['Abeokuta', 'Ijebu Ode', 'Sagamu', 'Ota'],
    'Edo': ['Benin City', 'Ekpoma', 'Auchi', 'Uromi'],
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicleType, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text('Step 1 of 5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  Spacer(),
                  Text('Personal information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                ]),
                const SizedBox(height: 12),
                Row(children: List.generate(5, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 4 ? 4 : 0), decoration: BoxDecoration(color: i < 1 ? AppTheme.primaryNavy : Colors.grey[300], borderRadius: BorderRadius.circular(2)))))),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('First Name', _firstNameController, 'enter first name'),
                  const SizedBox(height: 16),
                  _buildTextField('Last Name', _lastNameController, 'enter last name'),
                  const SizedBox(height: 16),
                  _buildTextField('Email Address', _emailController, 'enter your email address', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField('Phone Number', _phoneController, 'enter your phone number', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField('Occupation', _occupationController, 'enter your occupation'),
                  const SizedBox(height: 16),
                  _buildTextField('Address', _addressController, 'enter your address', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildDropdown('State', _selectedState, _states, (val) => setState(() { _selectedState = val; _selectedLGA = null; })),
                  const SizedBox(height: 16),
                  _buildDropdown('LGA', _selectedLGA, _selectedState != null ? _lgas[_selectedState] ?? [] : [], (val) => setState(() => _selectedLGA = val)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ComprehensiveVehicleInfoScreen(vehicleType: widget.vehicleType))),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType? keyboardType, int maxLines = 1, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: isDropdown ? Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            hint: Text('select your ${label.toLowerCase()}', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
