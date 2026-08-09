import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/error_messages.dart';

/// Centralized payment service.
/// Step 1: Call submit-product-proposal → get reference
/// Step 2: Call initiate-purchase with that reference → get authorization_url
class PaymentService {
  PaymentService._();

  static const String _paymentBaseUrl = 'https://eportaltest.rexinsure.com';
  static const String _proposalUrl =
      '$_paymentBaseUrl/api/submit-product-proposal';
  static const String _purchaseUrl =
      '$_paymentBaseUrl/api/mobile/initiate-purchase';
  static const String _agentSellingPriceUrl =
      '$_paymentBaseUrl/api/mobile/agent-selling-price';
  static const JsonEncoder _prettyJson = JsonEncoder.withIndent('  ');

  static void _logLong(String value) {
    const chunkSize = 900;
    if (value.length <= chunkSize) {
      debugPrint(value);
      return;
    }

    for (var start = 0; start < value.length; start += chunkSize) {
      final end = (start + chunkSize).clamp(0, value.length);
      debugPrint(value.substring(start, end));
    }
  }

  static String _formatPayload(dynamic payload) {
    try {
      return _prettyJson.convert(payload);
    } catch (_) {
      return payload.toString();
    }
  }

  static void _logPaymentRequest(
    String journey,
    String stage, {
    required String method,
    required String url,
    dynamic payload,
    dynamic files,
  }) {
    debugPrint('================ PAYMENT REQUEST ================');
    debugPrint('Journey: $journey');
    debugPrint('Stage: $stage');
    debugPrint('Method: $method');
    debugPrint('URL: $url');
    if (payload != null) {
      debugPrint('Payload:');
      _logLong(_formatPayload(payload));
    }
    if (files != null) {
      debugPrint('Files:');
      _logLong(_formatPayload(files));
    }
    debugPrint('=================================================');
  }

  static void _logPaymentResponse(
    String journey,
    String stage, {
    required int statusCode,
    required String body,
  }) {
    debugPrint('================ PAYMENT RESPONSE ===============');
    debugPrint('Journey: $journey');
    debugPrint('Stage: $stage');
    debugPrint('Status: $statusCode');
    debugPrint('Body:');
    _logLong(body);
    debugPrint('=================================================');
  }

  static void _logPaymentError(
    String stage,
    String message, {
    http.Response? response,
    Object? error,
    String? responseBody,
    int? statusCode,
  }) {
    debugPrint('================ PAYMENT ERROR ================');
    debugPrint('Stage: $stage');
    debugPrint('Message: $message');
    final status = response?.statusCode ?? statusCode;
    if (status != null) debugPrint('Status: $status');
    final body = response?.body ?? responseBody;
    if (body != null && body.isNotEmpty) debugPrint('Body: $body');
    if (error != null) debugPrint('Exception: $error');
    debugPrint('===============================================');
  }

  static PaymentResult _failure(
    String stage,
    String message, {
    http.Response? response,
    Object? error,
    String? responseBody,
    int? statusCode,
  }) {
    _logPaymentError(
      stage,
      message,
      response: response,
      error: error,
      responseBody: responseBody,
      statusCode: statusCode,
    );
    return PaymentResult(success: false, message: message);
  }

  /// Calculate Paystack charge: 1.5% + ₦100, capped at ₦2,000.
  static int calculatePaystackCharge(int premium) {
    double charge = (premium * 0.015) + 100;
    if (charge > 2000) charge = 2000;
    return charge.toInt();
  }

  static void _addAgentFields(
    Map<String, dynamic> payload,
    String agentCode,
    String agentUserType,
  ) {
    if (agentCode.isEmpty) return;

    payload['agentcode'] = agentCode;
    payload['agent_code'] = agentCode;
    payload['AgencyCode'] = agentCode;
    payload['Usercode'] = agentCode;
    if (agentUserType.isNotEmpty) {
      payload['UserType'] = agentUserType;
    }
  }

  static void _addAgentStringFields(
    Map<String, String> fields,
    String agentCode,
    String agentUserType,
  ) {
    if (agentCode.isEmpty) return;

    fields['agentcode'] = agentCode;
    fields['agent_code'] = agentCode;
    fields['AgencyCode'] = agentCode;
    fields['Usercode'] = agentCode;
    if (agentUserType.isNotEmpty) {
      fields['UserType'] = agentUserType;
    }
  }

  static String subProductCodeForOption(
      String productCode, String optionTitle) {
    final normalizedProductCode = productCode.trim().toUpperCase();
    final normalizedOption = optionTitle.trim().toLowerCase();

    const optionSuffixes = {
      'option a': 'A',
      'option b': 'B',
      'option c': 'C',
      'option d': 'D',
      'option e': 'E',
    };

    final suffix = optionSuffixes[normalizedOption];
    if (suffix == null || normalizedProductCode.isEmpty) {
      return normalizedProductCode;
    }
    return '$normalizedProductCode$suffix';
  }

  static int? _intFrom(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();

    final cleaned = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned)?.round();
  }

  static int? _findNetPremium(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      const keys = [
        'netpremium',
        'netPremium',
        'NetPremium',
        'NETPREMIUM',
        'net_premium',
      ];

      for (final key in keys) {
        final amount = _intFrom(map[key]);
        if (amount != null && amount > 0) return amount;
      }

      for (final value in map.values) {
        final nested = _findNetPremium(value);
        if (nested != null && nested > 0) return nested;
      }
    }

    if (data is List) {
      for (final item in data) {
        final nested = _findNetPremium(item);
        if (nested != null && nested > 0) return nested;
      }
    }

    return null;
  }

  static Future<int?> _agentSellingNetPremium({
    required String agentCode,
    required String productCode,
    required String subProductCode,
  }) async {
    final normalizedAgentCode = agentCode.trim();
    if (normalizedAgentCode.isEmpty) return null;

    final payload = {
      'IntCode': 'TESTCODE',
      'Password': 'royal1234',
      'agentcode': normalizedAgentCode,
      'productcode': productCode.trim().toUpperCase(),
      'subproductcode': subProductCode.trim().toUpperCase(),
    };

    if (kDebugMode) {
      debugPrint('=== AGENT SELLING PRICE REQUEST ===');
      debugPrint('URL: $_agentSellingPriceUrl');
      debugPrint('Payload: ${json.encode(payload)}');
      debugPrint('===================================');
    }
    _logPaymentRequest(
      'Buy/Renewal',
      'Agent selling price',
      method: 'POST application/json',
      url: _agentSellingPriceUrl,
      payload: payload,
    );

    try {
      final response = await http
          .post(
            Uri.parse(_agentSellingPriceUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('=== AGENT SELLING PRICE RESPONSE ===');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        debugPrint('====================================');
      }
      _logPaymentResponse(
        'Buy/Renewal',
        'Agent selling price',
        statusCode: response.statusCode,
        body: response.body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _logPaymentError(
          'Agent selling price',
          'Unable to get agent selling price',
          response: response,
        );
        return null;
      }

      final data = json.decode(response.body);
      return _findNetPremium(data);
    } catch (e) {
      _logPaymentError(
        'Agent selling price',
        'Unable to get agent selling price',
        error: e,
      );
      return null;
    }
  }

  static bool _usesCalculatedAgentPremium(String productCode) {
    return {'CP', 'RAS', 'RAB'}.contains(productCode.trim().toUpperCase());
  }

  static bool usesCalculatedAgentPremium(String productCode) {
    return _usesCalculatedAgentPremium(productCode);
  }

  static Future<int?> agentSellingNetPremium({
    required String agentCode,
    required String productCode,
    required String subProductCode,
  }) {
    return _agentSellingNetPremium(
      agentCode: agentCode,
      productCode: productCode,
      subProductCode: subProductCode,
    );
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
    String? agentCode,
    String? agentUserType,
    String? payerEmail,
    String? subProductCode,
    bool includeCredentials = true,
    bool isExploreFlow = false,
  }) async {
    try {
      final normalizedAgentCode = agentCode?.trim() ?? '';
      final normalizedAgentUserType = agentUserType?.trim() ?? '';
      final paymentEmail =
          payerEmail?.trim().isNotEmpty == true ? payerEmail!.trim() : email;
      final shouldUseAgentSellingPrice = normalizedAgentCode.isNotEmpty &&
          !_usesCalculatedAgentPremium(productCode);
      final agentNetPremium = shouldUseAgentSellingPrice
          ? await _agentSellingNetPremium(
              agentCode: normalizedAgentCode,
              productCode: productCode,
              subProductCode: subProductCode ?? productCode,
            )
          : null;
      if (shouldUseAgentSellingPrice && agentNetPremium == null) {
        return _failure(
          'Agent selling price',
          'Unable to get agent selling price',
        );
      }
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
      _addAgentFields(
          proposalPayload, normalizedAgentCode, normalizedAgentUserType);

      if (kDebugMode) {
        debugPrint(isExploreFlow
            ? '=== EXPLORE FLOW STEP 1: SUBMIT PROPOSAL ==='
            : '=== STEP 1: SUBMIT PROPOSAL ===');
        debugPrint('URL: $_proposalUrl');
        debugPrint('Payload: ${json.encode(proposalPayload)}');
        debugPrint('================================');
      }
      _logPaymentRequest(
        isExploreFlow ? 'Explore buy' : 'Buy',
        'Submit proposal',
        method: 'POST application/json',
        url: _proposalUrl,
        payload: proposalPayload,
      );

      final proposalResponse = await http
          .post(
            Uri.parse(_proposalUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(proposalPayload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint(isExploreFlow
            ? '=== EXPLORE FLOW PROPOSAL RESPONSE ==='
            : '=== PROPOSAL RESPONSE ===');
        debugPrint('Status: ${proposalResponse.statusCode}');
        debugPrint('Body: ${proposalResponse.body}');
        debugPrint('=========================');
      }
      _logPaymentResponse(
        isExploreFlow ? 'Explore buy' : 'Buy',
        'Submit proposal',
        statusCode: proposalResponse.statusCode,
        body: proposalResponse.body,
      );

      if (proposalResponse.statusCode != 200 &&
          proposalResponse.statusCode != 201) {
        final message = ErrorMessages.fromResponse(proposalResponse,
            fallback: 'Failed to submit proposal');
        return _failure(
          'Submit proposal',
          message,
          response: proposalResponse,
        );
      }

      final proposalData = json.decode(proposalResponse.body);
      if (proposalData['status'] != true) {
        final message =
            proposalData['message']?.toString() ?? 'Proposal submission failed';
        return _failure(
          'Submit proposal',
          message,
          response: proposalResponse,
        );
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
        return _failure(
          'Submit proposal',
          'No reference returned from proposal',
          response: proposalResponse,
        );
      }

      // Step 2: Initiate purchase with the proposal reference
      final payablePremium = agentNetPremium ?? premium;
      final charge = calculatePaystackCharge(payablePremium);
      final totalAmount = payablePremium + charge;
      if (kDebugMode && normalizedAgentCode.isNotEmpty) {
        debugPrint('=== AGENT PAYSTACK AMOUNT ===');
        debugPrint('Original premium: $premium');
        debugPrint(shouldUseAgentSellingPrice
            ? 'Agent netpremium: $payablePremium'
            : 'Calculated premium: $payablePremium');
        debugPrint('Paystack charge: $charge');
        debugPrint('Paystack total: $totalAmount');
        debugPrint('=============================');
      }

      final purchasePayload = {
        'IntCode': 'TESTCODE',
        'Password': 'royal1234',
        'product_code': productCode,
        'names': names,
        'email': paymentEmail,
        'mobileno': mobileno,
        'premium': totalAmount,
        'reference': proposalRef,
      };
      _addAgentFields(
          purchasePayload, normalizedAgentCode, normalizedAgentUserType);

      if (kDebugMode) {
        debugPrint(isExploreFlow
            ? '=== EXPLORE FLOW STEP 2: INITIATE PURCHASE ==='
            : '=== STEP 2: INITIATE PURCHASE ===');
        debugPrint('URL: $_purchaseUrl');
        debugPrint('Payload: ${json.encode(purchasePayload)}');
        debugPrint('=================================');
      }
      _logPaymentRequest(
        isExploreFlow ? 'Explore buy' : 'Buy',
        'Initiate purchase',
        method: 'POST application/json',
        url: _purchaseUrl,
        payload: purchasePayload,
      );

      final purchaseResponse = await http
          .post(
            Uri.parse(_purchaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(purchasePayload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint(isExploreFlow
            ? '=== EXPLORE FLOW PURCHASE RESPONSE ==='
            : '=== PURCHASE RESPONSE ===');
        debugPrint('Status: ${purchaseResponse.statusCode}');
        debugPrint('Body: ${purchaseResponse.body}');
        debugPrint('=========================');
      }
      _logPaymentResponse(
        isExploreFlow ? 'Explore buy' : 'Buy',
        'Initiate purchase',
        statusCode: purchaseResponse.statusCode,
        body: purchaseResponse.body,
      );

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
            return _failure(
              'Initiate purchase',
              'No payment URL returned from server',
              response: purchaseResponse,
            );
          }
        } else {
          final message =
              data['message']?.toString() ?? 'Purchase initialization failed';
          return _failure(
            'Initiate purchase',
            message,
            response: purchaseResponse,
          );
        }
      } else {
        final message = ErrorMessages.fromResponse(purchaseResponse,
            fallback: 'Unable to initiate payment');
        return _failure(
          'Initiate purchase',
          message,
          response: purchaseResponse,
        );
      }
    } catch (e) {
      return _failure(
        'Payment flow',
        'Connection error. Please check your internet.',
        error: e,
      );
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
    String? agentCode,
    String? agentUserType,
    String? payerEmail,
    String? subProductCode,
  }) async {
    try {
      final normalizedAgentCode = agentCode?.trim() ?? '';
      final normalizedAgentUserType = agentUserType?.trim() ?? '';
      final paymentEmail =
          payerEmail?.trim().isNotEmpty == true ? payerEmail!.trim() : email;

      final shouldUseAgentSellingPrice = normalizedAgentCode.isNotEmpty &&
          !_usesCalculatedAgentPremium(productCode);
      final agentNetPremium = shouldUseAgentSellingPrice
          ? await _agentSellingNetPremium(
              agentCode: normalizedAgentCode,
              productCode: productCode,
              subProductCode: subProductCode ?? productCode,
            )
          : null;
      if (shouldUseAgentSellingPrice && agentNetPremium == null) {
        return _failure(
          'Agent selling price',
          'Unable to get agent selling price',
        );
      }
      final payablePremium = agentNetPremium ?? premium;
      final charge = calculatePaystackCharge(payablePremium);
      final totalAmount =
          normalizedAgentCode.isNotEmpty ? payablePremium + charge : premium;
      if (kDebugMode && normalizedAgentCode.isNotEmpty) {
        debugPrint('=== AGENT RENEWAL PAYSTACK AMOUNT ===');
        debugPrint('Original renewal premium: $premium');
        debugPrint(shouldUseAgentSellingPrice
            ? 'Agent netpremium: $payablePremium'
            : 'Calculated premium: $payablePremium');
        debugPrint('Paystack charge: $charge');
        debugPrint('Paystack total: $totalAmount');
        debugPrint('=====================================');
      }

      final payload = {
        'IntCode': 'TESTCODE',
        'Password': 'royal1234',
        'product_code': productCode,
        'names': names,
        'email': paymentEmail,
        'mobileno': mobileno,
        'premium': totalAmount,
        'PolicyNo': policyNumber,
        'ProdCode': productCode,
        'EndDate': endDate,
      };
      _addAgentFields(payload, normalizedAgentCode, normalizedAgentUserType);

      if (kDebugMode) {
        debugPrint('=== INITIATE RENEWAL ===');
        debugPrint('URL: $_purchaseUrl');
        debugPrint('Payload: ${json.encode(payload)}');
        debugPrint('========================');
      }
      _logPaymentRequest(
        'Renewal',
        'Initiate renewal',
        method: 'POST application/json',
        url: _purchaseUrl,
        payload: payload,
      );

      final response = await http
          .post(
            Uri.parse(_purchaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('=== RENEWAL RESPONSE ===');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        debugPrint('========================');
      }
      _logPaymentResponse(
        'Renewal',
        'Initiate renewal',
        statusCode: response.statusCode,
        body: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final authUrl = data['authorization_url']?.toString() ??
              data['data']?['authorization_url']?.toString();
          final respRef = data['reference']?.toString() ??
              data['data']?['reference']?.toString();
          if (authUrl != null && authUrl.isNotEmpty) {
            return PaymentResult(
                success: true, authorizationUrl: authUrl, reference: respRef);
          } else {
            return _failure(
              'Initiate renewal',
              'No payment URL returned',
              response: response,
            );
          }
        } else {
          final message = data['message']?.toString() ?? 'Renewal failed';
          return _failure(
            'Initiate renewal',
            message,
            response: response,
          );
        }
      } else {
        final message = ErrorMessages.fromResponse(response,
            fallback: 'Unable to initiate renewal');
        return _failure(
          'Initiate renewal',
          message,
          response: response,
        );
      }
    } catch (e) {
      return _failure(
        'Renewal flow',
        'Connection error. Please check your internet.',
        error: e,
      );
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
    String? agentCode,
    String? agentUserType,
    String? payerEmail,
    String? subProductCode,
    bool isExploreFlow = false,
  }) async {
    try {
      final normalizedAgentCode = agentCode?.trim() ?? '';
      final normalizedAgentUserType = agentUserType?.trim() ?? '';
      final paymentEmail =
          payerEmail?.trim().isNotEmpty == true ? payerEmail!.trim() : email;
      const agentNetPremium = null;
      // Step 1: Submit CP proposal as multipart with images
      final request = http.MultipartRequest('POST', Uri.parse(_proposalUrl));
      request.fields.addAll(fields);
      request.fields['IntCode'] = 'TESTCODE';
      request.fields['Password'] = 'royal1234';
      _addAgentStringFields(
          request.fields, normalizedAgentCode, normalizedAgentUserType);

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
        const encoder = JsonEncoder.withIndent('  ');
        debugPrint('================ CP PROPOSAL REQUEST ================');
        debugPrint('Flow: ${isExploreFlow ? 'Explore' : 'Standard'}');
        debugPrint('Method: POST multipart/form-data');
        debugPrint('URL: $_proposalUrl');
        debugPrint('Fields:');
        debugPrint(encoder.convert(request.fields));
        debugPrint('Files:');
        debugPrint(encoder.convert(request.files
            .map((file) => {
                  'field': file.field,
                  'filename': file.filename,
                  'contentType': file.contentType.toString(),
                  'length': file.length,
                })
            .toList()));
        debugPrint('=====================================================');
      }
      final fileSummary = request.files
          .map((file) => {
                'field': file.field,
                'filename': file.filename,
                'contentType': file.contentType.toString(),
                'length': file.length,
              })
          .toList();
      _logPaymentRequest(
        isExploreFlow ? 'Explore comprehensive buy' : 'Comprehensive buy',
        'Submit comprehensive proposal',
        method: 'POST multipart/form-data',
        url: _proposalUrl,
        payload: request.fields,
        files: fileSummary,
      );

      final proposalStreamResponse =
          await request.send().timeout(const Duration(seconds: 45));
      final proposalBody = await proposalStreamResponse.stream.bytesToString();

      if (kDebugMode) {
        debugPrint('================ CP PROPOSAL RESPONSE ===============');
        debugPrint('Status: ${proposalStreamResponse.statusCode}');
        debugPrint('Body: $proposalBody');
        debugPrint('=====================================================');
      }
      _logPaymentResponse(
        isExploreFlow ? 'Explore comprehensive buy' : 'Comprehensive buy',
        'Submit comprehensive proposal',
        statusCode: proposalStreamResponse.statusCode,
        body: proposalBody,
      );

      if (proposalStreamResponse.statusCode != 200 &&
          proposalStreamResponse.statusCode != 201) {
        String errorMsg = 'Failed to submit proposal';
        try {
          final d = json.decode(proposalBody);
          errorMsg = d['message']?.toString() ??
              d['Message']?.toString() ??
              d['status']?.toString() ??
              d['Status']?.toString() ??
              errorMsg;
        } catch (_) {}
        return _failure(
          'Submit comprehensive proposal',
          errorMsg,
          responseBody: proposalBody,
          statusCode: proposalStreamResponse.statusCode,
        );
      }

      final proposalData = json.decode(proposalBody);
      if (proposalData['status'] != true) {
        final message =
            proposalData['message']?.toString() ?? 'Proposal failed';
        return _failure(
          'Submit comprehensive proposal',
          message,
          responseBody: proposalBody,
          statusCode: proposalStreamResponse.statusCode,
        );
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
        return _failure(
          'Submit comprehensive proposal',
          'No reference returned from proposal',
          responseBody: proposalBody,
          statusCode: proposalStreamResponse.statusCode,
        );
      }

      // Step 2: Initiate purchase with the proposal reference
      final payablePremium = agentNetPremium ?? premium;
      final charge = calculatePaystackCharge(payablePremium);
      final totalAmount = payablePremium + charge;
      if (kDebugMode && normalizedAgentCode.isNotEmpty) {
        debugPrint('=== AGENT CP PAYSTACK AMOUNT ===');
        debugPrint('Original premium: $premium');
        debugPrint('Calculated premium: $payablePremium');
        debugPrint('Paystack charge: $charge');
        debugPrint('Paystack total: $totalAmount');
        debugPrint('================================');
      }

      final purchasePayload = {
        'IntCode': 'TESTCODE',
        'Password': 'royal1234',
        'product_code': 'CP',
        'names': names,
        'email': paymentEmail,
        'mobileno': mobileno,
        'premium': totalAmount,
        'reference': proposalRef,
      };
      _addAgentFields(
          purchasePayload, normalizedAgentCode, normalizedAgentUserType);

      if (kDebugMode) {
        const encoder = JsonEncoder.withIndent('  ');
        debugPrint('================ CP PURCHASE REQUEST ================');
        debugPrint('Flow: ${isExploreFlow ? 'Explore' : 'Standard'}');
        debugPrint('Method: POST application/json');
        debugPrint('URL: $_purchaseUrl');
        debugPrint('Payload:');
        debugPrint(encoder.convert(purchasePayload));
        debugPrint('=====================================================');
      }
      _logPaymentRequest(
        isExploreFlow ? 'Explore comprehensive buy' : 'Comprehensive buy',
        'Initiate comprehensive purchase',
        method: 'POST application/json',
        url: _purchaseUrl,
        payload: purchasePayload,
      );

      final purchaseResponse = await http
          .post(
            Uri.parse(_purchaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(purchasePayload),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('================ CP PURCHASE RESPONSE ===============');
        debugPrint('Status: ${purchaseResponse.statusCode}');
        debugPrint('Body: ${purchaseResponse.body}');
        debugPrint('=====================================================');
      }
      _logPaymentResponse(
        isExploreFlow ? 'Explore comprehensive buy' : 'Comprehensive buy',
        'Initiate comprehensive purchase',
        statusCode: purchaseResponse.statusCode,
        body: purchaseResponse.body,
      );

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
            return _failure(
              'Initiate comprehensive purchase',
              'No payment URL returned',
              response: purchaseResponse,
            );
          }
        } else {
          final message = data['message']?.toString() ?? 'Purchase failed';
          return _failure(
            'Initiate comprehensive purchase',
            message,
            response: purchaseResponse,
          );
        }
      } else {
        final message = ErrorMessages.fromResponse(purchaseResponse,
            fallback: 'Unable to initiate payment');
        return _failure(
          'Initiate comprehensive purchase',
          message,
          response: purchaseResponse,
        );
      }
    } catch (e) {
      return _failure(
        'Comprehensive payment flow',
        'Connection error. Please check your internet.',
        error: e,
      );
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
