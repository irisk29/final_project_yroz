import 'package:final_project_yroz/screens/account_screen.dart';
import 'package:final_project_yroz/screens/categories_screen.dart';
import 'package:final_project_yroz/widgets/tabs_app_bar.dart';
import 'package:final_project_yroz/widgets/home_app_bar.dart';
import 'package:flutter/material.dart';


import 'favorite_screen.dart';
import 'map_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Widget> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    //_pages = [CategoriesScreen(), MapScreen(), FavoriteScreen(), AccountScreen()];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _pages = [CategoriesScreen(), MapScreen(), FavoriteScreen(), AccountScreen()];
    final homeAppBar = HomeAppBar().build(context, () => setState(() {}));
    final favoritesAppBar = TabsAppBar("Favorites").build(context);
    final nearbyAppBar = TabsAppBar("Nearby").build(context);
    final accountAppBar = TabsAppBar("My Account").build(context);
    List<AppBar> appBars = [homeAppBar, nearbyAppBar, favoritesAppBar, accountAppBar];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBars[_selectedPageIndex],
      body: _pages[_selectedPageIndex],
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
    );
  }
}
