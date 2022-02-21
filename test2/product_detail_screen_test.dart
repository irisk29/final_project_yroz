// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_demo/providers/products.dart';
import 'package:provider/provider.dart';
import '../lib/screens/product_detail_screen.dart';

void main() {

  testWidgets('Product Detail Screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProductDetailScreen().wrapWithMaterial());

    // Verify that our counter starts at 0.
    expect(find.text('\€'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
  });
}
