import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/error_messages.dart';

/// Centralized payment service.
/// Step 1: Call submit-product-proposal → get reference
/// Step 2: Call initiate-purchase with that reference → get authorization_url
class PaymentService {
  PaymentService._();

  static const String _proposalUrl =
      'https://eportaltest.rexinsure.com/api/submit-product-proposal';
  static const String _purchaseUrl =
      'https://eportaltest.rexinsure.com/api/mobile/initiate-purchase';

  /// Calculate Paystack charge: 1.5% + ₦100, capped at ₦2,000.
  static int calculatePaystackCharge(int premium) {
    double charge = (premium * 0.015) + 100;
    if (charge > 2000) charge = 2000;
    return charge.toInt();
  }

  /// Full purchase flow:
  /// 1. Submit proposal → get reference
  /// 2. Initiate purchase with reference → get Paystack authorization_url
  static Future<PaymentResult> initiatePurchase({
    required String productCode,
    required String names,
    required String email,
    required String mobileno,
    required int premium,
    Map<String, dynamic> extraFields = const {},
    bool includeCredentials = true,
  }) async {
    try {
      // Step 1: Submit product proposal
      final proposalPayload = {
        if (includeCredentials) ...{
          'IntCode': 'TESTCODE',
          'Password': 'royal1234',
        },
        'product_code': productCode,
        'names': names,
        'email': email,
        'mobileno': mobileno,
        'premium': premium,
        ...extraFields,
      };

      if (kDebugMode) {
        print('=== STEP 1: SUBMIT PROPOSAL ===');
        print('URL: $_proposalUrl');
        print('Payload: ${json.encode(proposalPayload)}');
        print('================================');
      }

      final proposalResponse = await http
          .post(
            Uri.parse(_proposalUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(proposalPayload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('=== PROPOSAL RESPONSE ===');
        print('Status: ${proposalResponse.statusCode}');
        print('Body: ${proposalResponse.body}');
        print('=========================');
      }

      if (proposalResponse.statusCode != 200 &&
          proposalResponse.statusCode != 201) {
        return PaymentResult(
            success: false,
            message: ErrorMessages.fromResponse(proposalResponse,
                fallback: 'Failed to submit proposal'));
      }

      final proposalData = json.decode(proposalResponse.body);
      if (proposalData['status'] != true) {
        return PaymentResult(
            success: false,
            message: proposalData['message']?.toString() ??
                'Proposal submission failed');
      }

      // Extract reference from proposal response. Some motor proposal responses
      // return the debit note as the payable reference instead of "reference".
      final proposalRef = proposalData['data']?['reference']?.toString() ??
          proposalData['data']?['Reference']?.toString() ??
          proposalData['data']?['debit_no']?.toString() ??
          proposalData['data']?['debitNo']?.toString() ??
          proposalData['data']?['DebitNo']?.toString() ??
          proposalData['reference']?.toString() ??
          proposalData['debit_no']?.toString() ??
          '';
      if (proposalRef.isEmpty) {
        return PaymentResult(
            success: false, message: 'No reference returned from proposal');
      }

      // Step 2: Initiate purchase with the proposal reference
      final charge = calculatePaystackCharge(premium);
      final totalAmount = premium + charge;

      final purchasePayload = {
        'product_code': productCode,
        'names': names,
        'email': email,
        'mobileno': mobileno,
        'premium': totalAmount,
        'reference': proposalRef,
      };

      if (kDebugMode) {
        print('=== STEP 2: INITIATE PURCHASE ===');
        print('URL: $_purchaseUrl');
        print('Payload: ${json.encode(purchasePayload)}');
        print('=================================');
      }

      final purchaseResponse = await http
          .post(
            Uri.parse(_purchaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(purchasePayload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('=== PURCHASE RESPONSE ===');
        print('Status: ${purchaseResponse.statusCode}');
        print('Body: ${purchaseResponse.body}');
        print('=========================');
      }

      if (purchaseResponse.statusCode == 200 ||
          purchaseResponse.statusCode == 201) {
        final data = json.decode(purchaseResponse.body);
        if (data['status'] == true) {
          final authUrl = data['authorization_url']?.toString() ??
              data['data']?['authorization_url']?.toString();
          final respRef = data['reference']?.toString() ??
              data['data']?['reference']?.toString() ??
              proposalRef;
          if (authUrl != null && authUrl.isNotEmpty) {
            return PaymentResult(
                success: true, authorizationUrl: authUrl, reference: respRef);
          } else {
            return PaymentResult(
                success: false, message: 'No payment URL returned from server');
          }
        } else {
          return PaymentResult(
              success: false,
              message: data['message']?.toString() ??
                  'Purchase initialization failed');
        }
      } else {
        return PaymentResult(
            success: false,
            message: ErrorMessages.fromResponse(purchaseResponse,
                fallback: 'Unable to initiate payment'));
      }
    } catch (e) {
      if (kDebugMode) print('Payment error: $e');
      return PaymentResult(
          success: false,
          message: 'Connection error. Please check your internet.');
    }
  }

  /// Renewal-only flow: skip proposal, go directly to initiate-purchase.
  static Future<PaymentResult> initiateRenewal({
    required String email,
    required int premium,
    required String policyNumber,
    required String names,
    required String mobileno,
    required String productCode,
    required String endDate,
  }) async {
    try {
      final ref =
          'RENEW_${policyNumber}_${DateTime.now().millisecondsSinceEpoch}';

      final payload = {
        'product_code': productCode,
        'names': names,
        'email': email,
        'mobileno': mobileno,
        'premium': premium,
        'PolicyNo': policyNumber,
        'ProdCode': productCode,
        'EndDate': endDate,
      };

      if (kDebugMode) {
        print('=== INITIATE RENEWAL ===');
        print('URL: $_purchaseUrl');
        print('Payload: ${json.encode(payload)}');
        print('========================');
      }

      final response = await http
          .post(
            Uri.parse(_purchaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('=== RENEWAL RESPONSE ===');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        print('========================');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final authUrl = data['authorization_url']?.toString() ??
              data['data']?['authorization_url']?.toString();
          final respRef = data['reference']?.toString() ??
              data['data']?['reference']?.toString() ??
              ref;
          if (authUrl != null && authUrl.isNotEmpty) {
            return PaymentResult(
                success: true, authorizationUrl: authUrl, reference: respRef);
          } else {
            return PaymentResult(
                success: false, message: 'No payment URL returned');
          }
        } else {
          return PaymentResult(
              success: false,
              message: data['message']?.toString() ?? 'Renewal failed');
        }
      } else {
        return PaymentResult(
            success: false,
            message: ErrorMessages.fromResponse(response,
                fallback: 'Unable to initiate renewal'));
      }
    } catch (e) {
      if (kDebugMode) print('Renewal error: $e');
      return PaymentResult(
          success: false,
          message: 'Connection error. Please check your internet.');
    }
  }

  /// CP (Comprehensive) flow — uses multipart form-data for proposal (requires image files).
  /// Step 1: Submit proposal with images → get reference
  /// Step 2: Initiate purchase with reference → get authorization_url
  static Future<PaymentResult> initiateComprehensivePurchase({
    required Map<String, String> fields,
    required List<String> imagePaths,
    required String names,
    required String email,
    required String mobileno,
    required int premium,
  }) async {
    try {
      // Step 1: Submit CP proposal as multipart with images
      final request = http.MultipartRequest('POST', Uri.parse(_proposalUrl));
      request.fields.addAll(fields);
      request.fields['IntCode'] = 'TESTCODE';
      request.fields['Password'] = 'royal1234';

      // Map image files to API field names
      // API requires 7 files: idtype, idtypeb, idtypec, idtyped, idtypee, idtypef, idtypeg
      // We have 5 pre-loss photos → map to idtypec through idtypeg
      // For idtype and idtypeb (Customer ID & Vehicle License), reuse the first photo as placeholder
      final fileKeys = ['idtypec', 'idtyped', 'idtypee', 'idtypef', 'idtypeg'];
      for (int i = 0; i < imagePaths.length && i < fileKeys.length; i++) {
        request.files
            .add(await http.MultipartFile.fromPath(fileKeys[i], imagePaths[i]));
      }
      // Send first photo as placeholder for idtype and idtypeb (required by API)
      if (imagePaths.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('idtype', imagePaths[0]));
        request.files
            .add(await http.MultipartFile.fromPath('idtypeb', imagePaths[0]));
      }

      if (kDebugMode) {
        print('=== STEP 1: SUBMIT CP PROPOSAL (MULTIPART) ===');
        print('URL: $_proposalUrl');
        print('Fields: ${request.fields}');
        print('Files: ${request.files.length}');
        print('================================================');
      }

      final proposalStreamResponse =
          await request.send().timeout(const Duration(seconds: 45));
      final proposalBody = await proposalStreamResponse.stream.bytesToString();

      if (kDebugMode) {
        print('=== CP PROPOSAL RESPONSE ===');
        print('Status: ${proposalStreamResponse.statusCode}');
        print('Body: $proposalBody');
        print('============================');
      }

      if (proposalStreamResponse.statusCode != 200 &&
          proposalStreamResponse.statusCode != 201) {
        String errorMsg = 'Failed to submit proposal';
        try {
          final d = json.decode(proposalBody);
          errorMsg = d['message']?.toString() ?? errorMsg;
        } catch (_) {}
        return PaymentResult(success: false, message: errorMsg);
      }

      final proposalData = json.decode(proposalBody);
      if (proposalData['status'] != true) {
        return PaymentResult(
            success: false,
            message: proposalData['message']?.toString() ?? 'Proposal failed');
      }

      final proposalRef = proposalData['data']?['reference']?.toString() ??
          proposalData['data']?['Reference']?.toString() ??
          proposalData['data']?['debit_no']?.toString() ??
          proposalData['data']?['debitNo']?.toString() ??
          proposalData['data']?['DebitNo']?.toString() ??
          proposalData['reference']?.toString() ??
          proposalData['debit_no']?.toString() ??
          '';
      if (proposalRef.isEmpty) {
        return PaymentResult(
            success: false, message: 'No reference returned from proposal');
      }

      // Step 2: Initiate purchase with the proposal reference
      final charge = calculatePaystackCharge(premium);
      final totalAmount = premium + charge;

      final purchasePayload = {
        'product_code': 'CP',
        'names': names,
        'email': email,
        'mobileno': mobileno,
        'premium': totalAmount,
        'reference': proposalRef,
      };

      if (kDebugMode) {
        print('=== STEP 2: INITIATE CP PURCHASE ===');
        print('URL: $_purchaseUrl');
        print('Payload: ${json.encode(purchasePayload)}');
        print('====================================');
      }

      final purchaseResponse = await http
          .post(
            Uri.parse(_purchaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(purchasePayload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('=== CP PURCHASE RESPONSE ===');
        print('Status: ${purchaseResponse.statusCode}');
        print('Body: ${purchaseResponse.body}');
        print('============================');
      }

      if (purchaseResponse.statusCode == 200 ||
          purchaseResponse.statusCode == 201) {
        final data = json.decode(purchaseResponse.body);
        if (data['status'] == true) {
          final authUrl = data['authorization_url']?.toString() ??
              data['data']?['authorization_url']?.toString();
          final respRef = data['reference']?.toString() ??
              data['data']?['reference']?.toString() ??
              proposalRef;
          if (authUrl != null && authUrl.isNotEmpty) {
            return PaymentResult(
                success: true, authorizationUrl: authUrl, reference: respRef);
          } else {
            return PaymentResult(
                success: false, message: 'No payment URL returned');
          }
        } else {
          return PaymentResult(
              success: false,
              message: data['message']?.toString() ?? 'Purchase failed');
        }
      } else {
        return PaymentResult(
            success: false,
            message: ErrorMessages.fromResponse(purchaseResponse,
                fallback: 'Unable to initiate payment'));
      }
    } catch (e) {
      if (kDebugMode) print('CP payment error: $e');
      return PaymentResult(
          success: false,
          message: 'Connection error. Please check your internet.');
    }
  }
}

/// Result of a payment initiation attempt.
class PaymentResult {
  final bool success;
  final String? authorizationUrl;
  final String? reference;
  final String? message;

  PaymentResult(
      {required this.success,
      this.authorizationUrl,
      this.reference,
      this.message});
}
