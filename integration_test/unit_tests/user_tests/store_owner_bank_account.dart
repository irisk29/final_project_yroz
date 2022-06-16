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

  group('save and remove store owner\'s bank account', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;
    late String storeOwnerID;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        StoreOwnerModel storeOwnerModel = new StoreOwnerModel();
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            imageUrl: "https://pic.png",
            hideStoreOwnerOptions: false,
            storeOwnerModel: storeOwnerModel,
            userModelStoreOwnerModelId: storeOwnerModel.id,
            isLoggedIn: true);
        storeOwnerID = storeOwnerModel.id;
        await Amplify.DataStore.save(storeOwnerModel);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('save bank account - good scenario', () async {
      String token = "token";
      await UsersStorageProxy().saveStoreBankAccount(token, storeOwnerID);
      var storeOwnerRes =
          await UsersStorageProxy().getStoreOwnerState("unittest@gmail.com");
      expect(storeOwnerRes.getTag(), true);
      StoreOwnerModel owner = storeOwnerRes.getValue();
      expect(owner.bankAccountToken != null, true);
      expect(owner.bankAccountToken, "token");
    });

    test('remove bank account - good scenario', () async {
      String token = "token";
      await UsersStorageProxy().removeStoreBankAccount(token);
      var storeOwnerRes =
          await UsersStorageProxy().getStoreOwnerState("unittest@gmail.com");
      expect(storeOwnerRes.getTag(), true);
      StoreOwnerModel owner = storeOwnerRes.getValue();
      expect(owner.bankAccountToken == null, true);
    });
  });
}
