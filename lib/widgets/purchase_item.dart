import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/PurchaseHistoryDTO.dart';
import 'package:final_project_yroz/DataLayer/PurchaseStorageProxy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPurchaseItem extends StatefulWidget {
  final PurchaseHistoryDTO purchase;
  final String storeName;

  const HistoryPurchaseItem(this.purchase, [this.storeName = "My Store"]);

  @override
  _HistoryPurchaseItemState createState() => _HistoryPurchaseItemState();
}

class _HistoryPurchaseItemState extends State<HistoryPurchaseItem> {
  var _expanded = false;
  late List<CartProductDTO> purchaseProducts = [];

  Future<List<CartProductDTO>> _getProducts() async {
    var res = await PurchaseStorageProxy()
        .getPurchaseProduct(widget.purchase.transactionID);
    if (res.getTag()) {
      setState(() => purchaseProducts = res.getValue()!);
      return res.getValue()!;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        (widget.purchase.cashBackAmount + widget.purchase.creditAmount)
            .toStringAsFixed(2);
    final purchaseDate =
        DateFormat('dd/MM/yyyy HH:mm').format(widget.purchase.purchaseDate);
    final deviceSize = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      height: _expanded
          ? (purchaseProducts.length > 0 ? purchaseProducts.length * 20 : 20) +
              deviceSize.height * 0.175
          : deviceSize.height * 0.175,
      child: Card(
        margin: EdgeInsets.only(
            right: deviceSize.width * 0.05,
            left: deviceSize.width * 0.05,
            top: deviceSize.height * 0.01,
            bottom: deviceSize.height * 0.01),
        child: Center(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(widget.storeName),
                subtitle:
                    Text("Total amount:  \€${totalAmount}\n ${purchaseDate}"),
                trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () async {
                    final productsTemp = await _getProducts();
                    setState(() {
                      _expanded = !_expanded;
                      purchaseProducts = productsTemp;
                    });
                  },
                ),
              ),
              _expanded
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn,
                      height: purchaseProducts.length > 0
                          ? purchaseProducts.length * 20
                          : 20,
                      child: purchaseProducts.length > 0
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                var product = purchaseProducts[index];
                                return Padding(
                                  padding:
                                      EdgeInsets.all(deviceSize.width * 0.01),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(product.name),
                                      Text(
                                          '${product.amount} X \€${product.price.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                );
                              },
                              itemCount: purchaseProducts.length,
                            )
                          : Padding(
                              padding: EdgeInsets.all(deviceSize.width * 0.01),
                              child: Center(child: Text("No Products Details")),
                            ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
