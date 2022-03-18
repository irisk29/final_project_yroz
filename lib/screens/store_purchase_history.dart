import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DTOs/PurchaseHistoryDTO.dart';
import '../LogicLayer/User.dart';

class StorePurchasesScreen extends StatefulWidget {
  @override
  _StorePurchasesScreenState createState() => _StorePurchasesScreenState();
}

class _StorePurchasesScreenState extends State<StorePurchasesScreen> {
  late List<PurchaseHistoryDTO> newStorePurchases;
  late List<PurchaseHistoryDTO> earlierStorePurchases;

  @override
  void initState() {
    super.initState();
    _pullRefresh();
  }

  Future<void> _pullRefresh() async {
    List<PurchaseHistoryDTO> newPurchasesTemp = await Provider.of<User>(context)
        .getSuccssefulPurchaseHistoryForStoreInPastMonth();
    setState(() {
      newStorePurchases = newPurchasesTemp;
    });
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
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: newStorePurchases.length,
          itemBuilder: (context, index) {
            return Container();
          },
        ),
      ),
    );
  }
}
