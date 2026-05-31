import 'dart:convert';

import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  static const _keyEmail = 'bio_email';
  static const _keyPassword = 'bio_password';
  static const _keySession = 'bio_session';
  static const _keyEnabled = 'biometric_enabled';

  /// Check if device supports biometrics
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Check if biometric login is enabled by user
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  /// Enable biometric login without storing long-lived password secrets.
  static Future<void> enable(String email) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.delete(key: _keyPassword);
    await saveCurrentSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, true);
  }

  /// Disable biometric and clear credentials
  static Future<void> disable() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keySession);
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
    } catch (_) {
      return false;
    }
  }

  /// Get stored login identifier after biometric auth.
  static Future<String?> getStoredEmail() async {
    await _storage.delete(key: _keyPassword);
    final email = await _storage.read(key: _keyEmail);
    return email != null && email.isNotEmpty ? email : null;
  }

  /// Save the current authenticated app session for biometric unlock.
  static Future<void> saveCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isAuthenticated') ?? false)) return;

    final session = <String, String>{
      'userId': prefs.getString('userId') ?? '',
      'userName': prefs.getString('userName') ?? '',
      'userEmail': prefs.getString('userEmail') ?? '',
      'loginEmail': prefs.getString('loginEmail') ?? '',
      'userType': prefs.getString('userType') ?? '',
      'userCode': prefs.getString('userCode') ?? '',
      'profilePhoto': prefs.getString('profilePhoto') ?? '',
      'userData': prefs.getString('userData') ?? '',
    };

    await _storage.write(key: _keySession, value: json.encode(session));
  }

  /// Get the biometric-protected app session.
  static Future<Map<String, dynamic>?> getStoredSession() async {
    final sessionString = await _storage.read(key: _keySession);
    if (sessionString == null || sessionString.isEmpty) return null;

    try {
      final decoded = json.decode(sessionString);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      await _storage.delete(key: _keySession);
      return null;
    }
  }

  /// Check if a biometric login identifier is stored.
  static Future<bool> hasStoredLogin() async {
    await _storage.delete(key: _keyPassword);
    final email = await _storage.read(key: _keyEmail);
    return email != null && email.isNotEmpty;
  }
}
