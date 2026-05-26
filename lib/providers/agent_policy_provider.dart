import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class AgentPolicyProvider with ChangeNotifier {
  List<Map<String, dynamic>> _policies = [];
  List<Map<String, dynamic>> _customers = [];
  bool _loading = false;
  int _activePolicies = 0;
  int _totalClients = 0;
  String _commission = '0';
  String _totalPremium = '0';
  Map<String, dynamic>? _commissionData;

  List<Map<String, dynamic>> get policies => _policies;
  List<Map<String, dynamic>> get customers => _customers;
  bool get loading => _loading;
  int get activePolicies => _activePolicies;
  int get totalClients => _totalClients;
  String get commission => _commission;
  String get totalPremium => _totalPremium;
  Map<String, dynamic>? get commissionData => _commissionData;

  Future<void> fetchAgentPolicies(BuildContext context) async {
    _loading = true;
    notifyListeners();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final agencyCode = auth.userCode?.toString() ?? '';

      debugPrint('=== AGENT POLICY REQUEST ===');
      debugPrint('AgencyCode: $agencyCode');

      final url =
          'https://eportaltest.rexinsure.com/api/getcustomerpolicytest?IntCode=TESTCODE&Password=royal1234&AgencyCode=$agencyCode';
      final r = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      debugPrint('=== AGENT POLICY RESPONSE: ${r.statusCode} ===');
      debugPrint(
          r.body.length > 500 ? '${r.body.substring(0, 500)}...' : r.body);

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'success' && d['data'] is List) {
          final dataList = d['data'] as List;
          final allPolicies = <Map<String, dynamic>>[];
          final seenPolicyIds = <String>{};
          final seenCustomerIds = <int>{};
          final allCustomers = <Map<String, dynamic>>[];

          for (final customer in dataList) {
            final customerId = customer['CustomerID'] as int? ?? 0;
            if (!seenCustomerIds.contains(customerId)) {
              seenCustomerIds.add(customerId);
              allCustomers.add({
                'customerId': customerId,
                'name':
                    '${customer['Firstname'] ?? ''} ${customer['Surname'] ?? ''}'
                        .trim(),
                'email': customer['Email']?.toString() ?? '',
                'state': customer['State']?.toString() ?? '',
                'clientType': customer['ClientType']?.toString() ?? '',
              });
            }

            final details = customer['PolicyDetails'];
            if (details != null && details['Policy'] is List) {
              for (final p in details['Policy']) {
                final policyId = p['PolicyID']?.toString() ?? '';
                if (policyId.isNotEmpty && !seenPolicyIds.contains(policyId)) {
                  seenPolicyIds.add(policyId);
                  final policyClass = p['PolicyClass']?.toString() ?? '';
                  allPolicies.add({
                    'policyId': policyId,
                    'premium': p['Premium']?.toString() ?? '',
                    'policyClass': policyClass,
                    'category': p['Category']?.toString() ??
                        p['PolicyCategory']?.toString() ??
                        p['ProductCategory']?.toString() ??
                        p['ProductClass']?.toString() ??
                        policyClass,
                    'status': _getPolicyStatus(p['PolicyEndDate']?.toString()),
                    'startDate': p['PolicyStartDate']?.toString() ?? '',
                    'endDate': p['PolicyEndDate']?.toString() ?? '',
                    'insured': p['Insured']?.toString() ?? '',
                    'sumInsured': p['SumInsured']?.toString() ?? '',
                    'customerName':
                        '${customer['Firstname'] ?? ''} ${customer['Surname'] ?? ''}'
                            .trim(),
                  });
                }
              }
            }
          }

          _policies = allPolicies;
          _customers = allCustomers;
          _activePolicies =
              allPolicies.where((p) => p['status'] == 'Active').length;
        }
      }
    } catch (e) {
      debugPrint('Fetch agent policies error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchCustomerCount(BuildContext context) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final agentCode = auth.userCode?.toString() ?? '';
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
      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        if (d['status'] == 'success') {
          _totalClients = d['total_customers'] ??
              (d['data'] is List ? (d['data'] as List).length : 0);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Fetch customer count error: $e');
    }
  }

  Future<void> fetchCommission(BuildContext context,
      {String period = 'this_month'}) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final agentCode = auth.userCode?.toString() ?? '';

      // Calculate date range based on period
      final now = DateTime.now();
      String startDate;
      String endDate;
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      if (period == 'today') {
        startDate = fmt(now);
        endDate = fmt(now);
      } else if (period == 'this_week') {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        startDate = fmt(weekStart);
        endDate = fmt(weekEnd);
      } else {
        // this_month
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        startDate = fmt(monthStart);
        endDate = fmt(monthEnd);
      }

      debugPrint('=== FETCH COMMISSION ===');
      debugPrint(
          'agentcode: $agentCode, period: $period, startdate: $startDate, enddate: $endDate');

      final r = await http.get(
        Uri.parse(
            'https://eportaltest.rexinsure.com/api/get-commission?agentcode=$agentCode&period=$period&startdate=$startDate&enddate=$endDate'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      debugPrint('=== COMMISSION RESPONSE: ${r.statusCode} ===');
      debugPrint(
          r.body.length > 500 ? '${r.body.substring(0, 500)}...' : r.body);

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        _commissionData = d;
        _commission = d['total_commission']?.toString() ??
            d['commission']?.toString() ??
            '0';
        _totalPremium =
            d['total_premium']?.toString() ?? d['premium']?.toString() ?? '0';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch commission error: $e');
    }
  }

  String _getPolicyStatus(String? endDate) {
    if (endDate == null || endDate.isEmpty) return 'Unknown';
    try {
      final end = DateTime.parse(endDate);
      return end.isAfter(DateTime.now()) ? 'Active' : 'Expired';
    } catch (_) {
      return 'Unknown';
    }
  }

  void clear() {
    _policies = [];
    _customers = [];
    _loading = false;
    _activePolicies = 0;
    _totalClients = 0;
    _commission = '0';
    _totalPremium = '0';
    _commissionData = null;
    notifyListeners();
  }

  /// Returns policy counts grouped by month for the last 6 months
  Map<String, int> getPolicyCountsByMonth() {
    final now = DateTime.now();
    final months = <String, int>{};
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    // Initialize last 6 months with 0
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key =
          '${monthNames[date.month - 1]} ${date.year.toString().substring(2)}';
      months[key] = 0;
    }

    for (final p in _policies) {
      final startDate = p['startDate']?.toString() ?? '';
      if (startDate.isEmpty) continue;
      try {
        final date = DateTime.parse(startDate);
        final key =
            '${monthNames[date.month - 1]} ${date.year.toString().substring(2)}';
        if (months.containsKey(key)) {
          months[key] = (months[key] ?? 0) + 1;
        }
      } catch (_) {}
    }
    return months;
  }
}
