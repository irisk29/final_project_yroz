import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  bool configured = false;

  Future<void> _configureAmplify() async {
    if (!configured) {
      Amplify.addPlugin(AmplifyAuthCognito());
      Amplify.addPlugin(AmplifyStorageS3());
      Amplify.addPlugin(
          AmplifyDataStore(modelProvider: ModelProvider.instance));
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

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('add and remove user\'s credit card', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            imageUrl: "https://pic.png",
            hideStoreOwnerOptions: false,
            creditCards: "[\"creditToken\"]",
            isLoggedIn: true);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('add credit card - good scenario', () async {
      String token = "token";
      var res = await UsersStorageProxy().addCreditCardToken(token);
      expect(res.getTag(), true);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.creditCards != null, true);
      List<String> cards = jsonDecode(user.creditCards!).cast<String>();
      expect(cards.contains(token), true);
    });

    test('remove credit card - good scenario', () async {
      String tokenToRemove = "creditToken";
      var res = await UsersStorageProxy().removeCreditCardToken(tokenToRemove);
      expect(res.getTag(), true);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.creditCards != null, true);
      List<String> cards = jsonDecode(user.creditCards!).cast<String>();
      expect(cards.contains(tokenToRemove), false);
    });

    test('remove credit card - bad scenario - no such credit card token',
        () async {
      String tokenToRemove = "nothing";
      var res = await UsersStorageProxy().removeCreditCardToken(tokenToRemove);
      expect(res.getTag(), false);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.creditCards != null, true);
      List<String> cards = jsonDecode(user.creditCards!).cast<String>();
      expect(cards.length, 1);
      expect(cards.contains("creditToken"), true);
    });
  });
}
