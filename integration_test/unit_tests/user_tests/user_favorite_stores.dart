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
import 'package:tuple/tuple.dart';

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

  group('add and remove user\'s favorite store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late PhysicalStoreModel physicalModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        onlineModel = OnlineStoreModel(
            name: "online test",
            phoneNumber: "+972123456789",
            address: "Ashdod, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        physicalModel = PhysicalStoreModel(
            name: "physical store",
            phoneNumber: "+972123456789",
            address: "Tel Aviv, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        var favStores = UsersStorageProxy.toJsonFromTupleList(
            [Tuple2(onlineModel.id, true)]);
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            imageUrl: "https://pic.png",
            hideStoreOwnerOptions: false,
            favoriteStores: favStores,
            isLoggedIn: true);
        await Amplify.DataStore.save(onlineModel);
        await Amplify.DataStore.save(physicalModel);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
        await Amplify.DataStore.delete(onlineModel);
        await Amplify.DataStore.delete(physicalModel);
      });
    });

    test('add favorite store - good scenario', () async {
      var res =
          await UsersStorageProxy().addFavoriteStore(physicalModel.id, false);
      expect(res.getTag(), true);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 2);
      expect(
          fav.firstWhere((element) => element.item1 == physicalModel.id,
                  orElse: null) !=
              null,
          true);
    });

    test('add favorite store - bad scenario - the store is already a favorite',
        () async {
      var res =
          await UsersStorageProxy().addFavoriteStore(onlineModel.id, true);
      expect(res.getTag(), false);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 1);
    });

    test('remove favorite store - good scenario', () async {
      var res =
          await UsersStorageProxy().removeFavoriteStore(onlineModel.id, true);
      expect(res.getTag(), true);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 0);
    });

    test('remove favorite store - bad scenario - the store is not a favorite',
        () async {
      var res = await UsersStorageProxy()
          .removeFavoriteStore(physicalModel.id, false);
      expect(res.getTag(), false);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 1);
    });
  });
}
