// Basic smoke test for the family app.

import 'package:flutter_test/flutter_test.dart';
import 'package:barangay_household_information_application/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyApp());
    expect(find.text('Sign in'), findsWidgets);
  });
}
