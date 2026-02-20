import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'policy_purchase_success_screen.dart';

class ComprehensiveSummaryScreen extends StatelessWidget {
  final String vehicleType;
  final String sumInsured;
  final String premium;
  final String regNumber;

  const ComprehensiveSummaryScreen({super.key, required this.vehicleType, required this.sumInsured, required this.premium, required this.regNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(vehicleType, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text('Step 5 of 5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                  Spacer(),
                  Text('Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                ]),
                const SizedBox(height: 12),
                Row(children: List.generate(5, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 4 ? 4 : 0), decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(2)))))),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Product', 'Motor Comprehensive'),
                  _buildInfoRow('Sum Insured', 'N$sumInsured'),
                  _buildInfoRow('Premium', premium),
                  const SizedBox(height: 24),
                  const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  _buildInfoRow('First Name', 'Toyota Camry'),
                  _buildInfoRow('Last Name', '2024'),
                  _buildInfoRow('Email', 'example@gmail.com'),
                  _buildInfoRow('Phone NUmber', '+234902389421'),
                  _buildInfoRow('Occupation', 'Banker'),
                  _buildInfoRow('State', 'Lagos'),
                  _buildInfoRow('LGA', 'Kosofe'),
                  _buildInfoRow('Address', '21, example street\nExample bustop'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) => const PolicyPurchaseSuccessScreen()), (route) => route.isFirst),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
