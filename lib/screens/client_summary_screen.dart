import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/agent_policy_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';
import '../widgets/agent_bottom_nav.dart';
import 'clients_list_screen.dart';

class ClientSummaryScreen extends StatefulWidget {
  final String clientType;
  final Map<String, String> clientData;

  const ClientSummaryScreen({
    super.key,
    required this.clientType,
    required this.clientData,
  });

  @override
  State<ClientSummaryScreen> createState() => _ClientSummaryScreenState();
}

class _ClientSummaryScreenState extends State<ClientSummaryScreen> {
  bool _isCreating = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardColor => _isDark ? const Color(0xFF111827) : Colors.grey[100]!;

  Color get _borderColor =>
      _isDark ? const Color(0xFF334155) : Colors.grey[300]!;

  Color get _secondaryTextColor =>
      _isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color get _agentAccent =>
      _isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

  String _convertDateFormat(String dateStr) {
    // Convert DD/MM/YYYY to YYYY-MM-DD
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
      return dateStr; // Return as-is if format is unexpected
    } catch (e) {
      return dateStr; // Return as-is if parsing fails
    }
  }

  Future<void> _createCustomer() async {
    setState(() {
      _isCreating = true;
    });

    try {
      // Convert DOB from DD/MM/YYYY to YYYY-MM-DD
      final dobFormatted = _convertDateFormat(widget.clientData['dob'] ?? '');
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final agentCode = auth.userCode?.toString() ??
          auth.userData?['Usercode']?.toString() ??
          '';

      final requestBody = {
        'cust_first_name': widget.clientType == 'corporate'
            ? (widget.clientData['businessName'] ?? '')
            : (widget.clientData['firstName'] ?? ''),
        'cust_middle_name': '.',
        'cust_last_name': widget.clientType == 'corporate'
            ? '.'
            : (widget.clientData['lastName'] ?? ''),
        'cust_type':
            widget.clientType == 'individual' ? 'Individual' : 'Corporate',
        'cust_occupation': 'Business',
        'cust_phone_no': widget.clientData['phone'] ?? '',
        'cust_email': widget.clientData['email'] ?? '',
        'cust_address': widget.clientType == 'corporate'
            ? (widget.clientData['businessAddress'] ?? '.')
            : (widget.clientData['address'] ?? '.'),
        'cust_town': '.',
        'cust_nationality': 'Nigerian',
        'cust_state': widget.clientData['state'] ?? 'Lagos',
        'cust_lga': widget.clientData['lga'] ?? 'Ikeja',
        'cust_dob': dobFormatted.isNotEmpty ? dobFormatted : '1990-01-01',
        'cust_national_id_name':
            widget.clientType == 'corporate' ? 'CAC' : 'NIN',
        'cust_national_id_no': widget.clientType == 'corporate'
            ? (widget.clientData['cac'] ?? '')
            : (widget.clientData['nin'] ?? ''),
        'cust_agent': agentCode,
      };

      debugPrint('=== CREATE CUSTOMER API REQUEST ===');
      debugPrint('URL: https://eportal.rexinsure.com/api/createcustomer');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http
          .post(
        Uri.parse('https://eportal.rexinsure.com/api/createcustomer'),
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

      setState(() {
        _isCreating = false;
      });

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer created successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh the customer list
          if (mounted) {
            Provider.of<AgentPolicyProvider>(context, listen: false)
                .fetchAgentPolicies(context);
            Provider.of<AgentPolicyProvider>(context, listen: false)
                .fetchCustomerCount(context);
          }

          // Navigate to clients list screen
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ClientsListScreen()),
              (route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMessages.fromResponse(response,
                  fallback: 'Failed to create customer')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('=== CREATE CUSTOMER API ERROR ===');
      debugPrint('Error: ${e.toString()}');
      debugPrint('=================================');

      setState(() {
        _isCreating = false;
      });

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
                      'Step 2 of 2',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Summary',
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
                          color: _agentAccent,
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
                  // Client Information Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Client Information Fields - Different for individual vs corporate
                        if (widget.clientType == 'corporate') ...[
                          _buildInfoRow('Business Name',
                              widget.clientData['businessName'] ?? ''),
                          _buildInfoRow('Address',
                              widget.clientData['businessAddress'] ?? ''),
                          _buildInfoRow('Business Sector',
                              widget.clientData['businessSector'] ?? ''),
                          _buildInfoRow(
                              'Phone Number', widget.clientData['phone'] ?? ''),
                          _buildInfoRow(
                              'Email', widget.clientData['email'] ?? ''),
                          _buildInfoRow('Year of Incorp.',
                              widget.clientData['yearOfIncorporation'] ?? '',
                              isLast: true),
                        ] else ...[
                          _buildInfoRow('First Name',
                              widget.clientData['firstName'] ?? ''),
                          _buildInfoRow(
                              'Last Name', widget.clientData['lastName'] ?? ''),
                          _buildInfoRow(
                              'Email', widget.clientData['email'] ?? ''),
                          _buildInfoRow(
                              'Phone Number', widget.clientData['phone'] ?? ''),
                          _buildInfoRow(
                              'State', widget.clientData['state'] ?? ''),
                          _buildInfoRow('LGA', widget.clientData['lga'] ?? ''),
                          _buildInfoRow(
                              'Address', widget.clientData['address'] ?? '',
                              isLast: true),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Add User Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createCustomer,
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
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Add User',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _agentAccent,
                        side: BorderSide(color: _agentAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
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

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _secondaryTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
