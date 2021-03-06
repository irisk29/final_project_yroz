import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../DTOs/PurchaseHistoryDTO.dart';
import '../LogicLayer/User.dart';
import '../widgets/purchase_item.dart';

class UserPurchasesScreen extends StatefulWidget {
  static const routeName = '/user-purchases';

  @override
  _UserPurchasesScreenState createState() => _UserPurchasesScreenState();
}

class _UserPurchasesScreenState extends State<UserPurchasesScreen> {
  late Future<List<Tuple2<String, PurchaseHistoryDTO>>> _purchasesFuture;

  @override
  void initState() {
    _purchasesFuture = _initPurchases();
    super.initState();
  }

  Future<List<Tuple2<String, PurchaseHistoryDTO>>> _initPurchases() async {
    User user = Provider.of<User>(context, listen: false);
    final start = DateFormat('yyyy/MM/dd hh:mm:ss').parse('2022/1/1 10:00:00');
    final end = DateTime.now();
    final purchases =
        await user.getSuccssefulPurchaseHistoryForUserInRange(start, end);
    List<Tuple2<String, PurchaseHistoryDTO>> purchaseTuples = [];
    for (var purchase in purchases) {
      var res = await StoreStorageProxy().getStoreNameByID(purchase.storeID);
      if (res.getTag()) {
        purchaseTuples.add(Tuple2(res.getValue(), purchase));
      } else {
        purchaseTuples.add(Tuple2("DELETED STORE", purchase));
      }
    }
    return purchaseTuples;
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: deviceSize.height * 0.1,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Latest Purchases",
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: FutureBuilder(
          future: _purchasesFuture,
          builder: (BuildContext context, AsyncSnapshot snap) {
            if (snap.connectionState != ConnectionState.done)
              return Center(child: CircularProgressIndicator());
            if (snap.data.length > 0) {
              (snap.data as List<Tuple2<String, PurchaseHistoryDTO>>).sort(
                  (p1, p2) =>
                      p1.item2.purchaseDate.compareTo(p2.item2.purchaseDate));
              return Padding(
                padding: EdgeInsets.only(top: deviceSize.height * 0.01),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snap.data.length,
                    itemBuilder: (context, index) => HistoryPurchaseItem(
                        snap.data[snap.data.length - index - 1].item2,
                        snap.data[snap.data.length - index - 1].item1)),
              );
            }
            return Container(
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: deviceSize.width * 0.11,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.history, size: 40),
                      radius: deviceSize.width * 0.1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(deviceSize.height * 0.01),
                    child: Text("Latest Purchases",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Text("No Purchases made yet"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
