import 'package:flutter/material.dart';
import 'client_summary_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/customer_details.dart';
import '../utils/error_messages.dart';
import '../widgets/agent_bottom_nav.dart';
import '../widgets/searchable_dropdown.dart';

class AddClientScreen extends StatefulWidget {
  final String clientType; // 'individual' or 'corporate'

  const AddClientScreen({super.key, required this.clientType});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  // Controllers
  final _ninController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _lgaController = TextEditingController();

  // Corporate client controllers
  final _cacController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessSectorController = TextEditingController();

  String? _selectedState;
  String? _selectedLga;
  List<Map<String, dynamic>> _lgaList = [];
  bool _isLoadingLgas = false;
  bool _isVerifyingNin = false;

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

  final Map<String, int> _stateIdMap = {
    'Abia': 1,
    'Adamawa': 2,
    'Akwa Ibom': 3,
    'Anambra': 4,
    'Bauchi': 5,
    'Bayelsa': 6,
    'Benue': 7,
    'Borno': 8,
    'Cross River': 9,
    'Delta': 10,
    'Ebonyi': 11,
    'Edo': 12,
    'Ekiti': 13,
    'Enugu': 14,
    'Federal Capital Territory': 15,
    'Gombe': 16,
    'Imo': 17,
    'Jigawa': 18,
    'Kaduna': 19,
    'Kano': 20,
    'Katsina': 21,
    'Kebbi': 22,
    'Kogi': 23,
    'Kwara': 24,
    'Lagos': 25,
    'Nasarawa': 26,
    'Niger': 27,
    'Ogun': 28,
    'Ondo': 29,
    'Osun': 30,
    'Oyo': 31,
    'Plateau': 32,
    'Rivers': 33,
    'Sokoto': 34,
    'Taraba': 35,
    'Yobe': 36,
    'Zamfara': 37,
  };

  final List<String> _nigerianStates = [
    'Select State',
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Federal Capital Territory',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  @override
  void dispose() {
    _ninController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _lgaController.dispose();
    _cacController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessSectorController.dispose();
    super.dispose();
  }

  Future<void> _fetchLgas(String stateName) async {
    final stateId = _stateIdMap[stateName];
    if (stateId == null) return;

    setState(() {
      _isLoadingLgas = true;
      _lgaList = [];
      _selectedLga = null;
    });

    try {
      final response = await http
          .get(
        Uri.parse(
            'https://eportal.rexinsure.com/api/get-lga?state_id=$stateId'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Handle different response formats
        List<Map<String, dynamic>> lgaList = [];
        if (data is List) {
          lgaList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          lgaList = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['lgas'] is List) {
          lgaList = List<Map<String, dynamic>>.from(data['lgas']);
        }

        setState(() {
          _lgaList = lgaList;
          _isLoadingLgas = false;
        });

        if (lgaList.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No LGAs found for this state')),
          );
        }
      } else {
        setState(() {
          _isLoadingLgas = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(ErrorMessages.fromResponse(response,
                    fallback: 'Failed to load LGAs'))),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingLgas = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ErrorMessages.fromException(e,
                  fallback: 'Failed to load LGAs'))),
        );
      }
    }
  }

  Future<void> _verifyNin() async {
    final nin = _ninController.text.trim();

    // Validate NIN length
    if (nin.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIN must be exactly 11 characters')),
      );
      return;
    }

    setState(() {
      _isVerifyingNin = true;
    });

    try {
      final response = await http
          .post(
        Uri.parse('https://eportaltest.rexinsure.com/api/mobile/verify/nin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Intcode': 'TESTCODE',
          'Password': 'royal1234',
          'number': nin,
        }),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      setState(() {
        _isVerifyingNin = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Check if verification was successful
        if (responseData['status'] == 'success' &&
            responseData['data'] != null &&
            responseData['data']['data'] != null &&
            responseData['data']['data']['kyc'] != null &&
            responseData['data']['data']['kyc']['firstname'] != null &&
            (responseData['data']['data']['kyc']['firstname']?.toString() ?? '')
                .isNotEmpty) {
          final kycData = responseData['data']['data']['kyc'];

          // Populate fields with response data
          setState(() {
            _firstNameController.text = kycData['firstname']?.toString() ?? '';
            _lastNameController.text = kycData['surname']?.toString() ?? '';
            _emailController.text = kycData['email']?.toString() ?? '';
            _phoneController.text = kycData['telephoneno']?.toString() ?? '';

            // Format date of birth from DD-MM-YYYY to DD/MM/YYYY
            String dob = kycData['birthdate']?.toString() ?? '';
            if (dob.isNotEmpty) {
              _dobController.text = dob.replaceAll('-', '/');
            }

            _addressController.text =
                kycData['residence_address']?.toString() ?? '';

            // Set state if available
            String residenceState =
                kycData['residence_state']?.toString() ?? '';
            if (residenceState.isNotEmpty &&
                _nigerianStates.contains(residenceState)) {
              _selectedState = residenceState;
              // Fetch LGAs for the state
              _fetchLgas(residenceState);
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NIN verified successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // No data returned or verification failed
          if (mounted) {
            final kycData = responseData['data']?['data']?['kyc'];
            final msg = kycData != null
                ? (kycData['status']?.toString() ?? 'Verification failed')
                : 'No data found. Please enter details manually';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
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
        _isVerifyingNin = false;
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

  // Kept for direct-create fallback if this form is reused without summary.
  // ignore: unused_element
  Future<void> _createCustomer() async {
    try {
      final requestBody = {
        'cust_first_name': _firstNameController.text.trim(),
        'cust_middle_name': '', // Not collected in form
        'cust_last_name': _lastNameController.text.trim(),
        'cust_type':
            widget.clientType == 'individual' ? 'Individual' : 'Corporate',
        'cust_occupation': '', // Not collected in form
        'cust_phone_no': _phoneController.text.trim(),
        'cust_email': _emailController.text.trim(),
        'cust_address': _addressController.text.trim(),
        'cust_town': '', // Not collected in form
        'cust_nationality': 'Nigerian', // Default value
        'cust_state': _selectedState ?? '',
        'cust_lga': _selectedLga ?? '',
        'cust_dob': CustomerDetails.normalizeApiDate(_dobController.text),
        'cust_national_id_name': 'NIN',
        'cust_national_id_no': _ninController.text.trim(),
      };

      debugPrint('=== CREATE CUSTOMER API REQUEST ===');
      debugPrint('URL: https://eportaltest.rexinsure.com/api/createcustomer');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http
          .post(
        Uri.parse('https://eportaltest.rexinsure.com/api/createcustomer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('=== CREATE CUSTOMER API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('===================================');

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer created successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to clients list
          Navigator.pop(context);
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  ErrorMessages.fromDecodedJson(responseData).isNotEmpty
                      ? ErrorMessages.fromDecodedJson(responseData)
                      : 'Failed to create customer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('=== CREATE CUSTOMER API ERROR ===');
      debugPrint('Error: ${e.toString()}');
      debugPrint('=================================');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.fromException(e,
                fallback: 'Failed to create customer')),
            backgroundColor: Colors.red,
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
                  // Enter NIN
                  Text(
                    'Enter NIN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ninController,
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration:
                        _inputDecoration('enter NIN (11 digits)').copyWith(
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifyingNin ? null : _verifyNin,
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
                      child: _isVerifyingNin
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

                  // First Name
                  Text(
                    'First Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstNameController,
                    autofillHints: const [AutofillHints.givenName],
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter first name'),
                  ),

                  const SizedBox(height: 16),

                  // Last Name
                  Text(
                    'Last Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lastNameController,
                    autofillHints: const [AutofillHints.familyName],
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter last name'),
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
                    autofillHints: const [AutofillHints.email],
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter your email address'),
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
                    autofillHints: const [AutofillHints.telephoneNumber],
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter your phone number'),
                  ),

                  const SizedBox(height: 16),

                  // Date of Birth
                  Text(
                    'Date of Birth',
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
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _dobController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dobController,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface),
                        decoration: _inputDecoration(
                          'dd/mm/yyyy',
                          suffixIcon: Icon(Icons.calendar_today_outlined,
                              color: _secondaryTextColor, size: 20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Address
                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    autofillHints: const [AutofillHints.streetAddressLine1],
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: _inputDecoration('enter your address'),
                  ),

                  const SizedBox(height: 16),

                  // State and LGA
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'State',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SearchableDropdown(
                              hint: 'select state',
                              value: _selectedState,
                              items: _nigerianStates
                                  .where((s) => s != 'Select State')
                                  .toList(),
                              fontSize: 14,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedState = newValue;
                                });
                                if (newValue != null) {
                                  _fetchLgas(newValue);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LGA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isLoadingLgas
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: _fieldColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _secondaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Loading...',
                                          style: TextStyle(
                                              color: _secondaryTextColor,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  )
                                : _lgaList.isNotEmpty
                                    ? SearchableDropdown(
                                        hint: 'select LGA',
                                        value: _selectedLga,
                                        items: _lgaList
                                            .map((lga) =>
                                                lga['name']?.toString() ??
                                                lga['lga']?.toString() ??
                                                '')
                                            .where((s) => s.isNotEmpty)
                                            .toList(),
                                        fontSize: 14,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedLga = newValue;
                                          });
                                        },
                                      )
                                    : TextField(
                                        controller: _lgaController,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                        decoration: _inputDecoration(
                                          _selectedState == null
                                              ? 'select state first'
                                              : 'enter LGA',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedLga = value;
                                          });
                                        },
                                      ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate all required fields
                        // Check NIN first (compulsory)
                        if (_ninController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter NIN')),
                          );
                          return;
                        }
                        if (_ninController.text.trim().length != 11) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('NIN must be exactly 11 digits')),
                          );
                          return;
                        }
                        if (_firstNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter first name')),
                          );
                          return;
                        }
                        if (_lastNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter last name')),
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
                        if (_phoneController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter phone number')),
                          );
                          return;
                        }
                        if (_dobController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select date of birth')),
                          );
                          return;
                        }
                        if (_addressController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter address')),
                          );
                          return;
                        }
                        if (_selectedState == null || _selectedState!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select state')),
                          );
                          return;
                        }
                        if (_selectedLga == null || _selectedLga!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select LGA')),
                          );
                          return;
                        }

                        // Collect all client data
                        final clientData = {
                          'nin': _ninController.text,
                          'firstName': _firstNameController.text,
                          'lastName': _lastNameController.text,
                          'email': _emailController.text,
                          'phone': _phoneController.text,
                          'dob': CustomerDetails.normalizeApiDate(
                              _dobController.text),
                          'address': _addressController.text,
                          'state': _selectedState ?? '',
                          'lga': _selectedLga ?? '',
                        };

                        // Navigate to summary screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientSummaryScreen(
                              clientType: widget.clientType,
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
