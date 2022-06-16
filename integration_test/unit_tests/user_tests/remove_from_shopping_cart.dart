import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
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

  group('remove products from shopping bag', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;
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
        shoppingBagModel = ShoppingBagModel(
            usermodelID: userID, onlineStoreID: onlineModel.id);
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
      var res = await UsersStorageProxy()
          .removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 0);
      var prods = await UsersStorageProxy()
          .getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(),
          false); //no products becuase we ereased the shopping bag
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

      var res = await UsersStorageProxy()
          .removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1);
      var prods = await UsersStorageProxy()
          .getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(), true);
      expect(prods.getValue().length, 1);
      expect(prods.getValue().first.name, storeProductModel2.name);

      //cleanup
      await Amplify.DataStore.delete(prod2);
    });

    test(
        'good scenario - remove product and the other shopping bag did not change',
        () async {
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

      ShoppingBagModel b = ShoppingBagModel(
          usermodelID: userID, onlineStoreID: onlineStoreModel.id);
      CartProductModel c = CartProductModel(
          name: p.name,
          categories: "",
          price: p.price,
          amount: 13,
          shoppingbagmodelID: b.id,
          storeProductID: p.id);
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

      var res = await UsersStorageProxy()
          .removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), true);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1); //the second bag
      var removedProds = await UsersStorageProxy()
          .getProductsOfShoppingBag(shoppingBagModel.id);
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
      var res = await UsersStorageProxy()
          .removeProductFromShoppingBag(prod, "aa", userID);
      expect(res.getTag(), false);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1); //did not remove
      var prods = await UsersStorageProxy()
          .getProductsOfShoppingBag(shoppingBagModel.id);
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
      var res = await UsersStorageProxy()
          .removeProductFromShoppingBag(prod, onlineModel.id, userID);
      expect(res.getTag(), false);
      var bags = await UsersStorageProxy().getUserShoppingBags(userID);
      expect(bags.length, 1); //did not remove
      var prods = await UsersStorageProxy()
          .getProductsOfShoppingBag(shoppingBagModel.id);
      expect(prods.getTag(), true);
      expect(prods.getValue().length, 1);
      expect(prods.getValue().first.name, prod.name);
    });
  });
}
