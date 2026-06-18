import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class PolicyProvider with ChangeNotifier {
  List<Map<String, dynamic>> _policies = [];
  List<Map<String, dynamic>> _claims = [];
  bool _loading = false;
  int _activePolicies = 0;

  List<Map<String, dynamic>> get policies => _policies;
  List<Map<String, dynamic>> get claims => _claims;
  bool get loading => _loading;
  int get activePolicies => _activePolicies;

  Future<void> fetchPolicies(BuildContext context) async {
    _loading = true;
    notifyListeners();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userData = auth.userData;
      final phone = (userData?['MobileNo']?.toString() ??
              userData?['Phone']?.toString() ??
              userData?['PhoneNo']?.toString() ??
              '')
          .trim();

      if (phone.isEmpty) {
        debugPrint('Fetch policies skipped: no mobile number found for user.');
        _policies = [];
        _claims = [];
        _activePolicies = 0;
      } else {
        await _fetchPoliciesForPhone(phone);
      }
    } on TimeoutException catch (e) {
      debugPrint('Fetch policies timeout: $e');
    } catch (e) {
      debugPrint('Fetch policies error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _fetchPoliciesForPhone(String phone) async {
    final requestBody = {
      'IntCode': 'TESTCODE',
      'Password': 'royal1234',
      'MobileNo': phone,
    };

    debugPrint('=== GET CUSTOMER POLICY REQUEST ===');
    debugPrint('Payload: ${json.encode(requestBody)}');
    debugPrint('===================================');

    final uri = Uri.https(
      'eportaltest.rexinsure.com',
      '/api/getcustomerpolicy',
      {
        'IntCode': 'TESTCODE',
        'Password': 'royal1234',
        'MobileNo': phone,
      },
    );

    debugPrint('=== GET CUSTOMER POLICY URL ===');
    debugPrint(uri.toString());

    final r = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    debugPrint('=== GET CUSTOMER POLICY RESPONSE: ${r.statusCode} ===');
    debugPrint(r.body.length > 500 ? '${r.body.substring(0, 500)}...' : r.body);

    if (r.statusCode == 200 || r.statusCode == 201) {
      final d = json.decode(r.body);
      if (d['status'] == 'success' && d['data'] is List) {
        final customers = d['data'] as List;
        final allPolicies = <Map<String, dynamic>>[];
        final allClaims = <Map<String, dynamic>>[];
        final seenPolicyIds = <String>{};

        for (final customer in customers) {
          final details = customer['PolicyDetails'];
          if (details != null) {
            if (details['Policy'] is List) {
              for (final p in details['Policy']) {
                final policyId = p['PolicyID']?.toString() ?? '';
                if (policyId.isNotEmpty && !seenPolicyIds.contains(policyId)) {
                  seenPolicyIds.add(policyId);
                  allPolicies.add({
                    if (p is Map) ...Map<String, dynamic>.from(p),
                    'policyId': policyId,
                    'premium': p['Premium']?.toString() ?? '',
                    'policyClass': p['PolicyClass']?.toString() ?? '',
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
            if (details['Claim'] is List) {
              for (final c in details['Claim']) {
                if (c['ClaimID'] != null) {
                  allClaims.add(Map<String, dynamic>.from(c));
                }
              }
            }
          }
        }

        _policies = allPolicies;
        _claims = allClaims;
        _activePolicies =
            allPolicies.where((p) => p['status'] == 'Active').length;
      }
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
    _claims = [];
    _activePolicies = 0;
    _loading = false;
    notifyListeners();
  }
}
