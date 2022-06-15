import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/PurchaseHistoryDTO.dart';
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

  DateTime _getPSTTime() {
    tz.initializeTimeZones();

    final DateTime now = DateTime.now();
    final pacificTimeZone = tz.getLocation('Asia/Jerusalem');

    return tz.TZDateTime.from(now, pacificTimeZone);
  }

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('Upgrade physical store', () {
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

    test('upgrade - good scenario', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

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
          await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);

      physicalStoreDTO.id = physicalStoreID;
      var upgradeRes =
          await user1.convertPhysicalStoreToOnline(physicalStoreDTO);
      expect(upgradeRes.getTag(), true);

      var onlineStore =
          await StoreStorageProxy().fetchOnlineStore(upgradeRes.getValue());
      expect(onlineStore != null, true);
      expect(onlineStore!.name, physicalStoreDTO.name);
      expect(onlineStore.address, physicalStoreDTO.address);
      expect(onlineStore.phoneNumber, physicalStoreDTO.phoneNumber);
      expect(onlineStore.categories,
          JsonEncoder.withIndent('  ').convert(physicalStoreDTO.categories));
      expect(onlineStore.operationHours,
          openingsToJson(physicalStoreDTO.operationHours));
      expect(onlineStore.storeProductModels!.length, 0);
    });

    test('upgrade - add products to the new online store', () async {
      var res = await UsersStorageProxy()
          .createUser("flowtest@gmail.com", "test flow", "https://pic.png");
      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      expect(res.item2, true); //created new user
      UserModel firstUser = res.item1;
      User user1 = User.fromModel(firstUser);
      await user1.createEWallet();

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
          await user1.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      expect(openStoreRes.getTag(), true);
      String physicalStoreID = openStoreRes.getValue();
      var currUser = await UsersStorageProxy().getUser(user1.email!);
      FLog.info(text: "$currUser");
      expect(currUser != null, true);
      expect(currUser!.userModelStoreOwnerModelId != null, true);

      physicalStoreDTO.id = physicalStoreID;
      var upgradeRes =
          await user1.convertPhysicalStoreToOnline(physicalStoreDTO);
      expect(upgradeRes.getTag(), true);

      var onlineStore =
          await StoreStorageProxy().fetchOnlineStore(upgradeRes.getValue());
      expect(onlineStore != null, true);
      expect(onlineStore!.name, physicalStoreDTO.name);
      expect(onlineStore.address, physicalStoreDTO.address);
      expect(onlineStore.phoneNumber, physicalStoreDTO.phoneNumber);
      expect(onlineStore.categories,
          JsonEncoder.withIndent('  ').convert(physicalStoreDTO.categories));
      expect(onlineStore.operationHours,
          openingsToJson(physicalStoreDTO.operationHours));
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

      OnlineStoreDTO onlineDTO = (await StoreStorageProxy()
              .convertOnlineStoreModelToDTO([onlineStore]))
          .first;
      String onlineStoreID = onlineDTO.id;
      productDTO.storeID = onlineStoreID;
      onlineDTO.products.add(productDTO);
      var editOnlineStore =
          await user1.updateOnlineStore(onlineDTO); //add product to store
      expect(editOnlineStore.getTag(), true);

      CartProductDTO cartProductDTO = CartProductDTO(
          "",
          productDTO.name,
          productDTO.price,
          "",
          null,
          productDTO.description,
          10,
          onlineStoreID,
          "");
      await user1.updateOrCreateCartProduct(productDTO, onlineStoreID, 10);

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

      var makePaymentRes = await user1.makePaymentOnlineStore(card, 0,
          productDTO.price * cartProductDTO.amount, user1.bagInStores.first);
      expect(makePaymentRes.getTag(), true);
      String transaction = makePaymentRes.getValue();

      DateTime now = _getPSTTime();
      DateTime dayAgo = new DateTime(now.year, now.month, now.day - 1);
      var purchases =
          await user1.getSuccssefulPurchaseHistoryForUserInRange(dayAgo, now);
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
