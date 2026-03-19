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
      final requestBody = {
        'userid': email,
        'password': password,
      };

      print('=== LOGIN API REQUEST ===');
      print('URL: https://eportaltest.rexinsure.com/api/userlogin');
      print('Request Body: ${json.encode(requestBody)}');
      print('=========================');
      
      final response = await http.post(
        Uri.parse('https://eportaltest.rexinsure.com/api/userlogin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('=== LOGIN API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==========================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        print('=== PARSED LOGIN DATA ===');
        print('All keys: ${data.keys.toList()}');
        print('Statuscode value: "${data['Statuscode']}" (type: ${data['Statuscode'].runtimeType})');
        print('Status value: "${data['Status']}" (type: ${data['Status'].runtimeType})');
        print('=========================');
        
        // Check if login was successful - accept any success indicator
        final statusCode = data['Statuscode']?.toString() ?? '';
        final status = data['Status']?.toString() ?? '';
        
        if ((statusCode == '201' || statusCode == '200') && status == 'Active') {
          final userData = data['Data'];
          final userTypeCode = userData['UserType']?.toString() ?? '';
          
          print('UserType code: $userTypeCode');
          
          // Determine user type based on UserType code
          // 009 = customer, 007/008/010 = agent
          final userType = userTypeCode == '009' ? 'customer' : 'agent';
          
          print('Determined user type: $userType');
          print('Will navigate to: ${userType == "agent" ? "AgentDashboard" : "CustomerDashboard"}');
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString('userId', data['Userid']?.toString() ?? '');
          await prefs.setString('userName', userData['FirstName']?.toString() ?? '');
          await prefs.setString('userEmail', userData['Email']?.toString() ?? '');
          await prefs.setString('userType', userType);
          await prefs.setString('userCode', userData['Usercode']?.toString() ?? '');
          await prefs.setString('profilePhoto', userData['ProfilePhoto']?.toString() ?? '');
          await prefs.setString('userData', json.encode(userData));
          
          // Update state
          _isAuthenticated = true;
          _userId = data['Userid']?.toString();
          _userName = userData['FirstName']?.toString();
          _userEmail = userData['Email']?.toString();
          _userType = userType;
          _userCode = userData['Usercode']?.toString();
          _profilePhoto = userData['ProfilePhoto'];
          _userData = userData;
          
          notifyListeners();
          return true;
        } else {
          print('=== LOGIN CHECK FAILED ===');
          print('statusCode check: $statusCode (expected 200 or 201)');
          print('status check: $status (expected Active)');
          print('==========================');
        }
      } else {
        print('=== LOGIN HTTP FAILED ===');
        print('HTTP Status code: ${response.statusCode} (expected 200 or 201)');
        print('Response: ${response.body}');
        print('=========================');
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
