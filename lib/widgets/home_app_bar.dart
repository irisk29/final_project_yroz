import 'package:final_project_yroz/widgets/badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/User.dart';
import '../screens/manage_online_store_screen.dart';
import '../screens/manage_physical_store_screen.dart';

class HomeAppBar {
  Widget? buildAction(BuildContext context) {
    final user = Provider.of<User>(context, listen: true);

    if (user.storeOwnerState != null) {
      var notificationValue = user.storeOwnerState!.newPurchasesNoViewed;
      var notificationString =
          notificationValue > 9 ? "9+" : notificationValue.toString();
      var icon = IconButton(
        icon: Icon(Icons.storefront),
        onPressed: () => user.storeOwnerState!.physicalStore != null
            ? Navigator.of(context)
                .pushNamed(ManagePhysicalStoreScreen.routeName)
            : Navigator.of(context)
                .pushNamed(ManageOnlineStoreScreen.routeName),
      );
      return notificationValue == 0
          ? icon
          : Badge(child: icon, value: notificationString);
    }
    return null;
  }

  AppBar build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final action = buildAction(context);

    return AppBar(
      leading: Padding(
        padding: EdgeInsets.only(
          left: deviceSize.width * 0.03,
        ),
        child: Image.asset('assets/icon/yroz-removebg.png'),
      ),
      leadingWidth: deviceSize.width * 0.37,
      toolbarHeight: deviceSize.height * 0.1,
      actions: action != null ? List.from([action]) : [],
    );
  }
}
