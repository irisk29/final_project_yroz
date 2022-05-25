import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
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
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:final_project_yroz/screens/open_online_store_screen.dart' as app;
import 'package:mockito/mockito.dart';
import 'package:tuple/tuple.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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

  takeScreenshot(tester, binding) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    await binding.takeScreenshot('test-screenshot');
  }

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

  group('non-functional tests', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late NavigatorObserver mockObserver;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      UserModel currUser =
          new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false, isLoggedIn: true);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      return Future(() => print("starting test.."));
    });

    tearDown(() async {
      var res = await UsersStorageProxy().deleteUser("test@gmail.com");
      print("in tear down: ${res.getMessage()}");
    });

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

    testWidgets('user with store owner role UI', (WidgetTester tester) async {
      await tester.pumpWidget(app.OpenOnlineStorePipeline().wrapWithMaterial([mockObserver]));
      await tester.pumpAndSettle();

      //agree to the terms
      Finder fab = find.widgetWithText(ElevatedButton, "Agree");
      await tester.tap(fab);
      await tester.pump();

      //start to fill the form
      fab = find.byKey(Key('storeName'));
      await tester.enterText(fab, "physical store test");
      await tester.pump();

      fab = find.byKey(Key('phoneNumber'));
      await tester.enterText(fab, "123456789");
      await tester.pump();

      fab = find.byKey(Key('storeAddress'));
      await tester.enterText(fab, "Ashdod, Israel");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('store_category_0'));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      //operations hours
      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      //add product
      fab = find.byKey(Key("add_product")); //move to the add product screen
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('title'));
      await tester.enterText(fab, "shoelace");
      await tester.pump();

      fab = find.byKey(Key('price'));
      await tester.enterText(fab, "12.5");
      await tester.pump();

      fab = find.byKey(Key('description'));
      await tester.enterText(fab, "very good product");
      await tester.pump();

      fab = find.byKey(Key("save")); //go back
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('bank_name'));
      await tester.enterText(fab, "yroz");
      await tester.pump();

      fab = find.byKey(Key('branch_number'));
      await tester.enterText(fab, "987");
      await tester.pump();

      fab = find.byKey(Key('account_number'));
      await tester.enterText(fab, "211896261");
      await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //when pressing this button it creates the store
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify the user has now the store owner role by viewing the store managment icon
      expect(find.byIcon(Icons.storefront), findsOneWidget);
      await Future.delayed(Duration(seconds: 1));

      await tester.tap(find.byKey(Key("tutorial_okay_button"))); //tap the alert dialog for the store owner
      await tester.pumpAndSettle();
    });

    testWidgets('consumer role UI', (WidgetTester tester) async {
      await tester.pumpWidget(TabsScreen().wrapWithMaterial([mockObserver]));
      await tester.pumpAndSettle();

      // Verify that the consumer does not have the store managment button
      expect(find.byIcon(Icons.storefront), findsNothing);
    });

    testWidgets('50 users simultaneously', (WidgetTester tester) async {
      int numOfUsers = 50;
      List<User> arr = [];
      for (int i = 0; i < numOfUsers; i++) {
        var res = await UsersStorageProxy().createUser("flowtest$i@gmail.com", "test$i flow", "https://pic.png");
        User currUser = User.fromModel(res.item1);
        arr.add(currUser);
        await Amplify.DataStore.save(res.item1);
      }

      int responses = 0;
      for (int i = 0; i < arr.length; i++) {
        UserAuthenticator().setCurrentUserId("flowtest$i@gmail.com");
        arr[i].getEWalletBalance().then((value) => responses++);
      }
      await Future.delayed(Duration(seconds: 5));
      expect(responses, numOfUsers);

      for (int i = 0; i < numOfUsers; i++) {
        var u = await UsersStorageProxy().getUser("flowtest$i@gmail.com");
        if (u != null) {
          print("deleted user - ${u.email}");
          await Amplify.DataStore.delete(u);
        }
      }
    });

    testWidgets('95% of the actions are under 3 seconds', (WidgetTester tester) async {
      int actionsUnder3Seconds = 0;
      int totalActions = 20;

      var uRes = await UsersStorageProxy().createUser("flowtest2@gmail.com", "test2 flow", "https://pic.png");
      User user2 = User.fromModel(uRes.item1);

      var user = await UsersStorageProxy().getUser("test@gmail.com");
      expect(user == null, false);

      User currUser = User.fromModel(user!);

      Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));
      final encrypted = encrypter.encrypt("6886 1232 0788 4701", iv: iv);
      String num = encrypted.base16.toString();

      Stopwatch stopwatch = Stopwatch()..start();
      var creditRes = await currUser.addCreditCard(num, "10/22", "987", "yroz");
      String creditToken = creditRes.getTag() ? creditRes.getValue() : "";
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.createEWallet();
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.getEWalletBalance();
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      ProductDTO productDTO = ProductDTO(
          id: "",
          name: "prod",
          price: 1.23,
          category: "",
          imageUrl: 'https://i.ibb.co/Sw9GgBp/clothes.png',
          description: "wow",
          storeID: "",
          imageFromPhone: null);
      ProductDTO productDTO2 = ProductDTO(
          id: "",
          name: "prod",
          price: 1.23,
          category: "",
          imageUrl: 'https://i.ibb.co/Sw9GgBp/clothes.png',
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
          products: [productDTO, productDTO2]);
      BankAccountDTO bankAccountDTO = BankAccountDTO("Yroz", "987", "207884701");

      stopwatch = Stopwatch()..start();
      var res = await currUser.openOnlineStore(onlineStoreDTO, bankAccountDTO);
      var storeID = res.getTag() ? res.getValue() : "";
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.addFavoriteStore(storeID, true);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      StoreDTO physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Food"],
          operationHours: op);
      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      stopwatch = Stopwatch()..start();
      var phyRes = await user2.openPhysicalStore(physicalStoreDTO, bankAccountDTO);
      String phyID = phyRes.getTag() ? phyRes.getValue() : "";
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      physicalStoreDTO = StoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Home"],
          operationHours: op);
      physicalStoreDTO.id = phyID;
      stopwatch = Stopwatch()..start();
      await user2.updatePhysicalStore(physicalStoreDTO);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      stopwatch = Stopwatch()..start();
      await currUser.makePaymentPhysicalStore(creditToken, 0, 100, phyID);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      stopwatch = Stopwatch()..start();
      await user2.convertPhysicalStoreToOnline(physicalStoreDTO);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      stopwatch = Stopwatch()..start();
      bankAccountDTO = BankAccountDTO("Yroz", "987", "211896261");
      await currUser.editStoreBankAccount(bankAccountDTO);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.getStoreBankAccountDetails();
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      UserAuthenticator().setCurrentUserId("flowtest2@gmail.com");
      stopwatch = Stopwatch()..start();
      await user2.deleteStore(phyID, true);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      UserAuthenticator().setCurrentUserId("flowtest@gmail.com");
      onlineStoreDTO = OnlineStoreDTO(
          id: "",
          name: "test store",
          address: "Ashdod, Israel",
          phoneNumber: "+972123456789",
          categories: ["Other"],
          operationHours: op,
          products: [productDTO, productDTO2]);
      stopwatch = Stopwatch()..start();
      await currUser.updateOnlineStore(onlineStoreDTO);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.getStoresByKeywords("Other");
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.removeFavoriteStore(storeID, true);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      currUser.toggleStoreOwnerViewOption();
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.updateOrCreateCartProduct(productDTO, storeID, 100);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      var shopBagRes = await currUser.getShoppingBag(storeID);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      var cartItem = shopBagRes != null ? shopBagRes.products.first : null;
      expect(cartItem != null, true);
      await currUser.updateOrCreateCartProduct(productDTO2, storeID, 3);
      stopwatch = Stopwatch()..start();
      await currUser.removeProductFromShoppingBag(cartItem!.id, storeID);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.makePaymentOnlineStore(creditToken, 0, shopBagRes!.calculateTotalPrice(), shopBagRes);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      DateTime now = DateTime.now();
      DateTime monthAgo = DateTime(now.year, now.month - 1, now.day);
      stopwatch = Stopwatch()..start();
      await currUser.getSuccssefulPurchaseHistoryForUserInRange(monthAgo, now);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      stopwatch = Stopwatch()..start();
      await currUser.removeCreditCardToken(creditToken);
      if (stopwatch.elapsed.inSeconds <= 3) actionsUnder3Seconds++;
      stopwatch.stop();

      double precentage = actionsUnder3Seconds * 100 / totalActions;
      expect(precentage >= 95.0, true);

      clearDB();
    });

    testWidgets('100 simultaneously requests under 3 seconds', (WidgetTester tester) async {
      int numOfUsers = 100;
      List<User> arr = [];
      int time = 0;
      for (int i = 0; i < numOfUsers; i++) {
        var res = await UsersStorageProxy().createUser("flowtest$i@gmail.com", "test$i flow", "https://pic.png");
        User currUser = User.fromModel(res.item1);
        arr.add(currUser);
        await Amplify.DataStore.save(res.item1);
      }

      for (int i = 0; i < arr.length; i++) {
        UserAuthenticator().setCurrentUserId("flowtest$i@gmail.com");
        var stopwatch = Stopwatch()..start();
        arr[i].getEWalletBalance().then((value) => time += stopwatch.elapsed.inSeconds);
      }
      await Future.delayed(Duration(seconds: 15));
      double avgTime = time / numOfUsers;
      expect(avgTime <= 3.0, true);

      for (int i = 0; i < numOfUsers; i++) {
        var u = await UsersStorageProxy().getUser("flowtest$i@gmail.com");
        if (u != null) {
          print("deleted user - ${u.email}");
          await Amplify.DataStore.delete(u);
        }
      }
    });
  });
}
