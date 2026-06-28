import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

class CustomerDetails {
  static Future<Map<String, String>> signupKycDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nin': prefs.getString('signup_nin') ?? '',
      'firstName': prefs.getString('signup_first_name') ?? '',
      'lastName': prefs.getString('signup_last_name') ?? '',
      'email': prefs.getString('signup_email') ?? '',
      'phone': prefs.getString('signup_phone') ?? '',
      'dob': prefs.getString('signup_dob') ?? '',
      'state': prefs.getString('signup_state') ?? '',
      'lga': prefs.getString('signup_lga') ?? '',
      'address': prefs.getString('signup_address') ?? '',
    };
  }

  static Future<bool> signupNinWasSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('signup_nin_skipped') ?? false;
  }

  static String normalizeApiDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '';

    final dateOnly = text.split(RegExp(r'\s+|T')).first;
    final normalized = dateOnly.replaceAll('/', '-');
    final parts = normalized.split('-');

    if (parts.length == 3) {
      if (parts[0].length == 4) {
        return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
      }
      if (parts[2].length == 4) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    }

    return normalized;
  }

  static Map<String, String> fromClientData(Map<String, dynamic>? data) {
    if (data == null) return const {};

    return {
      'nin': ninFrom(data),
      'firstName': valueFrom(data, const [
        'firstName',
        'FirstName',
        'Firstname',
        'cust_first_name',
        'cust_firstname',
      ]),
      'lastName': valueFrom(data, const [
        'lastName',
        'LastName',
        'Lastname',
        'Surname',
        'cust_last_name',
        'cust_lastname',
      ]),
      'email': valueFrom(data, const ['email', 'Email', 'cust_email']),
      'phone': valueFrom(data, const [
        'phone',
        'Phone',
        'PhoneNo',
        'MobileNo',
        'mobileno',
        'cust_phone',
        'cust_phone_no',
      ]),
      'dob': valueFrom(data, const ['dob', 'DOB', 'DateOfBirth', 'cust_dob']),
      'state': valueFrom(data, const ['state', 'State', 'cust_state']),
      'lga': valueFrom(data, const ['lga', 'LGA', 'cust_lga']),
      'address': valueFrom(data, const [
        'address',
        'Address',
        'ResidentialAddress',
        'cust_address',
      ]),
      'occupation': valueFrom(data, const [
        'occupation',
        'Occupation',
        'cust_occupation',
      ]),
      'gender': valueFrom(data, const ['gender', 'Gender', 'cust_gender']),
    };
  }

  static String valueFrom(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return '';

    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    final lowerKeys = keys.map((key) => key.toLowerCase()).toSet();
    for (final entry in data.entries) {
      if (!lowerKeys.contains(entry.key.toLowerCase())) continue;
      final value = entry.value?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    return '';
  }

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
