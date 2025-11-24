import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // Check authentication status
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  // Mock login
  Future<bool> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', 'user_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('userName', email.split('@')[0]);
      await prefs.setString('userEmail', email);
      
      _isAuthenticated = true;
      _userId = prefs.getString('userId');
      _userName = prefs.getString('userName');
      _userEmail = email;
      
      notifyListeners();
      return true;
    }
    return false;
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
    
    notifyListeners();
  }
}
