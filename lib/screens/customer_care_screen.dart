import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../widgets/agent_bottom_nav.dart';
import '../providers/auth_provider.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';
import 'new_ticket_screen.dart';
import 'service_request_screen.dart';
import 'complaint_screen.dart';
import 'track_ticket_screen.dart';

class CustomerCareScreen extends StatefulWidget {
  final bool isAgentFlow;
  const CustomerCareScreen({super.key, this.isAgentFlow = false});
  @override
  State<CustomerCareScreen> createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen> {
  final _searchController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _tickets = [];

  Color get _actionColor => Theme.of(context).brightness == Brightness.dark
      ? AppTheme.accentOrange
      : AppTheme.primaryNavy;

  DateTime? _ticketDate(Map<String, dynamic> ticket) {
    for (final key in [
      'created_at',
      'createdAt',
      'createdDate',
      'date',
      'updated_at',
      'updatedAt'
    ]) {
      final value = ticket[key]?.toString();
      if (value == null || value.isEmpty) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  List<Map<String, dynamic>> _sortTickets(List<Map<String, dynamic>> tickets) {
    final sorted = List<Map<String, dynamic>>.from(tickets);
    sorted.sort((a, b) {
      final bDate = _ticketDate(b);
      final aDate = _ticketDate(a);
      if (bDate != null && aDate != null) return bDate.compareTo(aDate);
      if (bDate != null) return 1;
      if (aDate != null) return -1;
      final bId = int.tryParse(b['id']?.toString() ?? '') ?? 0;
      final aId = int.tryParse(a['id']?.toString() ?? '') ?? 0;
      return bId.compareTo(aId);
    });
    return sorted;
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.headset_mic_outlined,
      'title': 'Service Request',
      'sub': 'General service inquiries',
      'bg': const Color(0xFFE3F2FD),
      'ic': const Color(0xFF1565C0)
    },
    {
      'icon': Icons.warning_amber_outlined,
      'title': 'Complaint',
      'sub': 'File a formal complaint',
      'bg': const Color(0xFFFCE4EC),
      'ic': const Color(0xFFE53935)
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTickets());
  }

  Future<void> _fetchTickets() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = (auth.loginEmail ??
              auth.userEmail ??
              auth.userData?['Email']?.toString() ??
              auth.userData?['email']?.toString() ??
              auth.userCode ??
              auth.userId ??
              '')
          .trim();

      if (userId.isEmpty) {
        _tickets = [];
        return;
      }

      final tickets = <Map<String, dynamic>>[];
      var page = 1;
      var hasNextPage = true;

      while (hasNextPage) {
        final uri = Uri.https(
          'eportal.rexinsure.com',
          '/api/support/tickets',
          {
            'userId': userId,
            'page': '$page',
            'perPage': '15',
          },
        );

        debugPrint('Fetching tickets: $uri');

        final response = await http.get(
          uri,
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode != 200) break;

        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          tickets.addAll(
              (data['data'] as List).map((e) => Map<String, dynamic>.from(e)));
        }

        final meta = data['meta'];
        if (meta is Map) {
          hasNextPage = meta['hasNextPage'] == true;
          final nextPage = int.tryParse(meta['nextPage']?.toString() ?? '');
          page = nextPage ?? page + 1;
        } else {
          hasNextPage = false;
        }
      }

      _tickets = _sortTickets(tickets);
    } catch (e) {
      debugPrint('Error fetching tickets: $e');
      _tickets = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          title: Text('Customer Care',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          centerTitle: true),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Search
            TextField(
                controller: _searchController,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                    hintText: 'Search help',
                    hintStyle: TextStyle(
                        color: ThemeHelper.getSecondaryTextColor(context),
                        fontSize: 13),
                    suffixIcon: Icon(Icons.search,
                        color: ThemeHelper.getSecondaryTextColor(context)),
                    filled: true,
                    fillColor: ThemeHelper.getCardColor(context),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _actionColor)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12))),
            const SizedBox(height: 24),
            Text('Select Issue Category',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 14),
            ...List.generate(_categories.length, (i) {
              final c = _categories[i];
              return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildCategoryItem(
                      c['icon'], c['title'], c['sub'], c['bg'], c['ic']));
            }),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Recent Tickets',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackTicketScreen(
                          tickets: _tickets, isAgentFlow: widget.isAgentFlow),
                    ),
                  );
                },
                child: const Text('View all',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentOrange)),
              ),
            ]),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ...List.generate(
                  _tickets.take(5).length,
                  (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildTicketCard(_tickets.take(5).toList()[i]))),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => NewTicketScreen(
                                isAgentFlow: widget.isAgentFlow)));
                    if (context.mounted) _fetchTickets();
                  },
                  child: const Text('Create New Ticket',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _actionColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
            const SizedBox(height: 80),
          ])),
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
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 30)))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.isAgentFlow
          ? buildAgentBottomNav(context, currentIndex: 0)
          : BottomAppBar(
              color: AppTheme.bottomNavBackgroundColor(context),
              shape: const CircularNotchedRectangle(),
              notchMargin: 4,
              child: SizedBox(
                  height: 44,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nav(
                            Icons.home_outlined,
                            'Home',
                            false,
                            () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CustomerDashboardScreen()),
                                (r) => false)),
                        _nav(Icons.description_outlined, 'Policies', false,
                            null),
                        const SizedBox(width: 48),
                        _nav(
                            Icons.assignment_outlined,
                            'Claims',
                            false,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MyClaimsScreen()))),
                        _nav(
                            Icons.person_outline,
                            'Profile',
                            true,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const CustomerProfileScreen()))),
                      ]))),
    );
  }

  Widget _buildCategoryItem(
      IconData icon, String title, String sub, Color bg, Color ic) {
    return GestureDetector(
        onTap: () async {
          if (title == 'Service Request') {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ServiceRequestScreen(isAgentFlow: widget.isAgentFlow)));
          } else if (title == 'Complaint') {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ComplaintScreen(isAgentFlow: widget.isAgentFlow)));
          } else {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        NewTicketScreen(isAgentFlow: widget.isAgentFlow)));
          }
          if (context.mounted) _fetchTickets();
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context))),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, color: ic, size: 22)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    Text(sub,
                        style: TextStyle(
                            fontSize: 11,
                            color: ThemeHelper.getSecondaryTextColor(context))),
                  ])),
              Icon(Icons.chevron_right,
                  color: ThemeHelper.getSecondaryTextColor(context), size: 22),
            ])));
  }

  Widget _buildTicketCard(Map<String, dynamic> t) {
    final status = (t['status'] as String?)?.toUpperCase() ?? 'OPEN';
    final displayStatus = status == 'OPEN' ? 'Open' : status;
    final isResolved = displayStatus == 'Resolved';
    final isPending = displayStatus == 'Pending';
    final statusColor = isResolved
        ? Colors.green
        : isPending
            ? Colors.orange
            : Colors.green;
    final statusBg = isResolved
        ? const Color(0xFFE8F5E9)
        : isPending
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFE8F5E9);

    final createdAt = t['created_at'] as String?;
    String timeText = 'Unknown';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inDays > 0) {
          timeText =
              'Created ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
        } else if (diff.inHours > 0) {
          timeText =
              'Created ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
        } else {
          timeText =
              'Created ${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
        }
      } catch (e) {
        timeText = createdAt;
      }
    }

    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: ThemeHelper.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeHelper.getBorderColor(context))),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('#TK${t['id']}',
                    style: TextStyle(
                        fontSize: 11,
                        color: ThemeHelper.getSecondaryTextColor(context))),
                const SizedBox(height: 2),
                Text(t['category'] ?? 'Unknown',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(timeText,
                    style: TextStyle(
                        fontSize: 10,
                        color: ThemeHelper.getSecondaryTextColor(context))),
              ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor)),
              child: Text(displayStatus,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor))),
        ]));
  }

  Widget _nav(IconData i, String l, bool s, VoidCallback? o) => InkWell(
      onTap: o,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(i,
            color: s
                ? AppTheme.bottomNavSelectedColor(context)
                : AppTheme.bottomNavUnselectedColor(context),
            size: 20),
        Text(l,
            style: TextStyle(
                fontSize: 10,
                color: s
                    ? AppTheme.bottomNavSelectedColor(context)
                    : AppTheme.bottomNavUnselectedColor(context)))
      ]));
}
