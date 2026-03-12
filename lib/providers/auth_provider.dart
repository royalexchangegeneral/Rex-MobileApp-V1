import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userType; // 'agent' or 'customer'
  String? _userCode;
  String? _profilePhoto;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userType => _userType;
  String? get userCode => _userCode;
  String? get profilePhoto => _profilePhoto;
  Map<String, dynamic>? get userData => _userData;
  
  bool isAgent() => _userType == 'agent';
  bool isCustomer() => _userType == 'customer';

  // Check authentication status
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userType = prefs.getString('userType');
    _userCode = prefs.getString('userCode');
    _profilePhoto = prefs.getString('profilePhoto');
    
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      _userData = json.decode(userDataString);
    }
    
    notifyListeners();
  }

  // API login
  Future<bool> login(String email, String password) async {
    try {
      debugPrint('Attempting login with email: $email');
      
      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/userlogin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userid': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        debugPrint('Parsed data: $data');
        debugPrint('Statuscode: ${data['Statuscode']}');
        debugPrint('Status: ${data['Status']}');
        
        // Check if login was successful
        if (data['Statuscode'] == '201' && data['Status'] == 'Active') {
          final userData = data['Data'];
          final userTypeCode = userData['UserType'];
          
          debugPrint('UserType code: $userTypeCode');
          
          // Determine user type based on UserType code
          // 009 = customer, 007/008/010 = agent
          final userType = userTypeCode == '009' ? 'customer' : 'agent';
          
          debugPrint('Determined user type: $userType');
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString('userId', data['Userid']);
          await prefs.setString('userName', userData['FirstName']);
          await prefs.setString('userEmail', userData['Email']);
          await prefs.setString('userType', userType);
          await prefs.setString('userCode', userData['Usercode']);
          await prefs.setString('profilePhoto', userData['ProfilePhoto'] ?? '');
          await prefs.setString('userData', json.encode(userData));
          
          // Update state
          _isAuthenticated = true;
          _userId = data['Userid'];
          _userName = userData['FirstName'];
          _userEmail = userData['Email'];
          _userType = userType;
          _userCode = userData['Usercode'];
          _profilePhoto = userData['ProfilePhoto'];
          _userData = userData;
          
          notifyListeners();
          return true;
        } else {
          debugPrint('Login failed - Status check failed');
        }
      } else {
        debugPrint('Login failed - Status code not 200');
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Mock signup
  Future<bool> signup(String name, String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', 'user_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      
      _isAuthenticated = true;
      _userId = prefs.getString('userId');
      _userName = name;
      _userEmail = email;
      
      notifyListeners();
      return true;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userType = null;
    _userCode = null;
    _profilePhoto = null;
    _userData = null;
    
    notifyListeners();
  }
}
