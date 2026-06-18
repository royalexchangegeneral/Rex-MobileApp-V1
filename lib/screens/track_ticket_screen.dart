import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../providers/auth_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class TrackTicketScreen extends StatefulWidget {
  final List<Map<String, dynamic>> tickets;
  final bool isAgentFlow;
  const TrackTicketScreen(
      {Key? key, required this.tickets, this.isAgentFlow = false})
      : super(key: key);

  @override
  State<TrackTicketScreen> createState() => _TrackTicketScreenState();
}

class _TrackTicketScreenState extends State<TrackTicketScreen> {
  String _selectedFilter = 'All';
  late List<Map<String, dynamic>> _filteredTickets;
  late List<Map<String, dynamic>> _tickets;
  List<Map<String, dynamic>> _displayedTickets = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasNextPage = false;
  int _nextPage = 1;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _tickets = _sortTickets(widget.tickets);
    _filteredTickets = _tickets;
    _displayedTickets = _filteredTickets;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstPage());
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasNextPage || _loadingMore || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 160) {
      _fetchTicketPage(page: _nextPage, append: true);
    }
  }

  Future<void> _loadFirstPage() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _userId = (auth.loginEmail ??
            auth.userEmail ??
            auth.userData?['Email']?.toString() ??
            auth.userData?['email']?.toString() ??
            auth.userCode ??
            auth.userId ??
            '')
        .trim();

    if (_userId.isEmpty) return;
    await _fetchTicketPage(page: 1, append: false);
  }

  Future<void> _fetchTicketPage(
      {required int page, required bool append}) async {
    if (_userId.isEmpty) return;

    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = _tickets.isEmpty;
      }
    });

    try {
      final uri = Uri.https(
        'eportaltest.rexinsure.com',
        '/api/support/tickets',
        {
          'userId': _userId,
          'page': '$page',
          'perPage': '15',
        },
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final nextTickets = data['success'] == true && data['data'] is List
          ? (data['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      final byId = <String, Map<String, dynamic>>{};
      for (final ticket
          in append ? [..._tickets, ...nextTickets] : nextTickets) {
        byId[ticket['id']?.toString() ?? ticket.hashCode.toString()] = ticket;
      }

      final meta = data['meta'];
      final hasNextPage = meta is Map && meta['hasNextPage'] == true;
      final nextPage = meta is Map
          ? int.tryParse(meta['nextPage']?.toString() ?? '') ?? page + 1
          : page + 1;

      if (!mounted) return;
      setState(() {
        _tickets = _sortTickets(byId.values.toList());
        _hasNextPage = hasNextPage;
        _nextPage = nextPage;
        _loading = false;
        _loadingMore = false;
      });
      _filterTickets(_selectedFilter);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _filterTickets(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredTickets = _tickets;
      } else {
        final normalizedFilter = filter
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('_', '')
            .replaceAll('-', '');
        _filteredTickets = _tickets.where((t) {
          final status = (t['status'] as String?)
                  ?.toLowerCase()
                  .replaceAll(' ', '')
                  .replaceAll('_', '')
                  .replaceAll('-', '') ??
              '';
          return status == normalizedFilter;
        }).toList();
      }
      _applySearch();
    });
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _displayedTickets = _filteredTickets;
    } else {
      _displayedTickets = _filteredTickets.where((t) {
        final id = '#TK${t['id']}';
        final status = (t['status'] as String?)?.toLowerCase() ?? '';
        return id.toLowerCase().contains(query) || status.contains(query);
      }).toList();
    }
    setState(() {});
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'in progress':
        return const Color(0xFFE3F2FD);
      case 'resolved':
        return const Color(0xFFE8F5E9);
      default:
        return Colors.grey[100]!;
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Track Ticket',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => _applySearch(),
              decoration: InputDecoration(
                hintText: 'Search tickets',
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.accentOrange
                            : AppTheme.primaryNavy)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Open', _selectedFilter == 'Open'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'In Progress', _selectedFilter == 'In Progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', _selectedFilter == 'Resolved'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Tickets',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _displayedTickets.length + (_hasNextPage ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= _displayedTickets.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: _loadingMore
                                  ? const CircularProgressIndicator()
                                  : TextButton(
                                      onPressed: () => _fetchTicketPage(
                                          page: _nextPage, append: true),
                                      child: const Text('Load more'),
                                    ),
                            ),
                          );
                        }

                        final t = _displayedTickets[i];
                        final createdAt = t['created_at'] != null
                            ? DateTime.tryParse(t['created_at'])
                            : null;
                        final status =
                            (t['status'] as String?)?.toLowerCase() ?? 'open';
                        final displayStatus =
                            status == 'open' ? 'Open' : status.capitalize();
                        final statusColor = _statusColor(status);
                        final statusBg = _statusBg(status);
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketChatScreen(ticket: t),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ThemeHelper.getCardColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: ThemeHelper.getBorderColor(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('#TK${t['id']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        displayStatus,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(t['category'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                    overflow: TextOverflow.ellipsis),
                                if (t['sub_category'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(t['sub_category'],
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? AppTheme.accentOrange
                                                    : AppTheme.primaryNavy,
                                            fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                if (t['description'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(t['description'],
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: ThemeHelper
                                                .getSecondaryTextColor(
                                                    context)),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14,
                                        color:
                                            ThemeHelper.getSecondaryTextColor(
                                                context)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        createdAt != null
                                            ? _formatTimeAgo(createdAt)
                                            : '',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: ThemeHelper
                                                .getSecondaryTextColor(
                                                    context)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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

  Widget _buildFilterChip(String label, bool selected) {
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 12)),
      selected: selected,
      selectedColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.accentOrange
          : AppTheme.primaryNavy,
      backgroundColor: ThemeHelper.getCardColor(context),
      showCheckmark: false,
      onSelected: (isSelected) {
        if (isSelected) _filterTickets(label);
      },
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: EdgeInsets.zero,
    );
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

class TicketChatScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketChatScreen({super.key, required this.ticket});

  String _value(List<String> keys) {
    for (final key in keys) {
      final value = ticket[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  DateTime? _dateFrom(Map<String, dynamic> data) {
    for (final key in [
      'created_at',
      'createdAt',
      'createdDate',
      'date',
      'updated_at',
      'updatedAt'
    ]) {
      final value = data[key]?.toString();
      if (value == null || value.isEmpty) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
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
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $suffix';
  }

  List<Map<String, dynamic>> _messages() {
    final messages = <Map<String, dynamic>>[];
    final initialMessage =
        _value(['description', 'message', 'body', 'details']);

    if (initialMessage.isNotEmpty) {
      messages.add({
        'text': initialMessage,
        'fromUser': true,
        'date': _dateFrom(ticket),
      });
    }

    for (final key in [
      'responses',
      'Replies',
      'replies',
      'comments',
      'Comments',
      'messages',
      'Messages'
    ]) {
      final value = ticket[key];
      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final text = _firstText(map, [
              'message',
              'response',
              'reply',
              'comment',
              'description',
              'body',
              'text'
            ]);
            if (text.isNotEmpty) {
              messages.add({
                'text': text,
                'fromUser': _isUserMessage(map),
                'date': _dateFrom(map),
              });
            }
          } else if (item != null && item.toString().trim().isNotEmpty) {
            messages.add({
              'text': item.toString().trim(),
              'fromUser': false,
              'date': null,
            });
          }
        }
      }
    }

    for (final key in [
      'resolver_response',
      'resolverResponse',
      'admin_response',
      'adminResponse',
      'resolution',
      'Resolution',
      'response',
      'Response'
    ]) {
      final value = ticket[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        messages.add({
          'text': value,
          'fromUser': false,
          'date': _dateFrom(ticket),
        });
      }
    }

    return messages;
  }

  String _firstText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  bool _isUserMessage(Map<String, dynamic> map) {
    final sender =
        _firstText(map, ['sender', 'sender_type', 'userType', 'type'])
            .toLowerCase();
    if (sender.contains('customer') || sender.contains('user')) return true;
    if (sender.contains('admin') ||
        sender.contains('resolver') ||
        sender.contains('support') ||
        sender.contains('agent')) return false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages();
    final status = _value(['status']).isEmpty ? 'Open' : _value(['status']);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('#TK${ticket['id'] ?? ''}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
              _value(['title', 'category']).isEmpty
                  ? 'Ticket Conversation'
                  : _value(['title', 'category']),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(status.capitalize(),
              style: TextStyle(
                  fontSize: 12,
                  color: ThemeHelper.getSecondaryTextColor(context))),
          const SizedBox(height: 18),
          if (messages.isEmpty)
            Text('No messages available for this ticket yet.',
                style: TextStyle(
                    fontSize: 13,
                    color: ThemeHelper.getSecondaryTextColor(context)))
          else
            ...messages.map((message) => _MessageBubble(
                  text: message['text']?.toString() ?? '',
                  fromUser: message['fromUser'] == true,
                  time: _formatDate(message['date'] as DateTime?),
                )),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool fromUser;
  final String time;

  const _MessageBubble({
    required this.text,
    required this.fromUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = fromUser
        ? (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.accentOrange
            : AppTheme.primaryNavy)
        : ThemeHelper.getCardColor(context);
    final textColor =
        fromUser ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(fromUser ? 14 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 14),
          ),
          border: fromUser
              ? null
              : Border.all(color: ThemeHelper.getBorderColor(context)),
        ),
        child: Column(
          crossAxisAlignment:
              fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(fromUser ? 'You' : 'Resolver',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: fromUser
                        ? Colors.white70
                        : ThemeHelper.getSecondaryTextColor(context))),
            const SizedBox(height: 5),
            Text(text,
                style: TextStyle(fontSize: 13, height: 1.35, color: textColor)),
            if (time.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(time,
                  style: TextStyle(
                      fontSize: 10,
                      color: fromUser
                          ? Colors.white70
                          : ThemeHelper.getSecondaryTextColor(context))),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
