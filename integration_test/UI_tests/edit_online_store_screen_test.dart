import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:final_project_yroz/screens/edit_online_store_screen.dart' as app;
import 'package:intl/intl.dart';
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
      //Amplify.addPlugin(AmplifyAPI());

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
        final dt = DateTime(now.year, now.month, now.day, t.operationHours.item1.hour, t.operationHours.item1.minute);
        final dt2 = DateTime(now.year, now.month, now.day, t.operationHours.item2.hour, t.operationHours.item2.minute);
        final format = DateFormat.jm();
        json = json + format.format(dt) + "," + format.format(dt2);
      }
      json = json + "\n";
    }
    return json;
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // to make the tests work

  group('end-to-end test', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late NavigatorObserver mockObserver;
    late UserModel user;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      OnlineStoreModel onlineStoreModel = OnlineStoreModel(
          name: "online store test",
          phoneNumber: "+972123456789",
          address: "Ashdod, Israel",
          operationHours: openingsToJson(op),
          categories: "[\"Food\"]",
          qrCode: "");
      TemporalDateTime time = TemporalDateTime.fromString(
          DateFormat('yyyy/MM/dd hh:mm:ss').parse('2022/1/1 10:00:00').toDateTimeIso8601String());
      StoreOwnerModel storeOwnerModel = StoreOwnerModel(
          storeOwnerModelOnlineStoreModelId: onlineStoreModel.id,
          onlineStoreModel: onlineStoreModel,
          lastPurchasesView: time);
      UserModel currUser = new UserModel(
          email: "test@gmail.com",
          name: "test name",
          hideStoreOwnerOptions: false,
          userModelStoreOwnerModelId: storeOwnerModel.id,
          storeOwnerModel: storeOwnerModel,
          isLoggedIn: true);
      await Amplify.DataStore.save(onlineStoreModel);
      await Amplify.DataStore.save(storeOwnerModel);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      user = currUser;
      return Future(() => print("starting test.."));
    });

    testWidgets('edit online store - positive scenario', (WidgetTester tester) async {
      await tester.pumpWidget(app.EditOnlineStorePipeline().wrapWithMaterial([mockObserver], user));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('storeName')), findsOneWidget);
      expect(find.byKey(Key('phoneNumber')), findsOneWidget);
      expect(find.byKey(Key('storeAddress')), findsOneWidget);
      expect(find.byKey(Key('continue_button')), findsOneWidget);
    });

  });
}
