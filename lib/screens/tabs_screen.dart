import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/account_screen.dart';
import 'package:final_project_yroz/screens/manage_online_store_screen.dart';
import 'package:final_project_yroz/screens/manage_physical_store_screen.dart';
import 'package:final_project_yroz/widgets/badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/categories_screen.dart';
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
    _pages = [
      CategoriesScreen(),
      MapScreen(),
      FavoriteScreen(),
      AccountScreen()
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Widget? buildAction() {
    final user = Provider.of<User>(context, listen: true);

    if (user.storeOwnerState != null) {
      var notificationValue = user.storeOwnerState!.newPurchasesNoViewed;
      var notificationString =
          notificationValue > 9 ? "9+" : notificationValue.toString();
      var icon = user.storeOwnerState!.physicalStore != null
          ? IconButton(
              icon: Icon(Icons.storefront),
              onPressed: () => Navigator.of(context).pushNamed(
                ManagePhysicalStoreScreen.routeName,
              ),
            )
          : IconButton(
              icon: Icon(Icons.store_outlined),
              onPressed: () => Navigator.of(context).pushNamed(
                ManageOnlineStoreScreen.routeName,
              ),
            );
      return notificationValue == 0
          ? icon
          : Badge(child: icon, value: notificationString);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final action = buildAction();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(
            left: deviceSize.width * 0.03,
          ),
          child: Image.asset('assets/icon/yroz-removebg.png'),
        ),
        leadingWidth: deviceSize.width * 0.37,
        toolbarHeight: deviceSize.height * 0.1,
        actions: action != null ? List.from([action]) : [],
      ),
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
