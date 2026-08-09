import 'package:flutter/material.dart';
import 'client_summary_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';
import '../widgets/agent_bottom_nav.dart';

class AddCorporateClientScreen extends StatefulWidget {
  const AddCorporateClientScreen({super.key});

  @override
  State<AddCorporateClientScreen> createState() =>
      _AddCorporateClientScreenState();
}

class _AddCorporateClientScreenState extends State<AddCorporateClientScreen> {
  final _cacController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessSectorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _yearOfIncorporationController = TextEditingController();

  bool _isVerifyingCac = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _fieldColor =>
      _isDark ? const Color(0xFF111827) : Colors.grey[100]!;

  Color get _borderColor =>
      _isDark ? const Color(0xFF334155) : Colors.grey[300]!;

  Color get _secondaryTextColor =>
      _isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color get _agentAccent =>
      _isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _secondaryTextColor, fontSize: 14),
      filled: true,
      fillColor: _fieldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _agentAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  @override
  void dispose() {
    _cacController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessSectorController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _yearOfIncorporationController.dispose();
    super.dispose();
  }

  Future<void> _verifyCac() async {
    final cac = _cacController.text.trim();

    // Validate CAC is not empty
    if (cac.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter CAC number')),
      );
      return;
    }

    setState(() {
      _isVerifyingCac = true;
    });

    try {
      final response = await http
          .post(
        Uri.parse('https://eportaltest.rexinsure.com/api/verify/cac'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'IntCode': 'TESTCODE',
          'Password': 'royal1234',
          'business_number': cac,
          'business_country': 'NG',
        }),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      setState(() {
        _isVerifyingCac = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Check if verification was successful
        if (responseData['status'] == 'success' &&
            responseData['data'] != null &&
            responseData['data']['data'] != null &&
            responseData['data']['data']['business_info'] != null) {
          final businessInfo = responseData['data']['data']['business_info'];

          // Populate fields with response data
          setState(() {
            _businessNameController.text =
                businessInfo['company_name']?.toString() ?? '';
            _businessAddressController.text =
                businessInfo['address']?.toString() ?? '';
            _emailController.text =
                businessInfo['email_address']?.toString() ?? '';

            // Format date of registration from ISO format to DD/MM/YYYY
            String dateOfReg =
                businessInfo['date_of_registration']?.toString() ?? '';
            if (dateOfReg.isNotEmpty) {
              try {
                DateTime parsedDate = DateTime.parse(dateOfReg);
                _yearOfIncorporationController.text =
                    '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
              } catch (e) {
                // If parsing fails, leave empty
              }
            }

            // Try to get phone number from persons array if available
            if (businessInfo['persons'] != null &&
                businessInfo['persons'] is List &&
                (businessInfo['persons'] as List).isNotEmpty) {
              final firstPerson = businessInfo['persons'][0];
              if (firstPerson['phoneNumber'] != null &&
                  firstPerson['phoneNumber'].toString().isNotEmpty) {
                _phoneController.text = firstPerson['phoneNumber'].toString();
              }
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('CAC verified successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // No data returned or verification failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No data found. Please enter details manually'),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${ErrorMessages.fromResponse(response, fallback: 'Verification failed')}. Please enter details manually'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isVerifyingCac = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${ErrorMessages.fromException(e, fallback: 'Verification failed')}. Please enter details manually'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add A New Client',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Client information',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _agentAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enter CAC
                  Text(
                    'Enter CAC',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cacController,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter CAC'),
                  ),

                  const SizedBox(height: 16),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifyingCac ? null : _verifyCac,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agentAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor:
                            AppTheme.disabledButtonColor(context),
                        disabledForegroundColor:
                            AppTheme.disabledButtonTextColor(context),
                      ),
                      child: _isVerifyingCac
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: _borderColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _secondaryTextColor,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: _borderColor)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Business Name
                  Text(
                    'Business Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _businessNameController,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('Business name'),
                  ),

                  const SizedBox(height: 16),

                  // Business Address
                  Text(
                    'Business Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _businessAddressController,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter your address'),
                  ),

                  const SizedBox(height: 16),

                  // Business Sector (optional)
                  Text(
                    'Business Sector (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _businessSectorController,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter your occupation'),
                  ),

                  const SizedBox(height: 16),

                  // Phone Number
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('+234902389421'),
                  ),

                  const SizedBox(height: 16),

                  // Email Address
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('example@gmail.com'),
                  ),

                  const SizedBox(height: 16),

                  // Year of Incorporation
                  Text(
                    'Year of Incorporation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _yearOfIncorporationController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _yearOfIncorporationController,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface),
                        decoration: _inputDecoration(
                          'dd/mm/yy',
                          suffixIcon: Icon(Icons.calendar_today_outlined,
                              color: _secondaryTextColor, size: 20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate all required fields (Business Sector is optional)
                        if (_businessNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter business name')),
                          );
                          return;
                        }
                        if (_businessAddressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter business address')),
                          );
                          return;
                        }
                        if (_phoneController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter phone number')),
                          );
                          return;
                        }
                        if (_emailController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter email address')),
                          );
                          return;
                        }
                        if (_yearOfIncorporationController.text
                            .trim()
                            .isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please select year of incorporation')),
                          );
                          return;
                        }

                        // Collect all client data
                        final clientData = {
                          'cac': _cacController.text,
                          'businessName': _businessNameController.text,
                          'businessAddress': _businessAddressController.text,
                          'businessSector': _businessSectorController.text,
                          'phone': _phoneController.text,
                          'email': _emailController.text,
                          'yearOfIncorporation':
                              _yearOfIncorporationController.text,
                        };

                        // Navigate to summary screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientSummaryScreen(
                              clientType: 'corporate',
                              clientData: clientData,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agentAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Buy policy for customer Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to buy policy screen
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _agentAccent,
                        side: BorderSide(color: _agentAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buy policy for customer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // Extra space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildAgentBottomNav(context, currentIndex: 2),
    );
  }
}
