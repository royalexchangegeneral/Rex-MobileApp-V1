import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'policy_provider.dart';
import 'agent_policy_provider.dart';
import 'notifications_provider.dart';

void clearSessionCaches(BuildContext context) {
  try {
    Provider.of<PolicyProvider>(context, listen: false).clear();
  } catch (_) {}

  try {
    Provider.of<AgentPolicyProvider>(context, listen: false).clear();
  } catch (_) {}

  try {
    Provider.of<NotificationsProvider>(context, listen: false).clear();
  } catch (_) {}
}
