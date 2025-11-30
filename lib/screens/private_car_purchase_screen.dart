import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'vehicle_information_screen.dart';

class PrivateCarPurchaseScreen extends StatefulWidget {
  const PrivateCarPurchaseScreen({super.key});

  @override
  State<PrivateCarPurchaseScreen> createState() =>
      _PrivateCarPurchaseScreenState();
}

class _PrivateCarPurchaseScreenState extends State<PrivateCarPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedState;
  String? _selectedLGA;

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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Private Car',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Step 1 of 3',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Personal information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'First Name*',
                      hint: 'enter first name',
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Last Name*',
                      hint: 'enter last name',
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Email Address*',
                      hint: 'enter your email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Phone Number*',
                      hint: 'enter your phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Occupation',
                      hint: 'enter your occupation',
                      controller: _occupationController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Address*',
                      hint: 'enter your address',
                      controller: _addressController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: 'State*',
                      hint: 'select your state',
                      value: _selectedState,
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: 'LGA*',
                      hint: 'select your LGA',
                      value: _selectedLGA,
                      onChanged: (value) {
                        setState(() {
                          _selectedLGA = value;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VehicleInformationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryNavy),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            items: const [],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
