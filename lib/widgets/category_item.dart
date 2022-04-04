import 'package:flutter/material.dart';
import '../screens/category_screen.dart';

class CategoryItem extends StatelessWidget {
  final String id;
  final String title;
  final Color color;
  final AssetImage image;

  CategoryItem(this.id, this.title, this.color, this.image);

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
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        child: Container(
            child: Stack(children: <Widget>[
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(image: this.image, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 5.0,
                      spreadRadius: 0,
                      offset: new Offset(10.0, 0.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: constraints.maxHeight * 0.14,
                      child: Column(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                this.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color.fromRGBO(20, 19, 42, 1),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
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
