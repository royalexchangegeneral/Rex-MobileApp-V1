import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import 'private_motor_details_screen.dart';

class VehicleInformationScreen extends StatefulWidget {
  final String vehicleType;
  final String price;
  final Map<String, String> personalInfo;
  
  const VehicleInformationScreen({
    super.key,
    this.vehicleType = 'Private Car',
    this.price = 'N15,000',
    this.personalInfo = const {},
  });

  @override
  State<VehicleInformationScreen> createState() => _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  final _regNumberController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  Map<String, dynamic>? _vehicleData;

  @override
  void dispose() {
    _regNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final regNo = _regNumberController.text.trim();
    if (regNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a registration number')),
      );
      return;
    }

    setState(() { _isVerifying = true; _isVerified = false; _vehicleData = null; });

    try {
      final requestBody = {
        'Intcode': 'Testcode',
        'Password': 'royal1234',
        'RegNo': regNo,
      };

      print('=== VEHICLE VERIFICATION REQUEST ===');
      print('URL: https://eportaltest.rexinsure.com/api/vehicleVerification');
      print('Payload: ${json.encode(requestBody)}');
      print('====================================');

      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/vehicleVerification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('=== VEHICLE VERIFICATION RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=====================================');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'Successful' && data['data'] != null && (data['data'] as List).isNotEmpty) {
          setState(() {
            _isVerifying = false;
            _isVerified = true;
            _vehicleData = Map<String, dynamic>.from(data['data'][0]);
          });

          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PrivateMotorDetailsScreen(
              vehicleType: widget.vehicleType,
              price: widget.price,
              personalInfo: widget.personalInfo,
              vehicleData: _vehicleData!,
            )));
          }
        } else {
          setState(() { _isVerifying = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']?.toString() ?? 'Vehicle not found'), backgroundColor: Colors.red),
          );
        }
      } else {
        setState(() { _isVerifying = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isVerifying = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                    Text('Step 2 of 3', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Vehicle Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: List.generate(3, (i) => Expanded(child: Container(
                    height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    decoration: BoxDecoration(color: i < 2 ? AppTheme.primaryNavy : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  )))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reg Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _regNumberController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'enter your reg. no.',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying || _isVerified ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVerified ? Colors.green : AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: _isVerifying ? AppTheme.primaryNavy.withValues(alpha: 0.7) : Colors.green,
                        disabledForegroundColor: Colors.white,
                      ),
                      child: _isVerifying
                          ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                              SizedBox(width: 12),
                              Text('Verifying RegNo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ])
                          : _isVerified
                              ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Registration No Verified', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ])
                              : const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
}
