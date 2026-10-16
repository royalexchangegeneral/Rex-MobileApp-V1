import 'dart:convert';
import 'package:http/http.dart' as http;

/// Reads policy details using the integration lookup if the workflow token fails.
Future<Map<String, dynamic>> fetchCertificatePolicy(
    String policyNumber, String bearerToken) async {
  final query = {
    'PolicyNo': policyNumber.trim(),
    'IntCode': 'Kissflow',
    'Password': '1lovetoeatcook1es',
  };
  var response = await http.get(
    Uri.https('eportal.rexinsure.com', '/api/kissflow/getpolinfo', query),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    },
  ).timeout(const Duration(seconds: 30));

  dynamic decoded;
  try {
    decoded = jsonDecode(response.body);
  } on FormatException {
    throw const FormatException('Policy lookup returned an invalid response');
  }
  final authError = decoded is Map ? decoded['error'] : null;
  if (response.statusCode == 401 ||
      response.statusCode == 403 ||
      authError == 'invalid_token' ||
      authError == 'missing_bearer_token') {
    response = await http.get(
      Uri.https('eportal.rexinsure.com', '/api/getpolicy', query),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 30));
    decoded = jsonDecode(response.body);
  }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Unable to retrieve policy for certificate');
  }
  if (decoded is Map) {
    final status = decoded['Status'] ?? decoded['status'];
    if (status == false ||
        (status is String &&
            ['error', 'failed', 'failure'].contains(status.toLowerCase())) ||
        decoded['error'] != null) {
      throw Exception('Unable to retrieve policy for certificate');
    }
    final productDetails = decoded['Product Details'];
    if (productDetails is Map) {
      return _policyRecord(productDetails['result']);
    }
    for (final key in [
      'Data',
      'data',
      'PolicyInfo',
      'policyInfo',
      'Policy',
      'policy'
    ]) {
      if (decoded.containsKey(key)) return _policyRecord(decoded[key]);
    }
  }
  return _policyRecord(decoded);
}

Map<String, dynamic> _policyRecord(dynamic value) {
  if (value is List && value.isNotEmpty) value = value.first;
  if (value is Map && value.isNotEmpty) {
    final record = Map<String, dynamic>.from(value);
    if ([
      'PolicyNo',
      'PolicyNumber',
      'policyno',
      'policyNo',
      'polnum',
      'Insured',
      'items'
    ].any((key) => record[key] != null)) return record;
  }
  throw const FormatException('Policy information not found');
}
