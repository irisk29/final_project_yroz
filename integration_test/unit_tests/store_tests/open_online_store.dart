import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
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
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Monday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Tuesday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Wednesday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Thursday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Friday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
    new OpeningTimes(
        day: "Saturday",
        closed: false,
        operationHours: Tuple2(TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 23, minute: 59))),
  ]);

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

  group('open online store', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com", name: "test name", hideStoreOwnerOptions: false, isLoggedIn: true);
        await Amplify.DataStore.save(currUser);
      });
    });

    tearDown(() {
      return Future(() async {
        var res = await UsersStorageProxy().deleteUser("unittest@gmail.com");
        print("in tear down: ${res.getMessage()}");
      });
    });

    tearDownAll(() {
      return Future(() async {
        await clearDB();
        print("cleared db");
      });
    });

    test('good scenario', () async {
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
}
