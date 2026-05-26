import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_device/safe_device.dart';

/// Handles device-level security checks: root/jailbreak detection,
/// screenshot prevention on sensitive screens via native MethodChannel.
class DeviceSecurityService {
  DeviceSecurityService._();

  static const _channel = MethodChannel('com.rexinsurance/security');

  /// Check if the device is rooted/jailbroken.
  static Future<bool> isDeviceCompromised() async {
    try {
      final isRooted = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;
      return isRooted || !isRealDevice;
    } catch (e) {
      if (kDebugMode) print('Device security check error: $e');
      return false;
    }
  }

  /// Show a warning dialog if the device is rooted/jailbroken.
  static Future<void> checkAndWarn(BuildContext context) async {
    if (kDebugMode) return;

    final compromised = await isDeviceCompromised();
    if (compromised && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Security Warning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          content: const Text(
            'This device appears to be rooted or jailbroken. '
            'Your data may be at risk. We recommend using a secure device for insurance transactions.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('I Understand',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }

  /// Enable FLAG_SECURE via native MethodChannel (Android only).
  static Future<void> enableSecureScreen() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _channel.invokeMethod('enableSecureScreen');
    } on MissingPluginException {
      // Native screenshot protection is only registered on supported builds.
    } catch (e) {
      if (kDebugMode) print('Enable secure screen error: $e');
    }
  }

  /// Disable FLAG_SECURE via native MethodChannel (Android only).
  static Future<void> disableSecureScreen() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _channel.invokeMethod('disableSecureScreen');
    } on MissingPluginException {
      // Native screenshot protection is only registered on supported builds.
    } catch (e) {
      if (kDebugMode) print('Disable secure screen error: $e');
    }
  }
}
