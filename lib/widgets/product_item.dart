import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatefulWidget {
  final ProductDTO product;
  final User user;
  final String storeID;

  ProductItem(this.product, this.user, this.storeID);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: widget.product,
            );
          },
          child: Image.network(
            widget.product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
              icon: widget.user.favoriteProducts.contains(widget.product.id) ? Icon(
                Icons.favorite,
              ) : Icon(
                Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                widget.user.favoriteProducts.contains(widget.product.id) ? await widget.user.removeFavoriteProduct(widget.product.id)
                : await widget.user.addFavoriteProduct(widget.product.id);
                setState(() {

                });
                //product.toggleFavoriteStatus(auth.token!, auth.userId!);
              },
          ),
          title: Text(
            widget.product.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
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
                          widget.user.addProductToShoppingBag(widget.product, quantity, widget.storeID);
                          //cart.addItem(product.id, product.price, product.title);
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added item to cart!',
                              ),
                              duration: Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  widget.user.removeProductFromShoppingBag(widget.product, widget.storeID);
                                  //cart.removeSingleItem(product.id);
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
                  ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
