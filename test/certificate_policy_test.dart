import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rex_insurance/services/certificate_policy_service.dart';
import 'package:rex_insurance/utils/certificate_url.dart';

void main() {
  for (final statusCode in [200, 401]) {
    test('falls back when workflow token is invalid ($statusCode)', () async {
      final paths = <String>[];
      final client = MockClient((request) async {
        paths.add(request.url.path);
        expect(request.url.queryParameters['PolicyNo'], 'P/PM/001');
        if (request.url.path.contains('kissflow')) {
          return http.Response('{"error":"invalid_token"}', statusCode);
        }
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response(
            jsonEncode({
              'Status': 'Success',
              'Data': [
                {
                  'PolicyNo': 'P/PM/001',
                  'Insured': 'Example Customer',
                  'items': []
                }
              ]
            }),
            200);
      });
      final policy = await http.runWithClient(
          () => fetchCertificatePolicy(' P/PM/001 ', 'test-token'),
          () => client);
      expect(policy['PolicyNo'], 'P/PM/001');
      expect(paths, ['/api/kissflow/getpolinfo', '/api/getpolicy']);
    });
  }

  test('valid workflow response does not call fallback', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('{"Data":[{"PolicyNo":"P/PM/001"}]}', 200);
    });
    final policy = await http.runWithClient(
        () => fetchCertificatePolicy('P/PM/001', 'test-token'), () => client);
    expect(policy['PolicyNo'], 'P/PM/001');
    expect(calls, 1);
  });

  test('reads the live Product Details result envelope', () async {
    final client = MockClient((request) async => http.Response(
        jsonEncode({
          'Product Details': {
            'result': [
              {
                'polnum': 'P/PM/001',
                'insured': 'Example Customer',
                'sumass': 16000000,
                'curprem': 400000,
                'effdate': '2026-10-17',
                'items': [
                  {'item_code': 'ABC123', 'desc': 'MAKE - MODEL'}
                ],
              }
            ]
          },
          'Product Period': {
            'result': {'status': 1, 'period': []}
          },
        }),
        200));
    final policy = await http.runWithClient(
        () => fetchCertificatePolicy('P/PM/001', 'test-token'), () => client);
    expect(policy['polnum'], 'P/PM/001');
    expect(policy['sumass'], 16000000);
    expect(policy['items'], isNotEmpty);
  });

  test('does not accept an empty policy response', () async {
    final client = MockClient((request) async =>
        http.Response('{"Status":"Success","Data":[]}', 200));
    await http.runWithClient(() async {
      await expectLater(fetchCertificatePolicy('P/PM/001', 'test-token'),
          throwsFormatException);
    }, () => client);
  });

  test('extracts nested strings and relative certificate file paths', () {
    expect(
        certificateUrlFromResponse('{"data":"https://example.com/cert.pdf"}'),
        'https://example.com/cert.pdf');
    expect(certificateUrlFromResponse('{"data":{"path":"storage/cert.pdf"}}'),
        'https://eportal.rexinsure.com/storage/cert.pdf');
    expect(certificateUrlFromResponse('{"url":"/certificates/1"}'),
        'https://eportal.rexinsure.com/certificates/1');
    expect(certificateUrlFromResponse('{"status":false,"url":"/error"}'), '');
    expect(certificateUrlFromResponse('{"message":"Unable to generate"}'), '');
  });
}
