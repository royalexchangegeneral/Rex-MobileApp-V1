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
    await prefs.setBool(_isPendingKey, true);
    await prefs.setString(_targetKey, target);
    await prefs.setString(_productNameKey, productName);
    await prefs.setString(_optionTitleKey, optionTitle);
    await prefs.setString(_priceKey, price);

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

    final target = prefs.getString(_targetKey) ?? '';
    final optionTitle = prefs.getString(_optionTitleKey) ?? '';
    final price = prefs.getString(_priceKey) ?? '';
    final productName = prefs.getString(_productNameKey) ?? '';
    final screen = _screenFor(
      target: target,
      optionTitle: optionTitle,
      price: price,
      productName: productName,
    );

    if (screen == null) return null;
    await _clearPending(prefs);
    return screen;
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
    for (final key in [
      _isPendingKey,
      _targetKey,
      _optionTitleKey,
      _priceKey,
      _productNameKey,
    ]) {
      await prefs.remove(key);
    }
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
