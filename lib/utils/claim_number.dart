/// Prefer the public claim number over the internal record ID for API lookups.
String claimNumberFrom(Map<String, dynamic> claim) {
  for (final key in const [
    'ClaimNo',
    'claimNo',
    'ClaimNO',
    'ClaimNum',
    'ClaimNumber',
    'Claim_Number',
    'claim_num',
    'claim_no',
    'ClaimID',
  ]) {
    final value = claim[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}
