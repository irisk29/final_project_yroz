import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/manage_online_store_screen.dart';
import '../screens/manage_physical_store_screen.dart';

class StoreItem extends StatelessWidget {
  final StoreDTO store;
  VoidCallback callback;

  StoreItem(this.store, this.callback);

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
      if (user.storeOwnerState!.hasPhysicalStore(store.id)) {
        Navigator.of(ctx)
            .pushNamed(ManagePhysicalStoreScreen.routeName)
            .then((value) {
          if (value != null) callback();
        });
        showManageMyStoreDialog(ctx);
      } else if (user.storeOwnerState!.hasOnlineStore(store.id)) {
        Navigator.of(ctx)
            .pushNamed(ManageOnlineStoreScreen.routeName)
            .then((value) {
          if (value != null) callback();
        });
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

  bool myStore(BuildContext context) {
    if (Provider.of<User>(context, listen: false)
            .storeOwnerState!
            .physicalStore !=
        null) {
      if (Provider.of<User>(context, listen: false)
              .storeOwnerState!
              .physicalStore!
              .id ==
          this.store.id)
        return true;
      else
        return false;
    } else if (Provider.of<User>(context, listen: false)
            .storeOwnerState!
            .onlineStore !=
        null) {
      if (Provider.of<User>(context, listen: false)
              .storeOwnerState!
              .onlineStore!
              .id ==
          this.store.id)
        return true;
      else
        return false;
    } else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        key: Key(this.store.id),
        child: Container(
            child: Stack(children: <Widget>[
          Positioned(
            child: this.store.image != null
                ? CachedNetworkImage(
                    imageUrl: this.store.image!,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/placeholder-image.jpeg'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                          child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).errorColor,
                        size: 30,
                      )),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                          image: AssetImage('assets/images/default-store.png'),
                          fit: BoxFit.cover),
                    ),
                  ),
          ),
          Positioned(
            top: constraints.maxHeight * 0.75,
            child: Container(
              height: constraints.maxHeight * 0.25,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15)),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: constraints.maxHeight * 0.14,
                    child: Column(
                      children: [
                        Text(
                          this.store.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color.fromRGBO(20, 19, 42, 1),
                            fontSize: constraints.maxHeight * 0.11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.09,
                    width: constraints.maxWidth * 0.95,
                    child: Column(
                      children: [
                        Text(
                          this.store.address,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: constraints.maxHeight * 0.0725,
                          ),
                        ),
                      ],
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
