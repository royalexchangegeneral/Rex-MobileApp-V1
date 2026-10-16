import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rex_insurance/screens/my_claims_screen.dart';
import 'package:rex_insurance/utils/claim_number.dart';

void main() {
  test('claim number takes precedence over the internal ID', () {
    expect(claimNumberFrom({'ClaimID': 42, 'claim_num': ' CL/2026/001 '}),
        'CL/2026/001');
    expect(claimNumberFrom({'ClaimID': 42, 'claim_no': 'CL/002'}), 'CL/002');
    expect(claimNumberFrom({'ClaimNo': 'CL/003', 'ClaimID': 42}), 'CL/003');
    expect(claimNumberFrom({'ClaimNo': ' ', 'ClaimID': 42}), '42');
    expect(claimNumberFrom({}), isEmpty);
  });

  testWidgets(
      'loads the public claim number and retains details if status fails',
      (tester) async {
    final requests = <Uri>[];
    final client = MockClient((request) async {
      requests.add(request.url);
      if (request.url.path == '/api/getclaim-info') {
        return http.Response(
            jsonEncode({
              'status': true,
              'data': {'ClaimType': 'Motor', 'PolicyNo': 'P/PM/001'},
            }),
            200);
      }
      return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Claim information not found',
          }),
          404);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(
        home: ClaimDetailsScreen(claim: {
          'ClaimID': 42,
          'claim_num': 'CL/2026/001',
        }),
      ));
      await tester.pumpAndSettle();
    }, () => client);

    expect(requests, hasLength(2));
    for (final uri in requests) {
      expect(uri.host, 'eportal.rexinsure.com');
      expect(uri.queryParameters['claim_num'], 'CL/2026/001');
    }
    expect(find.text('Claim Information'), findsOneWidget);
    expect(find.text('P/PM/001'), findsOneWidget);
    expect(find.text('Claim information not found'), findsNothing);
  });
  testWidgets('uses workflow details when the information record is missing',
      (tester) async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/getclaim-info') {
        return http.Response(
            jsonEncode({
              'status': false,
              'message': 'Claim information not found',
              'data': {'result': null},
            }),
            200);
      }
      return http.Response(
          jsonEncode({
            'Data': [
              {
                'Claim_Number': 'C/PM/001',
                'Policy_Number': 'P/PM/001',
                'Risk_Type': 'MOTOR-PRIVATE',
                'Loss_Date': '2026-09-24',
                'Description': 'Accidental damage',
                'IncidentPlace': 'Lagos',
                'Status2_Stages': 'Payment Approval Stage',
              }
            ],
          }),
          200);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(
        home: ClaimDetailsScreen(claim: {'ClaimID': 'C/PM/001'}),
      ));
      await tester.pumpAndSettle();
    }, () => client);

    expect(find.text('Claim Information'), findsOneWidget);
    expect(find.text('P/PM/001'), findsOneWidget);
    expect(find.text('MOTOR-PRIVATE'), findsWidgets);
    expect(find.text('Claim information not found'), findsNothing);
    await tester.scrollUntilVisible(find.text('Lagos'), 200);
    expect(find.text('Lagos'), findsOneWidget);
  });

  testWidgets('keeps the retry state when neither endpoint has a record',
      (tester) async {
    final client = MockClient((request) async =>
        http.Response(jsonEncode({'status': true, 'Data': []}), 200));
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(
        home: ClaimDetailsScreen(claim: {'ClaimID': 'C/PM/001'}),
      ));
      await tester.pumpAndSettle();
    }, () => client);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Claim information not found'), findsOneWidget);
    expect(find.text('Claim Information'), findsNothing);
  });
  for (final settledStatus in ['Settled', ' SETTLED ']) {
    testWidgets(
        'settled claim completes payment despite stale workflow stage: $settledStatus',
        (tester) async {
      final client = MockClient((request) async => http.Response(
          jsonEncode({
            'Data': [
              {
                'Claim_Number': 'C/PM/001',
                'Status': settledStatus,
                'Status2_Stages': 'Payment Approval Stage',
              }
            ],
          }),
          200));
      await http.runWithClient(() async {
        await tester.pumpWidget(const MaterialApp(
          home: ClaimDetailsScreen(claim: {'ClaimID': 'C/PM/001'}),
        ));
        await tester.pumpAndSettle();
      }, () => client);
      expect(find.text('Claim Paid'), findsWidgets);
      expect(find.text('In Progress'), findsNothing);
      await tester.scrollUntilVisible(find.text('Paid'), 200);
      expect(find.text('Paid'), findsOneWidget);
    });
  }
}
