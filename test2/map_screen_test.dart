// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/map_screen.dart';

void main() {
  testWidgets('Map Screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MapScreen().wrapWithMaterial());

    // Verify that our counter starts at 0.
    expect(find.text('Campground'), findsOneWidget);
    expect(find.text('Locksmith'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
    expect(find.text('Pet Store'), findsOneWidget);
    expect(find.text('Lawyer'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);
  });
}
