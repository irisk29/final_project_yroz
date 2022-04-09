import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
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

  group('create new user', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    setUp(() {
      return Future(() async {
        await _configureAmplify();
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('good scenario', () async {
      var res = await UsersStorageProxy().createUser("unittest@gmail.com", "test name", "https://pic.png");
      expect(res.item2, true); //created new user
      expect(res.item1.name, "test name");
      expect(res.item1.email, "unittest@gmail.com");
      expect(res.item1.imageUrl, "https://pic.png");
    });
  });

  group('fetch existing user', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com", name: "test name", imageUrl: "https://pic.png", hideStoreOwnerOptions: false, isLoggedIn: true);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('good scenario', () async {
      var res = await UsersStorageProxy().createUser("unittest@gmail.com", "test name", "https://pic.png");
      expect(res.item2, false); //fetched the user
      expect(res.item1.name, "test name");
      expect(res.item1.email, "unittest@gmail.com");
      expect(res.item1.imageUrl, "https://pic.png");
    });
  });

  group('create new user', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    setUp(() {
      return Future(() async {
        await _configureAmplify();
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('good scenario', () async {
      var res = await UsersStorageProxy().createUser("unittest@gmail.com", "test name", "https://pic.png");
      expect(res.item2, true); //created new user
      expect(res.item1.name, "test name");
      expect(res.item1.email, "unittest@gmail.com");
      expect(res.item1.imageUrl, "https://pic.png");
    });
  });

  group('add and remove user\'s favorite store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
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
        var favStores = UsersStorageProxy.toJsonFromTupleList([Tuple2(onlineModel.id, true)]);
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
      var res = await UsersStorageProxy().addFavoriteStore(physicalModel.id, false);
      expect(res.getTag(), true);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 2);
      expect(fav.firstWhere((element) => element.item1 == physicalModel.id, orElse: null) != null, true);
    });

    test('add favorite store - bad scenario - the store is already a favorite', () async {
      var res = await UsersStorageProxy().addFavoriteStore(onlineModel.id, true);
      expect(res.getTag(), false);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 1);
    });

    test('remove favorite store - good scenario', () async {
      var res = await UsersStorageProxy().removeFavoriteStore(onlineModel.id, true);
      expect(res.getTag(), true);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 0);
    });

    test('remove favorite store - bad scenario - the store is not a favorite', () async {
      var res = await UsersStorageProxy().removeFavoriteStore(physicalModel.id, false);
      expect(res.getTag(), false);
      var user = await UsersStorageProxy().getUser("unittest@gmail.com");
      expect(user != null, true);
      expect(user!.favoriteStores != null, true);
      var fav = UsersStorageProxy.fromJsonToTupleList(user.favoriteStores!);
      expect(fav.length, 1);
    });
  });

  group('add products to shopping bag', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late StoreProductModel storeProductModel1;
    late StoreProductModel storeProductModel2;
    late String userID;

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
        storeProductModel1 = StoreProductModel(
            name: "product1", categories: "", price: 1.23, onlinestoremodelID: onlineModel.id, description: "wow");
        storeProductModel2 = StoreProductModel(
            name: "product2", categories: "", price: 7.89, onlinestoremodelID: onlineModel.id, description: "cheap");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com", name: "test name", imageUrl: "https://pic.png", hideStoreOwnerOptions: false, isLoggedIn: true);
        userID = currUser.id;
        await Amplify.DataStore.save(onlineModel);
        await Amplify.DataStore.save(storeProductModel1);
        await Amplify.DataStore.save(storeProductModel2);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
        await Amplify.DataStore.delete(onlineModel);
      });
    });

    test('good scenario - add one product', () async {
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await UsersStorageProxy().addProductToShoppingBag(prod, onlineModel.id, 10, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, "product1");
    });

    test('good scenario - add multiple products', () async {
      //only one bag should be created for all the products in the same store
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      ProductDTO prod2 = ProductDTO(
          id: storeProductModel2.id,
          name: storeProductModel2.name,
          price: storeProductModel2.price,
          category: storeProductModel2.categories,
          imageUrl: null,
          description: storeProductModel2.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await UsersStorageProxy().addProductToShoppingBag(prod, onlineModel.id, 10, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, "product1");
      expect(bag.products.first.amount, 10);

      res = await UsersStorageProxy().addProductToShoppingBag(prod2, onlineModel.id, 7, userID);
      expect(res.getTag(), true);
      bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      expect(bags.first.onlineStoreID, onlineModel.id);
      expect(bags.first.products.length, 2);
      expect(
          bags.first.products.firstWhere((element) => element.id == storeProductModel2.id, orElse: null) != null, true);
    });

    test('good scenario - add products from different stores', () async {
      //should create 2 shopping bags for the products from the different stores
      OnlineStoreModel onlineStoreModel = OnlineStoreModel(
          name: "store2",
          phoneNumber: "+972123456789",
          address: "Jerusalem, Israel",
          operationHours:
              "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
          categories: "[\"Food\"]");
      StoreProductModel p =
          StoreProductModel(name: "prod3", categories: "", price: 4.56, onlinestoremodelID: onlineStoreModel.id);
      await Amplify.DataStore.save(onlineStoreModel);
      await Amplify.DataStore.save(p);
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      ProductDTO prod2 = ProductDTO(
          id: p.id,
          name: p.name,
          price: p.price,
          category: p.categories,
          imageUrl: null,
          description: p.description,
          storeID: onlineStoreModel.id,
          imageFromPhone: null);

      var res = await UsersStorageProxy().addProductToShoppingBag(prod, onlineModel.id, 10, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, "product1");
      expect(bag.products.first.amount, 10);

      res = await UsersStorageProxy().addProductToShoppingBag(prod2, onlineStoreModel.id, 5, userID);
      expect(res.getTag(), true);
      bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 2);
      ShoppingBagDTO? bagInFirstStore =
          bags.firstWhere((element) => element.onlineStoreID == onlineModel.id, orElse: null);
      expect(bagInFirstStore != null, true);
      expect(bagInFirstStore.products.length, 1);
      expect(bagInFirstStore.products.first.name, storeProductModel1.name);

      ShoppingBagDTO? bagInSecondStore =
          bags.firstWhere((element) => element.onlineStoreID == onlineStoreModel.id, orElse: null);
      expect(bagInSecondStore != null, true);
      expect(bagInSecondStore.products.length, 1);
      expect(bagInSecondStore.products.first.name, p.name);

      //clean up
      await Amplify.DataStore.delete(onlineStoreModel);
      await Amplify.DataStore.delete(p);
    });
  });

  group('remove products from shopping bag', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late StoreProductModel storeProductModel1;
    late StoreProductModel storeProductModel2;
    late ShoppingBagModel shoppingBagModel;
    late CartProductModel cartProductModel;
    late String userID;

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
        storeProductModel1 = StoreProductModel(
            name: "product1", categories: "", price: 1.23, onlinestoremodelID: onlineModel.id, description: "wow");
        storeProductModel2 = StoreProductModel(
            name: "product2", categories: "", price: 7.89, onlinestoremodelID: onlineModel.id, description: "cheap");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com", name: "test name", imageUrl: "https://pic.png", hideStoreOwnerOptions: false, isLoggedIn: true);
        userID = currUser.id;
        shoppingBagModel = ShoppingBagModel(usermodelID: userID, onlineStoreID: onlineModel.id);
        cartProductModel = CartProductModel(
            name: storeProductModel1.name,
            categories: "",
            price: storeProductModel1.price,
            amount: 50,
            storeProductID: storeProductModel1.id,
            shoppingbagmodelID: shoppingBagModel.id);
        await Amplify.DataStore.save(shoppingBagModel);
        await Amplify.DataStore.save(cartProductModel);
        await Amplify.DataStore.save(onlineModel);
        await Amplify.DataStore.save(storeProductModel1);
        await Amplify.DataStore.save(storeProductModel2);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
        await Amplify.DataStore.delete(onlineModel);
      });
    });

    test('good scenario - remove only product in bag', () async {
      //should remove the product and the shopping bag
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await UsersStorageProxy().removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 0);
      var prods = await UsersStorageProxy().getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(), false); //no products becuase we ereased the shopping bag
    });

    test('good scenario - remove one product', () async {
      //should remove the product but not the bag because we have more products in this bag
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      CartProductModel prod2 = CartProductModel(
          name: storeProductModel2.name,
          price: storeProductModel2.price,
          categories: storeProductModel2.categories,
          imageUrl: null,
          description: storeProductModel2.description,
          amount: 20,
          storeProductID: storeProductModel2.id,
          shoppingbagmodelID: shoppingBagModel.id);
      await Amplify.DataStore.save(prod2);

      var res = await UsersStorageProxy().removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      var prods = await UsersStorageProxy().getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(), true);
      expect(prods.getValue().length, 1);
      expect(prods.getValue().first.name, storeProductModel2.name);

      //cleanup
      await Amplify.DataStore.delete(prod2);
    });

    test('good scenario - remove product and the other shopping bag did not change', () async {
      OnlineStoreModel onlineStoreModel = OnlineStoreModel(
          name: "store2",
          phoneNumber: "+972123456789",
          address: "Jerusalem, Israel",
          operationHours:
              "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
          categories: "[\"Food\"]");
      StoreProductModel p =
          StoreProductModel(name: "prod3", categories: "", price: 4.56, onlinestoremodelID: onlineStoreModel.id);

      ShoppingBagModel b = ShoppingBagModel(usermodelID: userID, onlineStoreID: onlineStoreModel.id);
      CartProductModel c = CartProductModel(
          name: p.name, categories: "", price: p.price, amount: 13, shoppingbagmodelID: b.id, storeProductID: p.id);
      await Amplify.DataStore.save(onlineStoreModel);
      await Amplify.DataStore.save(p);
      await Amplify.DataStore.save(b);
      await Amplify.DataStore.save(c);
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);

      var res = await UsersStorageProxy().removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1); //the second bag
      var removedProds = await UsersStorageProxy().getProductsOfShoppingBag(shoppingBagModel.id);
      expect(removedProds.getTag(), false);
      var prods = await UsersStorageProxy().getProductsOfShoppingBag(b.id);
      expect(prods.getTag(), true);
      expect(prods.getValue().length, 1);
      expect(prods.getValue().first.name, p.name);

      //clean up
      await Amplify.DataStore.delete(onlineStoreModel);
      await Amplify.DataStore.delete(p);
    });

    test('bad scenario - no such bag', () async {
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await UsersStorageProxy().removeProductFromShoppingBag(prod, "aa", userID);
      expect(res.getTag(), false);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1); //did not remove
      var prods = await UsersStorageProxy().getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(), true);
      expect(prods.getValue().length, 1);
      expect(prods.getValue().first.name, prod.name);
    });

    test('bad scenario - no such product', () async {
      ProductDTO prod = ProductDTO(
          id: "aa",
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await UsersStorageProxy().removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), false);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1); //did not remove
      var prods = await UsersStorageProxy().getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(), true);
      expect(prods.getValue().length, 1);
      expect(prods.getValue().first.name, prod.name);
    });
  });

  group('update or create cart product for shopping bag and save it', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late StoreProductModel storeProductModel1;
    late StoreProductModel storeProductModel2;
    late ShoppingBagModel shoppingBagModel;
    late CartProductModel cartProductModel;
    late String userID;

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
        storeProductModel1 = StoreProductModel(
            name: "product1", categories: "", price: 1.23, onlinestoremodelID: onlineModel.id, description: "wow");
        storeProductModel2 = StoreProductModel(
            name: "product2", categories: "", price: 7.89, onlinestoremodelID: onlineModel.id, description: "cheap");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com", name: "test name", imageUrl: "https://pic.png", hideStoreOwnerOptions: false, isLoggedIn: true);
        userID = currUser.id;
        shoppingBagModel = ShoppingBagModel(usermodelID: userID, onlineStoreID: onlineModel.id);
        cartProductModel = CartProductModel(
            name: storeProductModel1.name,
            categories: "",
            price: storeProductModel1.price,
            amount: 10,
            storeProductID: storeProductModel1.id,
            shoppingbagmodelID: shoppingBagModel.id);
        await Amplify.DataStore.save(shoppingBagModel);
        await Amplify.DataStore.save(cartProductModel);
        await Amplify.DataStore.save(onlineModel);
        await Amplify.DataStore.save(storeProductModel1);
        await Amplify.DataStore.save(storeProductModel2);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
        await Amplify.DataStore.delete(onlineModel);
      });
    });

    test('good scenario - add one product', () async {
      ProductDTO prod = ProductDTO(
          id: storeProductModel2.id,
          name: storeProductModel2.name,
          price: storeProductModel2.price,
          category: storeProductModel2.categories,
          imageUrl: null,
          description: storeProductModel2.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await UsersStorageProxy().updateOrCreateCartProduct(prod, onlineModel.id, 10, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 2);
      expect(bag.products.firstWhere((element) => element.id == storeProductModel2.id, orElse: null) != null, true);
    });

    test('good scenario - update product quantity', () async {
      ProductDTO prod = ProductDTO(
          id: storeProductModel1.id,
          name: storeProductModel1.name,
          price: storeProductModel1.price,
          category: storeProductModel1.categories,
          imageUrl: null,
          description: storeProductModel1.description,
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res =
          await UsersStorageProxy().updateOrCreateCartProduct(prod, onlineModel.id, 27, userID); //27 instead of 10
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, storeProductModel1.name);
      expect(bag.products.first.amount, 27);
    });

    test('good scenario - add products from different stores', () async {
      //should create 2 shopping bags for the products from the different stores
      OnlineStoreModel onlineStoreModel = OnlineStoreModel(
          name: "store2",
          phoneNumber: "+972123456789",
          address: "Jerusalem, Israel",
          operationHours:
              "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
          categories: "[\"Food\"]");
      StoreProductModel p =
          StoreProductModel(name: "prod3", categories: "", price: 4.56, onlinestoremodelID: onlineStoreModel.id);
      await Amplify.DataStore.save(onlineStoreModel);
      await Amplify.DataStore.save(p);
      ProductDTO prod2 = ProductDTO(
          id: p.id,
          name: p.name,
          price: p.price,
          category: p.categories,
          imageUrl: null,
          description: p.description,
          storeID: onlineStoreModel.id,
          imageFromPhone: null);

      var res = await UsersStorageProxy().updateOrCreateCartProduct(prod2, onlineStoreModel.id, 5, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 2);
      ShoppingBagDTO? bagInFirstStore =
          bags.firstWhere((element) => element.onlineStoreID == onlineModel.id, orElse: null);
      expect(bagInFirstStore != null, true);
      expect(bagInFirstStore.products.length, 1);
      expect(bagInFirstStore.products.first.name, storeProductModel1.name);

      ShoppingBagDTO? bagInSecondStore =
          bags.firstWhere((element) => element.onlineStoreID == onlineStoreModel.id, orElse: null);
      expect(bagInSecondStore != null, true);
      expect(bagInSecondStore.products.length, 1);
      expect(bagInSecondStore.products.first.name, p.name);

      //clean up
      await Amplify.DataStore.delete(onlineStoreModel);
      await Amplify.DataStore.delete(p);
    });

    test('good scenario - save shopping bag', () async {
      CartProductDTO prod = CartProductDTO("", "new prod", 1.45, cartProductModel.categories, null,
          cartProductModel.description, 93, cartProductModel.storeProductID!, "");

      OnlineStoreModel o = OnlineStoreModel(
        name: "store",
        phoneNumber: "+972123456789",
        address: "Tel Aviv, Israel",
        operationHours:
            "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
        categories: "[\"Food\"]",
      );
      await Amplify.DataStore.save(o);
      ShoppingBagDTO shoppingBagDTO = new ShoppingBagDTO(null, userID, o.id);
      shoppingBagDTO.addProduct(prod);
      var res = await UsersStorageProxy().saveShoppingBag(shoppingBagDTO);
      expect(res.getTag(), true);
      List<ShoppingBagDTO> bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 2);
      ShoppingBagDTO? bag = bags.firstWhere((element) => element.onlineStoreID == o.id, orElse: null);
      expect(bag != null, true);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, "new prod");

      //cleanup
      await Amplify.DataStore.delete(o);
    });
  });

  group('add and remove user\'s credit card', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;

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

    test('remove credit card - bad scenario - no such credit card token', () async {
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

  group('save and remove store owner\'s bank account', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;

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
      await UsersStorageProxy().saveStoreBankAccount(token);
      var storeOwnerRes = await UsersStorageProxy().getStoreOwnerState("unittest@gmail.com");
      expect(storeOwnerRes.getTag(), true);
      StoreOwnerModel owner = storeOwnerRes.getValue();
      expect(owner.bankAccountToken != null, true);
      expect(owner.bankAccountToken, "token");
    });

    test('remove bank account - good scenario', () async {
      String token = "token";
      await UsersStorageProxy().removeStoreBankAccount(token);
      var storeOwnerRes = await UsersStorageProxy().getStoreOwnerState("unittest@gmail.com");
      expect(storeOwnerRes.getTag(), true);
      StoreOwnerModel owner = storeOwnerRes.getValue();
      expect(owner.bankAccountToken == null, true);
    });
  });
}
