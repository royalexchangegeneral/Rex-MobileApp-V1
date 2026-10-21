import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rex_insurance/services/app_update_service.dart';
import 'package:rex_insurance/widgets/app_update_gate.dart';

void main() {
  Future<void> pumpGate(WidgetTester tester, {bool required = false}) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) => AppUpdateGate(
        navigatorKey: navigatorKey,
        checkForUpdate: () async => AppUpdateInfo(
          updateAvailable: true,
          forceUpdate: required,
          latestVersion: '2.0.0',
          title: 'Update available',
          message: 'A new version is ready.',
          storeUrl: 'https://example.com/store',
        ),
        child: child!,
      ),
      home: const Scaffold(body: Text('Home')),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows an update above the app navigator and allows Later',
      (tester) async {
    await pumpGate(tester);
    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('required updates cannot be dismissed with back', (tester) async {
    await pumpGate(tester, required: true);
    expect(find.text('Later'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
