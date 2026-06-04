import 'package:flutter/material.dart';

class RenewalGuard {
  static const Duration renewalWindow = Duration(days: 14);

  static bool canRenew(Map<String, dynamic>? policyData) {
    final endDate = _policyEndDate(policyData);
    if (endDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(endDate.year, endDate.month, endDate.day);
    final daysToExpiry = expiryDate.difference(today).inDays;

    return daysToExpiry <= renewalWindow.inDays;
  }

  static Future<void> showNotRenewableDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Policy Still Active'),
        content: const Text(
          'This policy is still active and cannot be renewed until 2 weeks of expiration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static DateTime? _policyEndDate(Map<String, dynamic>? policyData) {
    if (policyData == null) return null;

    final value = policyData['endDate'] ??
        policyData['EndDate'] ??
        policyData['PolicyEndDate'] ??
        policyData['policyEndDate'];

    if (value == null) return null;
    return _parseDate(value.toString());
  }

  static DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed;

    final slashParts = trimmed.split('/');
    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }
}
