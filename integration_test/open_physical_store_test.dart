import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/widgets/default_store_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:final_project_yroz/screens/open_physical_store_screen.dart' as app;
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  takeScreenshot(tester, binding) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    await binding.takeScreenshot('test-screenshot');
  }

  Future<void> _configureAmplify() async {
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
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // to make the tests work

  group('end-to-end test', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late NavigatorObserver mockObserver;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      UserModel currUser = new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      return Future(() => print("starting test.."));
    });

    testWidgets('open physical store - positive scenerio', (WidgetTester tester) async {
      await tester.pumpWidget(app.OpenPhysicalStorePipeline().wrapWithMaterial([mockObserver]));
      await tester.pumpAndSettle();

      //agree to the terms
      Finder fab = find.widgetWithText(ElevatedButton, "Agree");
      await tester.tap(fab);
      await tester.pump();

      //start to fill the form
      fab = find.byKey(Key('storeName'));
      await tester.enterText(fab, "physical store test");
      await tester.pump();

      fab = find.byKey(Key('phoneNumber'));
      await tester.enterText(fab, "+972123456789");
      await tester.pump();

      fab = find.byKey(Key('storeAddress'));
      await tester.enterText(fab, "Ashdod, Israel");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('store_category_0'));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      //operations hours
      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('bank_name'));
      await tester.enterText(fab, "leumi");
      await tester.pump();

      fab = find.byKey(Key('branch_number'));
      await tester.enterText(fab, "123");
      await tester.pump();

      fab = find.byKey(Key('account_number'));
      await tester.enterText(fab, "123456789");
      await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //when pressing this button it creates the store
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key("tutorial_okay_button"))); //tap the alert dialog for the store owner
      await tester.pumpAndSettle();

      // Verify the store was created
      expect(find.byType(StoreItem), findsOneWidget);
      ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState("test@gmail.com");
      assert(storeOwnerRes.getTag() == true);
      StoreOwnerModel storeOwnerModel = storeOwnerRes.getValue();
      assert(storeOwnerModel.storeOwnerModelPhysicalStoreModelId != null);
      assert(storeOwnerModel.storeOwnerModelPhysicalStoreModelId!.isNotEmpty);
    });
  });
}
