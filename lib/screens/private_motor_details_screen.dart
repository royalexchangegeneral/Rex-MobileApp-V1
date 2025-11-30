import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivateMotorDetailsScreen extends StatelessWidget {
  const PrivateMotorDetailsScreen({super.key});

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
        title: const Text(
          'Private Motor Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Step 3 of 3',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Chassis No.', '1HGCMBB2633A123456'),
                  _buildInfoRow('Make', 'Honda'),
                  _buildInfoRow('Colour', 'Silver'),
                  _buildInfoRow('Model', 'City VX'),
                  _buildInfoRow('Engine Number', 'G4KEBX123456'),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow('First Name', 'Toyota Camry'),
                  _buildInfoRow('Last Name', '2024'),
                  _buildInfoRow('Email', 'example@gmail.com'),
                  _buildInfoRow('Phone Number', '+234902389421'),
                  _buildInfoRow('Occupation', 'Banker'),
                  _buildInfoRow('State', 'Lagos'),
                  _buildInfoRow('LGA', 'Kosofe'),
                  _buildInfoRow('Address', '21, example street\nExample bustop near\nsample'),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Pay Now button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle payment
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
