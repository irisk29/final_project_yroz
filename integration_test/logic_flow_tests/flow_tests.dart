import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/PurchaseHistoryDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

void main() {
  bool configured = false;

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

  Future<void> clearDB() async {
    List<StoreProductModel> prods = await Amplify.DataStore.query(StoreProductModel.classType);
    for (var p in prods) await Amplify.DataStore.delete(p);

    List<OnlineStoreModel> onlines = await Amplify.DataStore.query(OnlineStoreModel.classType);
    for (var o in onlines) await Amplify.DataStore.delete(o);

    List<PhysicalStoreModel> phys = await Amplify.DataStore.query(PhysicalStoreModel.classType);
    for (var p in phys) await Amplify.DataStore.delete(p);

    List<CartProductModel> carts = await Amplify.DataStore.query(CartProductModel.classType);
    for (var c in carts) await Amplify.DataStore.delete(c);

    List<ShoppingBagModel> bags = await Amplify.DataStore.query(ShoppingBagModel.classType);
    for (var b in bags) await Amplify.DataStore.delete(b);

    List<StoreOwnerModel> owners = await Amplify.DataStore.query(StoreOwnerModel.classType);
    for (var o in owners) await Amplify.DataStore.delete(o);

    List<UserModel> users = await Amplify.DataStore.query(UserModel.classType);
    for (var u in users) await Amplify.DataStore.delete(u);

    List<PurchaseHistoryModel> purchases = await Amplify.DataStore.query(PurchaseHistoryModel.classType);
    for (var p in purchases) await Amplify.DataStore.delete(p);
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // to make the tests work

  group('make online payment', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
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

    test('make payment - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
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
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String onlineModelID = openStoreRes.getValue();

      //"login" as the first user and make a purchase from the second user's store
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      CartProductDTO cartProductDTO = CartProductDTO(
          "", productDTO.name, productDTO.price, "", null, productDTO.description, 10, onlineModelID, "");
      await user1.updateOrCreateCartProduct(productDTO, onlineModelID, 10);

      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes = await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);
      String card = addCreditCardRes.getValue();

      var makePaymentRes = await user1.makePaymentOnlineStore(
          card, 0, productDTO.price * cartProductDTO.amount, user1.bagInStores.first);
      expect(makePaymentRes.getTag(), true);
      String transaction = makePaymentRes.getValue();

      DateTime now = DateTime.now();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases = await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 1);
      PurchaseHistoryDTO purchase = purchases.first;
      expect(purchase.transactionID, transaction);
      expect(purchase.userID, user1.id);
      expect(purchase.cashBackAmount, 0);
      expect(purchase.creditAmount, productDTO.price * cartProductDTO.amount);
      expect(purchase.storeID, onlineModelID);
    });

    test('make payment - bad scenario: using cashback when the user does not have any', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
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
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String onlineModelID = openStoreRes.getValue();

      //"login" as the first user and make a purchase from the second user's store
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      CartProductDTO cartProductDTO = CartProductDTO(
          "", productDTO.name, productDTO.price, "", null, productDTO.description, 10, onlineModelID, "");
      await user1.updateOrCreateCartProduct(productDTO, onlineModelID, 10);

      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes = await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);
      String card = addCreditCardRes.getValue();

      //use cash bank when the user does not have any
      var makePaymentRes = await user1.makePaymentOnlineStore(card, productDTO.price * cartProductDTO.amount * 10,
          productDTO.price * cartProductDTO.amount, user1.bagInStores.first);
      expect(makePaymentRes.getTag(), false);

      ShoppingBagDTO? shoppingBag = await user1.getCurrShoppingBag(onlineModelID);
      expect(shoppingBag != null, true); //becuase the payment was not succsseful, the shopping should remain unchanged
      expect(shoppingBag!.onlineStoreID, onlineModelID);
      expect(shoppingBag.userId, user1.id);
      expect(shoppingBag.products.length, 1);
      expect(shoppingBag.products.first.name, productDTO.name);
      expect(shoppingBag.products.first.amount, cartProductDTO.amount);

      DateTime now = DateTime.now();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases = await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 0);
    });
  });

  group('make physical payment', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
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

    test('make payment - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();

      //"login" as the first user and make a purchase from the second user's store
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");

      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes = await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);
      String card = addCreditCardRes.getValue();

      var makePaymentRes = await user1.makePaymentPhysicalStore(card, 0, 100, physicalStoreID);
      expect(makePaymentRes.getTag(), true);
      String transaction = makePaymentRes.getValue();

      DateTime now = DateTime.now();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases = await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 1);
      PurchaseHistoryDTO purchase = purchases.first;
      expect(purchase.transactionID, transaction);
      expect(purchase.userID, user1.id);
      expect(purchase.cashBackAmount, 0);
      expect(purchase.creditAmount, 100);
    });

    test('make payment - bad scenario: using cashback when the user does not have any', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();

      //"login" as the first user and make a purchase from the second user's store
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");

      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes = await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);
      String card = addCreditCardRes.getValue();

      //use cash bank when the user does not have any
      var makePaymentRes = await user1.makePaymentPhysicalStore(card, 20, 100, physicalStoreID);
      expect(makePaymentRes.getTag(), false);

      DateTime now = DateTime.now();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases = await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 0);
    });
  });

  group('Favorites - online store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
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

    test('add to favorite - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
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
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String onlineModelID = openStoreRes.getValue();

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);
    });

    test('add to favorite - store is already one', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
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
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String onlineModelID = openStoreRes.getValue();

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);

      favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), false); //already a favorite

      //check that the favorite list did not change
      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.length, 1);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);
    });

    test('remove favorite - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
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
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String onlineModelID = openStoreRes.getValue();

      //"login" as the first user and add the second user's store to favorites, then remove it
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);

      favRes = await user1.removeFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.length, 0);
    });

    test('remove favorite - bad scenario: no such favorite', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      var favRes = await user1.removeFavoriteStore("aa", true);
      expect(favRes.getTag(), false);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, false); //no favorites
    });
  });

  group('Favorites - physical store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
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

    test('add to favorite - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);
    });

    test('add to favorite - store is already one', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);

      favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), false); //already a favorite

      //check that the favorite list did not change
      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.length, 1);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);
    });

    test('remove favorite - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      res = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test flow2", "https://pic.png");
      expect(res.item2, true); //created new user
      UserModel secondUser = res.item1;
      User user2 = User.fromModel(secondUser);

      //"login" as the second user and open an online store
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      await user2.createEWallet();
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();

      //"login" as the first user and add the second user's store to favorites, then remove it
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);

      favRes = await user1.removeFavoriteStore(physicalStoreID, true);
      expect(favRes.getTag(), true);

      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(userWithFavorites.favoriteStores!);
      expect(fav.length, 0);
    });

    test('remove favorite - bad scenario: no such favorite', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      var favRes = await user1.removeFavoriteStore("aa", false);
      expect(favRes.getTag(), false);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, false); //no favorites
    });
  });

  group('Upgrade physical store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
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

    test('upgrade - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);

      physicalStoreDTO.id = physicalStoreID;
      var upgradeRes = await user1.convertPhysicalStoreToOnline(physicalStoreDTO);
      expect(upgradeRes.getTag(), true);

      var onlineStore = await StoreStorageProxy().fetchOnlineStore(upgradeRes.getValue());
      expect(onlineStore != null, true);
      expect(onlineStore!.name, physicalStoreDTO.name);
      expect(onlineStore.address, physicalStoreDTO.address);
      expect(onlineStore.phoneNumber, physicalStoreDTO.phoneNumber);
      expect(onlineStore.categories, JsonEncoder.withIndent('  ').convert(physicalStoreDTO.categories));
      expect(
          onlineStore.operationHours,
          JsonEncoder.withIndent('  ', (value) {
            if (value is TimeOfDay) {
              final now = new DateTime.now();
              final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
              final format = DateFormat.jm();
              return format.format(dt);
            } else {
              return value.toJson();
            }
          }).convert(physicalStoreDTO.operationHours));
      expect(onlineStore.storeProductModels!.length, 0);
    });

    test('upgrade - add products to the new online store', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);

      physicalStoreDTO.id = physicalStoreID;
      var upgradeRes = await user1.convertPhysicalStoreToOnline(physicalStoreDTO);
      expect(upgradeRes.getTag(), true);

      var onlineStore = await StoreStorageProxy().fetchOnlineStore(upgradeRes.getValue());
      expect(onlineStore != null, true);
      expect(onlineStore!.name, physicalStoreDTO.name);
      expect(onlineStore.address, physicalStoreDTO.address);
      expect(onlineStore.phoneNumber, physicalStoreDTO.phoneNumber);
      expect(onlineStore.categories, JsonEncoder.withIndent('  ').convert(physicalStoreDTO.categories));
      expect(
          onlineStore.operationHours,
          JsonEncoder.withIndent('  ', (value) {
            if (value is TimeOfDay) {
              final now = new DateTime.now();
              final dt = DateTime(now.year, now.month, now.day, value.hour, value.minute);
              final format = DateFormat.jm();
              return format.format(dt);
            } else {
              return value.toJson();
            }
          }).convert(physicalStoreDTO.operationHours));
      expect(onlineStore.storeProductModels!.length, 0);

      ProductDTO productDTO = ProductDTO(
          id: "",
          name: "prod",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: "",
          imageFromPhone: null);

      OnlineStoreDTO onlineDTO = (await StoreStorageProxy().convertOnlineStoreModelToDTO([onlineStore])).first;
      String onlineStoreID = onlineDTO.id;
      productDTO.storeID = onlineStoreID;
      onlineDTO.products.add(productDTO);
      var editOnlineStore = await user1.updateOnlineStore(onlineDTO); //add product to store
      expect(editOnlineStore.getTag(), true);

      CartProductDTO cartProductDTO = CartProductDTO(
          "", productDTO.name, productDTO.price, "", null, productDTO.description, 10, onlineStoreID, "");
      await user1.updateOrCreateCartProduct(productDTO, onlineStoreID, 10);

      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();
      var addCreditCardRes = await user1.addCreditCard(num, "10/22", "987", "yroz");
      expect(addCreditCardRes.getTag(), true);
      String card = addCreditCardRes.getValue();

      var makePaymentRes = await user1.makePaymentOnlineStore(
          card, 0, productDTO.price * cartProductDTO.amount, user1.bagInStores.first);
      expect(makePaymentRes.getTag(), true);
      String transaction = makePaymentRes.getValue();

      DateTime now = DateTime.now();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases = await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
      expect(purchases.length, 1);
      PurchaseHistoryDTO purchase = purchases.first;
      expect(purchase.transactionID, transaction);
      expect(purchase.userID, user1.id);
      expect(purchase.cashBackAmount, 0);
      expect(purchase.creditAmount, productDTO.price * cartProductDTO.amount);
      expect(purchase.storeID, onlineStoreID);
    });
  });
}
