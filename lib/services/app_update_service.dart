import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final bool updateAvailable;
  final bool forceUpdate;
  final String latestVersion;
  final String title;
  final String message;
  final String storeUrl;

  const AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersion,
    required this.title,
    required this.message,
    required this.storeUrl,
  });
}

class AppUpdateService {
  AppUpdateService._();

  static const String _configUrl = String.fromEnvironment(
    'APP_UPDATE_CONFIG_URL',
    defaultValue: 'https://eportal.rexinsure.com/api/mobile/app-version',
  );

  static const String _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rexinsure.rexverse';
  static const String _iosStoreUrl =
      'https://apps.apple.com/ng/app/rexverse/id6762462868';

  static Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber =
          int.tryParse(packageInfo.buildNumber.trim()) ?? 0;

      final response = await http.get(
        Uri.parse(_configUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;

      final latestVersion = _stringValue(data, [
        'latest_version',
        'latestVersion',
        'version',
      ]);
      if (latestVersion.isEmpty) return null;

      final latestBuild = _intValue(data, [
        'latest_build_number',
        'latestBuildNumber',
        'build_number',
        'buildNumber',
        'version_code',
        'versionCode',
      ]);
      final minimumVersion = _stringValue(data, [
        'minimum_supported_version',
        'minimumSupportedVersion',
        'min_version',
        'minVersion',
      ]);
      final minimumBuild = _intValue(data, [
        'minimum_supported_build_number',
        'minimumSupportedBuildNumber',
        'min_build_number',
        'minBuildNumber',
      ]);

      final isNewerVersion =
          _compareVersions(latestVersion, currentVersion) > 0;
      final isNewerBuild =
          latestBuild != null && latestBuild > currentBuildNumber;
      final updateAvailable = isNewerVersion || isNewerBuild;
      if (!updateAvailable) return null;

      final versionUnsupported = minimumVersion.isNotEmpty &&
          _compareVersions(currentVersion, minimumVersion) < 0;
      final buildUnsupported =
          minimumBuild != null && currentBuildNumber < minimumBuild;
      final forceUpdate = _boolValue(data, [
            'force_update',
            'forceUpdate',
            'required',
            'is_required',
          ]) ||
          versionUnsupported ||
          buildUnsupported;

      return AppUpdateInfo(
        updateAvailable: updateAvailable,
        forceUpdate: forceUpdate,
        latestVersion: latestVersion,
        title: _stringValue(data, ['title']).isNotEmpty
            ? _stringValue(data, ['title'])
            : 'Update available',
        message: _stringValue(data, ['message']).isNotEmpty
            ? _stringValue(data, ['message'])
            : 'A newer version of Rex Insurance is available.',
        storeUrl: Platform.isIOS
            ? _stringValue(data, ['ios_url', 'iosUrl', 'app_store_url']).trim()
            : _stringValue(
                data,
                ['android_url', 'androidUrl', 'play_store_url'],
              ).trim(),
      ).withFallbackStoreUrl();
    } catch (_) {
      return null;
    }
  }

  static int _compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    final maxLength = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (var i = 0; i < maxLength; i++) {
      final l = i < leftParts.length ? leftParts[i] : 0;
      final r = i < rightParts.length ? rightParts[i] : 0;
      if (l != r) return l.compareTo(r);
    }
    return 0;
  }

  static List<int> _versionParts(String version) {
    final cleaned = version.split('+').first.trim();
    return cleaned
        .split('.')
        .map(
            (part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
  }

  static String _stringValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static int? _intValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  static bool _boolValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is bool) return value;
      final normalized = value?.toString().toLowerCase().trim();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
    }
    return false;
  }
}

extension on AppUpdateInfo {
  AppUpdateInfo withFallbackStoreUrl() {
    if (storeUrl.isNotEmpty) return this;
    return AppUpdateInfo(
      updateAvailable: updateAvailable,
      forceUpdate: forceUpdate,
      latestVersion: latestVersion,
      title: title,
      message: message,
      storeUrl: Platform.isIOS
          ? AppUpdateService._iosStoreUrl
          : AppUpdateService._androidStoreUrl,
    );
  }
}
