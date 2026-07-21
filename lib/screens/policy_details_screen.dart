import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../utils/app_theme.dart';
import '../utils/renewal_guard.dart';
import '../utils/theme_helper.dart';
import '../widgets/agent_bottom_nav.dart';
import 'new_claims_screen.dart';
import 'help_support_screen.dart';
import 'service_request_screen.dart';
import 'policy_renewal_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class PolicyDetailsScreen extends StatelessWidget {
  final String policyType;
  final String policyNumber;
  final Map<String, dynamic>? policyData;
  final bool isAgentFlow;

  const PolicyDetailsScreen({
    super.key,
    required this.policyType,
    required this.policyNumber,
    this.policyData,
    this.isAgentFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = policyData;
    final status = data?['status']?.toString() ?? 'Unknown';
    final isActive = status == 'Active';
    final startDate = data?['startDate']?.toString() ?? '';
    final endDate = data?['endDate']?.toString() ?? '';
    final policyClass = data?['policyClass']?.toString() ?? policyType;
    final policyId = data?['policyNo']?.toString() ??
        data?['PolicyNo']?.toString() ??
        data?['policyId']?.toString() ??
        policyNumber;
    final premium = data?['premium']?.toString() ?? '';
    final insured = data?['insured']?.toString() ?? '';
    final sumInsured = data?['sumInsured']?.toString() ?? '';
    final customerName = data?['customerName']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Policy Details',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(_getPolicyIcon(policyClass),
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(policyClass,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text('Policy #$policyId',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(startDate,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(endDate,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                    child: _buildQuickAction(
                        context,
                        Icons.refresh,
                        'Renew Policy',
                        const Color(0xFFE8F4FD),
                        const Color(0xFF4A90D9), onTap: () {
                  if (!RenewalGuard.canRenew(policyData)) {
                    RenewalGuard.showNotRenewableDialog(context);
                    return;
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PolicyRenewalScreen(
                              policyType: policyType,
                              policyNumber: policyNumber,
                              premium: policyData?['premium']?.toString() ??
                                  policyData?['Premium']?.toString() ??
                                  '0',
                              isAgentFlow: isAgentFlow,
                              policyData: policyData)));
                })),
                Expanded(
                    child: _buildQuickAction(
                        context,
                        Icons.edit_document,
                        'Update Policy',
                        const Color(0xFFFFF5E6),
                        const Color(0xFFFFB74D),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ServiceRequestScreen(
                                    isAgentFlow: isAgentFlow))))),
                Expanded(
                    child: _buildQuickAction(
                        context,
                        Icons.assignment,
                        'File Claim',
                        const Color(0xFFF3E8FF),
                        const Color(0xFF9C27B0),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => NewClaimsScreen(
                                    policyNumber: policyNumber,
                                    isAgentFlow: isAgentFlow))))),
                Expanded(
                    child: _buildQuickAction(
                        context,
                        Icons.headset_mic,
                        'Support',
                        const Color(0xFFE8F4FD),
                        const Color(0xFF4A90D9),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HelpSupportScreen(
                                    isAgentFlow: isAgentFlow))))),
              ],
            ),
            SizedBox(height: 24),

            // Policy Details section (was Vehicle Information)
            Text('Policy Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, 'Policy No.', policyId),
                  _buildInfoRow(context, 'Policy Class', policyClass),
                  _buildInfoRow(context, 'Status', status),
                  _buildInfoRow(context, 'Insured', insured),
                  if (customerName.isNotEmpty)
                    _buildInfoRow(context, 'Customer Name', customerName),
                  _buildInfoRow(context, 'Premium',
                      premium.isNotEmpty ? '₦$premium' : 'N/A'),
                  _buildInfoRow(context, 'Sum Insured',
                      sumInsured.isNotEmpty ? '₦$sumInsured' : 'N/A'),
                  _buildInfoRow(context, 'Start Date', startDate),
                  _buildInfoRow(context, 'End Date', endDate),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Documents
            Text('Documents',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDocumentItem(context, 'Policy Certificate',
                      Icons.picture_as_pdf, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Talk to an Agent
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.headset_mic,
                          color: AppTheme.primaryNavy, size: 18),
                      SizedBox(width: 6),
                      Text('Talk to a Support Agent',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rex Support',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                            Text('+234 708 0606 100',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: ThemeHelper.getSecondaryTextColor(
                                        context))),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _callSupport(context),
                        icon: const Icon(Icons.phone, size: 14),
                        label: const Text('Call Now',
                            style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NewClaimsScreen(
                            policyNumber: policyNumber,
                            isAgentFlow: isAgentFlow))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('File a claim',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final certUrl = await _certificateUrl(context);
                  if (certUrl == null || !context.mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => _CertificateViewScreen(
                              url: certUrl, policyNumber: policyNumber)));
                },
                icon: const Icon(Icons.description, size: 14),
                label: const Text('View Certificate',
                    style: TextStyle(fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryNavy,
                  side: const BorderSide(color: AppTheme.primaryNavy),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
      floatingActionButton: isAgentFlow
          ? null
          : Transform.translate(
              offset: const Offset(0, 15),
              child: SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NewPolicyScreen())),
                  backgroundColor: AppTheme.accentOrange,
                  shape: const CircleBorder(),
                  elevation: 1,
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isAgentFlow
          ? buildAgentBottomNav(context, currentIndex: 1)
          : BottomAppBar(
              color: AppTheme.bottomNavBackgroundColor(context),
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.home_outlined, 'Home', false,
                        onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerDashboardScreen()),
                          (route) => false);
                    }),
                    _buildNavItem(
                        context, Icons.description_outlined, 'Policies', true),
                    const SizedBox(width: 48),
                    _buildNavItem(
                        context, Icons.assignment_outlined, 'Claims', false,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyClaimsScreen()));
                    }),
                    _buildNavItem(
                        context, Icons.person_outline, 'Profile', false,
                        onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerProfileScreen()));
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _getPolicyIcon(String policyClass) {
    final lower = policyClass.toLowerCase();
    if (lower.contains('motor') ||
        lower.contains('car') ||
        lower.contains('vehicle')) return Icons.directions_car;
    if (lower.contains('shop')) return Icons.store;
    if (lower.contains('home') || lower.contains('house')) return Icons.home;
    if (lower.contains('personal')) return Icons.person;
    if (lower.contains('student')) return Icons.school;
    if (lower.contains('parcel')) return Icons.local_shipping;
    if (lower.contains('driver') || lower.contains('rider'))
      return Icons.two_wheeler;
    return Icons.description;
  }

  static Future<void> _callSupport(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '+2347080606100');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Call Rex Support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: const Text('+234 708 0606 100',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
            ],
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Call Rex Support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: const Text('+234 708 0606 100',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
            ],
          ),
        );
      }
    }
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label,
      Color bgColor, Color iconColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: ThemeHelper.getSecondaryTextColor(context))),
          Flexible(
              child: Text(value.isNotEmpty ? value : 'N/A',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
      BuildContext context, String title, IconData icon, Color iconColor) {
    return GestureDetector(
      onTap: () => _downloadPolicyCertificate(context),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface))),
          const Icon(Icons.download, color: AppTheme.accentOrange, size: 18),
        ],
      ),
    );
  }

  Uri _certificateUri() {
    return Uri.https(
      'eportal.rexinsure.com',
      _getCertType(),
      {'policy': policyNumber},
    );
  }

  bool get _usesIesCertificateEndpoint {
    final normalized = policyNumber.trim().toUpperCase();
    return normalized.startsWith('P/PM') || normalized.startsWith('P/CV');
  }

  Future<String?> _certificateUrl(BuildContext context) async {
    if (!_usesIesCertificateEndpoint) {
      return _certificateUri().toString();
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Generating policy certificate...')),
      );

      final response = await http
          .post(
            Uri.parse(
                'https://eportaltest.rexinsure.com/api/kissflow/generate/certificate/ies'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode(_iesCertificatePayload()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Certificate generation failed');
      }

      final generatedUrl = _certificateUrlFromResponse(response.body);
      if (generatedUrl.isEmpty) {
        throw const FormatException('No certificate URL returned');
      }

      return _normalizeCertificateUrl(generatedUrl);
    } catch (e) {
      debugPrint('IES certificate generation error: $e');
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Unable to generate certificate')),
        );
      }
      return null;
    }
  }

  Map<String, dynamic> _iesCertificatePayload() {
    final names = _firstNonEmpty([
      policyData?['customerName'],
      policyData?['names'],
      policyData?['Insured'],
      policyData?['insured'],
    ]);
    final sumInsured = _firstNonEmpty([
      policyData?['sumInsured'],
      policyData?['SumInsured'],
      policyData?['SumAssured'],
      policyData?['sumassured'],
    ]);

    return {
      'IntCode': 'Kissflow',
      'Password': 'royal1234',
      'policyno': policyNumber,
      'prodcode': _numberValue(sumInsured) > 0 ? 'COM' : 'TP',
      'refno': _firstNonEmpty([
        policyData?['CP_REFERENCE_NO'],
        policyData?['cp_reference_no'],
        policyData?['refno'],
        policyData?['refNo'],
        policyData?['ReferenceNo'],
        policyData?['reference'],
        policyNumber,
      ]),
      'title': _firstNonEmpty([
        policyData?['customerTitle'],
        policyData?['Title'],
        'Mr',
      ]),
      'names': names,
      'vehmake': _vehicleValue([
        'vehmake',
        'VehicleMake',
        'vehicleMake',
        'Make',
        'make',
      ]),
      'vehmodel': _vehicleValue([
        'vehmodel',
        'VehicleModel',
        'vehicleModel',
        'Model',
        'model',
      ]),
      'vehcolor': _vehicleValue([
        'vehcolor',
        'VehicleColor',
        'vehicleColor',
        'Color',
        'color',
      ]),
      'vehtype': _firstNonEmpty([
        policyData?['VehicleType'],
        policyData?['vehicleType'],
        policyData?['ProductCover'],
        policyData?['policyClass'],
        policyType,
      ]),
      'regno': _vehicleValue([
        'regno',
        'RegNo',
        'RegistrationNo',
        'registrationNo',
        'VehicleRegNo',
        'item_code',
      ]),
      'startdate': _firstNonEmpty([
        policyData?['startDate'],
        policyData?['PolicyStartDate'],
        policyData?['StartDate'],
      ]),
      'approvedby': _firstNonEmpty([
        policyData?['ApprovedBy'],
        policyData?['approvedby'],
        'approver@rexinsure.com',
      ]),
      'othernames': _firstNonEmpty([
        policyData?['customerMiddleName'],
        policyData?['Middlename'],
        policyData?['MiddleName'],
      ]),
      'address': _firstNonEmpty([
        policyData?['customerAddress'],
        policyData?['Address'],
        policyData?['address'],
      ]),
      'suminsured': sumInsured,
      'occupation': _firstNonEmpty([
        policyData?['customerOccupation'],
        policyData?['Occupation'],
        policyData?['occupation'],
      ]),
      'premium': _firstNonEmpty([
        policyData?['premium'],
        policyData?['Premium'],
        policyData?['GrossPremium'],
      ]),
    };
  }

  String _vehicleValue(List<String> keys) {
    final direct = _firstNonEmpty(keys.map((key) => policyData?[key]));
    if (direct.isNotEmpty) return direct;

    final items = policyData?['items'] ?? policyData?['Items'];
    if (items is List && items.isNotEmpty && items.first is Map) {
      final item = Map<String, dynamic>.from(items.first as Map);
      final itemValue = _firstNonEmpty(keys.map((key) => item[key]));
      if (itemValue.isNotEmpty) return itemValue;

      final description = item['desc']?.toString().trim() ?? '';
      final isMake = keys.any((key) => key.toLowerCase().contains('make'));
      final isModel = keys.any((key) => key.toLowerCase().contains('model'));
      if (description.contains('-')) {
        final parts = description.split('-');
        if (isMake) return parts.first.trim();
        if (isModel) return parts.skip(1).join('-').trim();
      }
      if (isMake) return description;
    }
    return '';
  }

  String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  double _numberValue(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  String _certificateUrlFromResponse(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is String)
        return _looksLikeUrl(decoded) ? decoded.trim() : '';
      return _findCertificateUrl(decoded);
    } catch (_) {
      final trimmed = body.trim();
      return _looksLikeUrl(trimmed) ? trimmed : '';
    }
  }

  String _findCertificateUrl(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final key in [
        'url',
        'certificate_url',
        'certificateUrl',
        'download_url',
        'downloadUrl',
        'file_url',
        'fileUrl',
        'file',
        'path',
      ]) {
        final candidate = map[key]?.toString().trim() ?? '';
        if (_looksLikeUrl(candidate)) return candidate;
      }

      for (final nested in map.values) {
        final found = _findCertificateUrl(nested);
        if (found.isNotEmpty) return found;
      }
    }

    if (value is List) {
      for (final item in value) {
        final found = _findCertificateUrl(item);
        if (found.isNotEmpty) return found;
      }
    }

    return '';
  }

  bool _looksLikeUrl(String value) {
    final text = value.trim().toLowerCase();
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('/');
  }

  String _normalizeCertificateUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://eportaltest.rexinsure.com$trimmed';
    }
    return trimmed;
  }

  String _getCertType() {
    final pClass = (policyData?['policyClass'] ??
            policyData?['ProductClass'] ??
            policyData?['ProductCover'] ??
            policyType)
        .toString()
        .toLowerCase();
    if (pClass.contains('home') || pClass.contains('hp')) return 'hpcert';
    if (pClass.contains('shop') || pClass.contains('shp')) return 'shpcert';
    if (pClass.contains('group') || pClass.contains('gc')) return 'gccert';
    if (pClass.contains('family') || pClass.contains('fc')) return 'fccert';
    if (pClass.contains('parcel') || pClass.contains('pp')) return 'ppcert';
    if (pClass.contains('student') || pClass.contains('sp')) return 'spcert';
    if (pClass.contains('personal care') || pClass.contains('pc'))
      return 'pccert';
    if (pClass.contains('royal auto') ||
        pClass.contains('bronze') ||
        pClass.contains('silver')) return 'royalautocert';
    if (pClass.contains('comprehensive')) return 'royalautocert';
    return 'tpcert'; // default: third party motor
  }

  Future<void> _downloadPolicyCertificate(BuildContext ctx) async {
    final messenger = ScaffoldMessenger.of(ctx);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Downloading policy certificate...')),
      );

      final certUrl = await _certificateUrl(ctx);
      if (certUrl == null) return;
      final uri = Uri.parse(certUrl);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        client.close(force: true);
        throw HttpException(
          'Certificate download failed',
          uri: uri,
        );
      }

      final contentType = response.headers.contentType?.mimeType ?? '';
      final extension = _certificateExtension(contentType);
      final dir = await getApplicationDocumentsDirectory();
      final safePolicyNumber = policyNumber.replaceAll(RegExp(r'[^\w-]+'), '_');
      final file = File('${dir.path}/Certificate_$safePolicyNumber$extension');
      final sink = file.openWrite();
      await response.pipe(sink);
      client.close();

      if (!ctx.mounted) return;

      final box = ctx.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 0, 100, 100);
      await Share.shareXFiles([XFile(file.path)],
          subject: 'Policy Certificate - $policyNumber',
          sharePositionOrigin: origin);

      messenger.showSnackBar(
        const SnackBar(content: Text('Policy certificate downloaded')),
      );
    } catch (e) {
      debugPrint('Error downloading certificate: $e');
      if (!ctx.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to download policy certificate')),
      );
    }
  }

  String _certificateExtension(String contentType) {
    if (contentType.contains('pdf')) return '.pdf';
    if (contentType.contains('html')) return '.html';
    if (contentType.contains('png')) return '.png';
    if (contentType.contains('jpeg') || contentType.contains('jpg')) {
      return '.jpg';
    }
    return '.pdf';
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected
                  ? AppTheme.bottomNavSelectedColor(context)
                  : AppTheme.bottomNavUnselectedColor(context),
              size: 18),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: isSelected
                      ? AppTheme.bottomNavSelectedColor(context)
                      : AppTheme.bottomNavUnselectedColor(context))),
        ],
      ),
    );
  }
}

class _CertificateViewScreen extends StatefulWidget {
  final String url;
  final String policyNumber;
  const _CertificateViewScreen({required this.url, required this.policyNumber});
  @override
  State<_CertificateViewScreen> createState() => _CertificateViewScreenState();
}

class _CertificateViewScreenState extends State<_CertificateViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Certificate - ${widget.policyNumber}',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ]),
    );
  }
}
