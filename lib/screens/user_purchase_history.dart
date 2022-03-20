import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../DTOs/PurchaseHistoryDTO.dart';
import '../LogicLayer/User.dart';
import '../widgets/purchase_item.dart';

class UserPurchasesScreen extends StatefulWidget {
  static const routeName = '/user-purchases';

  @override
  _UserPurchasesScreenState createState() => _UserPurchasesScreenState();
}

class _UserPurchasesScreenState extends State<UserPurchasesScreen> {
  late Future<List<PurchaseHistoryDTO>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _purchasesFuture = _initPurchases();
  }

  Future<List<PurchaseHistoryDTO>> _initPurchases() async {
    User user = Provider.of<User>(context, listen: false);
    final start =
        DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM');
    final end = DateTime.now();
    final purchases =
        await user.getSuccssefulPurchaseHistoryForUserInRange(start, end);
    print(purchases.length);
    return purchases;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Latest Purchases",
        ),
      ),
      body: FutureBuilder(
        future: _purchasesFuture,
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
