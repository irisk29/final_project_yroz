import 'package:flutter/material.dart';
import '../screens/category_screen.dart';

class CategoryItem extends StatelessWidget {
  final String id;
  final String title;
  final Color color;

  CategoryItem(this.id, this.title, this.color);

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      CategoryScreen.routeName,
      arguments: {
        'title': title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          child: Stack(
              children: <Widget>[
                Positioned(
                    child: Container(
                        decoration: BoxDecoration(
                                  color: Colors.black,
                                  image: DecorationImage(
                                      image: this.title == 'Food' ? AssetImage("assets/images/food.png") : AssetImage("assets/images/home.png"),
                                      fit: BoxFit.cover
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                              ),
                    )
                ),Positioned(
                    top: 90,
                    left: -5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius : BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        color : Color.fromRGBO(255, 255, 255, 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      child: Column(
                        children: <Widget>[
                          Text(this.title, textAlign: TextAlign.start, style: TextStyle(
                            color: Color.fromRGBO(20, 19, 42, 1),
                            fontSize: 14,
                          ),
                        ),
                        ],
                      ),
                    )
                ),
              ]
          )
      ),
      onTap:() => selectCategory(context),

    );
  }
}
