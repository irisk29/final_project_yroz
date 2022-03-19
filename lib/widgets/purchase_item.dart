import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/PurchaseHistoryDTO.dart';
import 'package:final_project_yroz/DataLayer/PurchaseStorageProxy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPurchaseItem extends StatefulWidget {
  final PurchaseHistoryDTO purchase;

  const HistoryPurchaseItem(this.purchase);

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      height: _expanded ? (purchaseProducts.length * 30) + 95 : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(
                  '\€${widget.purchase.cashBackAmount + widget.purchase.cashBackAmount}'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                  .format(widget.purchase.purchaseDate)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            _expanded
                ? FutureBuilder(
                    future: _getProducts(),
                    builder: (BuildContext context, AsyncSnapshot snap) {
                      return snap.connectionState != ConnectionState.done
                          ? Center(child: CircularProgressIndicator())
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeIn,
                              height: purchaseProducts.length * 30,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  var product = purchaseProducts[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(product.name),
                                        Text(
                                            '${product.amount}X \€${product.price}'),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: purchaseProducts.length,
                              ),
                            );
                    })
                : Container(),
          ],
        ),
      ),
    );
  }
}
