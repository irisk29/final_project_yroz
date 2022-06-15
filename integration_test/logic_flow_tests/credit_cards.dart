import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

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

  Future<void> clearDB() async {
    List<StoreProductModel> prods =
        await Amplify.DataStore.query(StoreProductModel.classType);
    for (var p in prods) await Amplify.DataStore.delete(p);

    List<OnlineStoreModel> onlines =
        await Amplify.DataStore.query(OnlineStoreModel.classType);
    for (var o in onlines) await Amplify.DataStore.delete(o);

    List<PhysicalStoreModel> phys =
        await Amplify.DataStore.query(PhysicalStoreModel.classType);
    for (var p in phys) await Amplify.DataStore.delete(p);

    List<CartProductModel> carts =
        await Amplify.DataStore.query(CartProductModel.classType);
    for (var c in carts) await Amplify.DataStore.delete(c);

    List<ShoppingBagModel> bags =
        await Amplify.DataStore.query(ShoppingBagModel.classType);
    for (var b in bags) await Amplify.DataStore.delete(b);

    List<StoreOwnerModel> owners =
        await Amplify.DataStore.query(StoreOwnerModel.classType);
    for (var o in owners) await Amplify.DataStore.delete(o);

    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType);
    for (var u in users) await Amplify.DataStore.delete(u);

    List<PurchaseHistoryModel> purchases =
        await Amplify.DataStore.query(PurchaseHistoryModel.classType);
    for (var p in purchases) await Amplify.DataStore.delete(p);
  }

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('Credit Card', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
      });
    });

    tearDown(() {
      return Future(() async {
        await clearDB();
        print("cleared db");
      });
    });

    test('add the same credit card twice', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      Secret secret =
          await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes =
          await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);

      addCreditCardRes = await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), false);
    });

    test('try to remove credit card that we already removed', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      Secret secret =
          await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes =
          await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);
      String creditCardToken = addCreditCardRes.getValue();

      var removeCreditCardRes =
          await user1.removeCreditCardToken(creditCardToken);
      expect(removeCreditCardRes.getTag(), true);

      removeCreditCardRes = await user1.removeCreditCardToken(creditCardToken);
      expect(removeCreditCardRes.getTag(), false);
    });
  });
}
