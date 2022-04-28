import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/User.dart';
import '../screens/manage_online_store_screen.dart';
import '../screens/manage_physical_store_screen.dart';

class SecondaryStoreItem extends StatelessWidget {
  final StoreDTO store;

  SecondaryStoreItem(this.store) {}

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
        Navigator.of(ctx).pushNamed(ManagePhysicalStoreScreen.routeName);
        showManageMyStoreDialog(ctx);
      } else if (user.storeOwnerState!.hasOnlineStore(store.id)) {
        Navigator.of(ctx).pushNamed(ManageOnlineStoreScreen.routeName);
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        child: Container(
            child: Stack(children: <Widget>[
          Positioned(
            child: this.store.image != null
                ? CachedNetworkImage(
                    imageUrl: this.store.image!,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 5.0,
                            spreadRadius: 0,
                            offset: new Offset(10.0, 0.0),
                          ),
                        ],
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 5.0,
                            spreadRadius: 0,
                            offset: new Offset(10.0, 0.0),
                          ),
                        ],
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/placeholder-image.jpeg'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 5.0,
                            spreadRadius: 0,
                            offset: new Offset(10.0, 0.0),
                          ),
                        ],
                      ),
                      child: Center(
                          child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).errorColor,
                        size: 60,
                      )),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 5.0,
                          spreadRadius: 0,
                          offset: new Offset(10.0, 0.0),
                        ),
                      ],
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
                    bottomRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: constraints.maxHeight * 0.1,
                    child: Text(
                      this.store.name + " | " + this.store.address,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.85),
                        fontSize: constraints.maxHeight * 0.08,
                      ),
                    ),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.075,
                    width: constraints.maxWidth * 0.95,
                    child: Text(
                      this.store.categories.join(', '),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: constraints.maxHeight * 0.06,
                      ),
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
