import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class TrackTicketScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tickets;
  final bool isAgentFlow;
  const TrackTicketScreen({Key? key, required this.tickets, this.isAgentFlow = false}) : super(key: key);

  @override
  State<TrackTicketScreen> createState() => _TrackTicketScreenState();
}

class _TrackTicketScreenState extends State<TrackTicketScreen> {
  String _selectedFilter = 'All';
  late List<Map<String, dynamic>> _filteredTickets;
  List<Map<String, dynamic>> _displayedTickets = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTickets = widget.tickets;
    _displayedTickets = _filteredTickets;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTickets(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredTickets = widget.tickets;
      } else {
        final normalizedFilter = filter.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
        _filteredTickets = widget.tickets.where((t) {
          final status = (t['status'] as String?)?.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '') ?? '';
          return status == normalizedFilter;
        }).toList();
      }
      _applySearch();
    });
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _displayedTickets = _filteredTickets;
    } else {
      _displayedTickets = _filteredTickets.where((t) {
        final id = '#TK${t['id']}';
        final status = (t['status'] as String?)?.toLowerCase() ?? '';
        return id.toLowerCase().contains(query) || status.contains(query);
      }).toList();
    }
    setState(() {});
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(String status) {
    final color = _statusColor(status);
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'in progress':
        return const Color(0xFFE3F2FD);
      case 'resolved':
        return const Color(0xFFE8F5E9);
      default:
        return Colors.grey[100]!;
    }
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
        title: const Text('Track Ticket', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => _applySearch(),
              decoration: InputDecoration(
                hintText: 'Search tickets',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryNavy)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Open', _selectedFilter == 'Open'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', _selectedFilter == 'In Progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', _selectedFilter == 'Resolved'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Your Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _displayedTickets.length,
                itemBuilder: (context, i) {
                  final t = _displayedTickets[i];
                  final createdAt = t['created_at'] != null ? DateTime.tryParse(t['created_at']) : null;
                  final status = (t['status'] as String?)?.toLowerCase() ?? 'open';
                  final displayStatus = status == 'open' ? 'Open' : status.capitalize();
                  final statusColor = _statusColor(status);
                  final statusBg = _statusBg(status);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('#TK${t['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                displayStatus,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(t['category'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                        if (t['sub_category'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(t['sub_category'], style: const TextStyle(color: AppTheme.primaryNavy, fontSize: 12), overflow: TextOverflow.ellipsis),
                          ),
                        if (t['description'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(t['description'], style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                createdAt != null ? _formatTimeAgo(createdAt) : '',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isAgentFlow ? null : SizedBox(width: 50, height: 50, child: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
        backgroundColor: AppTheme.accentOrange, shape: const CircleBorder(), child: const Icon(Icons.add, color: Colors.white, size: 24))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.isAgentFlow ? buildAgentBottomNav(context, currentIndex: 0) : BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 6,
        child: SizedBox(height: 50, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _nav(Icons.home_outlined, 'Home', false, () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()), (r) => false)),
          _nav(Icons.description_outlined, 'Policies', false, null), const SizedBox(width: 40),
          _nav(Icons.assignment_outlined, 'Claims', false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClaimsScreen()))),
          _nav(Icons.person_outline, 'Profile', true, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()))),
        ]))),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 12)),
      selected: selected,
      selectedColor: AppTheme.primaryNavy,
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
      onSelected: (isSelected) {
        if (isSelected) _filterTickets(label);
      },
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: EdgeInsets.zero,
    );
  }

  Widget _nav(IconData i, String l, bool s, VoidCallback? o) => InkWell(onTap: o, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, color: s ? AppTheme.primaryNavy : Colors.grey, size: 20), Text(l, style: TextStyle(fontSize: 10, color: s ? AppTheme.primaryNavy : Colors.grey))]));
}

extension StringCasingExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
