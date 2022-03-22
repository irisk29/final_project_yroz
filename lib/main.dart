import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/screens/barcode_screen.dart';
import 'package:final_project_yroz/screens/credit_cards_screen.dart';
import 'package:final_project_yroz/screens/edit_online_store_screen.dart';
import 'package:final_project_yroz/screens/edit_physical_store_screen.dart';
import 'package:final_project_yroz/screens/online_payment_screen.dart';
import 'package:final_project_yroz/screens/online_store_products_screen.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/open_online_store_screen.dart';
import 'package:final_project_yroz/screens/open_physical_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:final_project_yroz/screens/store_purchase_history.dart';
import 'package:final_project_yroz/screens/user_purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'LogicLayer/User.dart';
import 'amplifyconfiguration.dart';
import 'blocs/application_bloc.dart';
import 'models/ModelProvider.dart';

import 'screens/landing_screen.dart';
import 'screens/manage_online_store_screen.dart';
import 'screens/manage_physical_store_screen.dart';
import 'screens/physical_payment_screen.dart';
import 'screens/category_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/tabs_screen.dart';
import 'screens/tutorial_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _configureAmplify();
      await deleteLocalDataStore();
      FlutterNativeSplash.remove();
    });
  }

  Future<void> deleteLocalDataStore() async {
    //get fresh information from cloud everytime the app starts
    try {
      await Amplify.DataStore.clear();
    } catch (error) {
      print('Error stopping DataStore: $error');
    }

    try {
      //await Amplify.DataStore.start();
    } catch (error) {
      print('Error starting DataStore: $error');
    }
  }

  Future<void> _configureAmplify() async {
    if (!mounted) return;

    Amplify.addPlugin(AmplifyAuthCognito());
    Amplify.addPlugin(AmplifyStorageS3());
    Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
    Amplify.addPlugin(AmplifyAPI());

    // Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print("Amplify was already configured. Was the app restarted?");
    }
    try {
      setState(() {
        _amplifyConfigured = true;
      });
      //await deleteLocalDataStore();
    } catch (e) {
      print(e);
    }
  }

  Map<int, Color> color = {
    50: Color.fromRGBO(243, 90, 106, .1),
    100: Color.fromRGBO(243, 90, 106, .2),
    200: Color.fromRGBO(243, 90, 106, .3),
    300: Color.fromRGBO(243, 90, 106, .4),
    400: Color.fromRGBO(243, 90, 106, .5),
    500: Color.fromRGBO(243, 90, 106, .6),
    600: Color.fromRGBO(243, 90, 106, .7),
    700: Color.fromRGBO(243, 90, 106, .8),
    800: Color.fromRGBO(243, 90, 106, .9),
    900: Color.fromRGBO(243, 90, 106, 1),
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ApplicationBloc(),
        ),
        ChangeNotifierProvider(
          create: (context) => User.withNull(),
        ),
      ],
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFFFF9191, color),
          accentColor: Colors.purple,
        ),
        home: LandingScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          TabsScreen.routeName: (ctx) => TabsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(null),
          CategoryScreen.routeName: (ctx) => CategoryScreen(),
          PhysicalPaymentScreen.routeName: (ctx) => PhysicalPaymentScreen(),
          OpenPhysicalStorePipeline.routeName: (ctx) =>
              OpenPhysicalStorePipeline(),
          OpenOnlineStorePipeline.routeName: (ctx) => OpenOnlineStorePipeline(),
          PhysicalStoreScreen.routeName: (ctx) => PhysicalStoreScreen(),
          OnlineStoreScreen.routeName: (ctx) => OnlineStoreScreen(),
          OnlineStoreProductsScreen.routeName: (ctx) =>
              OnlineStoreProductsScreen(),
          LandingScreen.routeName: (ctx) => LandingScreen(),
          EditOnlineStorePipeline.routeName: (ctx) => EditOnlineStorePipeline(),
          EditPhysicalStorePipeline.routeName: (ctx) =>
              EditPhysicalStorePipeline(),
          QRViewExample.routeName: (ctx) => QRViewExample(),
          CreditCardsScreen.routeName: (ctx) => CreditCardsScreen(),
          AddCreditCardScreen.routeName: (ctx) => AddCreditCardScreen(),
          ManageOnlineStoreScreen.routeName: (ctx) => ManageOnlineStoreScreen(),
          ManagePhysicalStoreScreen.routeName: (ctx) =>
              ManagePhysicalStoreScreen(),
          OnlinePaymentScreen.routeName: (ctx) => OnlinePaymentScreen(null),
          StorePurchasesScreen.routeName: (ctx) => StorePurchasesScreen(),
          UserPurchasesScreen.routeName: (ctx) => UserPurchasesScreen(),
          TutorialScreen.routeName: (ctx) => TutorialScreen(),
        },
      ),
    );
  }
}
