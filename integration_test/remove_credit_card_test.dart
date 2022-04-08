import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/widgets/default_store_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:final_project_yroz/screens/credit_cards_screen.dart' as app;
import 'package:intl/intl.dart';
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
    late UserModel user;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      UserModel currUser = new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false, creditCards: "[\"024314cf-d119-5246-b9fb-697bf0a22f0e\"]");
      await Amplify.DataStore.save(currUser);
      await InternalPaymentGateway().createUserAccount(currUser.id);
      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));
      final encrypted = encrypter.encrypt("6886 1232 1189 6261", iv: iv);
      String num = encrypted.base16.toString();
      await InternalPaymentGateway().addUserCreditCard(currUser.id, num, "10/22", "987", "yroz");
      mockObserver = MockNavigatorObserver();
      user = currUser;
      return Future(() => print("starting test.."));
    });

    testWidgets('remove credit card - positive scenario', (WidgetTester tester) async {
      await tester.pumpWidget(app.CreditCardsScreen().wrapWithMaterial([mockObserver], user));
      await tester.pumpAndSettle();

      //start to fill the form
      Finder fab = find.byKey(Key('6261'));
      await tester.longPress(fab);
      await tester.pumpAndSettle();

      await Future.delayed(Duration(seconds: 1));

      fab = find.byKey(Key('yes'));
      await tester.tap(fab,);
      await tester.pumpAndSettle();

      await Future.delayed(Duration(seconds: 10));

      // Verify the credit card was removed
      UserModel? userModel = await UsersStorageProxy().getUser("test@gmail.com");
      assert(userModel!.creditCards=="[]");
    });
  });
}
