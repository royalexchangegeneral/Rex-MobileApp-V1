import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  final List<Map<String, String>> _payments = const [
    {
      'title': 'Motor Insurance',
      'policyNo': 'Policy #INS-2024-001',
      'premium': '₦12,400',
      'method': 'Paystack',
      'date': 'Dec 15, 2024',
      'reference': 'PSK_123456789',
      'status': 'Success',
    },
    {
      'title': 'Motor Comprehensive',
      'policyNo': 'Policy #INS-2024-001',
      'premium': '₦12,400',
      'method': 'Paystack',
      'date': 'Dec 15, 2024',
      'reference': 'PSK_123456789',
      'status': 'Success',
    },
    {
      'title': 'Third Party Insurance',
      'policyNo': 'Policy #INS-2024-001',
      'premium': '₦12,400',
      'method': 'Paystack',
      'date': 'Dec 15, 2024',
      'reference': 'PSK_123456789',
      'status': 'Success',
    },
  ];

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
        title: const Text('Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            ...List.generate(_payments.length, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index < _payments.length - 1 ? 14 : 0),
                child: _buildPaymentCard(context, _payments[index]),
              );
            }),
            const SizedBox(height: 100),
          ],
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
              _buildNavItem(Icons.description_outlined, 'Policies', false),
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

  Widget _buildPaymentCard(BuildContext context, Map<String, String> payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car_outlined, color: AppTheme.primaryNavy, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 2),
                    Text(payment['policyNo']!, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(payment['status']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailRow('Premium', payment['premium']!),
          const SizedBox(height: 8),
          _buildDetailRow('Payment Method', payment['method']!),
          const SizedBox(height: 8),
          _buildDetailRow('Date', payment['date']!),
          const SizedBox(height: 8),
          _buildDetailRow('Reference', payment['reference']!),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: payment['reference']!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reference copied'), duration: Duration(seconds: 1)),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, size: 13, color: AppTheme.accentOrange),
                  SizedBox(width: 4),
                  Text('Copy', style: TextStyle(fontSize: 10, color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
      ],
    );
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
