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
import 'package:final_project_yroz/screens/edit_online_store_screen.dart';
import 'package:final_project_yroz/widgets/default_store_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:final_project_yroz/screens/edit_online_store_screen.dart' as app;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  bool configured = false;
  takeScreenshot(tester, binding) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    await binding.takeScreenshot('test-screenshot');
  }

  Future<void> _configureAmplify() async {
    if (!configured) {
      Amplify.addPlugin(AmplifyAuthCognito());
      Amplify.addPlugin(AmplifyStorageS3());
      Amplify.addPlugin(
          AmplifyDataStore(modelProvider: ModelProvider.instance));
      //Amplify.addPlugin(AmplifyAPI());

      // Amplify can only be configured once.
      try {
        await Amplify.configure(amplifyconfig);
        configured = true;
      } on AmplifyAlreadyConfiguredException {
        print("Amplify was already configured. Was the app restarted?");
      }
    }
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // to make the tests work

  group('end-to-end test', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late NavigatorObserver mockObserver;
    late UserModel user;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      OnlineStoreModel onlineStoreModel = OnlineStoreModel(
          name: "online store test",
          phoneNumber: "+972123456789",
          address: "Ashdod, Israel",
          operationHours: "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
          categories: "[\"Food\"]",
          qrCode: "");
      TemporalDateTime time = TemporalDateTime.fromString(
          DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM').toDateTimeIso8601String());
      StoreOwnerModel storeOwnerModel = StoreOwnerModel(storeOwnerModelOnlineStoreModelId: onlineStoreModel.id, onlineStoreModel: onlineStoreModel, lastPurchasesView: time);
      UserModel currUser = new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false, userModelStoreOwnerModelId: storeOwnerModel.id, storeOwnerModel: storeOwnerModel, isLoggedIn: true);
      await Amplify.DataStore.save(onlineStoreModel);
      await Amplify.DataStore.save(storeOwnerModel);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      user = currUser;
      return Future(() => print("starting test.."));
    });

    testWidgets('edit online store - positive scenario', (WidgetTester tester) async {
      await tester.pumpWidget(app.EditOnlineStorePipeline().wrapWithMaterial([mockObserver], user));
      await tester.pumpAndSettle();

      Finder fab = find.byKey(Key('storeName'));
      await tester.enterText(fab, "");
      await tester.enterText(fab, "online store check");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();


      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('store_category_2'));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      //operations hours
      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();


      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //when pressing this button it creates the store
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await Future.delayed(Duration(seconds: 10));

      ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState("test@gmail.com");
      assert(storeOwnerRes.getTag() == true);
      StoreOwnerModel storeOwnerModel = storeOwnerRes.getValue();
      assert(storeOwnerModel.onlineStoreModel!.name == "online store check");
      assert(storeOwnerModel.storeOwnerModelOnlineStoreModelId != null);
      assert(storeOwnerModel.storeOwnerModelOnlineStoreModelId!.isNotEmpty);
    });

    testWidgets('edit online store - sad scenario', (WidgetTester tester) async {
      await tester.pumpWidget(app.EditOnlineStorePipeline().wrapWithMaterial([mockObserver], user));
      await tester.pumpAndSettle();

      Finder fab = find.byKey(Key('phoneNumber'));
      await tester.enterText(fab, "");
      await tester.enterText(fab, "+9722222");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();


      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('store_category_2'));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      //operations hours
      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();


      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //when pressing this button it creates the store
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await Future.delayed(Duration(seconds: 10));

      ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState("test@gmail.com");
      assert(storeOwnerRes.getTag() == true);
      StoreOwnerModel storeOwnerModel = storeOwnerRes.getValue();
      assert(storeOwnerModel.onlineStoreModel!.phoneNumber != "+9722222");
      assert(storeOwnerModel.storeOwnerModelOnlineStoreModelId != null);
      assert(storeOwnerModel.storeOwnerModelOnlineStoreModelId!.isNotEmpty);
    });
  });
}
