import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/comprehensive_personal_info_screen.dart';
import '../screens/family_care_purchase_screen.dart';
import '../screens/parcel_protection_purchase_screen.dart';
import '../screens/personal_care_purchase_screen.dart';
import '../screens/private_car_purchase_screen.dart';
import '../screens/royal_auto_purchase_screen.dart';
import '../screens/shop_protection_purchase_screen.dart';
import '../screens/signup_screen.dart';

class ExploreKycFlow {
  static const _isPendingKey = 'pending_explore_kyc';
  static const _targetKey = 'pending_explore_target';
  static const _optionTitleKey = 'pending_explore_option_title';
  static const _priceKey = 'pending_explore_price';
  static const _productNameKey = 'pending_explore_product_name';
  static const _isActiveKey = 'active_explore_buy_flow';

  static Future<void> start(
    BuildContext context, {
    required String target,
    required String productName,
    String optionTitle = '',
    String price = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_signup_flow', true);
    await prefs.setBool('has_existing_policy', false);
    await prefs.setBool(_isActiveKey, true);
    await prefs.setBool(_isPendingKey, true);
    await prefs.setString(_targetKey, target);
    await prefs.setString(_productNameKey, productName);
    await prefs.setString(_optionTitleKey, optionTitle);
    await prefs.setString(_priceKey, price);

    debugPrint('=== EXPLORE FLOW KYC START PAYLOAD ===');
    debugPrint('Payload: ${json.encode({
          'target': target,
          'productName': productName,
          'optionTitle': optionTitle,
          'price': price,
          'nextRoute': '/verify-phone',
        })}');
    debugPrint('======================================');

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(
          nextRoute: '/verify-phone',
          title: 'KYC',
          showLoginPrompt: false,
        ),
      ),
    );
  }

  static Future<Widget?> pendingResumeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isPending = prefs.getBool(_isPendingKey) ?? false;
    if (!isPending) return null;

    final screen = await _resumeScreenFromPrefs(prefs);
    if (screen == null) return null;
    await prefs.setBool('is_signup_flow', false);
    await _clearPending(prefs);
    return screen;
  }

  static Future<Widget?> activeResumeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_isActiveKey) ?? false;
    if (!isActive) return null;

    final screen = await _resumeScreenFromPrefs(prefs);
    if (screen == null) return null;
    await prefs.setBool('is_signup_flow', false);
    return screen;
  }

  static Future<Widget?> _resumeScreenFromPrefs(SharedPreferences prefs) async {
    final target = prefs.getString(_targetKey) ?? '';
    final optionTitle = prefs.getString(_optionTitleKey) ?? '';
    final price = prefs.getString(_priceKey) ?? '';
    final productName = prefs.getString(_productNameKey) ?? '';
    final resumePayload = {
      'target': target,
      'productName': productName,
      'optionTitle': optionTitle,
      'price': price,
      'kyc': {
        'nin': prefs.getString('signup_nin') ?? '',
        'firstName': prefs.getString('signup_first_name') ?? '',
        'lastName': prefs.getString('signup_last_name') ?? '',
        'email': prefs.getString('signup_email') ?? '',
        'phone': prefs.getString('signup_phone') ?? '',
        'dob': prefs.getString('signup_dob') ?? '',
        'state': prefs.getString('signup_state') ?? '',
        'lga': prefs.getString('signup_lga') ?? '',
        'address': prefs.getString('signup_address') ?? '',
      },
    };

    debugPrint('=== EXPLORE FLOW RESUME PAYLOAD ===');
    debugPrint('Payload: ${json.encode(resumePayload)}');
    debugPrint('===================================');

    final screen = _screenFor(
      target: target,
      optionTitle: optionTitle,
      price: price,
      productName: productName,
    );

    return screen;
  }

  static Future<bool> isPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPendingKey) ?? false;
  }

  static Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isActiveKey) ?? false;
  }

  static Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _isActiveKey,
      _isPendingKey,
      _targetKey,
      _optionTitleKey,
      _priceKey,
      _productNameKey,
    ]) {
      await prefs.remove(key);
    }
  }

  static Widget? _screenFor({
    required String target,
    required String optionTitle,
    required String price,
    required String productName,
  }) {
    switch (target) {
      case 'private_car':
        return PrivateCarPurchaseScreen(
          vehicleType: optionTitle,
          price: price,
          isExploreFlow: true,
        );
      case 'comprehensive_motor':
        return const ComprehensivePersonalInfoScreen(isExploreFlow: true);
      case 'royal_auto':
        return RoyalAutoPurchaseScreen(
          productName: productName.isEmpty ? optionTitle : productName,
          price: price,
          isExploreFlow: true,
        );
      case 'personal_care':
        return PersonalCarePurchaseScreen(
          optionTitle: optionTitle,
          price: price,
          productName:
              productName.isEmpty ? 'Royal Personal Care' : productName,
          isExploreFlow: true,
        );
      case 'family_care':
        return FamilyCarePurchaseScreen(
          optionTitle: optionTitle,
          price: price,
          isExploreFlow: true,
        );
      case 'shop_protection':
        return ShopProtectionPurchaseScreen(
          optionTitle: optionTitle,
          price: price,
          productName:
              productName.isEmpty ? 'Shop Protection Plan' : productName,
          isExploreFlow: true,
        );
      case 'driver_protection':
        return PersonalCarePurchaseScreen(
          optionTitle: optionTitle,
          price: price,
          productName:
              productName.isEmpty ? 'Driver Protection Plan' : productName,
          isExploreFlow: true,
        );
      case 'parcel_protection':
        return ParcelProtectionPurchaseScreen(
          optionTitle: optionTitle,
          price: price,
          isExploreFlow: true,
        );
      default:
        return null;
    }
  }

  static Future<void> _clearPending(SharedPreferences prefs) async {
    await prefs.remove(_isPendingKey);
  }
}

Future<void> startExploreKycFlow(
  BuildContext context, {
  required String target,
  required String productName,
  String optionTitle = '',
  String price = '',
}) {
  return ExploreKycFlow.start(
    context,
    target: target,
    productName: productName,
    optionTitle: optionTitle,
    price: price,
  );
}
