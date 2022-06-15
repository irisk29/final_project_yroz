import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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

  group('non-functional tests', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      UserModel currUser = new UserModel(
          email: "test@gmail.com",
          name: "test name",
          hideStoreOwnerOptions: false,
          isLoggedIn: true);
      await Amplify.DataStore.save(currUser);
      return Future(() => print("starting test.."));
    });

    tearDown(() async {
      var res = await UsersStorageProxy().deleteUser("test@gmail.com");
      print("in tear down: ${res.getMessage()}");
    });

    testWidgets('50 users simultaneously', (WidgetTester tester) async {
      int numOfUsers = 50;
      List<User> arr = [];
      for (int i = 0; i < numOfUsers; i++) {
        var res = await UsersStorageProxy().createUser(
            "flowtest$i@gmail.com", "test$i flow", "https://pic.png");
        User currUser = User.fromModel(res.item1);
        arr.add(currUser);
        await Amplify.DataStore.save(res.item1);
      }

      int responses = 0;
      for (int i = 0; i < arr.length; i++) {
        UserAuthenticator().setCurrentUserId("flowtest$i@gmail.com");
        arr[i].getEWalletBalance().then((value) => responses++);
      }
      await Future.delayed(Duration(seconds: 5));
      expect(responses, numOfUsers);

      for (int i = 0; i < numOfUsers; i++) {
        var u = await UsersStorageProxy().getUser("flowtest$i@gmail.com");
        if (u != null) {
          print("deleted user - ${u.email}");
          await Amplify.DataStore.delete(u);
        }
      }
    });
  });
}
