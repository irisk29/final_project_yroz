import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DTOs/PurchaseHistoryDTO.dart';
import '../LogicLayer/User.dart';
import '../widgets/purchase_item.dart';

class StorePurchasesScreen extends StatefulWidget {
  static const routeName = '/store-purchases';

  @override
  _StorePurchasesScreenState createState() => _StorePurchasesScreenState();
}

class _StorePurchasesScreenState extends State<StorePurchasesScreen> {
  late List<PurchaseHistoryDTO> newStorePurchases = [];
  late List<PurchaseHistoryDTO> earlierStorePurchases = [];

  Future<void> _pullRefresh() async {
    User user = Provider.of<User>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime monthAgo = new DateTime(now.year, now.month - 1, now.day);
    DateTime lastVisit = user.storeOwnerState!.lastTimeViewedPurchases;
    newStorePurchases = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(lastVisit, now);
    earlierStorePurchases = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(monthAgo, lastVisit);
    await user.storeOwnerState!.updateLastTimeViewedPurchses(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Latest Purchases",
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: FutureBuilder(
          future: _pullRefresh(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            return snap.connectionState != ConnectionState.done
                ? Center(child: CircularProgressIndicator())
                : newStorePurchases.length + earlierStorePurchases.length > 0
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: newStorePurchases.length +
                            earlierStorePurchases.length,
                        itemBuilder: (context, index) {
                          if (index == 0 && newStorePurchases.length > 0) {
                            return Column(children: [
                              ListTile(title: Text("New")),
                              HistoryPurchaseItem(newStorePurchases[index])
                            ]);
                          } else if (index == newStorePurchases.length) {
                            return Column(children: [
                              ListTile(title: Text("Earlier")),
                              HistoryPurchaseItem(earlierStorePurchases[
                                  index - newStorePurchases.length])
                            ]);
                          } else if (index < newStorePurchases.length) {
                            return HistoryPurchaseItem(
                                newStorePurchases[index]);
                          }
                          return HistoryPurchaseItem(earlierStorePurchases[
                              index - newStorePurchases.length]);
                        },
                      )
                    : Center(
                        child: Text(
                            "We are Sorry, no purchases made in your store yet"),
                      );
          },
        ),
      ),
    );
  }
}
