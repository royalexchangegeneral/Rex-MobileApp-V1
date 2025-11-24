import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class EnterDriversLicenseScreen extends StatefulWidget {
  const EnterDriversLicenseScreen({super.key});

  @override
  State<EnterDriversLicenseScreen> createState() => _EnterDriversLicenseScreenState();
}

class _EnterDriversLicenseScreenState extends State<EnterDriversLicenseScreen> {
  final _licenseController = TextEditingController();
  bool _hasDocument = false;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _hasDocument = true;
      });
    }
  }

  void _continue() {
    if (_licenseController.text.isNotEmpty || _hasDocument) {
      Navigator.pushNamed(context, '/create-password');
    }
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
          "Driver's License",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              const Text(
                "Enter your Driver's License Number",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _licenseController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "enter your driver's license number",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              
              const SizedBox(height: 32),
              
              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Scan or upload a copy of your document',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _pickDocument,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: 200,
                              height: 4,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 150,
                              height: 4,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 180,
                              height: 4,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_licenseController.text.isNotEmpty || _hasDocument) ? _continue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_licenseController.text.isNotEmpty || _hasDocument)
                  ? AppTheme.primaryBlue
                  : Colors.grey[300],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
