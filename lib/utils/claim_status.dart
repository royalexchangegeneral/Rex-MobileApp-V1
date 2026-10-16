/// Settlement confirms payment even when a workflow stage has not caught up.
bool hasSettledClaimStatus(Iterable<Map<String, dynamic>> records) {
  return records.any((record) => const [
        'ClaimStatus',
        'Status',
        'status',
        'clmstatus',
        'Status2_Stages',
        'status2_stages',
        'Status2Stages',
      ].any(
          (key) => record[key]?.toString().trim().toLowerCase() == 'settled'));
}
