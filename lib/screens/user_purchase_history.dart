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
    final start =
        DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM');
    final end = DateTime.now();
    final purchases =
        await user.getSuccssefulPurchaseHistoryForUserInRange(start, end);
    List<Tuple2<String, PurchaseHistoryDTO>> purchaseTuples = [];
    for (var purchase in purchases) {
      var res = await StoreStorageProxy().getStoreNameByID(purchase.storeID);
      purchaseTuples.add(Tuple2(res.getValue(), purchase));
    }
    return purchaseTuples;
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
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
      ),
      body: FutureBuilder(
        future: _purchasesFuture,
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : snap.data.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(top: deviceSize.height * 0.01),
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snap.data.length,
                          itemBuilder: (context, index) => HistoryPurchaseItem(
                              snap.data[index].item2, snap.data[index].item1)),
                    )
                  : Container(
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
    );
  }
}
