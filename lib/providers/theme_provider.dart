import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // null means "follow system", true/false means manual override
  bool? _themeOverride;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Returns the ThemeMode the app should use.
  /// - system (default): follows iOS/Android system setting
  /// - light/dark: manual override
  ThemeMode get themeMode {
    if (_themeOverride == null) return ThemeMode.system;
    return _themeOverride! ? ThemeMode.dark : ThemeMode.light;
  }

  /// Whether the user has manually selected dark mode.
  /// Falls back to false when following system.
  bool get isDarkMode => _themeOverride ?? false;

  /// Whether the app is following the system theme.
  bool get isSystemMode => _themeOverride == null;

  /// Load saved preference. If none saved, stays as system.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('themeOverride')) {
      _themeOverride = prefs.getBool('themeOverride');
    } else {
      _themeOverride = null; // follow system
    }
    notifyListeners();
  }

  /// Toggle between light and dark (manual override).
  Future<void> toggleTheme() async {
    _themeOverride = !(_themeOverride ?? false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themeOverride', _themeOverride!);
    notifyListeners();
  }

  /// Set theme explicitly.
  Future<void> setTheme(bool isDark) async {
    _themeOverride = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('themeOverride', _themeOverride!);
    notifyListeners();
  }

  /// Reset to follow system theme.
  Future<void> useSystemTheme() async {
    _themeOverride = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('themeOverride');
    notifyListeners();
  }
}
