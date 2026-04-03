import 'package:flutter/material.dart';
import '../screens/agent_dashboard_screen.dart';
import '../screens/agent_policies_screen.dart';
import '../screens/clients_list_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/agent_profile_screen.dart';

BottomNavigationBar buildAgentBottomNav(BuildContext context, {int currentIndex = 0}) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: const Color(0xFF1E2D64),
    unselectedItemColor: Colors.grey,
    currentIndex: currentIndex,
    onTap: (index) {
      if (index == 0) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AgentDashboardScreen()), (r) => false);
      if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentPoliciesScreen()));
      if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsListScreen()));
      if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
      if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentProfileScreen()));
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Policy'),
      BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clients'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    ],
  );
}
