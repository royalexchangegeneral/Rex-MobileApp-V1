import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';
import 'select_client_type_screen.dart';
import 'buy_new_policy_screen.dart';

class AgentDashboardScreen extends StatelessWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          height: 32,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commission Card with Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2D64), Color(0xFF2A3F7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Commission amount and dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'N430,000.00',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Commission',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This month',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatItem('124', 'Total Client')),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Expanded(child: _buildStatItem('4', 'Pending Claims')),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Expanded(child: _buildStatItem('132', 'Active Policies')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Access
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Add Client',
                    Icons.person_add_outlined,
                    const Color(0xFF1E2D64),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectClientTypeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'New Policy',
                    Icons.add_circle_outline,
                    const Color(0xFF1E2D64),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyNewPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'File a Claim',
                    Icons.assignment_outlined,
                    const Color(0xFF1E2D64),
                    () {},
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // My Policies
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Policies',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Policy List
            _buildPolicyItem(
              'Motor Insurance',
              'Policy #MOT-2025-089',
              '28 May, 2025',
              'Active',
              Icons.directions_car_outlined,
              const Color(0xFF4CAF50),
            ),
            
            const SizedBox(height: 12),
            
            _buildPolicyItem(
              'Health Insurance',
              'Policy #HLT-2025-156',
              '15 Jun, 2025',
              'Active',
              Icons.favorite_outline,
              const Color(0xFF4CAF50),
            ),
            
            const SizedBox(height: 24),
            
            // Earnings History
            const Text(
              'Earnings History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time Period Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodButton('Weekly', false),
                const SizedBox(width: 8),
                _buildPeriodButton('Monthly', true),
                const SizedBox(width: 8),
                _buildPeriodButton('Yearly', false),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Chart Container
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _buildEarningsChart(),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activities
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildActivityItem(
              'Robert Johnson',
              'Renewed Motor insurance',
              '2 hours ago',
              Icons.check_circle_outline,
              const Color(0xFF2196F3),
            ),
            
            const SizedBox(height: 12),
            
            _buildActivityItem(
              'Emily Chen',
              'Filed claim for Motor Insurance',
              '3 hours ago',
              Icons.warning_amber_outlined,
              const Color(0xFFFFA726),
            ),
            
            const SizedBox(height: 12),
            
            _buildActivityItem(
              'Michael Smith',
              'Claim approved for fire insurance',
              '1 day ago',
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
            
            const SizedBox(height: 12),
            
            _buildActivityItem(
              'Laura Martinez',
              'Requested policy details for Royal Group life care',
              '1 day ago',
              Icons.info_outline,
              const Color(0xFF2196F3),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Policy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(
    String title,
    String policyNumber,
    String renewalDate,
    String status,
    IconData icon,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D64).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E2D64), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  policyNumber,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Renewal Date',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                renewalDate,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2D64),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aderomi Abgranie',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'aaderonmi@example.com',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 3),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_outline,
                  title: 'All Customers',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Policies',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Claims',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.trending_up,
                  title: 'Reports',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Log Out',
                  isLogout: true,
                  onTap: () {
                    Navigator.pop(context);
                    // Add logout logic here
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/user-portal',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E2D64) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : isSelected
                  ? Colors.white
                  : const Color(0xFF1E2D64),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isLogout
                ? Colors.red
                : isSelected
                    ? Colors.white
                    : const Color(0xFF1E2D64),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildPeriodButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E2D64) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E2D64) : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }
  
  Widget _buildEarningsChart() {
    // Mock chart data points
    final List<double> dataPoints = [400, 500, 800, 600, 450, 600, 500, 700];
    final List<String> months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    
    return Column(
      children: [
        // Y-axis labels and chart
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Y-axis labels
              SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$1k', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('\$800', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('\$600', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('\$400', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('\$200', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('0', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chart area
              Expanded(
                child: CustomPaint(
                  painter: LineChartPainter(dataPoints),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // X-axis labels
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: months.map((month) => Text(
              month,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            )).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivityItem(
    String name,
    String activity,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  
  LineChartPainter(this.dataPoints);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E2D64)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final maxValue = 1000.0;
    final stepX = size.width / (dataPoints.length - 1);
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (dataPoints[i] / maxValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
