import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:tuple/tuple.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  bool configured = false;
  Openings op = Openings(days: [
    new OpeningTimes(
        day: "Sunday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Monday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Tuesday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Wednesday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Thursday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Friday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Saturday",
        closed: false,
        operationHours: Tuple2(
            TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
  ]);

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

  DateTime _getPSTTime() {
    tz.initializeTimeZones();

    final DateTime now = DateTime.now();
    final pacificTimeZone = tz.getLocation('Asia/Jerusalem');

    return tz.TZDateTime.from(now, pacificTimeZone);
  }

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('Try to purchase from deleted store', () {
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

    test('online scenario', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy()
          .createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      ProductDTO productDTO = ProductDTO(
          id: "",
          name: "prod",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: "",
          imageFromPhone: null);
      OnlineStoreDTO onlineStoreDTO = OnlineStoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: [productDTO]);
      BankAccountDTO bankAccountDTO =
          BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes =
          await user2.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String onlineModelID = openStoreRes.getValue();

      //"login" as the first user and make a purchase from the second user's store
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      CartProductDTO cartProductDTO = CartProductDTO(
          "",
          productDTO.name,
          productDTO.price,
          "",
          null,
          productDTO.description,
          10,
          onlineModelID,
          "");
      await user1.updateOrCreateCartProduct(productDTO, onlineModelID, 10);

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
      String card = addCreditCardRes.getValue();

      //login as the second user and delete the store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      var deleteRes = await user2.deleteStore(onlineModelID, true);
      expect(deleteRes.getTag(), true);

      await Future.delayed(Duration(seconds: 5));
      //login as the first user and try to make a purchase
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var makePaymentRes = await user1.makePaymentOnlineStore(card, 0,
          productDTO.price * cartProductDTO.amount, user1.bagInStores.first);
      expect(makePaymentRes.getTag(), false);

      ShoppingBagDTO? shoppingBag =
          await user1.getCurrShoppingBag(onlineModelID);
      expect(shoppingBag != null,
          true); //becuase the payment was not succsseful, the shopping should remain unchanged
      expect(shoppingBag!.onlineStoreID, onlineModelID);
      expect(shoppingBag.userId, user1.id);
      expect(shoppingBag.products.length, 1);
      expect(shoppingBag.products.first.name, productDTO.name);
      expect(shoppingBag.products.first.amount, cartProductDTO.amount);

      DateTime now = _getPSTTime();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases =
          await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 0);
    }, timeout: Timeout(Duration(minutes: 1)));

    test('physical scenario', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy()
          .createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO =
          BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes =
          await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();

      //"login" as the first user and make a purchase from the second user's store
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");

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
      String card = addCreditCardRes.getValue();

      //login as the second user and delete the store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      var deleteRes = await user2.deleteStore(physicalStoreID, false);
      expect(deleteRes.getTag(), true);

      await Future.delayed(Duration(seconds: 5));

      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var makePaymentRes =
          await user1.makePaymentPhysicalStore(card, 0, 100, physicalStoreID);
      expect(makePaymentRes.getTag(), false);

      DateTime now = _getPSTTime();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases =
          await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 0);
    }, timeout: Timeout(Duration(minutes: 1)));
  });
}
