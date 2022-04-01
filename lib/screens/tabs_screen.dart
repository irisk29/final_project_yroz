import 'package:final_project_yroz/screens/account_screen.dart';
import 'package:final_project_yroz/screens/categories_screen.dart';
import 'package:final_project_yroz/widgets/tabs_app_bar.dart';
import 'package:final_project_yroz/widgets/home_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/User.dart';
import 'favorite_screen.dart';
import 'map_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';

  @override
  _TabsScreenState createState() => _TabsScreenState();

  //for test purposes
  Widget wrapWithMaterial(List<NavigatorObserver> nav) => MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: User("test@gmail.com", "test name"),
            ),
          ],
          child: Scaffold(
            body: this,
          ),
        ),
        // This mocked observer will now receive all navigation events
        // that happen in our app.
        navigatorObservers: nav,
      );
}

class _TabsScreenState extends State<TabsScreen> {
  late int _selectedPageIndex;
  var _init = false;

  @override
  void didChangeDependencies() {
    if (!_init) {
      final routeArgs = ModalRoute.of(context)!.settings.arguments;
      _selectedPageIndex = routeArgs != null &&
              routeArgs is Map<String, Object> &&
              routeArgs.containsKey("index")
          ? routeArgs['index'] as int
          : 0;
      _init = true;
      super.didChangeDependencies();
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeAppBar = HomeAppBar().build(context, () => setState(() {}));
    final favoritesAppBar = TabsAppBar("Favorites").build(context);
    final nearbyAppBar = TabsAppBar("Nearby").build(context);
    final accountAppBar = TabsAppBar("My Account").build(context);
    List<AppBar> appBars = [
      homeAppBar,
      nearbyAppBar,
      favoritesAppBar,
      accountAppBar
    ];

    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBars[_selectedPageIndex],
        body: const [
          CategoriesScreen(),
          MapScreen(),
          FavoriteScreen(),
          AccountScreen()
        ][_selectedPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: _selectPage,
          backgroundColor: Colors.white,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Theme.of(context).primaryColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          currentIndex: _selectedPageIndex,
          items: [
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.location_on_outlined),
              label: 'Nearby',
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
