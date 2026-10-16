import 'package:flutter_test/flutter_test.dart';
import 'package:rex_insurance/utils/claim_status.dart';

void main() {
  test('settled list record wins over cached workflow stage', () {
    expect(
        hasSettledClaimStatus([
          {'ClaimStatus': 'Settled'},
          {
            'Status': 'Survey Completed',
            'Status2_Stages': 'Payment Approval Stage'
          },
        ]),
        isTrue);
  });

  test('settled API status wins over list record', () {
    expect(
        hasSettledClaimStatus([
          {'ClaimStatus': 'Pending'},
          {'Status': ' SETTLED ', 'Status2_Stages': 'Payment Approval Stage'},
        ]),
        isTrue);
  });

  test('pending, approved, and unsettled claims are not settled', () {
    for (final status in ['Pending', 'Payment Approved', 'Unsettled']) {
      expect(
          hasSettledClaimStatus([
            {'Status': status}
          ]),
          isFalse);
    }
    expect(hasSettledClaimStatus([]), isFalse);
  });
}
