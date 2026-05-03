import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class EnterNinScreen extends StatefulWidget {
  const EnterNinScreen({super.key});
  @override
  State<EnterNinScreen> createState() => _EnterNinScreenState();
}

class _EnterNinScreenState extends State<EnterNinScreen> {
  final _ninController = TextEditingController();
  bool _hasDocument = false;
  bool _isVerifying = false;
  bool _ninVerified = false;
  Map<String, dynamic>? _kycData;

  @override
  void initState() {
    super.initState();
    _ninController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _verifyNin() async {
    if (_ninController.text.trim().length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NIN must be 11 digits')));
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/verify/nin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'Intcode': 'TESTCODE', 'Password': 'royal1234', 'number': _ninController.text.trim()}),
      ).timeout(const Duration(seconds: 15));
      print('=== NIN VERIFY (Signup): ${response.statusCode} ===');
      print('Body: ${response.body}');
      setState(() => _isVerifying = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data']?['data']?['kyc'] != null && data['data']['data']['kyc']['firstname'] != null && (data['data']['data']['kyc']['firstname']?.toString() ?? '').isNotEmpty) {
          setState(() { _ninVerified = true; _kycData = data['data']['data']['kyc']; });
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NIN verified successfully'), backgroundColor: Colors.green));
        } else {
          setState(() => _ninVerified = false);
          final kyc = data['data']?['data']?['kyc'];
          final msg = kyc != null ? (kyc['status']?.toString() ?? 'Verification failed') : 'NIN not found. You can still continue.';
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _hasDocument = true);
  }

  void _continue() async {
    if (_ninController.text.length == 11 || _hasDocument) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_nin', _ninController.text.trim());
      if (_kycData != null) {
        await prefs.setString('signup_dob', _kycData!['birthdate']?.toString() ?? '');
        await prefs.setString('signup_state', _kycData!['residence_state']?.toString() ?? '');
        await prefs.setString('signup_lga', _kycData!['residence_lga']?.toString() ?? '');
        await prefs.setString('signup_address', _kycData!['residence_address']?.toString() ?? '');
      }
      Navigator.pushNamed(context, '/create-password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('NIN', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 20),
            Text('Enter your NIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 24),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _ninController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'enter your 11-digit NIN', hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorText: _ninController.text.isNotEmpty && _ninController.text.length != 11 ? 'NIN must be exactly 11 digits' : null,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              )),
              const SizedBox(width: 8),
              SizedBox(height: 52, width: 90, child: ElevatedButton(
                onPressed: _ninController.text.length == 11 && !_isVerifying ? _verifyNin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ninVerified ? Colors.green : AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: EdgeInsets.zero,
                ),
                child: _isVerifying
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_ninVerified ? '✓ Verified' : 'Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              )),
            ]),
            // Show verified info
            if (_ninVerified && _kycData != null) ...[
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[200]!)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Verified Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                  SizedBox(height: 8),
                  _infoRow('Name', '${_kycData!['firstname'] ?? ''} ${_kycData!['surname'] ?? ''}'.trim()),
                  _infoRow('Phone', _kycData!['telephoneno']?.toString() ?? '-'),
                  _infoRow('DOB', _kycData!['birthdate']?.toString() ?? '-'),
                  _infoRow('Email', _kycData!['email']?.toString() ?? '-'),
                ])),
            ],
            SizedBox(height: 32),
            Center(child: Text('OR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface))),
            const SizedBox(height: 24),
            Text('Scan or upload a copy of your document', style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDocument,
              child: Container(width: double.infinity, height: 200,
                decoration: BoxDecoration(color: _hasDocument ? Colors.green[50] : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: _hasDocument ? Colors.green : Colors.grey[300]!, width: _hasDocument ? 2 : 1)),
                child: Center(child: _hasDocument
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.check_circle, size: 80, color: Colors.green), const SizedBox(height: 16),
                        const Text('Document Uploaded', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green)), const SizedBox(height: 8),
                        Text('Tap to upload a different document', style: TextStyle(fontSize: 12, color: Colors.grey[600]))])
                    : Stack(children: [
                        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.person_outline, size: 80, color: Colors.grey[300]), const SizedBox(height: 16),
                          Container(width: 200, height: 4, color: Colors.grey[300]), const SizedBox(height: 8),
                          Container(width: 150, height: 4, color: Colors.grey[300]), const SizedBox(height: 8),
                          Container(width: 180, height: 4, color: Colors.grey[300])]),
                        Positioned(bottom: 16, right: 16, child: Container(width: 56, height: 56, decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28)))]))),
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
              onPressed: (_ninController.text.length == 11 || _hasDocument) ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_ninController.text.length == 11 || _hasDocument) ? AppTheme.primaryBlue : Colors.grey[300],
                foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(padding: EdgeInsets.only(bottom: 4),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
      Expanded(child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface))),
    ]));
}
