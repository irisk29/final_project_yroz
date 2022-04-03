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
  late List<PurchaseHistoryDTO> newStorePurchases;
  late List<PurchaseHistoryDTO> earlierStorePurchases;

  late Future<void> _purchasesFuture;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _purchasesFuture = _initPurchases();
  }

  Future<void> _initPurchases() async {
    User user = Provider.of<User>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime monthAgo = new DateTime(now.year, now.month - 1, now.day);
    DateTime lastVisit = user.storeOwnerState!.lastTimeViewedPurchases;

    await user.storeOwnerState!.updateLastTimeViewedPurchses(now);
    newStorePurchases = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(lastVisit, now);
    earlierStorePurchases = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(monthAgo, lastVisit);
  }

  Future<void> _pullRefresh() async {
    User user = Provider.of<User>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime monthAgo = new DateTime(now.year, now.month - 1, now.day);
    DateTime lastVisit = user.storeOwnerState!.lastTimeViewedPurchases;

    await user.storeOwnerState!.updateLastTimeViewedPurchses(now);
    final newPurchasesTemp = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(lastVisit, now);
    final earlierPurchasesTemp = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(monthAgo, lastVisit);
    setState(() {
      newStorePurchases = newPurchasesTemp;
      earlierStorePurchases = earlierPurchasesTemp;
    });
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
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _pullRefresh,
                  child: newStorePurchases.length +
                              earlierStorePurchases.length >
                          0
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
                      : Container(
                          width: MediaQuery.of(context).size.width,
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
                                padding:
                                    EdgeInsets.all(deviceSize.height * 0.01),
                                child: Text("Latest Purchases",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                  "We are Sorry, no purchases made in your store yet"),
                            ],
                          ),
                        ),
                );
        },
      ),
    );
  }
}
