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

  group('UI test', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late NavigatorObserver mockObserver;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      UserModel currUser =
      new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false, isLoggedIn: true);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      return Future(() => print("starting test.."));
    });

    tearDown(() async {
      var res = await UsersStorageProxy().deleteUser("test@gmail.com");
      print("in tear down: ${res.getMessage()}");
    });


    testWidgets('open online store', (WidgetTester tester) async {
      await tester.pumpWidget(app.OpenOnlineStorePipeline().wrapWithMaterial([mockObserver]));
      await tester.pumpAndSettle();

      //agree to the terms
      Finder fab = find.widgetWithText(ElevatedButton, "Agree");
      await tester.tap(fab);
      await tester.pump();

      expect(find.byKey(Key('storeName')), findsOneWidget);
      expect(find.byKey(Key('phoneNumber')), findsOneWidget);
      expect(find.byKey(Key('storeAddress')), findsOneWidget);
      expect(find.byKey(Key('continue_button')), findsOneWidget);

    });
  });
}
