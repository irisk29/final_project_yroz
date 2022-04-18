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
  late String storeName;
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

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    storeName = routeArgs['storeName'] as String;
    super.didChangeDependencies();
  }

  Future<void> _initPurchases() async {
    User user = Provider.of<User>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime monthAgo = new DateTime(now.year, now.month - 1, now.day);
    DateTime lastVisit = user.storeOwnerState!.lastTimeViewedPurchases;

    await user.storeOwnerState!.updateLastTimeViewedPurchses(now);
    newStorePurchases = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(lastVisit, now);
    newStorePurchases
        .sort((p1, p2) => p1.purchaseDate.compareTo(p2.purchaseDate));
    earlierStorePurchases = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(monthAgo, lastVisit);
    earlierStorePurchases
        .sort((p1, p2) => p1.purchaseDate.compareTo(p2.purchaseDate));
  }

  Future<void> _pullRefresh() async {
    User user = Provider.of<User>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime monthAgo = new DateTime(now.year, now.month - 1, now.day);
    DateTime lastVisit = user.storeOwnerState!.lastTimeViewedPurchases;

    await user.storeOwnerState!.updateLastTimeViewedPurchses(now);
    var newPurchasesTemp = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(lastVisit, now);
    newPurchasesTemp
        .sort((p1, p2) => p1.purchaseDate.compareTo(p2.purchaseDate));
    var earlierPurchasesTemp = await user.storeOwnerState!
        .getSuccssefulPurchaseHistoryForStoreInDateRange(monthAgo, lastVisit);
    earlierPurchasesTemp
        .sort((p1, p2) => p1.purchaseDate.compareTo(p2.purchaseDate));
    setState(() {
      newStorePurchases = newPurchasesTemp;
      earlierStorePurchases = earlierPurchasesTemp;
    });
  }

  double totalStoreEarning() {
    final double newTotal = newStorePurchases.fold(
        0, (sum, item) => sum + item.cashBackAmount + item.creditAmount);
    final double earlierTotal = earlierStorePurchases.fold(
        0, (sum, item) => sum + item.cashBackAmount + item.creditAmount);
    final totalEarning = (newTotal + earlierTotal) * 0.9;
    return totalEarning;
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
                      ? Column(
                          children: [
                            Container(
                              height: deviceSize.height * 0.2,
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: deviceSize.height * 0.075,
                                        child:
                                            Image.asset('assets/icon/icon.png'),
                                      ),
                                      Text(
                                        "  \€" +
                                            totalStoreEarning()
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Total Earnings",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: newStorePurchases.length +
                                    earlierStorePurchases.length,
                                itemBuilder: (context, index) {
                                  if (index == 0 &&
                                      newStorePurchases.length > 0) {
                                    return Column(children: [
                                      ListTile(title: Text("New")),
                                      HistoryPurchaseItem(
                                          newStorePurchases[
                                              newStorePurchases.length -
                                                  index -
                                                  1],
                                          storeName)
                                    ]);
                                  } else if (index ==
                                      newStorePurchases.length) {
                                    return Column(children: [
                                      ListTile(title: Text("Earlier")),
                                      HistoryPurchaseItem(
                                          earlierStorePurchases[
                                              earlierStorePurchases.length -
                                                  (index -
                                                      newStorePurchases
                                                          .length) -
                                                  1],
                                          storeName)
                                    ]);
                                  } else if (index < newStorePurchases.length) {
                                    return HistoryPurchaseItem(
                                        newStorePurchases[
                                            newStorePurchases.length -
                                                index -
                                                1],
                                        storeName);
                                  }
                                  return HistoryPurchaseItem(
                                      earlierStorePurchases[
                                          earlierStorePurchases.length -
                                              (index -
                                                  newStorePurchases.length) -
                                              1],
                                      storeName);
                                },
                              ),
                            ),
                          ],
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
