import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/app_drawer.dart';

import '../screens/categories_screen.dart';
import 'map_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';
  User? user;

  TabsScreen(User? user){
    this.user = user;
  }

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _pages = [
      {
        'page': CategoriesScreen(),
        'title': 'Home',
      },
      {
        'page': SplashScreen(),
        'title': 'Your Favorites',
      },
      {
        'page': MapScreen(),
        'title': 'Locations',
      },
      {
        'page': SplashScreen(),
        'title': 'Wallet',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pages[_selectedPageIndex]['title'] as String,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName, arguments: widget.user);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _pages[_selectedPageIndex]['page'] as Widget,
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
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.favorite_border),
            title: Text('Favorites'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.location_on_outlined),
            title: Text('Nearby'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.account_balance_wallet_outlined),
            title: Text('Wallet'),
          ),
        ],
      ),
    );
  }
}
