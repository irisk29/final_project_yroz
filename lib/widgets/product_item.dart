import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DTOs/ProductDTO.dart';
import '../LogicLayer/User.dart';

class ProductItem extends StatefulWidget {
  final ProductDTO product;
  final String storeID;

  ProductItem(this.product, this.storeID);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final myController = TextEditingController();

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Card(
          semanticContainer: true,
          elevation: 2,
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.03,
            vertical: constraints.maxHeight * 0.025,
          ),
          shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 0.5,
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: constraints.maxWidth * 0.04,
                    top: constraints.maxHeight * 0.075,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      widget.product.description != null
                          ? Text(widget.product.description!,
                              style: TextStyle(color: Colors.black54))
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\€${widget.product.price}',
                              style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add_shopping_cart),
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.all(0),
                            onPressed: () async {
                              double quantity = 0;
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Select quantity'),
                                  content: TextField(
                                    controller: myController,
                                    keyboardType: TextInputType.number,
                                  ),
                                  actions: [
                                    FlatButton(
                                      child: Text('Okay'),
                                      onPressed: () {
                                        quantity =
                                            double.parse(myController.text);
                                        Navigator.of(context).pop();
                                        user.updateOrCreateCartProduct(
                                            widget.product,
                                            widget.storeID,
                                            quantity);
                                        Scaffold.of(context)
                                            .hideCurrentSnackBar();
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Added item to cart!',
                                            ),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: constraints.maxWidth * 0.05,
                      top: constraints.maxHeight * 0.06,
                      bottom: constraints.maxHeight * 0.06),
                  child: FittedBox(
                    child: Container(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: widget.product.imageUrl != null &&
                                widget.product.imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.product.imageUrl!),
                                fit: BoxFit.cover)
                            : DecorationImage(
                                image: AssetImage(
                                    'assets/images/default_product.png'),
                                fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
