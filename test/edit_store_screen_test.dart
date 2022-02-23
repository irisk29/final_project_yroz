// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:final_project_yroz/screens/edit_store_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Edit store screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(EditStoreScreen().wrapWithMaterial());

    // Verify that our counter starts at 0.
    expect(find.text('Store Name'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Image URL'), findsOneWidget);
  });
}
