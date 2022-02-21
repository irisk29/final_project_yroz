// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/cart_screen.dart';

void main() {
  testWidgets('Cart Screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CartScreen().wrapWithMaterial());

    // Verify that our counter starts at 0.
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('ORDER NOW'), findsOneWidget);
  });
}
