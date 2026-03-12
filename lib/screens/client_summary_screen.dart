import 'package:flutter/material.dart';

class ClientSummaryScreen extends StatelessWidget {
  final String clientType;
  final Map<String, String> clientData;
  
  const ClientSummaryScreen({
    super.key,
    required this.clientType,
    required this.clientData,
  });

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
          'Add A New Client',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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
                          color: const Color(0xFF1E2D64),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2D64),
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Client Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Client Information Fields - Different for individual vs corporate
                        if (clientType == 'corporate') ...[
                          _buildInfoRow('Business Name', clientData['businessName'] ?? ''),
                          _buildInfoRow('Address', clientData['businessAddress'] ?? ''),
                          _buildInfoRow('Business Sector', clientData['businessSector'] ?? ''),
                          _buildInfoRow('Phone Number', clientData['phone'] ?? ''),
                          _buildInfoRow('Email', clientData['email'] ?? ''),
                          _buildInfoRow('Year of Incorp.', clientData['yearOfIncorporation'] ?? '', isLast: true),
                        ] else ...[
                          _buildInfoRow('First Name', clientData['firstName'] ?? ''),
                          _buildInfoRow('Last Name', clientData['lastName'] ?? ''),
                          _buildInfoRow('Email', clientData['email'] ?? ''),
                          _buildInfoRow('Phone Number', clientData['phone'] ?? ''),
                          _buildInfoRow('State', clientData['state'] ?? ''),
                          _buildInfoRow('LGA', clientData['lga'] ?? ''),
                          _buildInfoRow('Address', clientData['address'] ?? '', isLast: true),
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
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Client added successfully')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2D64),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
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
                        foregroundColor: const Color(0xFF1E2D64),
                        side: const BorderSide(color: Color(0xFF1E2D64), width: 1.5),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined, size: 22),
            label: 'Policy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 22),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, size: 22),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 22),
            label: 'Profile',
          ),
        ],
      ),
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
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
