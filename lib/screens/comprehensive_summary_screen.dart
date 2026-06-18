import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import '../services/payment_service.dart';
import '../widgets/paystack_webview.dart';
import 'policy_purchase_success_screen.dart';

class ComprehensiveSummaryScreen extends StatelessWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;
  final Map<String, String> personalInfo;
  final Map<String, dynamic> vehicleData;
  final List<File> imageFiles;
  final bool isLoggedIn;
  final bool isAgent;
  final bool isExploreFlow;

  const ComprehensiveSummaryScreen(
      {super.key,
      required this.vehicleType,
      required this.sumInsured,
      required this.premium,
      required this.regNumber,
      this.personalInfo = const {},
      this.vehicleData = const {},
      this.imageFiles = const [],
      this.isLoggedIn = false,
      this.isAgent = false,
      this.isExploreFlow = false});

  double _getBaseAmount() {
    final cleaned = premium.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  double _getPaystackCharge() {
    final base = _getBaseAmount();
    double charge = (base * 0.015) + 100;
    if (charge > 2000) charge = 2000;
    return charge;
  }

  double _getTotalAmount() => _getBaseAmount() + _getPaystackCharge();

  String _formatNaira(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';
  }

  Future<void> _submitProposalAndPay(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.white)));

    final premiumAmount = _getBaseAmount().toInt();
    final names =
        '${personalInfo['firstName'] ?? ''} ${personalInfo['lastName'] ?? ''}'
            .trim();
    final email = personalInfo['email'] ?? 'customer@rexinsure.com';
    final mobileno = personalInfo['phone'] ?? '';

    // Build fields for multipart proposal
    final fields = <String, String>{
      'product_code': 'CP',
      'type': 'Individual',
      'names': names,
      'email': email,
      'mobileno': mobileno,
      'premium': premiumAmount.toString(),
      'occupation': personalInfo['occupation'] ?? '',
      'state': personalInfo['state'] ?? '',
      'address': personalInfo['address'] ?? '',
      'vehregno': regNumber,
      'vehchasisno': vehicleData['chassisNo']?.toString() ??
          vehicleData['VIN']?.toString() ??
          '',
      'engnumb': vehicleData['vehicleEngineno']?.toString() ??
          vehicleData['EngineNumber']?.toString() ??
          '',
      'engcap': vehicleData['vehicleEngineCapacity']?.toString() ?? '',
      'vehmake': vehicleData['vehicleMake']?.toString() ??
          vehicleData['VehicleMake']?.toString() ??
          '',
      'vehmodel': vehicleData['vehicleModel']?.toString() ??
          vehicleData['VehicleModel']?.toString() ??
          '',
      'vehyear': vehicleData['Year']?.toString() ?? '',
      'vehtype': vehicleData['VehicleType']?.toString() ?? 'Saloon',
      'vehcolor': vehicleData['vehicleColor']?.toString() ??
          vehicleData['VehicleColor']?.toString() ??
          '',
      'sumInsured': sumInsured,
      'premrate': '5',
      'grosspremium': premiumAmount.toString(),
    };

    // Collect image file paths
    final imagePaths =
        imageFiles.where((f) => f.existsSync()).map((f) => f.path).toList();

    final result = await PaymentService.initiateComprehensivePurchase(
      fields: fields,
      imagePaths: imagePaths,
      names: names,
      email: email,
      mobileno: mobileno,
      premium: premiumAmount,
    );

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result.success && result.authorizationUrl != null) {
      final payResult = await Navigator.push<PaymentVerifyResult>(
          context,
          MaterialPageRoute(
              builder: (_) => PaystackWebView(url: result.authorizationUrl!)));
      if (payResult != null && payResult.success && context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PolicyPurchaseSuccessScreen(
                        isLoggedIn: isLoggedIn,
                        isAgent: isAgent,
                        isExploreFlow: isExploreFlow,
                        reference: payResult.reference,
                        message: payResult.message,
                        accountData: {
                          'firstName': personalInfo['firstName'] ?? '',
                          'lastName': personalInfo['lastName'] ?? '',
                          'email': email,
                          'phone': mobileno,
                          'occupation': personalInfo['occupation'] ?? '',
                          'state': personalInfo['state'] ?? '',
                          'address': personalInfo['address'] ?? '',
                        })));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text(vehicleType,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
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
                    Text('Step 5 of 5',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                    Spacer(),
                    Text('Summary',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy)),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                      children: List.generate(
                          5,
                          (i) => Expanded(
                              child: Container(
                                  height: 4,
                                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                                  decoration: BoxDecoration(
                                      color: AppTheme.primaryNavy,
                                      borderRadius:
                                          BorderRadius.circular(2)))))),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  SizedBox(height: 16),
                  _buildInfoRow(context, 'Product', 'Motor Comprehensive'),
                  _buildInfoRow(context, 'Sum Insured', 'N$sumInsured'),
                  _buildInfoRow(context, 'Premium', premium),
                  _buildInfoRow(context, 'Paystack Charges',
                      _formatNaira(_getPaystackCharge())),
                  _buildInfoRow(
                      context, 'Total', _formatNaira(_getTotalAmount())),
                  SizedBox(height: 24),
                  Text('Vehicle Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'Reg Number',
                      vehicleData['registrationNo']?.toString() ?? regNumber),
                  _buildInfoRow(context, 'Chassis No.',
                      vehicleData['chassisNo']?.toString() ?? '-'),
                  _buildInfoRow(context, 'Make',
                      vehicleData['vehicleMake']?.toString().trim() ?? '-'),
                  _buildInfoRow(context, 'Model',
                      vehicleData['vehicleModel']?.toString() ?? '-'),
                  _buildInfoRow(context, 'Colour',
                      vehicleData['vehicleColor']?.toString() ?? '-'),
                  _buildInfoRow(context, 'Engine Number',
                      vehicleData['vehicleEngineno']?.toString() ?? '-'),
                  _buildInfoRow(context, 'Engine Capacity',
                      vehicleData['vehicleEngineCapacity']?.toString() ?? '-'),
                  _buildInfoRow(context, 'Category',
                      vehicleData['vehicleCategory']?.toString() ?? '-'),
                  _buildInfoRow(context, 'Owner',
                      vehicleData['ownersName']?.toString() ?? '-'),
                  SizedBox(height: 24),
                  Text('Personal Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      context, 'First Name', personalInfo['firstName'] ?? '-'),
                  _buildInfoRow(
                      context, 'Last Name', personalInfo['lastName'] ?? '-'),
                  _buildInfoRow(context, 'Email', personalInfo['email'] ?? '-'),
                  _buildInfoRow(
                      context, 'Phone Number', personalInfo['phone'] ?? '-'),
                  _buildInfoRow(
                      context, 'Occupation', personalInfo['occupation'] ?? '-'),
                  _buildInfoRow(context, 'State', personalInfo['state'] ?? '-'),
                  _buildInfoRow(context, 'LGA', personalInfo['lga'] ?? '-'),
                  _buildInfoRow(
                      context, 'Address', personalInfo['address'] ?? '-'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        builder: (ctx) => Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2))),
                              SizedBox(height: 24),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _submitProposalAndPay(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(children: [
                                    Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.cyan[50],
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Icon(Icons.payment,
                                            color: Colors.cyan[600], size: 24)),
                                    SizedBox(width: 16),
                                    Text('Pay with Paystack',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface)),
                                    const Spacer(),
                                    Icon(Icons.radio_button_checked,
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
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.accentOrange
                                : AppTheme.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('Proceed to Payment',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;
    final valueColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(fontSize: 14, color: labelColor))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
