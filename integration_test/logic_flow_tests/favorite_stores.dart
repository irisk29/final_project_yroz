import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tuple/tuple.dart';

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

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('Favorites - online store', () {
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

    test('add to favorite - good scenario', () async {
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

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);
    });

    test('add to favorite - store is already one', () async {
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

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);

      favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), false); //already a favorite

      //check that the favorite list did not change
      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.length, 1);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);
    });

    test('remove favorite - good scenario', () async {
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

      //"login" as the first user and add the second user's store to favorites, then remove it
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.first.item1, onlineModelID);
      expect(fav.first.item2, true);

      favRes = await user1.removeFavoriteStore(onlineModelID, true);
      expect(favRes.getTag(), true);

      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.length, 0);
    });

    test('remove favorite - bad scenario: no such favorite', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
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

    test('add to favorite - good scenario', () async {
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

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);
    });

    test('add to favorite - store is already one', () async {
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

      //"login" as the first user and add the second user's store to favorites
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);

      favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), false); //already a favorite

      //check that the favorite list did not change
      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.length, 1);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);
    });

    test('remove favorite - good scenario', () async {
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

      //"login" as the first user and add the second user's store to favorites, then remove it
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      var favRes = await user1.addFavoriteStore(physicalStoreID, false);
      expect(favRes.getTag(), true);

      var userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      List<Tuple2<String, bool>> fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.first.item1, physicalStoreID);
      expect(fav.first.item2, false);

      favRes = await user1.removeFavoriteStore(physicalStoreID, true);
      expect(favRes.getTag(), true);

      userWithFavorites = await UsersStorageProxy().getUser(user1.email!);
      expect(userWithFavorites != null, true);
      expect(userWithFavorites!.favoriteStores != null, true);
      fav = UsersStorageProxy.fromJsonToTupleList(
          userWithFavorites.favoriteStores!);
      expect(fav.length, 0);
    });

    test('remove favorite - bad scenario: no such favorite', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
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
}
