import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:project_demo/screens/physical_store_screen.dart';
import '../screens/category_screen.dart';

class StoreItem extends StatelessWidget {
  final MemoryImage image;
  final String title;
  final String address;

  StoreItem(this.image, this.title, this.address);

  void selectStore(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      PhysicalStoreScreen.routeName,
      arguments: {
        'title': title,
        'address': address,
        'image': image,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          child: Stack(children: <Widget>[
        Positioned(
            child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(image: this.image, fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(15),
          ),
        )),
        Positioned(
            top: 110,
            left: -5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              padding: EdgeInsets.symmetric(horizontal: 88, vertical: 10),
              child: Column(
                children: <Widget>[
                  Text(
                    this.title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color.fromRGBO(20, 19, 42, 1),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    this.address,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )),
      ])),
      onTap: () => selectStore(context),
    );
  }
}
