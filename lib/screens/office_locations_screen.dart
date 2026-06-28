import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import '../utils/app_theme.dart';
import '../utils/theme_helper.dart';
import '../widgets/agent_bottom_nav.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'my_claims_screen.dart';
import 'my_policies_screen.dart';
import 'new_policy_screen.dart';

class OfficeLocationsScreen extends StatefulWidget {
  final bool isAgentFlow;
  const OfficeLocationsScreen({super.key, this.isAgentFlow = false});
  @override
  State<OfficeLocationsScreen> createState() => _OfficeLocationsScreenState();
}

class _OfficeLocationsScreenState extends State<OfficeLocationsScreen> {
  String _currentAddress = 'Detecting your location...';
  int _closestIdx = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _offices = [
    {
      'name': 'Head Office',
      'address':
          '26E Abdulrahman Okene Close, off Ligali Ayorinde street, VI, Lagos',
      'hours': 'Mon-Fri 8AM-4PM',
      'phone': '+234 708 0606 100',
      'email': 'general@rexinsure.com',
      'lat': 6.4281,
      'lng': 3.4219
    },
    {
      'name': 'Lagos Main Branch',
      'address': '41 Ikorodu Road, Jibowu, Lagos',
      'hours': 'Mon-Fri 8AM-4PM',
      'phone': '08055266886',
      'lat': 6.4905,
      'lng': 3.3711
    },
    {
      'name': 'Abuja',
      'address':
          '21 Park Plaza, Ademola Adetokunbo Crescent, Wuse II, FCT, Abuja',
      'hours': 'Mon-Fri 8AM-4PM',
      'phone': '08032122649',
      'lat': 9.0579,
      'lng': 7.4951
    },
    {
      'name': 'Port Harcourt',
      'address':
          '2nd Floor, Plot 278, Diobu (Tombia Plaza) New GRA Phase II, Port Harcourt, River State',
      'hours': 'Mon-Fri 8AM-4PM',
      'phone': '08066746261',
      'lat': 4.8156,
      'lng': 7.0498
    },
  ];

  late WebViewController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_mapHtml());
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() =>
            _currentAddress = 'Location services disabled. Please enable GPS.');
        return;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied)
        p = await Geolocator.requestPermission();
      if (p == LocationPermission.deniedForever ||
          p == LocationPermission.denied) {
        setState(() => _currentAddress = 'Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      debugPrint('=== GOT POSITION: ${pos.latitude}, ${pos.longitude} ===');
      _closestIdx = _findClosest(pos.latitude, pos.longitude);
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
            p.country
          ].where((s) => s != null && s.isNotEmpty).toList();
          setState(() => _currentAddress = parts.join(', '));
        }
      } catch (_) {
        setState(() => _currentAddress =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
      }
      _mapController.loadHtmlString(_mapHtml());
      setState(() {});
    } catch (e) {
      debugPrint('=== LOCATION ERROR: $e ===');
      if (mounted)
        setState(() => _currentAddress = 'Could not get location: $e');
    }
  }

  int _findClosest(double lat, double lng) {
    int idx = 0;
    double minD = double.infinity;
    for (int i = 0; i < _offices.length; i++) {
      final d = _dist(lat, lng, _offices[i]['lat'], _offices[i]['lng']);
      if (d < minD) {
        minD = d;
        idx = i;
      }
    }
    return idx;
  }

  double _dist(double lat1, double lng1, double lat2, double lng2) {
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 6371 * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  bool _isOpen() {
    final n = DateTime.now();
    return n.weekday >= 1 && n.weekday <= 5 && n.hour >= 8 && n.hour < 16;
  }

  String _mapHtml() {
    final o = _offices[_closestIdx];
    return '''<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>body{margin:0}#map{width:100%;height:100vh}</style></head><body>
    <div id="map"></div><script>
    var map=L.map('map').setView([${o['lat']},${o['lng']}],15);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png',{maxZoom:19}).addTo(map);
    L.marker([${o['lat']},${o['lng']}]).addTo(map).bindPopup('${o['name']}').openPopup();
    </script></body></html>''';
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _isOpen();
    final closest = _offices[_closestIdx];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.pop(context)),
          title: Text('Office Locations',
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
            TextField(
                controller: _searchController,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                    hintText: 'Search by location or zip',
                    hintStyle: TextStyle(
                        color: ThemeHelper.getSecondaryTextColor(context),
                        fontSize: 13),
                    suffixIcon: Icon(Icons.my_location,
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.accentOrange
                                    : AppTheme.primaryNavy)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
            const SizedBox(height: 14),
            Row(children: [
              Icon(Icons.my_location,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.accentOrange
                      : AppTheme.primaryNavy,
                  size: 16),
              const SizedBox(width: 6),
              Text('Your Current location',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.accentOrange
                          : AppTheme.primaryNavy))
            ]),
            const SizedBox(height: 4),
            Text(_currentAddress,
                style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getSecondaryTextColor(context))),
            const SizedBox(height: 14),
            // Map
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                    height: 200,
                    child: WebViewWidget(controller: _mapController))),
            const SizedBox(height: 20),
            Center(
                child: Text('Location closest to you',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface))),
            const SizedBox(height: 14),
            _buildCard(context, closest, isOpen),
            const SizedBox(height: 20),
            Center(
                child: Text('Our Office Location',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface))),
            const SizedBox(height: 14),
            ...List.generate(_offices.length, (i) {
              final o = _offices[i];
              if (_searchQuery.isNotEmpty &&
                  !'${o['name']} ${o['address']}'
                      .toLowerCase()
                      .contains(_searchQuery)) return const SizedBox.shrink();
              return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildCard(context, o, isOpen));
            }),
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
                        _nav(
                            Icons.description_outlined,
                            'Policies',
                            false,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MyPoliciesScreen()))),
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

  Widget _buildCard(BuildContext ctx, Map<String, dynamic> o, bool isOpen) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: ThemeHelper.getCardColor(ctx),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeHelper.getBorderColor(ctx))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), shape: BoxShape.circle),
                child: Icon(Icons.business,
                    color: Theme.of(ctx).brightness == Brightness.dark
                        ? AppTheme.accentOrange
                        : AppTheme.primaryNavy,
                    size: 18)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(o['name'],
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface))),
            Icon(Icons.circle,
                size: 8, color: isOpen ? Colors.green : Colors.red),
            const SizedBox(width: 4),
            Text(isOpen ? 'Open Now' : 'Closed',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOpen ? Colors.green : Colors.red)),
          ]),
          const SizedBox(height: 10),
          Text(o['address'],
              style: TextStyle(
                  fontSize: 12,
                  color: ThemeHelper.getSecondaryTextColor(ctx),
                  height: 1.4)),
          const SizedBox(height: 8),
          Text('Hours: ${o['hours']}',
              style: TextStyle(
                  fontSize: 12, color: ThemeHelper.getSecondaryTextColor(ctx))),
          const SizedBox(height: 4),
          Text('Phone: ${o['phone']}',
              style: TextStyle(
                  fontSize: 12, color: ThemeHelper.getSecondaryTextColor(ctx))),
          if (o['email'] != null) ...[
            const SizedBox(height: 4),
            Text('Email: ${o['email']}',
                style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getSecondaryTextColor(ctx)))
          ],
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(
                onPressed: () async {
                  final addr = Uri.encodeComponent(o['address']);
                  final url = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=$addr');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                icon: const Icon(Icons.directions, size: 16),
                label: const Text('Get Directions',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)))),
            const SizedBox(width: 10),
            Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ThemeHelper.getBorderColor(ctx))),
                child: IconButton(
                    icon: Icon(Icons.phone,
                        size: 18,
                        color: ThemeHelper.getSecondaryTextColor(ctx)),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: o['phone']);
                      try {
                        final l = await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                        if (!l && ctx.mounted) _showPhone(ctx, o['phone']);
                      } catch (_) {
                        if (ctx.mounted) _showPhone(ctx, o['phone']);
                      }
                    })),
          ]),
        ]));
  }

  void _showPhone(BuildContext c, String p) => showDialog(
      context: c,
      builder: (x) => AlertDialog(
              title: const Text('Call Office'),
              content: Text(p,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(x), child: const Text('OK'))
              ]));
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
