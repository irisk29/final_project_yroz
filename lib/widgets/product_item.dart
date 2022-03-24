// import 'package:final_project_yroz/DTOs/ProductDTO.dart';
// import 'package:final_project_yroz/LogicLayer/User.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../screens/product_detail_screen.dart';

// class ProductItem extends StatefulWidget {
//   final ProductDTO product;
//   final String storeID;

//   ProductItem(this.product, this.storeID);

//   @override
//   State<ProductItem> createState() => _ProductItemState();
// }

// class _ProductItemState extends State<ProductItem> {
//   final myController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: GridTile(
//         child: GestureDetector(
//             onTap: () {
//               Navigator.of(context).pushNamed(
//                 ProductDetailScreen.routeName,
//                 arguments: widget.product,
//               );
//             },
//             child: Positioned(
//                 child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 image: widget.product.imageUrl != null
//                     ? DecorationImage(
//                         image: NetworkImage(widget.product.imageUrl!),
//                         fit: BoxFit.cover)
//                     : DecorationImage(
//                         image: AssetImage('assets/images/default_product.png'),
//                         fit: BoxFit.cover),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ))),
//         footer: GridTileBar(
//           backgroundColor: Colors.black87,
//           title: Text(
//             widget.product.name,
//             textAlign: TextAlign.center,
//           ),
//           trailing: IconButton(
//             icon: Icon(
//               Icons.shopping_cart,
//             ),
//             onPressed: () async {
//               double quantity = 0;
//               await showDialog(
//                   context: context,
//                   builder: (_) => AlertDialog(
//                         title: Text('Select quantity'),
//                         content: TextField(
//                           controller: myController,
//                           keyboardType: TextInputType.number,
//                         ),
//                         actions: [
//                           FlatButton(
//                             child: Text('Okay'),
//                             onPressed: () {
//                               quantity = double.parse(myController.text);
//                               Navigator.of(context).pop();
//                               Provider.of<User>(context, listen: false)
//                                   .addProductToShoppingBag(
//                                       widget.product, quantity, widget.storeID);
//                               //cart.addItem(product.id, product.price, product.title);
//                               Scaffold.of(context).hideCurrentSnackBar();
//                               Scaffold.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     'Added item to cart!',
//                                   ),
//                                   duration: Duration(seconds: 2),
//                                   action: SnackBarAction(
//                                     label: 'UNDO',
//                                     onPressed: () {
//                                       Provider.of<User>(context, listen: false)
//                                           .removeProductFromShoppingBag(
//                                               widget.product, widget.storeID);
//                                       //cart.removeSingleItem(product.id);
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                           FlatButton(
//                             child: Text('Cancel'),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           )
//                         ],
//                       ));
//             },
//             color: Theme.of(context).accentColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    final myController = TextEditingController();

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Card(
          semanticContainer: true,
          elevation: 2,
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
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      widget.product.description != null
                          ? Text(widget.product.description!, style: TextStyle(color: Colors.black54))
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('\€${widget.product.price}'),
                          IconButton(
                            icon: Icon(Icons.add_shopping_cart),
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
                                        quantity = double.parse(myController.text);
                                        Navigator.of(context).pop();
                                        Provider.of<User>(context, listen: false)
                                            .updateOrCreateCartProduct(widget.product, widget.storeID, quantity);
                                        Scaffold.of(context).hideCurrentSnackBar();
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Added item to cart!',
                                            ),
                                            duration: Duration(seconds: 3),
                                            action: SnackBarAction(
                                              label: 'UNDO',
                                              onPressed: () {
                                                // Provider.of<User>(context, listen: false)
                                                //     .removeProductFromShoppingBag(
                                                //         widget.product, widget.storeID);
                                                //TODO: call remove cart item
                                              },
                                            ),
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
                  padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: FittedBox(
                    child: Container(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image:
                            DecorationImage(image: AssetImage('assets/images/default_product.png'), fit: BoxFit.cover),
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
