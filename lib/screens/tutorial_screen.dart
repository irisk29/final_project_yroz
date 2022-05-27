import 'package:final_project_yroz/screens/categories_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

class TutorialScreen extends StatefulWidget {
  static const routeName = '/tutorial-screen';

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final categoriesScreen = CategoriesScreen();

    return ArrowContainer(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: EdgeInsets.only(
                left: deviceSize.width * 0.03,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/icon/yroz-removebg.png'),
              ),
            ),
            leadingWidth: deviceSize.width * 0.37,
            toolbarHeight: deviceSize.height * 0.1,
            actions: [
              ArrowElement(
                id: 'action',
                child: IconButton(
                  icon: Icon(Icons.storefront),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Theme.of(context).primaryColor,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            currentIndex: 0,
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
          body: Stack(
            children: [
              categoriesScreen,
              AlertDialog(
                title: ArrowElement(
                    id: 'arrow',
                    sourceAnchor: Alignment.topCenter,
                    targetId: 'action',
                    color: Colors.purple,
                    child: Container(
                        margin: EdgeInsets.only(
                          top: deviceSize.height * 0.01,
                        ),
                        child: Text('Congratulations!'))),
                content: Text("You can now manage your store from this button"),
                actions: [
                  FlatButton(
                      key: const Key("tutorial_okay_button"),
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(TabsScreen.routeName);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
