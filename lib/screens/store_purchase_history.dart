import 'package:flutter/material.dart';

import '../DTOs/OnlineStoreDTO.dart';

class StorePurchasesScreen extends StatefulWidget {

  late OnlineStoreDTO store;

  @override
  _StorePurchasesScreenState createState() => _StorePurchasesScreenState();
}

class _StorePurchasesScreenState extends State<StorePurchasesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.store.name,
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 60,
            itemBuilder: (context, index){
              return ButtonTheme(
                minWidth: 20.0,
                height: 20.0,
                child: MaterialButton(
                  onPressed: () => print(index),
                  shape: RoundedRectangleBorder(borderRadius:
                  BorderRadius.circular(10.0)),
                  child:  Text('$index'),
                ),
              );
            },
          ),
        ),
      );
  }
}
