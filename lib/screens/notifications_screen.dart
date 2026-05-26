import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../providers/notifications_provider.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'new_policy_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isAgentFlow;
  const NotificationsScreen({super.key, this.isAgentFlow = false});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filter = 0;
  bool get _isAgent => widget.isAgentFlow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false)
          .fetchNotifications(context);
    });
  }

  List<Map<String, dynamic>> _filtered(
      List<Map<String, dynamic>> items, Set<int> read) {
    if (_filter == 1) {
      return items
          .where((n) => read.contains(n['id'] ?? items.indexOf(n)))
          .toList();
    }
    if (_filter == 2) {
      return items
          .where((n) => !read.contains(n['id'] ?? items.indexOf(n)))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
        builder: (context, notifProvider, child) {
      final list =
          _filtered(notifProvider.notifications, notifProvider.readIds);
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pop(context)),
            title: Text('Notification',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            centerTitle: true),
        body: notifProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          children: List.generate(
                              3,
                              (i) => Padding(
                                  padding:
                                      EdgeInsets.only(right: i < 2 ? 8 : 0),
                                  child: GestureDetector(
                                      onTap: () => setState(() => _filter = i),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: _filter == i
                                                  ? AppTheme.bottomNavSelectedColor(
                                                      context)
                                                  : ThemeHelper.getCardColor(
                                                      context),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                  color: _filter == i
                                                      ? AppTheme.bottomNavSelectedColor(context)
                                                      : ThemeHelper.getBorderColor(context))),
                                          child: Text(['All', 'Read', 'Unread'][i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _filter == i ? Colors.white : Theme.of(context).colorScheme.onSurface))))))),
                      const SizedBox(height: 20),
                      if (list.isEmpty)
                        Center(
                            child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Text('No notifications',
                                    style: TextStyle(
                                        color:
                                            ThemeHelper.getSecondaryTextColor(
                                                context)))))
                      else
                        ...list.map((n) => _card(n, notifProvider)),
                      const SizedBox(height: 80),
                    ])),
        floatingActionButton: _isAgent
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
        bottomNavigationBar: _isAgent
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
    });
  }

  Widget _card(Map<String, dynamic> n, NotificationsProvider notifProvider) {
    final id = _notificationId(n, notifProvider);
    final unread = !notifProvider.readIds.contains(id);
    final title = _notificationTitle(n);
    final msg = _notificationMessage(n);
    final time = _notificationTime(n);

    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              if (unread) {
                await notifProvider.markAsRead(context, id);
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NotificationDetailsScreen(
                            notification: n,
                            isAgentFlow: _isAgent,
                          )));
            },
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: ThemeHelper.getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: ThemeHelper.getBorderColor(context))),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppTheme.bottomNavSelectedColor(context)
                                  .withValues(alpha: unread ? 0.16 : 0.1),
                              shape: BoxShape.circle),
                          child: Icon(_iconFor(title),
                              color: AppTheme.bottomNavSelectedColor(context),
                              size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                            if (msg.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(msg,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeHelper.getSecondaryTextColor(
                                          context),
                                      height: 1.4))
                            ],
                            const SizedBox(height: 6),
                            Text(time,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: ThemeHelper.getSecondaryTextColor(
                                        context))),
                          ])),
                      if (unread)
                        Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                                color: AppTheme.accentOrange,
                                shape: BoxShape.circle)),
                    ]))));
  }

  int _notificationId(
      Map<String, dynamic> n, NotificationsProvider notifProvider) {
    final rawId = n['id'] ?? n['Id'] ?? n['ID'] ?? n['notificationId'];
    if (rawId is int) return rawId;
    return int.tryParse(rawId?.toString() ?? '') ??
        notifProvider.notifications.indexOf(n);
  }

  String _notificationTitle(Map<String, dynamic> n) =>
      n['title']?.toString() ??
      n['Title']?.toString() ??
      n['subject']?.toString() ??
      n['Subject']?.toString() ??
      'Notification';

  String _notificationMessage(Map<String, dynamic> n) =>
      n['message']?.toString() ??
      n['Message']?.toString() ??
      n['body']?.toString() ??
      n['Body']?.toString() ??
      n['description']?.toString() ??
      n['Description']?.toString() ??
      n['content']?.toString() ??
      '';

  String _notificationTime(Map<String, dynamic> n) =>
      n['time']?.toString() ??
      n['created_at']?.toString() ??
      n['CreatedAt']?.toString() ??
      n['date']?.toString() ??
      n['Date']?.toString() ??
      n['timestamp']?.toString() ??
      '';

  IconData _iconFor(String t) {
    final l = t.toLowerCase();
    if (l.contains('payment')) return Icons.payment_outlined;
    if (l.contains('claim')) return Icons.check_circle_outline;
    if (l.contains('renew')) return Icons.autorenew;
    if (l.contains('offer')) return Icons.local_offer_outlined;
    return Icons.notifications_outlined;
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

class NotificationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isAgentFlow;

  const NotificationDetailsScreen({
    super.key,
    required this.notification,
    this.isAgentFlow = false,
  });

  String _title() =>
      notification['title']?.toString() ??
      notification['Title']?.toString() ??
      notification['subject']?.toString() ??
      notification['Subject']?.toString() ??
      'Notification';

  String _message() =>
      notification['message']?.toString() ??
      notification['Message']?.toString() ??
      notification['body']?.toString() ??
      notification['Body']?.toString() ??
      notification['description']?.toString() ??
      notification['Description']?.toString() ??
      notification['content']?.toString() ??
      '';

  String _time() =>
      notification['time']?.toString() ??
      notification['created_at']?.toString() ??
      notification['CreatedAt']?.toString() ??
      notification['date']?.toString() ??
      notification['Date']?.toString() ??
      notification['timestamp']?.toString() ??
      '';

  IconData _iconFor(String title) {
    final value = title.toLowerCase();
    if (value.contains('payment')) return Icons.payment_outlined;
    if (value.contains('claim')) return Icons.check_circle_outline;
    if (value.contains('renew')) return Icons.autorenew;
    if (value.contains('offer')) return Icons.local_offer_outlined;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final title = _title();
    final message = _message();
    final time = _time();
    final accent = AppTheme.bottomNavSelectedColor(context);

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
        title: Text(
          'Notification Details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar:
          isAgentFlow ? buildAgentBottomNav(context, currentIndex: 0) : null,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ThemeHelper.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeHelper.getBorderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconFor(title), color: accent, size: 22),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    message.isNotEmpty ? message : 'No details available.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
