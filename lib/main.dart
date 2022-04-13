import 'dart:async';

import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/screens/barcode_screen.dart';
import 'package:final_project_yroz/screens/credit_cards_screen.dart';
import 'package:final_project_yroz/screens/edit_bank_account.dart';
import 'package:final_project_yroz/screens/edit_online_store_screen.dart';
import 'package:final_project_yroz/screens/edit_physical_store_screen.dart';
import 'package:final_project_yroz/screens/invoice_screen.dart';
import 'package:final_project_yroz/screens/loading_splash_screen.dart';
import 'package:final_project_yroz/screens/online_store_products_screen.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/open_online_store_screen.dart';
import 'package:final_project_yroz/screens/open_physical_store_screen.dart';
import 'package:final_project_yroz/screens/physical_payment_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:final_project_yroz/screens/store_purchase_history.dart';
import 'package:final_project_yroz/screens/user_purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'LogicLayer/User.dart';
import 'blocs/application_bloc.dart';
import 'package:flutter/services.dart';

import 'screens/landing_screen.dart';
import 'screens/manage_online_store_screen.dart';
import 'screens/manage_physical_store_screen.dart';
import 'screens/category_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/tabs_screen.dart';
import 'screens/tutorial_screen.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
          fontFamily: 'Montserrat',
        ),
        home: LoadingSplashScreen(),
        routes: {
          CartScreen.routeName: (ctx) => CartScreen(),
          TabsScreen.routeName: (ctx) => TabsScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(null),
          CategoryScreen.routeName: (ctx) => CategoryScreen(),
          OpenPhysicalStorePipeline.routeName: (ctx) =>
              OpenPhysicalStorePipeline(),
          OpenOnlineStorePipeline.routeName: (ctx) => OpenOnlineStorePipeline(),
          PhysicalStoreScreen.routeName: (ctx) => PhysicalStoreScreen(),
          OnlineStoreScreen.routeName: (ctx) => OnlineStoreScreen(),
          OnlineStoreProductsScreen.routeName: (ctx) =>
              OnlineStoreProductsScreen(),
          LandingScreen.routeName: (ctx) => LandingScreen(),
          LoadingSplashScreen.routeName: (ctx) => LoadingSplashScreen(),
          EditOnlineStorePipeline.routeName: (ctx) => EditOnlineStorePipeline(),
          EditPhysicalStorePipeline.routeName: (ctx) =>
              EditPhysicalStorePipeline(),
          EditBankAccountScreen.routeName: (ctx) => EditBankAccountScreen(),
          QRViewExample.routeName: (ctx) => QRViewExample(),
          CreditCardsScreen.routeName: (ctx) => CreditCardsScreen(),
          AddCreditCardScreen.routeName: (ctx) => AddCreditCardScreen(),
          ManageOnlineStoreScreen.routeName: (ctx) => ManageOnlineStoreScreen(),
          ManagePhysicalStoreScreen.routeName: (ctx) =>
              ManagePhysicalStoreScreen(),
          StorePurchasesScreen.routeName: (ctx) => StorePurchasesScreen(),
          UserPurchasesScreen.routeName: (ctx) => UserPurchasesScreen(),
          TutorialScreen.routeName: (ctx) => TutorialScreen(),
          InvoiceScreen.routeName: (ctx) => InvoiceScreen(ctx),
        },
      ),
    );
  }
}
