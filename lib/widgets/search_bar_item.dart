import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';

class SearchBarItem extends StatelessWidget {
  final StoreDTO store;

  SearchBarItem(this.store);

  void selectStore(BuildContext ctx) {
    this.store is OnlineStoreDTO
        ? Navigator.of(ctx).pushNamed(
            OnlineStoreScreen.routeName,
            arguments: {
              'store': store,
            },
          )
        : Navigator.of(ctx).pushNamed(
            PhysicalStoreScreen.routeName,
            arguments: {
              'store': store,
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
        this.store.name,
        style: TextStyle(
          color: Color.fromRGBO(20, 19, 42, 1),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        this.store.address,
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      onTap: () => selectStore(context),
    );
  }
}
