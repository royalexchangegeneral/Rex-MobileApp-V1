import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_theme.dart';
import '../providers/policy_provider.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class MyCertificateScreen extends StatefulWidget {
  const MyCertificateScreen({super.key});

  @override
  State<MyCertificateScreen> createState() => _MyCertificateScreenState();
}

class _MyCertificateScreenState extends State<MyCertificateScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _certificates = [];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _surfaceCardColor =>
      _isDark ? const Color(0xFF111827) : Colors.white;

  Color get _borderColor =>
      _isDark ? const Color(0xFF334155) : Colors.grey[200]!;

  Color get _secondaryTextColor =>
      _isDark ? const Color(0xFFCBD5E1) : Colors.grey[600]!;

  Color get _brandActionColor =>
      _isDark ? AppTheme.accentOrange : AppTheme.primaryNavy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final policyProvider =
          Provider.of<PolicyProvider>(context, listen: false);
      if (policyProvider.policies.isEmpty) {
        await policyProvider.fetchPolicies(context);
      }
      _loadCertificates();
    });
  }

  void _loadCertificates() {
    final policyProvider = Provider.of<PolicyProvider>(context, listen: false);
    final policies = policyProvider.policies;
    setState(() {
      _certificates.clear();
      for (final p in policies) {
        final policyNo =
            p['policyNo']?.toString() ?? p['policyId']?.toString() ?? '';
        _certificates.add({
          'id': policyNo,
          'type': (p['policyClass']?.toString() ?? 'INSURANCE').toUpperCase(),
          'name':
              p['insured']?.toString() ?? p['customerName']?.toString() ?? '',
          'policyNo': policyNo,
          'certNo': policyNo,
          'startDate': p['startDate']?.toString() ?? '',
          'expiryDate': p['endDate']?.toString() ?? '',
        });
      }
    });
  }

  String _getCertPath(String type) {
    final t = type.toLowerCase();
    if (t.contains('home') || t.contains('hp')) return 'hpcert';
    if (t.contains('shop') || t.contains('shp')) return 'shpcert';
    if (t.contains('group') || t.contains('gc')) return 'gccert';
    if (t.contains('family') || t.contains('fc')) return 'fccert';
    if (t.contains('parcel') || t.contains('pp')) return 'ppcert';
    if (t.contains('student') || t.contains('sp')) return 'spcert';
    if (t.contains('personal') || t.contains('pc')) return 'pccert';
    if (t.contains('royal auto') ||
        t.contains('bronze') ||
        t.contains('silver') ||
        t.contains('comprehensive')) {
      return 'royalautocert';
    }
    return 'tpcert';
  }

  String _getCertUrl(Map<String, String> cert) {
    final certPath = _getCertPath(cert['type'] ?? '');
    return 'https://eportal.rexinsure.com/$certPath?policy=${cert['policyNo'] ?? ''}';
  }

  List<Map<String, String>> get _filteredCertificates {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _certificates;
    return _certificates.where((c) {
      final text =
          '${c['id']} ${c['type']} ${c['name']} ${c['policyNo']} ${c['certNo']}'
              .toLowerCase();
      return text.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certs = _filteredCertificates;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Certificate',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Consumer<PolicyProvider>(builder: (context, policyProvider, _) {
        if (policyProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search certificate',
                  hintStyle: TextStyle(
                      color:
                          _isDark ? const Color(0xFF94A3B8) : Colors.grey[400],
                      fontSize: 13),
                  suffixIcon: Icon(Icons.search,
                      color:
                          _isDark ? const Color(0xFF94A3B8) : Colors.grey[400]),
                  filled: true,
                  fillColor: _surfaceCardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _borderColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _borderColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _brandActionColor)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Certificate cards
              if (certs.isEmpty) ...[
                const SizedBox(height: 40),
                Center(
                    child: Column(children: [
                  Icon(Icons.description_outlined,
                      size: 60,
                      color:
                          _isDark ? const Color(0xFF475569) : Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No certificates found',
                      style:
                          TextStyle(fontSize: 14, color: _secondaryTextColor)),
                ])),
              ] else ...[
                ...List.generate(certs.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index < certs.length - 1 ? 16 : 0),
                    child: _buildCertificateCard(context, certs[index]),
                  );
                }),
              ],

              const SizedBox(height: 20),

              // Need Help section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF111827)
                      : const Color(0xFFF3F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent,
                            color: _brandActionColor, size: 20),
                        const SizedBox(width: 8),
                        Text('Need Help?',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact support if you need assistance accessing or downloading your certificates.',
                      style: TextStyle(
                          fontSize: 12,
                          color: _secondaryTextColor,
                          height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _callSupport(),
                      child: Text('Contact Support',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _brandActionColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NewPolicyScreen())),
            backgroundColor: AppTheme.accentOrange,
            shape: const CircleBorder(),
            elevation: 1,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.bottomNavBackgroundColor(context),
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false, onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CustomerDashboardScreen()),
                    (route) => false);
              }),
              _buildNavItem(Icons.description_outlined, 'Policies', false),
              const SizedBox(width: 48),
              _buildNavItem(Icons.assignment_outlined, 'Claims', false,
                  onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyClaimsScreen()));
              }),
              _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
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
  }

  Widget _buildCertificateCard(BuildContext context, Map<String, String> cert) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and type
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _brandActionColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.description_outlined,
                    color: _brandActionColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${cert['id']} – ${cert['type']}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _brandActionColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details rows
          _buildDetailRow(context, 'Name of Policy', cert['name']!),
          const SizedBox(height: 10),
          _buildDetailRow(context, 'Policy No.', cert['policyNo']!),
          const SizedBox(height: 10),
          _buildDetailRow(context, 'Certificate No.', cert['certNo']!),
          const SizedBox(height: 10),
          _buildDetailRow(
              context, 'Date of the commencement', cert['startDate']!),
          const SizedBox(height: 10),
          _buildDetailRow(context, 'Date of expiry', cert['expiryDate']!,
              valueColor: Colors.red),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // View button
              ElevatedButton.icon(
                onPressed: () {
                  final url = _getCertUrl(cert);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => _CertWebView(
                              url: url, title: '${cert['type']} Certificate')));
                },
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandActionColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
              // Download button
              OutlinedButton.icon(
                onPressed: () async {
                  final url = _getCertUrl(cert);
                  final uri = Uri.parse(url);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Download',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brandActionColor,
                  side: BorderSide(color: _brandActionColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(width: 10),
              // Share button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _brandActionColor),
                ),
                child: IconButton(
                  onPressed: () => _shareCertificate(cert),
                  icon: Icon(Icons.share_outlined,
                      size: 18, color: _brandActionColor),
                  constraints:
                      const BoxConstraints(minWidth: 38, minHeight: 38),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: TextStyle(fontSize: 11, color: _secondaryTextColor)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _shareCertificate(Map<String, String> cert) {
    final certUrl = _getCertUrl(cert);
    final text = '''Rex Insurance Certificate
${cert['id']} – ${cert['type']}

Name of Policy: ${cert['name']}
Policy No.: ${cert['policyNo']}
Certificate No.: ${cert['certNo']}
Date of Commencement: ${cert['startDate']}
Date of Expiry: ${cert['expiryDate']}

View Certificate: $certUrl

Rex Insurance – Protecting What Matters Most''';
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);
    Share.share(text, sharePositionOrigin: origin);
  }

  Future<void> _callSupport() async {
    final uri = Uri(scheme: 'tel', path: '+2347080606100');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) _showPhoneDialog();
    } catch (_) {
      if (mounted) _showPhoneDialog();
    }
  }

  void _showPhoneDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Support',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('+234 708 0606 100',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
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

class _CertWebView extends StatefulWidget {
  final String url;
  final String title;
  const _CertWebView({required this.url, required this.title});
  @override
  State<_CertWebView> createState() => _CertWebViewState();
}

class _CertWebViewState extends State<_CertWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          title: Text(widget.title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          centerTitle: true),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ]),
    );
  }
}
