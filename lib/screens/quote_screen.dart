import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'quote_success_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class QuoteScreen extends StatefulWidget {
  final String insuranceType;
  
  const QuoteScreen({super.key, required this.insuranceType});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _sumInsuredController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userData = auth.userData;
      if (userData != null) {
        final firstName = userData['FirstName']?.toString() ?? '';
        final lastName = userData['LastName']?.toString() ?? '';
        _nameController.text = '$firstName $lastName'.trim();
        _emailController.text = userData['Email']?.toString() ?? '';
        _phoneController.text = userData['Phone']?.toString() ?? userData['PhoneNo']?.toString() ?? userData['Phoneno']?.toString() ?? userData['MobileNo']?.toString() ?? userData['Mobile']?.toString() ?? userData['PhoneNumber']?.toString() ?? userData['Telephone']?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _sumInsuredController.dispose();
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
        title: const Text('Quote', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Show selected product type
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppTheme.primaryNavy, size: 18),
                  const SizedBox(width: 8),
                  Text('Product: ${widget.insuranceType}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.black),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              decoration: InputDecoration(
                hintText: 'enter fullname',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.black),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'enter your email address',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
              decoration: InputDecoration(
                hintText: 'enter your phone number',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Enter sum Insured', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _sumInsuredController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Sum insured is required';
                final num = int.tryParse(v.trim());
                if (num == null || num <= 0) return 'Enter a valid amount';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'enter value between 0 and 1000000',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Get Quote', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
          backgroundColor: AppTheme.accentOrange,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (route) => false);
              }),
              _buildNavItem(Icons.description_outlined, 'Policies', true),
              const SizedBox(width: 40),
              _buildNavItem(Icons.assignment_outlined, 'Claims', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
              }),
              _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final sumInsured = _sumInsuredController.text.trim();

    setState(() => _isLoading = true);

    try {
      final requestBody = {
        'email': email,
        'name': name,
        'phoneNo': phone,
        'productType': widget.insuranceType,
        'sumInsured': int.tryParse(sumInsured) ?? 0,
      };

      print('=== QUOTE API REQUEST ===');
      print('URL: https://eportaltest.rexinsure.com/api/quote-enquiry');
      print('Payload: ${json.encode(requestBody)}');
      print('=========================');

      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/quote-enquiry'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('=== QUOTE API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==========================');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['Status'] == 'Success') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuoteSuccessScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['Message'] ?? 'Request failed'), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey, size: 20),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryNavy : Colors.grey)),
        ],
      ),
    );
  }
}