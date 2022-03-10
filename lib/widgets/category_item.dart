import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import '../screens/category_screen.dart';

class CategoryItem extends StatelessWidget {
  final String id;
  final String title;
  final Color color;
  final User user;

  CategoryItem(this.id, this.title, this.color, this.user);

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      CategoryScreen.routeName,
      arguments: {
        'title': title,
        'User': user
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        child: Container(
            child: Stack(children: <Widget>[
          Positioned(
              child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                  image: this.title == 'Food'
                      ? AssetImage("assets/images/food.png")
                      : AssetImage("assets/images/home.png"),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15),
            ),
          )),
          Positioned(
              top: constraints.maxHeight * 0.75,
              child: Container(
                height: constraints.maxHeight * 0.25,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      this.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(20, 19, 42, 1),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
        ])),
        onTap: () => selectCategory(context),
      ),
    );
  }
}
