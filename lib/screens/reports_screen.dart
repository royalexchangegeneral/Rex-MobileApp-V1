import 'package:flutter/material.dart';
import 'agent_dashboard_screen.dart';
import 'clients_list_screen.dart';
import 'agent_profile_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedReportType;
  int _selectedDateRange = -1;
  int _selectedFormat = -1;
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();

  final List<String> _reportTypes = [
    'Sales Report',
    'Commission Report',
    'Policy Report',
    'Claims Report',
  ];

  final List<String> _dateRanges = ['Today', 'This Week', 'This Month', 'Custom'];

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

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
          'Reports',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReportType,
                  isExpanded: true,
                  hint: Text('select report type', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 18),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  items: _reportTypes.map((String type) {
                    return DropdownMenuItem<String>(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() { _selectedReportType = newValue; });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_dateRanges.length, (index) {
                      final isSelected = _selectedDateRange == index;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () { setState(() { _selectedDateRange = index; }); },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8923E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: isSelected ? const Color(0xFFD4A574) : Colors.grey[300]!),
                              ),
                              child: Center(
                                child: Text(
                                  _dateRanges[index],
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Custom date range fields
                  if (_selectedDateRange == 3) ...[
                    const SizedBox(height: 14),
                    const Text('From Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _fromDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _fromDateController,
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'dd/mm/yyyy',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[500], size: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('To Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _toDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _toDateController,
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'dd/mm/yyyy',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[500], size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Download Format',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFormatCard(0, Icons.description_outlined, 'CSV', const Color(0xFF2E7D6F), const Color(0xFFE8F5E9), const Color(0xFF2E7D6F)),
                      const SizedBox(width: 12),
                      _buildFormatCard(1, Icons.picture_as_pdf_outlined, 'PDF', const Color(0xFFE53935), const Color(0xFFFFEBEE), const Color(0xFFE53935)),
                      const SizedBox(width: 12),
                      _buildFormatCard(2, Icons.table_chart_outlined, 'Excel', const Color(0xFF1565C0), const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedReportType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a report type')));
                    return;
                  }
                  if (_selectedDateRange == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date range')));
                    return;
                  }
                  if (_selectedFormat == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a download format')));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading report...'), backgroundColor: Color(0xFF1E2D64)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2D64),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Download Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Recent Reports',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 10),
            _buildRecentReportItem(title: 'Sales Report - November', subtitle: 'Generated 2 days ago'),
            const SizedBox(height: 8),
            _buildRecentReportItem(title: 'Commission Report - Q4', subtitle: 'Generated 1 week ago'),
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E2D64),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AgentDashboardScreen()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClientsListScreen()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AgentProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 22), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined, size: 22), label: 'Policy'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline, size: 22), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined, size: 22), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 22), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFormatCard(int index, IconData icon, String label, Color iconColor, Color bgColor, Color borderColor) {
    final isSelected = _selectedFormat == index;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() { _selectedFormat = index; }); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? borderColor : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReportItem({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined, color: Color(0xFFD4A574), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
          const Icon(Icons.download_outlined, color: Color(0xFFD4A574), size: 20),
        ],
      ),
    );
  }
}
