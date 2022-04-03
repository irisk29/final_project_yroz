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
    final deviceSize = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      height: _expanded
          ? (purchaseProducts.length * 30) + deviceSize.height * 0.14
          : deviceSize.height * 0.14,
      child: Card(
        margin: EdgeInsets.all(deviceSize.width * 0.025),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              title: Text(
                  '\€${widget.purchase.cashBackAmount + widget.purchase.creditAmount}'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                  .format(widget.purchase.purchaseDate)),
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
                    height: purchaseProducts.length * 30,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var product = purchaseProducts[index];
                        return Padding(
                          padding: EdgeInsets.all(deviceSize.width * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(product.name),
                              Text('${product.amount} X \€${product.price}'),
                            ],
                          ),
                        );
                      },
                      itemCount: purchaseProducts.length,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
