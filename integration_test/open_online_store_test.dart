import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/widgets/default_store_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:final_project_yroz/screens/open_online_store_screen.dart' as app;
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
      Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
      Amplify.addPlugin(AmplifyAPI());

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

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      UserModel currUser = new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false, isLoggedIn: true);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      return Future(() => print("starting test.."));
    });

    tearDown(() async {
      var res = await UsersStorageProxy().deleteUser("test@gmail.com");
      print("in tear down: ${res.getMessage()}");
    });

    testWidgets('open online store - positive scenario', (WidgetTester tester) async {
      await tester.pumpWidget(app.OpenOnlineStorePipeline().wrapWithMaterial([mockObserver]));
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

      //add product
      fab = find.byKey(Key("add_product")); //move to the add product screen
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('title'));
      await tester.enterText(fab, "shoelace");
      await tester.pump();

      fab = find.byKey(Key('price'));
      await tester.enterText(fab, "12.5");
      await tester.pump();

      fab = find.byKey(Key('description'));
      await tester.enterText(fab, "very good product");
      await tester.pump();

      fab = find.byKey(Key("save")); //go back
      await tester.tap(fab);
      await tester.pumpAndSettle();

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
      assert(storeOwnerModel.storeOwnerModelOnlineStoreModelId != null);
      assert(storeOwnerModel.storeOwnerModelOnlineStoreModelId!.isNotEmpty);
    });

    testWidgets('open online store - sad scenario', (WidgetTester tester) async {
      await tester.pumpWidget(app.OpenOnlineStorePipeline().wrapWithMaterial([mockObserver]));
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
      await tester.enterText(fab, "+1234567"); //wrong phone format
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

      //add product
      fab = find.byKey(Key("add_product")); //move to the add product screen
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('title'));
      await tester.enterText(fab, "shoelace");
      await tester.pump();

      fab = find.byKey(Key('price'));
      await tester.enterText(fab, "12.5");
      await tester.pump();

      fab = find.byKey(Key('description'));
      await tester.enterText(fab, "very good product");
      await tester.pump();

      fab = find.byKey(Key("save")); //go back
      await tester.tap(fab);
      await tester.pumpAndSettle();

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

      await Amplify.DataStore.clear();
      await Amplify.DataStore.start();
      var hubSubscription = Amplify.Hub.listen([HubChannel.DataStore], (msg) async {
        if (msg.eventName == 'ready') {
          print("ready to check");
          List<OnlineStoreDTO> onlineStores = await StoreStorageProxy().fetchAllOnlineStores();
          assert(onlineStores.isEmpty);
          print("finished check");
        } else {
          print("Not ready yet");
        }
      });
      await Future.delayed(Duration(seconds: 10));

      await tester.tap(find.byKey(Key("tutorial_okay_button"))); //tap the alert dialog for the store owner
      await tester.pumpAndSettle();

      expect(find.byType(StoreItem), findsNothing); // no store should apear because the open was not succssefull
    });
  });
}
