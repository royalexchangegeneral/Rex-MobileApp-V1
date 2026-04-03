import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  static const _keyEmail = 'bio_email';
  static const _keyPassword = 'bio_password';
  static const _keyEnabled = 'biometric_enabled';

  /// Check if device supports biometrics
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) { return false; }
  }

  /// Check if biometric login is enabled by user
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  /// Enable biometric and store credentials
  static Future<void> enable(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, true);
  }

  /// Disable biometric and clear credentials
  static Future<void> disable() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, false);
  }

  /// Authenticate with biometrics
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to login to RexVerse',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) { return false; }
  }

  /// Get stored credentials after biometric auth
  static Future<Map<String, String>?> getCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Check if credentials are stored
  static Future<bool> hasStoredCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    return email != null && email.isNotEmpty;
  }
}
