import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/screens/online_store_screen.dart';
import 'package:final_project_yroz/screens/physical_store_screen.dart';
import 'package:flutter/material.dart';

class StoreItem extends StatelessWidget {
  final StoreDTO store;

  StoreItem(this.store) {}

  void selectStore(BuildContext ctx) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        key: Key(this.store.id),
        child: Container(
            child: Stack(children: <Widget>[
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                image: this.store.image != null
                    ? DecorationImage(
                        image: NetworkImage(this.store.image!),
                        fit: BoxFit.cover)
                    : DecorationImage(
                        image: AssetImage('assets/images/default-store.png'),
                        fit: BoxFit.cover),
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
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              this.store.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromRGBO(20, 19, 42, 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.09,
                    child: Column(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              this.store.address,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
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
