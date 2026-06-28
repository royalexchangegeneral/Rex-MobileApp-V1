import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rex_insurance/main.dart';

void main() {
  testWidgets('app opens to onboarding screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Into a Future Built on Security and Confidence'),
        findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
