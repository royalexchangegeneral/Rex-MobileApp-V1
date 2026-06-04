import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
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
  int get remainingAttempts =>
      (_maxAttempts - _failedLoginAttempts).clamp(0, _maxAttempts);

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

  /// Restore a biometric-protected local session without storing the password.
  Future<bool> restoreBiometricSession(Map<String, dynamic> session) async {
    final loginEmail = session['loginEmail']?.toString() ?? '';
    final userType = session['userType']?.toString() ?? '';
    final userDataString = session['userData']?.toString() ?? '';

    if (loginEmail.isEmpty || userType.isEmpty || userDataString.isEmpty) {
      return false;
    }

    Map<String, dynamic> userData;
    try {
      final decoded = json.decode(userDataString);
      userData = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
    } catch (_) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userId', session['userId']?.toString() ?? '');
    await prefs.setString('userName', session['userName']?.toString() ?? '');
    await prefs.setString('userEmail', session['userEmail']?.toString() ?? '');
    await prefs.setString('loginEmail', loginEmail);
    await prefs.setString('userType', userType);
    await prefs.setString('userCode', session['userCode']?.toString() ?? '');
    await prefs.setString(
        'profilePhoto', session['profilePhoto']?.toString() ?? '');
    await prefs.setString('userData', userDataString);

    _isAuthenticated = true;
    _userId = session['userId']?.toString();
    _userName = session['userName']?.toString();
    _userEmail = session['userEmail']?.toString();
    _loginEmail = loginEmail;
    _userType = userType;
    _userCode = session['userCode']?.toString();
    _profilePhoto = session['profilePhoto']?.toString();
    _userData = userData;
    _failedLoginAttempts = 0;
    _lockoutUntil = null;

    notifyListeners();
    return true;
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
      final userId = email.trim();
      final requestBody = {
        'userid': userId,
        'password': password,
      };

      if (kDebugMode) {
        print('=== LOGIN API REQUEST ===');
        print('URL: https://eportaltest.rexinsure.com/api/userlogin');
        print('=========================');
      }

      final response = await http
          .post(
            Uri.parse('https://eportaltest.rexinsure.com/api/userlogin'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('=== LOGIN API RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('==========================');
      }

      final data = _decodeResponseBody(response.body);
      final apiMessage = _messageFrom(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = _asMap(_read(data, 'Data') ?? _read(data, 'data'));

        final statusCode = _read(data, 'Statuscode')?.toString() ??
            _read(data, 'StatusCode')?.toString() ??
            '';
        final status = (_read(data, 'Status')?.toString() ?? '').toLowerCase();
        final userStatus =
            (_read(userData, 'Status')?.toString() ?? '').toLowerCase();
        final hasSuccessCode =
            statusCode == '201' || statusCode == '200' || statusCode.isEmpty;
        final hasSuccessStatus = status.isEmpty ||
            status == 'active' ||
            status == 'success' ||
            status == 'successful' ||
            status.contains('success');
        final hasActiveUser =
            userStatus.isEmpty || userStatus == 'active' || userStatus == '1';

        if (hasSuccessCode &&
            hasSuccessStatus &&
            hasActiveUser &&
            userData.isNotEmpty) {
          final userTypeCode = _read(userData, 'UserType')?.toString() ?? '';

          // Determine user type: 009 = customer, 007/008/010 = agent
          final userType = userTypeCode == '009' ? 'customer' : 'agent';

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString(
              'userId', _read(data, 'Userid')?.toString() ?? '');
          await prefs.setString(
              'userName', _read(userData, 'FirstName')?.toString() ?? '');
          await prefs.setString(
              'userEmail', _read(userData, 'Email')?.toString() ?? '');
          await prefs.setString('loginEmail', userId);
          await prefs.setString('userType', userType);
          await prefs.setString(
              'userCode', _read(userData, 'Usercode')?.toString() ?? '');
          await prefs.setString('profilePhoto',
              _read(userData, 'ProfilePhoto')?.toString() ?? '');
          await prefs.setString('userData', json.encode(userData));

          // Update state
          _isAuthenticated = true;
          _userId = _read(data, 'Userid')?.toString();
          _userName = _read(userData, 'FirstName')?.toString();
          _userEmail = _read(userData, 'Email')?.toString();
          _loginEmail = userId;
          _userType = userType;
          _userCode = _read(userData, 'Usercode')?.toString();
          _profilePhoto = _read(userData, 'ProfilePhoto')?.toString();
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
                : (apiMessage.isEmpty ? 'Invalid credentials.' : apiMessage),
          );
        }
      } else {
        return LoginResult(
          success: false,
          message: apiMessage.isEmpty
              ? 'Server error (${response.statusCode}). Please try again.'
              : apiMessage,
        );
      }
    } on TimeoutException {
      return LoginResult(
          success: false,
          message: 'Login request timed out. Please try again.');
    } catch (e) {
      debugPrint('Login error: $e');
      return LoginResult(
          success: false,
          message: 'Connection error. Please check your internet.');
    }
  }

  void _recordFailedAttempt() {
    _failedLoginAttempts++;
    if (_failedLoginAttempts >= _maxAttempts) {
      _lockoutUntil = DateTime.now().add(_lockoutDuration);
    }
    notifyListeners();
  }

  dynamic _read(Map<String, dynamic> map, String key) {
    if (map.containsKey(key)) return map[key];
    final lowerKey = key.toLowerCase();
    for (final entry in map.entries) {
      if (entry.key.toLowerCase() == lowerKey) return entry.value;
    }
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _decodeResponseBody(String body) {
    try {
      final decoded = json.decode(body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  String _messageFrom(Map<String, dynamic> data) {
    final message = _read(data, 'message') ??
        _read(data, 'Message') ??
        _read(data, 'StatusMessage') ??
        _read(data, 'statusMessage') ??
        _read(data, 'error') ??
        _read(data, 'Error');
    return message?.toString().trim() ?? '';
  }

  // Mock signup used while live registration APIs are disabled.
  Future<bool> signup(
    String name,
    String email,
    String password, {
    Map<String, dynamic>? userData,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      final userId = 'mock_${DateTime.now().millisecondsSinceEpoch}';
      final data = <String, dynamic>{
        'FirstName': name.split(' ').first,
        'Surname': name.split(' ').skip(1).join(' '),
        'Email': email,
        'UserType': '009',
        'Usercode': userId,
        ...?userData,
      };
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', userId);
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      await prefs.setString('loginEmail', email);
      await prefs.setString('userType', 'customer');
      await prefs.setString('userCode', userId);
      await prefs.setString('userData', json.encode(data));

      _isAuthenticated = true;
      _userId = userId;
      _userName = name;
      _userEmail = email;
      _loginEmail = email;
      _userType = 'customer';
      _userCode = userId;
      _userData = data;

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
