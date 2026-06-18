import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/error_messages.dart';
import '../utils/theme_helper.dart';
import '../providers/policy_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'new_claims_screen.dart';
import 'new_policy_screen.dart';
import 'my_policies_screen.dart';

double _claimAmountValue(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
  if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') return 0;
  return double.tryParse(cleaned) ?? 0;
}

Map<String, dynamic> _claimPayloadFrom(dynamic decoded) {
  if (decoded is Map) {
    final map = Map<String, dynamic>.from(decoded);
    for (final key in [
      'data',
      'Data',
      'claim',
      'Claim',
      'claim_info',
      'ClaimInfo',
      'claimInfo',
    ]) {
      final value = map[key];
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is List && value.isNotEmpty && value.first is Map) {
        return Map<String, dynamic>.from(value.first as Map);
      }
    }
    return map;
  }
  if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
    return Map<String, dynamic>.from(decoded.first as Map);
  }
  return <String, dynamic>{};
}

String _claimMapValue(Map<String, dynamic> claim, List<String> keys) {
  for (final key in keys) {
    final value = claim[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return '';
}

String _claimNumberFrom(Map<String, dynamic> claim) {
  return _claimMapValue(claim, [
    'ClaimNo',
    'claimNo',
    'ClaimNO',
    'ClaimNum',
    'ClaimNumber',
    'Claim_Number',
    'ClaimID',
    'claim_num',
    'claim_no',
  ]);
}

int _claimProgressIndex(String status) {
  final s = status.toLowerCase();
  if (s.contains('claim paid')) return 7;
  if (s.contains('paid') || s.contains('settled')) return 6;
  if (s.contains('payment approved')) return 5;
  if (s.contains('payment approval stage')) return 4;
  if (s.contains('offer')) return 2;
  if (s.contains('payment approval') ||
      s.contains('awaiting payement approval') ||
      s.contains('awaiting payment approval') ||
      s.contains('payment')) {
    return 4;
  }
  if (s.contains('awaiting appointment of loss adjuster')) return 1;
  if (s.contains('pending offer processing')) return 2;
  if (s.contains('dv') || s.contains('execution') || s.contains('execut')) {
    return 3;
  }
  if (s.contains('review') || s.contains('progress') || s.contains('process')) {
    return 1;
  }
  if (s.contains('registered') ||
      s.contains('new claim') ||
      s.contains('submitted') ||
      s.contains('pending')) {
    return 1;
  }
  return 1;
}

class MyClaimsScreen extends StatefulWidget {
  final bool isAgentFlow;
  const MyClaimsScreen({super.key, this.isAgentFlow = false});

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'In Progress', 'Approved', 'Completed'];
  final Map<String, Map<String, dynamic>> _claimStatusCache = {};
  final Set<String> _claimStatusLoading = {};

  String _getClaimStatus(Map<String, dynamic> c) {
    return c['ClaimStatus']?.toString() ?? c['Status']?.toString() ?? 'Pending';
  }

  String _getCurrentClaimStatus(Map<String, dynamic> claim) {
    final claimNo = _claimNumberFrom(claim);
    final statusPayload = _claimStatusCache[claimNo];
    final rawStatus = statusPayload == null
        ? _getClaimStatus(claim)
        : _claimMapValue(statusPayload, ['Status', 'status']).isNotEmpty
            ? _claimMapValue(statusPayload, ['Status', 'status'])
            : _getClaimStatus(claim);
    final progressStage = statusPayload == null
        ? ''
        : _claimMapValue(statusPayload,
            ['Status2_Stages', 'status2_stages', 'Status2Stages']);
    final progressIndex = _claimProgressIndex(
        progressStage.isNotEmpty ? progressStage : rawStatus);

    if (progressIndex > 6) return 'Claim Paid';
    if (progressStage.isNotEmpty) return progressStage;
    return rawStatus.isNotEmpty ? rawStatus : 'Pending';
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('claim paid') ||
        s.contains('complet') ||
        s.contains('settled') ||
        s.contains('paid') ||
        s.contains('payment approved')) {
      return Colors.green;
    }
    if (s.contains('progress') ||
        s.contains('process') ||
        s.contains('pending') ||
        s.contains('registered') ||
        s.contains('submitted') ||
        s.contains('review') ||
        s.contains('offer') ||
        s.contains('dv') ||
        s.contains('payment approval') ||
        s.contains('payment')) return const Color(0xFFE8923E);
    if (s.contains('approv')) return Colors.green;
    if (s.contains('reject') || s.contains('denied')) return Colors.red;
    return Colors.grey;
  }

  String _claimFilterBucket(Map<String, dynamic> claim) {
    final status = _getCurrentClaimStatus(claim).toLowerCase();

    if (status.contains('complet') ||
        status.contains('settled') ||
        status.contains('closed') ||
        status.contains('claim paid')) {
      return 'completed';
    }

    if (status.contains('pending') ||
        status.contains('registered') ||
        status.contains('submitted') ||
        status.contains('review') ||
        status.contains('progress') ||
        status.contains('process') ||
        status.contains('offer') ||
        status.contains('dv') ||
        status.contains('payment')) {
      return 'in_progress';
    }

    if (status.contains('approv') || status.contains('accepted')) {
      return 'approved';
    }

    return 'in_progress';
  }

  void _prefetchClaimStatuses(List<Map<String, dynamic>> claims) {
    for (final claim in claims) {
      final claimNo = _claimNumberFrom(claim);
      if (claimNo.isEmpty ||
          _claimStatusCache.containsKey(claimNo) ||
          _claimStatusLoading.contains(claimNo)) {
        continue;
      }

      _claimStatusLoading.add(claimNo);
      _fetchClaimStatus(claimNo).then((payload) {
        if (!mounted) return;
        setState(() {
          _claimStatusCache[claimNo] = payload;
          _claimStatusLoading.remove(claimNo);
        });
      }).catchError((e) {
        debugPrint('Unable to load claim status for $claimNo: $e');
        if (!mounted) return;
        setState(() => _claimStatusLoading.remove(claimNo));
      });
    }
  }

  Future<Map<String, dynamic>> _fetchClaimStatus(String claimNo) async {
    final uri = Uri.https(
      'eportaltest.rexinsure.com',
      '/api/getclaim-status',
      {'claim_num': claimNo},
    );

    final response = await http.get(uri, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(ErrorMessages.fromResponse(response,
          fallback: 'Unable to load claim status'));
    }

    return _claimPayloadFrom(json.decode(response.body));
  }

  List<Map<String, dynamic>> _filteredClaims(
      List<Map<String, dynamic>> claims) {
    if (_selectedFilter == 0) return claims;
    final selectedBucket = switch (_filters[_selectedFilter]) {
      'In Progress' => 'in_progress',
      'Approved' => 'approved',
      'Completed' => 'completed',
      _ => '',
    };
    return claims.where((c) {
      return _claimFilterBucket(c) == selectedBucket;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PolicyProvider>(builder: (context, pp, _) {
      final allClaims = pp.claims;
      _prefetchClaimStatuses(allClaims);
      final filtered = _filteredClaims(allClaims);
      final approvedCount =
          allClaims.where((c) => _claimFilterBucket(c) == 'approved').length;
      final inProgressCount =
          allClaims.where((c) => _claimFilterBucket(c) == 'in_progress').length;

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('My Claims',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D64),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${allClaims.length}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('Total Claims',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white70)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('Approved',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.white
                                                .withValues(alpha: 0.8))),
                                    const SizedBox(height: 4),
                                    Text('$approvedCount',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.white.withValues(alpha: 0.2)),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text('In Progress',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.white
                                                .withValues(alpha: 0.8))),
                                    const SizedBox(height: 4),
                                    Text('$inProgressCount',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilter == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1E2D64)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1E2D64)
                                      : Colors.grey[300]!),
                            ),
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Claims header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Claims',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                      TextButton(
                        onPressed: () => setState(() => _selectedFilter = 0),
                        child: const Text('View All',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentOrange,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (pp.loading)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator()))
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                          child: Text('No claims found',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12))),
                    )
                  else
                    ...filtered.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildClaimCard(c),
                        )),

                  const SizedBox(height: 100),
                ],
              ),
            ),
            // New claim FAB
            Positioned(
              bottom: 0,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            NewClaimsScreen(isAgentFlow: widget.isAgentFlow))),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Icon(Icons.edit_note_outlined,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: widget.isAgentFlow
            ? null
            : Transform.translate(
                offset: const Offset(0, 15),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: FloatingActionButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NewPolicyScreen())),
                    backgroundColor: AppTheme.accentOrange,
                    shape: const CircleBorder(),
                    elevation: 1,
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: widget.isAgentFlow
            ? buildAgentBottomNav(context, currentIndex: 0)
            : BottomAppBar(
                color: AppTheme.bottomNavBackgroundColor(context),
                shape: const CircularNotchedRectangle(),
                notchMargin: 4,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_outlined, 'Home', false, () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerDashboardScreen()),
                            (route) => false);
                      }),
                      _buildNavItem(
                          Icons.description_outlined, 'Policies', false, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyPoliciesScreen()));
                      }),
                      const SizedBox(width: 48),
                      _buildNavItem(
                          Icons.assignment_outlined, 'Claims', true, () {}),
                      _buildNavItem(Icons.person_outline, 'Profile', false, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CustomerProfileScreen()));
                      }),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildClaimCard(Map<String, dynamic> c) {
    final claimId = c['ClaimID']?.toString() ?? '';
    final claimType =
        c['ClaimType']?.toString() ?? c['PolicyClass']?.toString() ?? 'Claim';
    final status = _getCurrentClaimStatus(c);
    final statusColor = _getStatusColor(status);
    final claimAmount =
        c['ClaimAmount']?.toString() ?? c['Amount']?.toString() ?? '';
    final hasClaimAmount = _claimAmountValue(claimAmount) > 0;
    final dateFiled = c['ClaimDate']?.toString() ??
        c['DateFiled']?.toString() ??
        c['CreatedDate']?.toString() ??
        '';
    final insured =
        c['Insured']?.toString() ?? c['ClaimantName']?.toString() ?? '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D64).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_outlined,
                    color: Color(0xFF1E2D64), size: 20),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claimType,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 2),
                    if (insured.isNotEmpty)
                      Text(insured,
                          style: TextStyle(
                              fontSize: 10,
                              color:
                                  ThemeHelper.getSecondaryTextColor(context))),
                    Text('Claim #$claimId',
                        style: TextStyle(
                            fontSize: 10,
                            color: ThemeHelper.getSecondaryTextColor(context))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasClaimAmount) ...[
            _claimMetaItem(
              label: 'Claim Amount',
              value: '₦$claimAmount',
              valueWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF111827)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeHelper.getBorderColor(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _claimMetaItem(
                    label: 'Date Filed',
                    value: dateFiled.isNotEmpty ? dateFiled : 'N/A',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _claimMetaItem(
                    label: 'Status',
                    value: status,
                    valueColor: statusColor,
                    valueWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClaimDetailsScreen(claim: c),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2D64),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('View Details',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _claimMetaItem({
    required String label,
    required String value,
    Color? valueColor,
    FontWeight valueWeight = FontWeight.w600,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: ThemeHelper.getSecondaryTextColor(context))),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11,
                height: 1.25,
                fontWeight: valueWeight,
                color: valueColor ?? Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected
                  ? AppTheme.bottomNavSelectedColor(context)
                  : AppTheme.bottomNavUnselectedColor(context),
              size: 20),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? AppTheme.bottomNavSelectedColor(context)
                      : AppTheme.bottomNavUnselectedColor(context))),
        ],
      ),
    );
  }
}

class ClaimDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> claim;

  const ClaimDetailsScreen({super.key, required this.claim});

  @override
  State<ClaimDetailsScreen> createState() => _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState extends State<ClaimDetailsScreen> {
  Map<String, dynamic>? _details;
  Map<String, dynamic>? _statusDetails;
  bool _loading = true;
  String? _error;

  static const String _supportDialPhone = '+2347080606100';
  static const String _supportDisplayPhone = '+234 708 0606 100';

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final claimNo = _claimNumber;

    if (claimNo.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Claim number not found';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.https(
        'eportaltest.rexinsure.com',
        '/api/getclaim-info',
        {'claim_num': claimNo},
      );

      final response = await http.get(uri, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorMessages.fromResponse(response,
            fallback: 'Unable to load claim details'));
      }

      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['status'] == false) {
        final message = ErrorMessages.fromDecodedJson(decoded);
        throw Exception(
            message.isNotEmpty ? message : 'Unable to load claim details');
      }
      final payload = _payloadFrom(decoded);
      final statusPayload = await _fetchStatusDetails(claimNo);

      if (!mounted) return;
      setState(() {
        _details = payload;
        _statusDetails = statusPayload;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = ErrorMessages.fromException(e,
            fallback: 'Unable to load claim details');
      });
    }
  }

  Future<Map<String, dynamic>> _fetchStatusDetails(String claimNo) async {
    final uri = Uri.https(
      'eportaltest.rexinsure.com',
      '/api/getclaim-status',
      {'claim_num': claimNo},
    );

    final response = await http.get(uri, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(ErrorMessages.fromResponse(response,
          fallback: 'Unable to load claim status'));
    }

    final decoded = json.decode(response.body);
    if (decoded is Map && decoded['status'] == false) {
      final message = ErrorMessages.fromDecodedJson(decoded);
      throw Exception(
          message.isNotEmpty ? message : 'Unable to load claim status');
    }

    return _payloadFrom(decoded);
  }

  Map<String, dynamic> _payloadFrom(dynamic decoded) {
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      for (final key in [
        'data',
        'Data',
        'claim',
        'Claim',
        'claim_info',
        'ClaimInfo',
        'claimInfo',
      ]) {
        final value = map[key];
        if (value is Map) return Map<String, dynamic>.from(value);
        if (value is List && value.isNotEmpty && value.first is Map) {
          return Map<String, dynamic>.from(value.first as Map);
        }
      }
      return map;
    }
    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> get _source => {
        ...widget.claim,
        if (_details != null) ..._details!,
        if (_statusDetails != null) ..._statusDetails!,
      };

  String get _claimNumber => _read([
        'ClaimNo',
        'claimNo',
        'ClaimNO',
        'ClaimNum',
        'ClaimNumber',
        'Claim_Number',
        'ClaimID',
        'claim_num',
        'claim_no',
      ]);

  String _read(List<String> keys, {bool fromFallbackOnly = false}) {
    final maps = fromFallbackOnly
        ? [widget.claim]
        : [
            _source,
            widget.claim,
            if (_details != null) _details!,
            if (_statusDetails != null) _statusDetails!,
          ];

    for (final map in maps) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }
    return '';
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('complet') || s.contains('settled') || s.contains('paid')) {
      return Colors.green;
    }
    if (s.contains('progress') || s.contains('process')) {
      return const Color(0xFFE8923E);
    }
    if (s.contains('approv')) return Colors.green;
    if (s.contains('reject') || s.contains('denied')) return Colors.red;
    return const Color(0xFFE8923E);
  }

  String _formatDate(String value) {
    if (value.isEmpty) return 'N/A';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  String _formatMoney(String value) {
    if (value.isEmpty) return 'N/A';
    if (value.contains('₦') || value.toUpperCase().startsWith('N')) {
      return value;
    }
    return '₦$value';
  }

  int _progressIndex(String status) {
    final s = status.toLowerCase();
    if (s.contains('claim paid')) return 7;
    if (s.contains('paid') || s.contains('settled')) return 6;
    if (s.contains('payment approved')) return 5;
    if (s.contains('payment approval stage')) return 4;
    if (s.contains('offer')) return 2;
    if (s.contains('payment approval') ||
        s.contains('awaiting payement approval') ||
        s.contains('awaiting payment approval') ||
        s.contains('payment')) {
      return 4;
    }
    if (s.contains('awaiting appointment of loss adjuster')) return 1;
    if (s.contains('pending offer processing')) return 2;
    if (s.contains('dv') || s.contains('execution') || s.contains('execut')) {
      return 3;
    }
    if (s.contains('review') ||
        s.contains('progress') ||
        s.contains('process')) {
      return 1;
    }
    if (s.contains('registered') ||
        s.contains('new claim') ||
        s.contains('submitted') ||
        s.contains('pending')) {
      return 1;
    }
    return 1;
  }

  Future<void> _callSupport() async {
    final uri = Uri(scheme: 'tel', path: _supportDialPhone);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showSupportPhoneDialog();
      }
    } catch (_) {
      if (mounted) _showSupportPhoneDialog();
    }
  }

  void _showSupportPhoneDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call Rex Support',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(_supportDisplayPhone,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final claimType = _read([
      'ClaimType',
      'claim_type',
      'PolicyClass',
      'policy_class',
      'Policy_Class',
      'risktype',
      'Risk_Type',
      'LossType',
      'TypeOfLoss',
    ]);
    final status = _read(['ClaimStatus', 'Status', 'status', 'clmstatus']);
    final dateFiled = _formatDate(_read([
      'ClaimDate',
      'clmdate',
      'SubmittedDate',
      'Date_Request_Created',
      'DateFiled',
      'CreatedDate',
      'DateCreated',
      'NotificationDate',
    ]));
    final rawAmount = _read([
      'ClaimAmount',
      'Amount',
      'amount',
      'claim_to_pay',
      'claim_paid',
      'salvage',
    ]);
    final amount = _formatMoney(rawAmount);
    final hasClaimAmount = _claimAmountValue(rawAmount) > 0;
    final policyNo = _read([
      'PolicyNo',
      'PolicyNumber',
      'PolicyID',
      'policyno',
      'polnum',
      'Policy_Number'
    ]);
    final incidentDate = _formatDate(_read([
      'IncidentDate',
      'LossDate',
      'lossdate',
      'Loss_Date',
      'DateOfLoss',
      'AccidentDate',
      'EventDate',
    ]));
    final location = _read([
      'Location',
      'LossLocation',
      'AccidentLocation',
      'IncidentLocation',
      'Address',
    ]);
    final description = _read([
      'Description',
      'LossDescription',
      'Narration',
      'narration',
      'CauseOfLoss',
      'Remarks',
      'Comment',
    ]);
    final progressStage =
        _read(['Status2_Stages', 'status2_stages', 'Status2Stages']);
    final progressIndex =
        _progressIndex(progressStage.isNotEmpty ? progressStage : status);
    final overallStatus = progressIndex > 6
        ? 'Claim Paid'
        : (status.isNotEmpty ? status : 'Pending');
    final statusColor = _statusColor(overallStatus);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Claims Details',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: _fetchDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryHeader(
                          claimType: claimType.isNotEmpty ? claimType : 'Claim',
                          claimNo: _claimNumber,
                          status: overallStatus,
                          statusColor: statusColor,
                        ),
                        const SizedBox(height: 18),
                        _section(
                          title: 'Claim Information',
                          child: Column(
                            children: [
                              _detailRow('Claim Type',
                                  claimType.isNotEmpty ? claimType : 'N/A'),
                              _detailRow('Filed Date', dateFiled),
                              if (hasClaimAmount)
                                _detailRow('Claim Amount', amount),
                              _detailRow('Policy Number',
                                  policyNo.isNotEmpty ? policyNo : 'N/A',
                                  valueFontSize: 11,
                                  valueMaxLines: 3,
                                  isLast: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _section(
                          title: 'Claim Progress',
                          child: Column(
                            children: [
                              _progressStep(
                                  'Claim Registered', 0, progressIndex),
                              _progressStep(
                                  'Claim Under review', 1, progressIndex),
                              _progressStep('Offer Stage', 2, progressIndex),
                              _progressStep(
                                  'Awaiting Execution of DV', 3, progressIndex),
                              _progressStep('Awaiting Payment Approval', 4,
                                  progressIndex),
                              _progressStep(
                                  'Payment Approved', 5, progressIndex,
                                  isLast: false),
                              _progressStep('Claim Paid', 6, progressIndex,
                                  isLast: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _section(
                          title: 'Incident Details',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _incidentItem('Incident Date', incidentDate),
                              _incidentItem('Location',
                                  location.isNotEmpty ? location : 'N/A'),
                              _incidentItem('Description',
                                  description.isNotEmpty ? description : 'N/A',
                                  isLast: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _needHelp(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: ThemeHelper.getSecondaryTextColor(context))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2D64),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryHeader({
    required String claimType,
    required String claimNo,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car_outlined,
                color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(claimType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text('Claim $claimNo',
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color: ThemeHelper.getSecondaryTextColor(context))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor)),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111827)
            : const Color(0xFFFAFAFA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isLast = false, double valueFontSize = 13, int valueMaxLines = 2}) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : ThemeHelper.getBorderColor(context),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                maxLines: valueMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _progressStep(String title, int stageIndex, int currentStageIndex,
      {bool isLast = false}) {
    final isCompleted = stageIndex < currentStageIndex;
    final isCurrent = stageIndex == currentStageIndex;
    final stageColor = isCompleted
        ? const Color(0xFF16A34A)
        : isCurrent
            ? const Color(0xFFE8923E)
            : Colors.grey;
    final subtitle = isCompleted
        ? 'Approved'
        : isCurrent
            ? 'In Progress'
            : 'Pending';

    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : ThemeHelper.getBorderColor(context),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_box, size: 16, color: stageColor),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? stageColor
                            : Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                        color: isCurrent
                            ? stageColor
                            : ThemeHelper.getSecondaryTextColor(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _incidentItem(String label, String value, {bool isLast = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : ThemeHelper.getBorderColor(context),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: ThemeHelper.getSecondaryTextColor(context))),
        ],
      ),
    );
  }

  Widget _needHelp() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need Help?',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 3),
              Text('Contact your claim manager',
                  style: TextStyle(
                      fontSize: 10,
                      color: ThemeHelper.getSecondaryTextColor(context))),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _callSupport,
          icon: const Icon(Icons.phone_outlined, size: 15),
          label: const Text('Call Now',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E2D64),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
