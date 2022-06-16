import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
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

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  String openingsToJson(Openings openings) {
    String json = "";
    for (OpeningTimes t in openings.days) {
      json = json + t.day + "-";
      if (t.closed)
        json = json + "closed";
      else {
        final now = new DateTime.now();
        final dt = DateTime(now.year, now.month, now.day,
            t.operationHours.item1.hour, t.operationHours.item1.minute);
        final dt2 = DateTime(now.year, now.month, now.day,
            t.operationHours.item2.hour, t.operationHours.item2.minute);
        final format = DateFormat.jm();
        json = json + format.format(dt) + "," + format.format(dt2);
      }
      json = json + "\n";
    }
    return json;
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

  group('fetch stores by keywords', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
        as IntegrationTestWidgetsFlutterBinding;

    late OnlineStoreModel onlineModel;
    late PhysicalStoreModel physicalModel;

    setUp(() {
      return Future(() async {
        await _configureAmplify();
        UserAuthenticator().setCurrentUserId("unittest@gmail.com");
        UserModel currUser = new UserModel(
            email: "unittest@gmail.com",
            name: "test name",
            hideStoreOwnerOptions: false,
            isLoggedIn: true);
        OnlineStoreModel onlineStoreModel = OnlineStoreModel(
            name: "online test",
            phoneNumber: "+972123456789",
            address: "Ashdod, Israel",
            operationHours: openingsToJson(op),
            categories: "[\"Food\"]",
            qrCode: "");
        PhysicalStoreModel physicalStoreModel = PhysicalStoreModel(
            name: "physical store",
            phoneNumber: "+972123456789",
            address: "Tel Aviv, Israel",
            operationHours: openingsToJson(op),
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

    tearDownAll(() {
      return Future(() async {
        await clearDB();
        print("cleared db");
      });
    });

    test('fetch by category', () async {
      List<StoreDTO> res =
          await StoreStorageProxy().fetchStoresByKeywords("food");
      expect(res.length, 2);
      try {
        var online = res.singleWhere((element) => element.name == "online test",
            orElse: null);
        expect(online != null, true);
        var phy = res.singleWhere((element) => element.name == "physical store",
            orElse: null);
        expect(phy != null, true);
      } on StateError catch (e) {
        expect(true, false);
      }
    });

    test('fetch by name', () async {
      List<StoreDTO> res =
          await StoreStorageProxy().fetchStoresByKeywords("physical");
      expect(res.length, 1);
      expect(res.first.name, "physical store");
    });

    test('fetch by address', () async {
      List<StoreDTO> res =
          await StoreStorageProxy().fetchStoresByKeywords("Ashdod");
      expect(res.length, 1);
      expect(res.first.name, "online test");
    });

    test('no such store for keyword', () async {
      List<StoreDTO> res = await StoreStorageProxy()
          .fetchStoresByKeywords("Shoes"); //no such store in this category
      expect(res.length, 0);
    });
  });
}
