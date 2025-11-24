import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  bool _hasSeenOnboarding = false;
  int _currentPage = 0;

  bool get hasSeenOnboarding => _hasSeenOnboarding;
  int get currentPage => _currentPage;

  // Check if user has completed onboarding
  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    notifyListeners();
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  // Update current page
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', false);
    _hasSeenOnboarding = false;
    _currentPage = 0;
    notifyListeners();
  }
}
