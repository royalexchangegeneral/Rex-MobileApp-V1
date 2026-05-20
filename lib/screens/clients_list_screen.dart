import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardColor => _isDark ? const Color(0xFF111827) : Colors.grey[50]!;

  Color get _borderColor =>
      _isDark ? const Color(0xFF334155) : Colors.grey[200]!;

  Color get _secondaryTextColor =>
      _isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color get _agentAccent =>
      _isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

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

      debugPrint('=== FETCH AGENT CUSTOMERS ===');
      debugPrint('agent_code: $agentCode');

      final r = await http
          .post(
            Uri.parse('https://eportaltest.rexinsure.com/api/agent/customers'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json'
            },
            body: json.encode({'agent_code': agentCode}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('=== CUSTOMERS RESPONSE: ${r.statusCode} ===');
      debugPrint(
          r.body.length > 500 ? '${r.body.substring(0, 500)}...' : r.body);

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'success' && d['data'] is List) {
          _customers = (d['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          _totalCustomers = d['total_customers'] ?? _customers.length;
        }
      }
    } catch (e) {
      debugPrint('Fetch customers error: $e');
    }
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _customers;
    final query = _searchController.text.toLowerCase().trim();
    // Filter by type
    if (_selectedFilterIndex == 1) {
      list = list
          .where(
              (c) => c['cust_type']?.toString().toLowerCase() == 'individual')
          .toList();
    } else if (_selectedFilterIndex == 2) {
      list = list
          .where((c) => c['cust_type']?.toString().toLowerCase() == 'corporate')
          .toList();
    }

    // Search
    if (query.isNotEmpty) {
      list = list.where((c) {
        final name =
            '${c['cust_first_name'] ?? ''} ${c['cust_middle_name'] ?? ''} ${c['cust_last_name'] ?? ''}'
                .toLowerCase();
        final email = (c['cust_email'] ?? '').toString().toLowerCase();
        final phone = (c['cust_phone'] ?? '').toString().toLowerCase();
        final id = (c['cust_id'] ?? '').toString();
        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            id.contains(query);
      }).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filtered;
    final individualCount = _customers
        .where((c) => c['cust_type']?.toString().toLowerCase() == 'individual')
        .length;
    final corporateCount = _customers
        .where((c) => c['cust_type']?.toString().toLowerCase() == 'corporate')
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context)),
        title: Text('Clients',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search name, email or phone',
                hintStyle: TextStyle(color: _secondaryTextColor, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: _secondaryTextColor),
                filled: true,
                fillColor: _isDark ? _cardColor : Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _borderColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _borderColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _agentAccent)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    ? Center(
                        child: Text('No clients found',
                            style: TextStyle(
                                color: _secondaryTextColor, fontSize: 13)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) =>
                            _buildClientCard(customers[index]),
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
                color: _isDark ? _cardColor : Colors.grey[100],
                border: Border(top: BorderSide(color: _borderColor))),
            child: Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: _agentAccent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Showing ${customers.length} of $_totalCustomers clients',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface)),
            ]),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SelectClientTypeScreen())),
          backgroundColor: const Color(0xFFFF6B35),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New client',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
          color: isSelected ? _agentAccent : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _agentAccent : _borderColor),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (_isDark ? Colors.black : Colors.white)
                    : Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> c) {
    final firstName = c['cust_first_name']?.toString() ?? '';
    final middleName = c['cust_middle_name']?.toString() ?? '';
    final lastName = c['cust_last_name']?.toString() ?? '';
    final name =
        '$firstName ${middleName.isNotEmpty ? "$middleName " : ""}$lastName'
            .trim();
    final email = c['cust_email']?.toString() ?? '';
    final phone = c['cust_phone']?.toString() ?? '';
    final type = c['cust_type']?.toString() ?? '';
    final isCorporate = type.toLowerCase() == 'corporate';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _isDark
              ? _agentAccent.withValues(alpha: 0.14)
              : isCorporate
                  ? const Color(0xFFE8EAF6)
                  : const Color(0xFFE3F2FD),
          child: Icon(isCorporate ? Icons.business : Icons.person,
              color: _agentAccent, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(name.isNotEmpty ? name : 'Unknown',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: isCorporate
                      ? const Color(0xFF7B1FA2).withValues(alpha: 0.14)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(type,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isCorporate
                          ? const Color(0xFF7B1FA2)
                          : const Color(0xFF2E7D32))),
            ),
          ]),
          const SizedBox(height: 4),
          if (email.isNotEmpty)
            Text(email,
                style: TextStyle(fontSize: 11, color: _secondaryTextColor)),
          if (phone.isNotEmpty)
            Text(phone,
                style: TextStyle(fontSize: 11, color: _secondaryTextColor)),
        ])),
      ]),
    );
  }
}
