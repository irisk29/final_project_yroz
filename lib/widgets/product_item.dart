import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  //final String id;
  final ProductDTO product;
  final User user;
  final String storeID;

  final myController = TextEditingController();

  ProductItem(this.product, this.user, this.storeID);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
              icon: user.favoriteProducts.contains(product.id) ? Icon(
                Icons.favorite,
              ) : Icon(
                Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                user.favoriteProducts.contains(product.id) ? await user.addFavoriteProduct(product.id)
                : await user.removeFavoriteProduct(product.id);
                //product.toggleFavoriteStatus(auth.token!, auth.userId!);
              },
          ),
          title: Text(
            product.name,
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
                          user.addProductToShoppingBag(product, quantity, storeID);
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
                                  user.removeProductFromShoppingBag(product, storeID);
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
