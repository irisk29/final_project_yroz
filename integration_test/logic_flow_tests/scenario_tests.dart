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
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
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

  group('Open physical store', () {
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

    test('open - good scenario', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

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
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);
    });

    test('open - bad phone number', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

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
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+9721234",
          categories: ["Food"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);

      await Amplify.DataStore.clear();
      await Amplify.DataStore.start();
      var hubSubscription = Amplify.Hub.listen([HubChannel.DataStore], (msg) async {
        if (msg.eventName == 'ready') {
          print("ready to check");
          List<StoreDTO> physicalStores = await StoreStorageProxy().fetchAllPhysicalStores();
          assert(physicalStores.isEmpty);
          print("finished check");
        } else {
          print("Not ready yet");
        }
      });
      await Future.delayed(Duration(seconds: 10));
    });

    test('open - no category', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

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
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: [],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);
    });

    test('open - not existing category', () async {
      var res = await UsersStorageProxy().createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

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
      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Itay"],
          operationHours: op);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");
      var openStoreRes = await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);
    });
  });
}
