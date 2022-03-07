import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';

class StoreItem extends StatelessWidget {
  final MemoryImage? image;
  final String title;
  final String address;
  final String phoneNumber;
  late final Map<String, List<TimeOfDay>> operationHours;
  late final List<ProductDTO> products;

  StoreItem(
      this.image, this.title, this.address, this.phoneNumber, operationHours, products) {
    this.operationHours = Map<String, List<TimeOfDay>>.from(operationHours);
    this.products = List<ProductDTO>.from(products);
  }

  void selectStore(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      OnlineStoreScreen.routeName,
      arguments: {
        'title': title,
        'address': address,
        'image': image,
        'phoneNumber': phoneNumber,
        'operationHours': Map<String, List<TimeOfDay>>.from(operationHours),
        'products': products
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
              color: Colors.white,
              image: this.image != null
                  ? DecorationImage(image: this.image!, fit: BoxFit.cover)
                  : null,
              borderRadius: BorderRadius.circular(15),
            ),
          )),
          Positioned(
            top: constraints.maxHeight * 0.75,
            child: Container(
              height: constraints.maxHeight * 0.25,
              width: constraints.maxWidth,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Text(
                    this.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(20, 19, 42, 1),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    this.address,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ])),
        onTap: () => selectStore(context),
      ),
    );
  }
}
