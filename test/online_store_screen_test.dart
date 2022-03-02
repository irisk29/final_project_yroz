// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Online Store Screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(OnlineStoreScreen().wrapWithMaterial());

    // Verify that our counter starts at 0.
    expect(find.text('About the store'), findsOneWidget);
    expect(find.text('Open Now'), findsOneWidget);
    expect(find.text('www.mooo.com'), findsOneWidget);
    expect(find.text('+44 345 3366'), findsOneWidget);
  });
}
