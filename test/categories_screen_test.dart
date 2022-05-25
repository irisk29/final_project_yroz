// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_yroz/screens/categories_screen.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';


void main() {
  testWidgets('Categories Screen test', (WidgetTester tester) async {
    Amplify.addPlugin(AmplifyAuthCognito());
    Amplify.addPlugin(AmplifyStorageS3());
    Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
    //Amplify.addPlugin(AmplifyAPI());

    // Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print("Amplify was already configured. Was the app restarted?");
    }
    // Build our app and trigger a frame.
    await tester.pumpWidget(new MaterialApp(home: new Directionality(textDirection: TextDirection.ltr, child: MediaQuery(data: MediaQueryData(), child: CategoriesScreen()))));

    // Verify that our counter starts at 0.
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Physical Stores'), findsOneWidget);
    expect(find.text('Online Stores'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}
