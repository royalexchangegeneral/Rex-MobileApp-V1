import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/renewal_guard.dart';
import '../utils/theme_helper.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import '../widgets/agent_bottom_nav.dart';
import '../widgets/paystack_webview.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'policy_purchase_success_screen.dart';

class PolicyRenewalScreen extends StatelessWidget {
  final String policyType;
  final String policyNumber;
  final String premium;
  final bool isAgentFlow;
  final Map<String, dynamic>? policyData;

  const PolicyRenewalScreen(
      {super.key,
      required this.policyType,
      required this.policyNumber,
      this.premium = '0',
      this.isAgentFlow = false,
      this.policyData});

  Future<void> _initiatePayment(
    BuildContext context, {
    required String email,
    required String names,
    required String phone,
  }) async {
    final cleaned = premium.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleaned) ?? 0;
    final productCode = _renewalProductCode();
    final endDate = _renewalEndDate();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.white)));

    final result = await PaymentService.initiateRenewal(
      email: email,
      premium: amount.toInt(),
      policyNumber: policyNumber,
      names: names,
      mobileno: phone,
      productCode: productCode,
      endDate: endDate,
    );

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result.success && result.authorizationUrl != null) {
      final payResult = await Navigator.push<PaymentVerifyResult>(
          context,
          MaterialPageRoute(
              builder: (_) => PaystackWebView(url: result.authorizationUrl!)));
      if (payResult != null && payResult.success && context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => PolicyPurchaseSuccessScreen(
                    isLoggedIn: true,
                    isAgent: isAgentFlow,
                    reference: payResult.reference,
                    message: payResult.message)),
            (route) => false);
      } else if (payResult != null && !payResult.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(payResult.message ?? 'Payment verification failed'),
            backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? 'Payment failed'),
          backgroundColor: Colors.red));
    }
  }

  String _renewalProductCode() {
    final directCode = policyData?['product_code'] ??
        policyData?['productCode'] ??
        policyData?['ProductCode'] ??
        policyData?['ProdCode'] ??
        policyData?['prodCode'];
    final code = directCode?.toString().trim() ?? '';
    final normalizedCode = code.toLowerCase();
    if (normalizedCode == 'rab' || normalizedCode.contains('bronze')) {
      return 'RAB';
    }
    if (normalizedCode == 'ras' || normalizedCode.contains('silver')) {
      return 'RAS';
    }
    if (code.isNotEmpty) return code;

    final source = [
      policyType,
      policyData?['policyClass']?.toString() ?? '',
      policyData?['ProductClass']?.toString() ?? '',
      policyData?['ProductCover']?.toString() ?? '',
    ].join(' ').toLowerCase();

    if (source.contains('bronze')) return 'RAB';
    if (source.contains('silver')) return 'RAS';
    if (source.contains('third') || source.contains('tp')) return 'TP';
    if (source.contains('comprehensive') || source.contains('cp')) return 'CP';
    if (source.contains('royal auto') && source.contains('rab')) return 'RAB';
    if (source.contains('royal auto') && source.contains('ras')) return 'RAS';
    if (source.contains('auto')) return 'TP';
    return policyType.trim().isNotEmpty ? policyType.trim() : 'TP';
  }

  String _renewalEndDate() {
    final currentEndDate = _parsePolicyDate(policyData?['endDate']) ??
        _parsePolicyDate(policyData?['EndDate']) ??
        _parsePolicyDate(policyData?['PolicyEndDate']) ??
        _parsePolicyDate(policyData?['policyEndDate']);

    final baseDate = currentEndDate ?? DateTime.now();
    return _formatApiDate(
        DateTime(baseDate.year + 1, baseDate.month, baseDate.day));
  }

  DateTime? _parsePolicyDate(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;

    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;

    final slashParts = text.split('/');
    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  String _formatApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _isMotorRelatedPolicy() {
    final productCode = (policyData?['product_code'] ??
            policyData?['productCode'] ??
            policyData?['ProductCode'] ??
            policyData?['ProdCode'] ??
            policyData?['prodCode'])
        ?.toString()
        .trim()
        .toUpperCase();

    if (productCode != null &&
        {'TP', 'CP', 'RAB', 'RAS'}.contains(productCode)) {
      return true;
    }

    final source = [
      policyType,
      policyData?['policyClass'],
      policyData?['PolicyClass'],
      policyData?['ProductClass'],
      policyData?['ProductCover'],
      policyData?['productName'],
      policyData?['ProductName'],
      policyData?['riskType'],
      policyData?['RiskType'],
    ].whereType<Object>().map((value) => value.toString()).join(' ');

    final normalized = source.toLowerCase();
    return normalized.contains('motor') ||
        normalized.contains('auto') ||
        normalized.contains('vehicle') ||
        normalized.contains('third party') ||
        normalized.contains('comprehensive');
  }

  String _policyValue(List<String> keys) {
    final value = _readPolicyValue(policyData, keys);
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  dynamic _readPolicyValue(dynamic source, List<String> keys) {
    if (source is! Map) return null;

    for (final key in keys) {
      if (source.containsKey(key)) {
        final value = source[key];
        if (value != null && value.toString().trim().isNotEmpty) return value;
      }
    }

    final lowerKeys = keys.map((key) => key.toLowerCase()).toSet();
    for (final entry in source.entries) {
      if (lowerKeys.contains(entry.key.toString().toLowerCase())) {
        final value = entry.value;
        if (value != null && value.toString().trim().isNotEmpty) return value;
      }
    }

    for (final value in source.values) {
      if (value is Map) {
        final nestedValue = _readPolicyValue(value, keys);
        if (nestedValue != null && nestedValue.toString().trim().isNotEmpty) {
          return nestedValue;
        }
      }
    }

    return null;
  }

  List<Widget> _vehicleInfoRows(BuildContext context) {
    final items = [
      MapEntry(
          'Reg Number',
          _policyValue([
            'RegNo',
            'RegNumber',
            'RegistrationNo',
            'RegistrationNumber',
            'VehicleRegNo',
            'VehicleRegistrationNo',
            'vehregno',
            'registrationNo',
            'regNumber',
          ])),
      MapEntry(
          'Chassis No.',
          _policyValue([
            'ChassisNo',
            'ChassisNumber',
            'VehicleChassisNo',
            'VehicleChassisNumber',
            'chassisNo',
            'chassisNumber',
          ])),
      MapEntry(
          'Make',
          _policyValue([
            'Make',
            'VehicleMake',
            'VehicleManufacturer',
            'make',
            'vehicleMake',
          ])),
      MapEntry(
          'Colour',
          _policyValue([
            'Colour',
            'Color',
            'VehicleColour',
            'VehicleColor',
            'colour',
            'color',
          ])),
      MapEntry(
          'Model',
          _policyValue([
            'Model',
            'VehicleModel',
            'model',
            'vehicleModel',
          ])),
      MapEntry(
          'Engine Number',
          _policyValue([
            'EngineNo',
            'EngineNumber',
            'VehicleEngineNo',
            'VehicleEngineNumber',
            'engineNo',
            'engineNumber',
          ])),
      MapEntry(
          'Engine Capacity',
          _policyValue([
            'EngineCapacity',
            'VehicleEngineCapacity',
            'Capacity',
            'engineCapacity',
          ])),
      MapEntry(
          'Year',
          _policyValue([
            'Year',
            'YearOfMake',
            'ManufactureYear',
            'VehicleYear',
            'ModelYear',
            'year',
            'vehicleYear',
          ])),
    ];

    if (items.every((item) => item.value == '-')) {
      return [
        _buildInfoRow(context, 'Vehicle Details',
            'No vehicle details available for this policy'),
      ];
    }

    return items
        .map((item) => _buildInfoRow(context, item.key, item.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userData = auth.userData;
    final email = userData?['Email']?.toString() ?? 'customer@rexinsure.com';
    final firstName = userData?['FirstName']?.toString() ??
        userData?['Firstname']?.toString() ??
        userData?['First_Name']?.toString() ??
        '';
    final lastName = userData?['LastName']?.toString() ??
        userData?['Lastname']?.toString() ??
        userData?['Surname']?.toString() ??
        userData?['Last_Name']?.toString() ??
        '';
    final names = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
    final phone = userData?['Phone']?.toString() ??
        userData?['PhoneNo']?.toString() ??
        userData?['Phoneno']?.toString() ??
        userData?['MobileNo']?.toString() ??
        userData?['Mobile']?.toString() ??
        userData?['PhoneNumber']?.toString() ??
        userData?['Telephone']?.toString() ??
        '';
    final showVehicleInformation = _isMotorRelatedPolicy();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Renewal',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    Text('Summary',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                    height: 3,
                    decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Policy Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: ThemeHelper.getSecondaryCardColor(context),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Policy Information',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 14),
                        _buildInfoRow(context, 'Policy Number', policyNumber),
                        _buildInfoRow(context, 'Product', policyType),
                        _buildInfoRow(context, 'Premium', '₦$premium'),
                        _buildInfoRow(context, 'Start Date', '2/04/2025'),
                        _buildInfoRow(context, 'End Date', '2/04/2026'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personal Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: ThemeHelper.getSecondaryCardColor(context),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personal Information',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 14),
                        if (isAgentFlow && policyData != null) ...[
                          _buildInfoRow(
                              context,
                              'Insured',
                              policyData!['insured']?.toString() ??
                                  policyData!['customerName']?.toString() ??
                                  '-'),
                          _buildInfoRow(context, 'Policy Class',
                              policyData!['policyClass']?.toString() ?? '-'),
                          _buildInfoRow(context, 'Sum Insured',
                              '₦${policyData!['sumInsured']?.toString() ?? '0'}'),
                          _buildInfoRow(context, 'Start Date',
                              policyData!['startDate']?.toString() ?? '-'),
                          _buildInfoRow(context, 'End Date',
                              policyData!['endDate']?.toString() ?? '-'),
                        ] else ...[
                          _buildInfoRow(context, 'First Name',
                              userData?['FirstName']?.toString() ?? '-'),
                          _buildInfoRow(context, 'Last Name',
                              lastName.isNotEmpty ? lastName : '-'),
                          _buildInfoRow(context, 'Email',
                              userData?['Email']?.toString() ?? '-'),
                          _buildInfoRow(context, 'Phone Number', phone),
                          _buildInfoRow(context, 'Occupation',
                              userData?['Occupation']?.toString() ?? '-'),
                          _buildInfoRow(context, 'State',
                              userData?['State']?.toString() ?? '-'),
                          _buildInfoRow(context, 'LGA',
                              userData?['LGA']?.toString() ?? '-'),
                          _buildInfoRow(context, 'Address',
                              userData?['Address']?.toString() ?? '-'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (showVehicleInformation) ...[
                    // Vehicle Information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: ThemeHelper.getSecondaryCardColor(context),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicle Information',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 14),
                          ..._vehicleInfoRows(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Renew Now button
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 8, 24, 16 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!RenewalGuard.canRenew(policyData)) {
                    RenewalGuard.showNotRenewableDialog(context);
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: ThemeHelper.getBorderColor(context),
                                  borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              _initiatePayment(
                                context,
                                email: email,
                                names: names.isNotEmpty
                                    ? names
                                    : policyData?['customerName']?.toString() ??
                                        'Customer Name',
                                phone: phone,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          ThemeHelper.getBorderColor(context)),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: ThemeHelper.isDarkMode(context)
                                            ? Colors.cyan[700]!
                                                .withValues(alpha: 0.16)
                                            : Colors.cyan[50],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.payment,
                                        color: ThemeHelper.isDarkMode(context)
                                            ? Colors.cyan[200]
                                            : Colors.cyan[600],
                                        size: 24)),
                                const SizedBox(width: 16),
                                Text('Pay with Paystack',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                                const Spacer(),
                                const Icon(Icons.radio_button_checked,
                                    color: AppTheme.primaryNavy, size: 22),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Renew Now',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
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
                  ))),
      floatingActionButtonLocation:
          isAgentFlow ? null : FloatingActionButtonLocation.centerDocked,
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
                          onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerDashboardScreen()),
                              (route) => false)),
                      _buildNavItem(context, Icons.description_outlined,
                          'Policies', true),
                      const SizedBox(width: 48),
                      _buildNavItem(
                          context, Icons.assignment_outlined, 'Claims', false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyClaimsScreen()))),
                      _buildNavItem(
                          context, Icons.person_outline, 'Profile', false,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CustomerProfileScreen()))),
                    ],
                  )),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: ThemeHelper.getSecondaryTextColor(context)))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon,
            color: isSelected
                ? AppTheme.primaryNavy
                : ThemeHelper.getSecondaryTextColor(context),
            size: 20),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? AppTheme.primaryNavy
                    : ThemeHelper.getSecondaryTextColor(context))),
      ]),
    );
  }
}
