import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'select_client_type_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});
  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  int _selectedFilterIndex = 0;
  final _searchController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _customers = [];
  int _totalCustomers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCustomers());
  }

  Future<void> _fetchCustomers() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final agentCode = auth.userCode ?? '';

      print('=== FETCH AGENT CUSTOMERS ===');
      print('agent_code: $agentCode');

      final r = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/agent/customers'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({'agent_code': agentCode}),
      ).timeout(const Duration(seconds: 15));

      print('=== CUSTOMERS RESPONSE: ${r.statusCode} ===');
      print(r.body.length > 500 ? '${r.body.substring(0, 500)}...' : r.body);

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'success' && d['data'] is List) {
          _customers = (d['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
          _totalCustomers = d['total_customers'] ?? _customers.length;
        }
      }
    } catch (e) { print('Fetch customers error: $e'); }
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _customers;
    final query = _searchController.text.toLowerCase().trim();
    // Filter by type
    if (_selectedFilterIndex == 1) {
      list = list.where((c) => c['cust_type']?.toString().toLowerCase() == 'individual').toList();
    } else if (_selectedFilterIndex == 2) {
      list = list.where((c) => c['cust_type']?.toString().toLowerCase() == 'corporate').toList();
    }

    // Search
    if (query.isNotEmpty) {
      list = list.where((c) {
        final name = '${c['cust_first_name'] ?? ''} ${c['cust_middle_name'] ?? ''} ${c['cust_last_name'] ?? ''}'.toLowerCase();
        final email = (c['cust_email'] ?? '').toString().toLowerCase();
        final phone = (c['cust_phone'] ?? '').toString().toLowerCase();
        final id = (c['cust_id'] ?? '').toString();
        return name.contains(query) || email.contains(query) || phone.contains(query) || id.contains(query);
      }).toList();
    }
    return list;
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final customers = _filtered;
    final individualCount = _customers.where((c) => c['cust_type']?.toString().toLowerCase() == 'individual').length;
    final corporateCount = _customers.where((c) => c['cust_type']?.toString().toLowerCase() == 'corporate').length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Clients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search name, email or phone',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _buildFilterChip('All (${_customers.length})', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Individual ($individualCount)', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Corporate ($corporateCount)', 2),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : customers.isEmpty
                ? Center(child: Text('No clients found', style: TextStyle(color: Colors.grey[500], fontSize: 13)))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) => _buildClientCard(customers[index]),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(color: Colors.grey[100], border: Border(top: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!))),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1E2D64), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Showing ${customers.length} of $_totalCustomers clients', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectClientTypeScreen())),
          backgroundColor: const Color(0xFFFF6B35),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New client', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      bottomNavigationBar: buildAgentBottomNav(context, currentIndex: 2),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2D64) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1E2D64) : Colors.grey[300]!),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> c) {
    final firstName = c['cust_first_name']?.toString() ?? '';
    final middleName = c['cust_middle_name']?.toString() ?? '';
    final lastName = c['cust_last_name']?.toString() ?? '';
    final name = '$firstName ${middleName.isNotEmpty ? "$middleName " : ""}$lastName'.trim();
    final email = c['cust_email']?.toString() ?? '';
    final phone = c['cust_phone']?.toString() ?? '';
    final type = c['cust_type']?.toString() ?? '';
    final isCorporate = type.toLowerCase() == 'corporate';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isCorporate ? const Color(0xFFE8EAF6) : const Color(0xFFE3F2FD),
          child: Icon(isCorporate ? Icons.business : Icons.person, color: const Color(0xFF1E2D64), size: 24),
        ),
        SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name.isNotEmpty ? name : 'Unknown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: isCorporate ? const Color(0xFFEDE7F6) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
              child: Text(type, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isCorporate ? const Color(0xFF7B1FA2) : const Color(0xFF2E7D32))),
            ),
          ]),
          const SizedBox(height: 4),
          if (email.isNotEmpty) Text(email, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          if (phone.isNotEmpty) Text(phone, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ])),
      ]),
    );
  }
}
