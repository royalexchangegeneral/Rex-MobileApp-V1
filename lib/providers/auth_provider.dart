import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _loginEmail;
  String? _userType; // 'agent' or 'customer'
  String? _userCode;
  String? _profilePhoto;
  Map<String, dynamic>? _userData;

  // Brute force protection
  int _failedLoginAttempts = 0;
  DateTime? _lockoutUntil;
  static const int _maxAttempts = 5;
  static const Duration _lockoutDuration = Duration(seconds: 30);

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get loginEmail => _loginEmail;
  String? get userType => _userType;
  String? get userCode => _userCode;
  String? get profilePhoto => _profilePhoto;
  Map<String, dynamic>? get userData => _userData;
  int get failedLoginAttempts => _failedLoginAttempts;
  int get remainingAttempts => (_maxAttempts - _failedLoginAttempts).clamp(0, _maxAttempts);

  bool isAgent() => _userType == 'agent';
  bool isCustomer() => _userType == 'customer';

  /// Returns true if the account is currently locked out due to too many failed attempts.
  bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      _lockoutUntil = null;
      _failedLoginAttempts = 0;
      return false;
    }
    return true;
  }

  /// Returns the remaining lockout duration, or Duration.zero if not locked.
  Duration get lockoutRemaining {
    if (_lockoutUntil == null) return Duration.zero;
    final remaining = _lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _loginEmail = prefs.getString('loginEmail');
    _userType = prefs.getString('userType');
    _userCode = prefs.getString('userCode');
    _profilePhoto = prefs.getString('profilePhoto');
    
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      _userData = json.decode(userDataString);
    }
    
    notifyListeners();
  }

  /// API login with brute force protection.
  /// Returns a LoginResult with success status and optional error message.
  Future<LoginResult> login(String email, String password) async {
    // Check lockout
    if (isLockedOut) {
      final secs = lockoutRemaining.inSeconds;
      return LoginResult(
        success: false,
        message: 'Too many failed attempts. Try again in $secs seconds.',
      );
    }

    try {
      final requestBody = {
        'userid': email,
        'password': password,
      };

      if (kDebugMode) {
        print('=== LOGIN API REQUEST ===');
        print('URL: https://eportaltest.rexinsure.com/api/userlogin');
        print('=========================');
      }
      
      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/userlogin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('=== LOGIN API RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('==========================');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        final statusCode = data['Statuscode']?.toString() ?? '';
        final status = data['Status']?.toString() ?? '';
        
        if ((statusCode == '201' || statusCode == '200') && status == 'Active') {
          final userData = data['Data'];
          final userTypeCode = userData['UserType']?.toString() ?? '';
          
          // Determine user type: 009 = customer, 007/008/010 = agent
          final userType = userTypeCode == '009' ? 'customer' : 'agent';
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString('userId', data['Userid']?.toString() ?? '');
          await prefs.setString('userName', userData['FirstName']?.toString() ?? '');
          await prefs.setString('userEmail', userData['Email']?.toString() ?? '');
          await prefs.setString('loginEmail', email);
          await prefs.setString('userType', userType);
          await prefs.setString('userCode', userData['Usercode']?.toString() ?? '');
          await prefs.setString('profilePhoto', userData['ProfilePhoto']?.toString() ?? '');
          await prefs.setString('userData', json.encode(userData));
          
          // Update state
          _isAuthenticated = true;
          _userId = data['Userid']?.toString();
          _userName = userData['FirstName']?.toString();
          _userEmail = userData['Email']?.toString();
          _loginEmail = email;
          _userType = userType;
          _userCode = userData['Usercode']?.toString();
          _profilePhoto = userData['ProfilePhoto'];
          _userData = userData;

          // Reset brute force counters on success
          _failedLoginAttempts = 0;
          _lockoutUntil = null;
          
          notifyListeners();
          return LoginResult(success: true);
        } else {
          _recordFailedAttempt();
          return LoginResult(
            success: false,
            message: _failedLoginAttempts >= _maxAttempts
                ? 'Account locked for ${_lockoutDuration.inSeconds} seconds due to too many failed attempts.'
                : 'Invalid credentials. $remainingAttempts attempts remaining.',
          );
        }
      } else {
        _recordFailedAttempt();
        return LoginResult(
          success: false,
          message: 'Server error (${response.statusCode}). $remainingAttempts attempts remaining.',
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return LoginResult(success: false, message: 'Connection error. Please check your internet.');
    }
  }

  void _recordFailedAttempt() {
    _failedLoginAttempts++;
    if (_failedLoginAttempts >= _maxAttempts) {
      _lockoutUntil = DateTime.now().add(_lockoutDuration);
    }
    notifyListeners();
  }

  // Mock signup
  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', 'user_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      await prefs.setString('loginEmail', email);
      
      _isAuthenticated = true;
      _userId = prefs.getString('userId');
      _userName = name;
      _userEmail = email;
      _loginEmail = email;
      
      notifyListeners();
      return true;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('loginEmail');
    await prefs.remove('userType');
    await prefs.remove('userCode');
    await prefs.remove('profilePhoto');
    await prefs.remove('userData');

    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _loginEmail = null;
    _userType = null;
    _userCode = null;
    _profilePhoto = null;
    _userData = null;

    notifyListeners();
  }
}

/// Result of a login attempt, includes success flag and optional message.
class LoginResult {
  final bool success;
  final String? message;
  LoginResult({required this.success, this.message});
}
