import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:project_demo/LogicLayer/User.dart';
import 'package:project_demo/blocs/application_bloc.dart';
import 'package:project_demo/models/ModelProvider.dart';
import 'package:project_demo/providers/stores.dart';
import 'package:project_demo/screens/online_store_screen.dart';
import 'package:project_demo/screens/open_online_store_screen.dart';
import 'package:project_demo/screens/physical_store_screen.dart';
import 'package:provider/provider.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplifyconfiguration.dart';
import 'providers/auth.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/products.dart';

import 'screens/landing_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/category_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/open_physical_store_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tabs_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
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
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (con, val, old) =>
              Products(val.token, val.userId, old == null ? [] : old.items),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (con, val, old) =>
              Orders(val.token, val.userId, old == null ? [] : old.orders),
        ),
        ChangeNotifierProvider(
          create: (context) => ApplicationBloc(),
        ),
        ChangeNotifierProvider(
          create: (context) => User(),
        ),
        ChangeNotifierProxyProvider<User, Stores>(
          create: null,
          update: (con, val, old) => Stores(
              val,
              old == null ? [] : old.onlineStores,
              old == null ? [] : old.physicalStores),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: MaterialColor(0xFFF35A6A, color),
            accentColor: Colors.purple,
          ),
          home: auth.isAuth
              ? ProductDetailScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : LandingScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            TabsScreen.routeName: (ctx) => TabsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            CategoryScreen.routeName: (ctx) => CategoryScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            PaymentScreen.routeName: (ctx) => PaymentScreen(),
            OpenPhysicalStoreScreen.routeName: (ctx) =>
                OpenPhysicalStoreScreen(),
            OpenOnlineStoreScreen.routeName: (ctx) => OpenOnlineStoreScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            PhysicalStoreScreen.routeName: (ctx) => PhysicalStoreScreen(),
            OnlineStoreScreen.routeName: (ctx) => OnlineStoreScreen(),
            LandingScreen.routeName: (ctx) => LandingScreen(),
          },
        ),
      ),
    );
  }
}
