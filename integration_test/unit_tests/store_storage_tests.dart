import 'dart:math';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // to make the tests work

  group('open online store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser =
            new UserModel(email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false);
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
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      List<ProductDTO> prods = [
        ProductDTO(
            id: "",
            name: "prod test",
            price: 1.23,
            category: "",
            imageUrl: null,
            description: "very good",
            storeID: "",
            imageFromPhone: null)
      ];
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: "",
          name: "online test",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: prods);

      ResultInterface res = await StoreStorageProxy().openOnlineStore(storeDTO);
      expect(res.getTag(), true);
      String storeID = (res.getValue() as Tuple2).item1.id;
      var store = await StoreStorageProxy().fetchOnlineStore(storeID);
      expect(store != null, true);
      expect(store!.name, "online test");
      expect(store.address, "Ashdod, Israel");
      expect(store.phoneNumber, "+972123456789");
    });

    test('sad scenario - wrong phone format', () async {
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      List<ProductDTO> prods = [
        ProductDTO(
            id: "",
            name: "prod test",
            price: 1.23,
            category: "",
            imageUrl: null,
            description: "very good",
            storeID: "",
            imageFromPhone: null)
      ];
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: "",
          name: "online test",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: prods);

      ResultInterface res = await StoreStorageProxy().openOnlineStore(storeDTO);
      String storeId = (res.getValue() as Tuple2).item1.id;
      await Amplify.DataStore.clear();
      await Amplify.DataStore.start();
      var hubSubscription = Amplify.Hub.listen([HubChannel.DataStore], (msg) async {
        if (msg.eventName == 'ready') {
          print("ready to check");
          OnlineStoreModel? model = await StoreStorageProxy().fetchOnlineStore(storeId);
          assert(model == null);
          print("finished check");
        } else {
          print("Not ready yet");
        }
      });
      await Future.delayed(Duration(seconds: 10));
    });
  });

  group('open physical store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser =
            new UserModel(email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false);
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
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO storeDTO = StoreDTO(
          id: "",
          name: "physical test",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);

      ResultInterface res = await StoreStorageProxy().openPhysicalStore(storeDTO);
      expect(res.getTag(), true);
      String storeID = (res.getValue() as Tuple2).item1.id;
      var store = await StoreStorageProxy().fetchPhysicalStore(storeID);
      expect(store != null, true);
      expect(store!.name, "physical test");
      expect(store.address, "Ashdod, Israel");
      expect(store.phoneNumber, "+972123456789");
    });

    test('sad scenario - wrong phone format', () async {
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO storeDTO = StoreDTO(
          id: "",
          name: "physical test",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);

      ResultInterface res = await StoreStorageProxy().openPhysicalStore(storeDTO);
      String storeId = (res.getValue() as Tuple2).item1.id;
      await Amplify.DataStore.clear();
      await Amplify.DataStore.start();
      var hubSubscription = Amplify.Hub.listen([HubChannel.DataStore], (msg) async {
        if (msg.eventName == 'ready') {
          print("ready to check");
          PhysicalStoreModel? model = await StoreStorageProxy().fetchPhysicalStore(storeId);
          assert(model == null);
          print("finished check");
        } else {
          print("Not ready yet");
        }
      });
      await Future.delayed(Duration(seconds: 10));
    });
  });

  group('fetch stores by keywords', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late PhysicalStoreModel physicalModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser =
            new UserModel(email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false);
        OnlineStoreModel onlineStoreModel = OnlineStoreModel(
            name: "online test",
            phoneNumber: "+972123456789",
            address: "Ashdod, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        PhysicalStoreModel physicalStoreModel = PhysicalStoreModel(
            name: "physical store",
            phoneNumber: "+972123456789",
            address: "Tel Aviv, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        onlineModel = onlineStoreModel;
        physicalModel = physicalStoreModel;
        await Amplify.DataStore.save(onlineStoreModel);
        await Amplify.DataStore.save(physicalStoreModel);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        await Amplify.DataStore.delete(onlineModel);
        await Amplify.DataStore.delete(physicalModel);
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('fetch by category', () async {
      List<StoreDTO> res = await StoreStorageProxy().fetchStoresByKeywords("food");
      expect(res.length, 2);
      try {
        var online = res.singleWhere((element) => element.name == "online test", orElse: null);
        expect(online != null, true);
        var phy = res.singleWhere((element) => element.name == "physical store", orElse: null);
        expect(phy != null, true);
      } on StateError catch (e) {
        expect(true, false);
      }
    });

    test('fetch by name', () async {
      List<StoreDTO> res = await StoreStorageProxy().fetchStoresByKeywords("physical store");
      expect(res.length, 1);
      expect(res.first.name, "physical store");
    });

    test('fetch by address', () async {
      List<StoreDTO> res = await StoreStorageProxy().fetchStoresByKeywords("Ashdod, Israel");
      expect(res.length, 1);
      expect(res.first.name, "online test");
    });

    test('no such store for keyword', () async {
      List<StoreDTO> res = await StoreStorageProxy().fetchStoresByKeywords("Shoes"); //no such store in this category
      expect(res.length, 0);
    });
  });

  group('create products for online store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser =
            new UserModel(email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false);
        OnlineStoreModel onlineStoreModel = OnlineStoreModel(
            name: "online test",
            phoneNumber: "+972123456789",
            address: "Ashdod, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        onlineModel = onlineStoreModel;
        await Amplify.DataStore.save(onlineStoreModel);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        await Amplify.DataStore.delete(onlineModel);
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('good scenario', () async {
      ProductDTO productDTO1 = ProductDTO(
          id: "",
          name: "product test",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      ProductDTO productDTO2 = ProductDTO(
          id: "",
          name: "product2 test",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      var res = await StoreStorageProxy().createProductForOnlineStore(productDTO1, onlineModel.id);
      expect(res.getTag(), true);
      res = await StoreStorageProxy().createProductForOnlineStore(productDTO2, onlineModel.id);
      expect(res.getTag(), true);
      //check that the connection between the products and the online store is working
      List<ProductDTO> prods = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(prods.length, 2);
      try {
        var prod1 = prods.singleWhere((element) => element.name == "product test", orElse: null);
        expect(prod1 != null, true);
        var prod2 = prods.singleWhere((element) => element.name == "product2 test", orElse: null);
        expect(prod2 != null, true);
      } on StateError catch (e) {
        expect(true, false);
      }
    });
  });

  group('update physical store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late PhysicalStoreModel physicalModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser =
            new UserModel(email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false);
        PhysicalStoreModel physicalStoreModel = PhysicalStoreModel(
            name: "physical store",
            phoneNumber: "+972123456789",
            address: "Tel Aviv, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        physicalModel = physicalStoreModel;
        await Amplify.DataStore.save(physicalStoreModel);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        await Amplify.DataStore.delete(physicalModel);
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('good scenario', () async {
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO storeDTO = StoreDTO(
          id: physicalModel.id,
          name: "new name", //changed name
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);

      ResultInterface res = await StoreStorageProxy().updatePhysicalStore(storeDTO);
      expect(res.getTag(), true);
      var store = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(store != null, true);
      expect(store!.name, "new name");
    });

    test('bad scenario - no such store', () async {
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO storeDTO = StoreDTO(
          id: "",
          name: "new name", //changed name
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);

      ResultInterface res = await StoreStorageProxy().updatePhysicalStore(storeDTO);
      expect(res.getTag(), false);
      var store = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(store != null, true);
      expect(store!.name, "physical store"); //the update did not happen - the name stayed the same
    });
  });

  group('update online store and it\'s products', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late StoreProductModel productModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser =
            new UserModel(email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false);
        onlineModel = OnlineStoreModel(
            name: "online test",
            phoneNumber: "+972123456789",
            address: "Ashdod, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        productModel = StoreProductModel(
          name: "product test",
          categories: "",
          price: 1.23,
          onlinestoremodelID: onlineModel.id,
          description: "wow",
        );
        await Amplify.DataStore.save(productModel);
        await Amplify.DataStore.save(onlineModel);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        await Amplify.DataStore.delete(onlineModel);
        await Amplify.DataStore.delete(productModel);
        print("in tear down: ${res.getMessage()}");
      });
    });

    test('good scenario - update online store info', () async {
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
          name: "product test",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: onlineModel.id,
          name: "new name", //changed name
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: [productDTO]);

      ResultInterface res = await StoreStorageProxy().updateOnlineStore(storeDTO);
      expect(res.getTag(), true);
      var store = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(store != null, true);
      expect(store!.name, "new name");
    });

    test('good scenario - update online store\'s product', () async {
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
          name: "product test",
          price: 7.89, //new price
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: onlineModel.id,
          name: "new name", //changed name
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: [productDTO]);

      ResultInterface res = await StoreStorageProxy().updateOnlineStore(storeDTO);
      expect(res.getTag(), true);
      var store = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(store != null, true);
      expect(store!.name, "new name");
      var updatedProd = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(updatedProd.length, 1);
      expect(updatedProd.first.price, 7.89);
    });

    test('good scenario - update products', () async {
      ProductDTO productDTO = ProductDTO(
          id: "",
          name: "product new name", //new name
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);

      //add new product to store during the update
      ProductDTO productDTO2 = ProductDTO(
          id: "",
          name: "second product",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);

      ResultInterface res =
          await StoreStorageProxy().updateOnlineStoreProducts([productDTO, productDTO2], onlineModel.id);
      expect(res.getTag(), true);
      var products = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(products.length, 2);
      expect(products.firstWhere((element) => element.name == "product new name", orElse: null) != null, true);
      expect(products.firstWhere((element) => element.name == "second product", orElse: null) != null, true);
    });

    test('bad scenario - no such store', () async {
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
          name: "product test",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: "bb",
          name: "new name", //changed name
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: [productDTO]);

      ResultInterface res = await StoreStorageProxy().updateOnlineStore(storeDTO);
      expect(res.getTag(), false);
      var store = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(store != null, true);
      expect(store!.name, "online test"); //the update did not happen - the name stayed the same
    });

    test('bad scenario - no such products in store', () async {
      ProductDTO productDTO = ProductDTO(
          id: "",
          name: "product new name", //new name
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);

      ResultInterface res = await StoreStorageProxy().updateOnlineStoreProducts([productDTO], "21");
      expect(res.getTag(), false);
      var products = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(products.length, 1);
      expect(products.first.name, "product test"); //the update did not happen - the name stayed the same
    });
  });

  group('delete physical store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late PhysicalStoreModel physicalModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        physicalModel = PhysicalStoreModel(
            name: "physical store",
            phoneNumber: "+972123456789",
            address: "Tel Aviv, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        StoreOwnerModel storeOwnerModel = StoreOwnerModel(
            physicalStoreModel: physicalModel,
            storeOwnerModelPhysicalStoreModelId: physicalModel.id,
            lastPurchasesView: TemporalDateTime.fromString(
                DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM').toDateTimeIso8601String()));
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            hideStoreOwnerOptions: false,
            storeOwnerModel: storeOwnerModel,
            userModelStoreOwnerModelId: storeOwnerModel.id);
        await Amplify.DataStore.save(physicalModel);
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

    test('good scenario', () async {
      var res = await StoreStorageProxy().deleteStore(physicalModel.id, false);
      expect(res.getTag(), true);
      var store = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(store == null, true);
    });

    test('bad scenario - try to delete online store with physical store id', () async {
      var res = await StoreStorageProxy().deleteStore(physicalModel.id, true);
      expect(res.getTag(), false);
      var store = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(store != null, true);
      expect(store!.name, "physical store");
      await Amplify.DataStore.delete(physicalModel); // clean up after the test
    });

    test('bad scenario - no such store', () async {
      var res = await StoreStorageProxy().deleteStore("aa", false);
      expect(res.getTag(), false);
      var store = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(store != null, true);
      expect(store!.name, "physical store");
      await Amplify.DataStore.delete(physicalModel); // clean up after the test
    });
  });

  group('delete online store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late StoreProductModel productModel;

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
        productModel = StoreProductModel(
          name: "product test",
          categories: "",
          price: 1.23,
          onlinestoremodelID: onlineModel.id,
          description: "wow",
        );
        StoreOwnerModel storeOwnerModel = StoreOwnerModel(
            onlineStoreModel: onlineModel,
            storeOwnerModelOnlineStoreModelId: onlineModel.id,
            lastPurchasesView: TemporalDateTime.fromString(
                DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM').toDateTimeIso8601String()));
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            hideStoreOwnerOptions: false,
            storeOwnerModel: storeOwnerModel,
            userModelStoreOwnerModelId: storeOwnerModel.id);
        await Amplify.DataStore.save(productModel);
        await Amplify.DataStore.save(onlineModel);
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

    test('good scenario', () async {
      var res = await StoreStorageProxy().deleteStore(onlineModel.id, true);
      expect(res.getTag(), true);
      var store = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(store == null, true);
      var products = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(products.length, 0);
    });

    test('bad scenario - try to delete physical store with online store id', () async {
      var res = await StoreStorageProxy().deleteStore(onlineModel.id, false);
      expect(res.getTag(), false);
      var store = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(store != null, true);
      expect(store!.name, "online test");
      await Amplify.DataStore.delete(onlineModel);
      await Amplify.DataStore.delete(productModel); // clean up after the test
    });

    test('bad scenario - no such store', () async {
      var res = await StoreStorageProxy().deleteStore("aa", true);
      expect(res.getTag(), false);
      var store = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(store != null, true);
      expect(store!.name, "online test");
      await Amplify.DataStore.delete(onlineModel);
      await Amplify.DataStore.delete(productModel); // clean up after the test
    });
  });

  group('convert physical store to online store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late PhysicalStoreModel physicalModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        physicalModel = PhysicalStoreModel(
            name: "physical store",
            phoneNumber: "+972123456789",
            address: "Tel Aviv, Israel",
            operationHours:
                "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
            categories: "[\"Food\"]",
            qrCode: "");
        StoreOwnerModel storeOwnerModel = StoreOwnerModel(
            physicalStoreModel: physicalModel,
            storeOwnerModelPhysicalStoreModelId: physicalModel.id,
            lastPurchasesView: TemporalDateTime.fromString(
                DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM').toDateTimeIso8601String()));
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            hideStoreOwnerOptions: false,
            storeOwnerModel: storeOwnerModel,
            userModelStoreOwnerModelId: storeOwnerModel.id);
        await Amplify.DataStore.save(physicalModel);
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

    test('good scenario', () async {
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO storeDTO = StoreDTO(
          id: physicalModel.id,
          name: "physical store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      var res = await StoreStorageProxy().convertPhysicalStoreToOnline(storeDTO);
      expect(res.getTag(), true);
      var phyStore = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(phyStore == null, true);
      var onlineStore = await StoreStorageProxy().fetchOnlineStore(physicalModel.id);
      expect(onlineStore != null, true);
      expect(onlineStore!.name, "physical store");
      //cleanup
      await Amplify.DataStore.delete(onlineStore);
    });

    test('bad scenario - no such store', () async {
      Map<String, List<TimeOfDay>> op = {
        "sunday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "monday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "tuesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "wednesday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "thursday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "friday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
        "saturday": [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59)],
      };
      StoreDTO storeDTO = StoreDTO(
          id: "aa",
          name: "physical store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      var res = await StoreStorageProxy().convertPhysicalStoreToOnline(storeDTO);
      expect(res.getTag(), false);
      var phyStore = await StoreStorageProxy().fetchPhysicalStore(physicalModel.id);
      expect(phyStore != null, true);
      expect(phyStore!.name, "physical store");
      //cleanup
      await Amplify.DataStore.delete(physicalModel);
    });
  });

  group('convert online store to physical store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late OnlineStoreModel onlineModel;
    late StoreProductModel productModel;

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
        productModel = StoreProductModel(
          name: "product test",
          categories: "",
          price: 1.23,
          onlinestoremodelID: onlineModel.id,
          description: "wow",
        );
        StoreOwnerModel storeOwnerModel = StoreOwnerModel(
            onlineStoreModel: onlineModel,
            storeOwnerModelOnlineStoreModelId: onlineModel.id,
            lastPurchasesView: TemporalDateTime.fromString(
                DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM').toDateTimeIso8601String()));
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            hideStoreOwnerOptions: false,
            storeOwnerModel: storeOwnerModel,
            userModelStoreOwnerModelId: storeOwnerModel.id);
        await Amplify.DataStore.save(productModel);
        await Amplify.DataStore.save(onlineModel);
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

    test('good scenario', () async {
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
          name: "product test",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: onlineModel.id,
          name: "online test",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: [productDTO]);
      var res = await StoreStorageProxy().convertOnlineStoreToPhysical(storeDTO);
      expect(res.getTag(), true);
      var onlineStore = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(onlineStore == null, true);
      var phyStore = await StoreStorageProxy().fetchPhysicalStore(onlineModel.id);
      expect(phyStore != null, true);
      expect(phyStore!.name, "online test");
      var prod = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(prod.length, 0);
      //cleanup
      await Amplify.DataStore.delete(phyStore);
    });

    test('bad scenario - no such store', () async {
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
          name: "product test",
          price: 1.23,
          category: "",
          imageUrl: null,
          description: "wow",
          storeID: onlineModel.id,
          imageFromPhone: null);
      OnlineStoreDTO storeDTO = OnlineStoreDTO(
          id: "aa",
          name: "online test",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op,
          products: [productDTO]);
      var res = await StoreStorageProxy().convertOnlineStoreToPhysical(storeDTO);
      expect(res.getTag(), false);
      var onlineStore = await StoreStorageProxy().fetchOnlineStore(onlineModel.id);
      expect(onlineStore != null, true);
      expect(onlineStore!.name, "online test");
      var prod = await StoreStorageProxy().fetchStoreProducts(onlineModel.id);
      expect(prod.length, 1);
      expect(prod.firstWhere((element) => element.name == "product test", orElse: null) != null, true);
      //cleanup
      await Amplify.DataStore.delete(onlineStore);
      await Amplify.DataStore.delete(productModel);
    });
  });
}