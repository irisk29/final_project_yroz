import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';

class SearchBarItem extends StatelessWidget {
  final MemoryImage? image;
  final String title;
  final String address;
  final String phoneNumber;
  late final Map<String, List<TimeOfDay>> operationHours;
  late final List<ProductDTO>? products;

  SearchBarItem(this.image, this.title, this.address, this.phoneNumber,
      operationHours, products) {
    this.operationHours = Map<String, List<TimeOfDay>>.from(operationHours);
    this.products = products == null ? null : List<ProductDTO>.from(products);
  }

  void selectStore(BuildContext ctx) {
    this.products == null
        ? Navigator.of(ctx).pushNamed(
            PhysicalStoreScreen.routeName,
            arguments: {
              'title': title,
              'address': address,
              'image': image,
              'phoneNumber': phoneNumber,
              'operationHours':
                  Map<String, List<TimeOfDay>>.from(operationHours),
            },
          )
        : Navigator.of(ctx).pushNamed(
            OnlineStoreScreen.routeName,
            arguments: {
              'title': title,
              'address': address,
              'image': image,
              'phoneNumber': phoneNumber,
              'operationHours':
                  Map<String, List<TimeOfDay>>.from(operationHours),
              'products': products
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.store)],
      ),
      title: Text(
        this.title,
        style: TextStyle(
          color: Color.fromRGBO(20, 19, 42, 1),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        this.address,
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      onTap: () => selectStore(context),
    );
  }
}
