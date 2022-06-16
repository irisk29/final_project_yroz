import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
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

  group('add products to shopping bag', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;
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
            name: "product1",
            categories: "",
            price: 1.23,
            onlinestoremodelID: onlineModel.id,
            description: "wow");
        storeProductModel2 = StoreProductModel(
            name: "product2",
            categories: "",
            price: 7.89,
            onlinestoremodelID: onlineModel.id,
            description: "cheap");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            imageUrl: "https://pic.png",
            hideStoreOwnerOptions: false,
            isLoggedIn: true);
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
      var res = await UsersStorageProxy()
          .addProductToShoppingBag(prod, onlineModel.id, 10, userID);
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
      var res = await UsersStorageProxy()
          .addProductToShoppingBag(prod, onlineModel.id, 10, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, "product1");
      expect(bag.products.first.amount, 10);

      res = await UsersStorageProxy()
          .addProductToShoppingBag(prod2, onlineModel.id, 7, userID);
      expect(res.getTag(), true);
      bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      expect(bags.first.onlineStoreID, onlineModel.id);
      expect(bags.first.products.length, 2);
      expect(
          bags.first.products.firstWhere(
                  (element) => element.id == storeProductModel2.id,
                  orElse: null) !=
              null,
          true);
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
      StoreProductModel p = StoreProductModel(
          name: "prod3",
          categories: "",
          price: 4.56,
          onlinestoremodelID: onlineStoreModel.id);
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

      var res = await UsersStorageProxy()
          .addProductToShoppingBag(prod, onlineModel.id, 10, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      ShoppingBagDTO bag = bags.first;
      expect(bag.onlineStoreID, onlineModel.id);
      expect(bag.products.length, 1);
      expect(bag.products.first.name, "product1");
      expect(bag.products.first.amount, 10);

      res = await UsersStorageProxy()
          .addProductToShoppingBag(prod2, onlineStoreModel.id, 5, userID);
      expect(res.getTag(), true);
      bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 2);
      ShoppingBagDTO? bagInFirstStore = bags.firstWhere(
          (element) => element.onlineStoreID == onlineModel.id,
          orElse: null);
      expect(bagInFirstStore != null, true);
      expect(bagInFirstStore.products.length, 1);
      expect(bagInFirstStore.products.first.name, storeProductModel1.name);

      ShoppingBagDTO? bagInSecondStore = bags.firstWhere(
          (element) => element.onlineStoreID == onlineStoreModel.id,
          orElse: null);
      expect(bagInSecondStore != null, true);
      expect(bagInSecondStore.products.length, 1);
      expect(bagInSecondStore.products.first.name, p.name);

      //clean up
      await Amplify.DataStore.delete(onlineStoreModel);
      await Amplify.DataStore.delete(p);
    });
  });
}
