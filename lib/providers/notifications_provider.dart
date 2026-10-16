import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class NotificationsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  Set<int> _readIds = {};
  bool _loading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  Set<int> get readIds => _readIds;
  bool get loading => _loading;
  int get unreadCount => _notifications
      .where((n) => !_readIds.contains(n['id'] ?? _notifications.indexOf(n)))
      .length;

  Future<void> fetchNotifications(BuildContext context) async {
    _loading = true;
    notifyListeners();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userCode = auth.userCode ?? auth.userId ?? '';

      final r = await http.get(
        Uri.parse(
            'https://eportal.rexinsure.com/api/notifications?userId=$userCode'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (r.statusCode == 200 || r.statusCode == 201) {
        final d = json.decode(r.body);
        List<dynamic> list = d is List
            ? d
            : (d is Map && d['data'] is List
                ? d['data']
                : d is Map && d['notifications'] is List
                    ? d['notifications']
                    : []);
        _notifications = list.map((e) => Map<String, dynamic>.from(e)).toList();

        // Pre-mark already read notifications
        _readIds.clear();
        for (final item in _notifications) {
          if (item['is_read'] == true || item['is_read'] == 1) {
            _readIds.add(item['id'] ?? _notifications.indexOf(item));
          }
        }
      } else {
        _notifications = [];
      }
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
      _notifications = [];
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _notifications = [];
    _readIds = {};
    _loading = false;
    notifyListeners();
  }

  Future<void> markAsRead(BuildContext context, int notifId) async {
    if (_readIds.contains(notifId)) return;

    _readIds.add(notifId);
    notifyListeners();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userCode = auth.userCode ?? auth.userId ?? '';

      final body = {'notificationId': notifId, 'userId': userCode};
      final r = await http
          .post(
            Uri.parse(
                'https://eportal.rexinsure.com/api/notifications/mark-read'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint('Mark read response: ${r.statusCode} ${r.body}');
    } catch (e) {
      debugPrint('Mark read error: $e');
      // If failed, remove from readIds
      _readIds.remove(notifId);
      notifyListeners();
    }
  }
}
