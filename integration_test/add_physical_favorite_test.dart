import 'dart:convert';
import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/DataLayer/user_authenticator.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/amplifyconfiguration.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/widgets/default_store_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:final_project_yroz/screens/tabs_screen.dart' as app;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  takeScreenshot(tester, binding) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    await binding.takeScreenshot('test-screenshot');
  }

  Future<void> _configureAmplify() async {
    Amplify.addPlugin(AmplifyAuthCognito());
    Amplify.addPlugin(AmplifyStorageS3());
    Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
    //Amplify.addPlugin(AmplifyAPI());

    // Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print("Amplify was already configured. Was the app restarted?");
    }
  }

  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // to make the tests work

  Map<String, List<TimeOfDay>> opHours(Map<String, dynamic> oper) {
    Map<String, List<TimeOfDay>> map = {};
    for (MapEntry e in oper.entries) {
      List<TimeOfDay> l = [];
      for (dynamic d in e.value) {
        l.add(TimeOfDay.fromDateTime(DateFormat.jm().parse(d.toString())));
      }
      map.addEntries([MapEntry(e.key, l)]);
    }
    return map;
  }

  group('end-to-end test', () {
    final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;
    late NavigatorObserver mockObserver;
    late UserModel user;

    setUp(() async {
      await _configureAmplify();
      UserAuthenticator().setCurrentUserId("test@gmail.com");
      PhysicalStoreModel physicalStoreModel = PhysicalStoreModel(
          name: "physical store test",
          phoneNumber: "+972123456789",
          address: "Ashdod, Israel",
          operationHours: "{ \"sunday\": [ \"7:00 AM\", \"11:59 PM\" ], \"monday\": [ \"7:00 AM\", \"11:59 PM\" ], \"tuesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"wednesday\": [ \"7:00 AM\", \"11:59 PM\" ], \"thursday\": [ \"7:00 AM\", \"11:59 PM\" ], \"friday\": [ \"7:00 AM\", \"11:59 PM\" ], \"saturday\": [ \"7:00 AM\", \"11:59 PM\" ] }",
          categories: "[\"Food\"]",
          qrCode: "");
      TemporalDateTime time = TemporalDateTime.fromString(
          DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM').toDateTimeIso8601String());
      StoreOwnerModel storeOwnerModel = StoreOwnerModel(storeOwnerModelPhysicalStoreModelId: physicalStoreModel.id, physicalStoreModel: physicalStoreModel, lastPurchasesView: time);
      UserModel currUser = new UserModel(email: "test@gmail.com", name: "test name", hideStoreOwnerOptions: false, userModelStoreOwnerModelId: storeOwnerModel.id, storeOwnerModel: storeOwnerModel);
      await Amplify.DataStore.save(physicalStoreModel);
      await Amplify.DataStore.save(storeOwnerModel);
      await Amplify.DataStore.save(currUser);
      mockObserver = MockNavigatorObserver();
      user = currUser;
      return Future(() => print("starting test.."));
    });

    testWidgets('favorite physical store - positive scenario', (WidgetTester tester) async {
      PhysicalStoreModel model = user.storeOwnerModel!.physicalStoreModel!;
      StoreDTO dto = StoreDTO(
          id: model.id,
          name: model.name,
          address: model.address,
          phoneNumber: model.phoneNumber,
          categories: jsonDecode(model.categories).cast<String>(),
          operationHours: opHours(jsonDecode(model.operationHours)),
          image: model.imageUrl,
          qrCode: model.qrCode!);
      await tester.pumpWidget(app.TabsScreen().wrapWithMaterial2([mockObserver], user));
      await tester.pumpAndSettle();

      //start to fill the form
      Finder fab = find.byKey(Key(user.storeOwnerModel!.physicalStoreModel!.id));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key('favorite'));
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      fab = find.byKey(Key("continue_button")); //move forward from one form to another
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await Future.delayed(Duration(seconds: 10));

      // Verify the store was created
      ResultInterface storeOwnerRes = await UsersStorageProxy().getStoreOwnerState("test@gmail.com");
      assert(storeOwnerRes.getTag() == true);
      StoreOwnerModel storeOwnerModel = storeOwnerRes.getValue();
      assert(storeOwnerModel.physicalStoreModel!.name == "physical store check");
      assert(storeOwnerModel.storeOwnerModelPhysicalStoreModelId != null);
      assert(storeOwnerModel.storeOwnerModelPhysicalStoreModelId!.isNotEmpty);
    });
  });
}
