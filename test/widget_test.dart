// FinanceFlow AI Widget Tests
// This file contains tests for the FinanceFlow AI app

import 'package:flutter_test/flutter_test.dart';
import 'package:finance_flow_ai/main.dart';

void main() {
  testWidgets('App initializes and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const FinanceFlowApp());

    // Verify that splash screen elements are present
    expect(find.text('FinanceFlow'), findsOneWidget);
    expect(find.text('AI-Powered Finance Manager'), findsOneWidget);
  });
}
