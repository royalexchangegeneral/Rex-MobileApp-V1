import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'select_client_type_screen.dart';
import 'new_policy_screen.dart';

class SelectClientScreen extends StatefulWidget {
  const SelectClientScreen({super.key});
  @override
  State<SelectClientScreen> createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  int _selectedFilterIndex = 0;
  final _searchController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _customers = [];

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
      final r = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/agent/customers'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({'agent_code': agentCode}),
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'success' && d['data'] is List) {
          _customers = (d['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) { print('Fetch customers error: $e'); }
    setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _customers;
    final query = _searchController.text.toLowerCase().trim();
    if (_selectedFilterIndex == 1) list = list.where((c) => c['cust_type']?.toString().toLowerCase() == 'individual').toList();
    if (_selectedFilterIndex == 2) list = list.where((c) => c['cust_type']?.toString().toLowerCase() == 'corporate').toList();
    if (query.isNotEmpty) {
      list = list.where((c) {
        final name = '${c['cust_first_name'] ?? ''} ${c['cust_last_name'] ?? ''}'.toLowerCase();
        final email = (c['cust_email'] ?? '').toString().toLowerCase();
        final phone = (c['cust_phone'] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query) || phone.contains(query);
      }).toList();
    }
    return list;
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  String _getInitials(Map<String, dynamic> c) {
    final f = (c['cust_first_name'] ?? '').toString();
    final l = (c['cust_last_name'] ?? '').toString();
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
  }

  String _getName(Map<String, dynamic> c) {
    final f = c['cust_first_name']?.toString() ?? '';
    final m = c['cust_middle_name']?.toString() ?? '';
    final l = c['cust_last_name']?.toString() ?? '';
    return '$f ${m.isNotEmpty ? "$m " : ""}$l'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filtered;
    final individualCount = _customers.where((c) => c['cust_type']?.toString().toLowerCase() == 'individual').length;
    final corporateCount = _customers.where((c) => c['cust_type']?.toString().toLowerCase() == 'corporate').length;
    final recent = _customers.take(4).toList();
    final colors = [const Color(0xFF1E2D64), const Color(0xFFFF6B35), const Color(0xFFE63946), const Color(0xFF0066FF)];

    return Scaffold(
      appBar: AppBar(elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Select Client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)), centerTitle: true),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Recent
        if (recent.isNotEmpty) Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Recent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 12),
          SizedBox(height: 72, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(recent.length, (i) {
            final c = recent[i];
            return _buildRecentCard(c, colors[i % colors.length]);
          }))),
        ])),
        // Search
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: TextField(
          controller: _searchController, onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(hintText: 'Search name, email or phone', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]), filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
        const SizedBox(height: 16),
        // Filters
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _chip('All (${_customers.length})', 0), const SizedBox(width: 8),
          _chip('Individual ($individualCount)', 1), const SizedBox(width: 8),
          _chip('Corporate ($corporateCount)', 2),
        ]))),
        const SizedBox(height: 16),
        // List
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
            ? Center(child: Text('No clients found', style: TextStyle(color: Colors.grey[500], fontSize: 13)))
            : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: customers.length,
                itemBuilder: (_, i) => _buildClientCard(customers[i]))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectClientTypeScreen())),
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New client', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      bottomNavigationBar: buildAgentBottomNav(context, currentIndex: 2),
    );
  }

  Widget _buildRecentCard(Map<String, dynamic> c, Color color) {
    final initials = _getInitials(c);
    final name = _getName(c);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewPolicyScreen(isAgent: true, clientData: c))),
      child: Container(width: 85, margin: EdgeInsets.only(right: 10), padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)))),
          SizedBox(height: 3),
          Text(name, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, height: 1.0), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 1),
          Text(c['cust_type']?.toString() ?? '', style: TextStyle(fontSize: 7, color: Colors.grey[600], height: 1.0), maxLines: 1),
        ])));
  }

  Widget _chip(String label, int index) {
    final sel = _selectedFilterIndex == index;
    return GestureDetector(onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: sel ? const Color(0xFF1E2D64) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? const Color(0xFF1E2D64) : Colors.grey[300]!)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: sel ? Colors.white : Colors.black))));
  }

  Widget _buildClientCard(Map<String, dynamic> c) {
    final name = _getName(c);
    final email = c['cust_email']?.toString() ?? '';
    final phone = c['cust_phone']?.toString() ?? '';
    final type = c['cust_type']?.toString() ?? '';
    final isCorporate = type.toLowerCase() == 'corporate';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewPolicyScreen(isAgent: true, clientData: c))),
      child: Container(margin: EdgeInsets.only(bottom: 12), padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: isCorporate ? const Color(0xFFE8EAF6) : const Color(0xFFE3F2FD),
            child: Icon(isCorporate ? Icons.business : Icons.person, color: const Color(0xFF1E2D64), size: 24)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(name.isNotEmpty ? name : 'Unknown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: isCorporate ? const Color(0xFFEDE7F6) : const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                child: Text(type, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isCorporate ? const Color(0xFF7B1FA2) : const Color(0xFF2E7D32)))),
            ]),
            const SizedBox(height: 4),
            if (email.isNotEmpty) Text(email, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            if (phone.isNotEmpty) Text(phone, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ])),
        ])));
  }
}
