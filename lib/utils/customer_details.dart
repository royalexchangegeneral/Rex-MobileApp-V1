import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

class CustomerDetails {
  static Future<String> ninFromAuth(AuthProvider authProvider) async {
    final inMemoryNin = ninFrom(authProvider.userData);
    if (inMemoryNin.isNotEmpty) return inMemoryNin;

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    final signupNin = _usableValue(prefs.getString('signup_nin'));

    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        final decoded = json.decode(userDataString);
        if (decoded is Map) {
          final storedNin = ninFrom(Map<String, dynamic>.from(decoded));
          if (storedNin.isNotEmpty) return storedNin;
        }
      } catch (_) {
        return signupNin;
      }
    }

    return signupNin;
  }

  static String ninFrom(Map<String, dynamic>? data) {
    if (data == null) return '';

    const keys = [
      'NIN',
      'Nin',
      'nin',
      'NationalId',
      'NationalID',
      'nationalId',
      'NationalIdNo',
      'nationalIdNo',
      'NationalIdentificationNumber',
      'nationalIdentificationNumber',
      'NationalIdentityNumber',
      'nationalIdentityNumber',
      'National_Identity_Number',
      'cust_national_id_no',
      'Cust_National_Id_No',
      'CustNationalIdNo',
      'CustNationalIDNo',
      'CustomerNationalIdNo',
      'CustomerNationalIDNo',
      'Customer_National_Id_No',
      'national_id_no',
      'national_id_number',
      'NationalNo',
      'nationalNo',
      'idNumber',
      'IdNumber',
      'IDNumber',
      'IDNo',
      'IdNo',
    ];

    for (final key in keys) {
      final value = _usableValue(data[key]);
      if (value.isNotEmpty) return value;
    }

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;
      if (key.contains('name') || key.contains('type')) continue;

      if (value is Map) {
        final nested = ninFrom(Map<String, dynamic>.from(value));
        if (nested.isNotEmpty) return nested;
      }

      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            final nested = ninFrom(Map<String, dynamic>.from(item));
            if (nested.isNotEmpty) return nested;
          }
        }
      }

      final looksLikeNinField = key.contains('nin') ||
          key.contains('nationalid') ||
          key.contains('national_id') ||
          key.contains('nationalidentity') ||
          key.contains('national_identity');
      if (looksLikeNinField) {
        final text = _usableValue(value);
        if (text.isNotEmpty) return text;
      }
    }

    return '';
  }

  static String _usableValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '';

    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) return digits;

    if (text.toLowerCase() == 'nin') return '';
    return text;
  }
}
