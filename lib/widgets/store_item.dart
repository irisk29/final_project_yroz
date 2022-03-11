import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';

class StoreItem extends StatelessWidget {
  final StoreDTO store;
  final User user;

  StoreItem(this.store, this.user) {

  }

  void selectStore(BuildContext ctx) {
    this.store is OnlineStoreDTO
        ? Navigator.of(ctx).pushNamed(
            OnlineStoreScreen.routeName,
            arguments: {
              'store': store,
              'user': user
            },
          )
        : Navigator.of(ctx).pushNamed(
            PhysicalStoreScreen.routeName,
            arguments: {
              'store': store,
              'user': user
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
              image: this.store.image != null
                  ? DecorationImage(image: this.store.imageFile!, fit: BoxFit.cover)
                  : DecorationImage(
                      image: AssetImage('assets/images/default-store.png'),
                      fit: BoxFit.cover),
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
                    this.store.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(20, 19, 42, 1),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    this.store.address,
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
