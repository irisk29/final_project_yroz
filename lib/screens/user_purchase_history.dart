import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../DTOs/PurchaseHistoryDTO.dart';
import '../LogicLayer/User.dart';
import '../widgets/purchase_item.dart';

class UserPurchasesScreen extends StatelessWidget {
  static const routeName = '/user-purchases';

  @override
  Widget build(BuildContext context) {
    var start =
        DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM');
    var end = DateTime.now();
    Future<List<PurchaseHistoryDTO>> purchasesFuture =
        Provider.of<User>(context, listen: false)
            .getSuccssefulPurchaseHistoryForUserInRange(start, end);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Latest Purchases",
        ),
      ),
      body: FutureBuilder(
        future: purchasesFuture,
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : snap.data.length > 0
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snap.data.length,
                      itemBuilder: (context, index) =>
                          HistoryPurchaseItem(snap.data[index]))
                  : Center(
                      child: Text("No purchases made yet"),
                    );
        },
      ),
    );
  }
}
