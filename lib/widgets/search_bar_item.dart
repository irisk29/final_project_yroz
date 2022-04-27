import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/User.dart';
import '../screens/manage_online_store_screen.dart';
import '../screens/manage_physical_store_screen.dart';

class SearchBarItem extends StatelessWidget {
  final StoreDTO store;

  SearchBarItem(this.store);

  void showManageMyStoreDialog(BuildContext ctx) {
    SnackBar snackBar = SnackBar(
      duration: Duration(seconds: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Theme.of(ctx).primaryColor,
      behavior: SnackBarBehavior.floating,
      content: const Text(
          'You chose your store, you can see how other users see it using "View My Store" option',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black87)),
      width: MediaQuery.of(ctx).size.width * 0.8,
    );
    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
  }

  void selectStore(BuildContext ctx) {
    final user = Provider.of<User>(ctx, listen: false);

    if (user.storeOwnerState != null) {
      user.storeOwnerState!.hasPhysicalStore(store.id)
          ? Navigator.of(ctx).pushNamed(ManagePhysicalStoreScreen.routeName)
          : Navigator.of(ctx).pushNamed(ManageOnlineStoreScreen.routeName);
      showManageMyStoreDialog(ctx);
    } else {
      this.store is OnlineStoreDTO
          ? Navigator.of(ctx).pushNamed(
              OnlineStoreScreen.routeName,
              arguments: {'store': store},
            )
          : Navigator.of(ctx).pushNamed(
              PhysicalStoreScreen.routeName,
              arguments: {'store': store},
            );
    }
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
