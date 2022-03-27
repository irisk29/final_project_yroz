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
  bool showArrows = true;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final categoriesScreen = CategoriesScreen();

    return ArrowContainer(
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(
              left: deviceSize.width * 0.03,
            ),
            child: Image.asset('assets/icon/yroz-removebg.png'),
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
        body: Center(
          child: Stack(
            children: [
              categoriesScreen,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ArrowElement(
                    show: showArrows,
                    id: 'arrow',
                    sourceAnchor: Alignment.topCenter,
                    targetId: 'action',
                    color: Colors.purple,
                    child: AlertDialog(
                      title: Text('Congratulations!'),
                      content: Text(
                          "You can now manage your store from this button"),
                      actions: [
                        FlatButton(
                            child: Text('Okay'),
                            onPressed: () {
                              setState(() {
                                showArrows = !showArrows;
                              });
                              Navigator.of(context)
                                  .pushReplacementNamed(TabsScreen.routeName);
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
