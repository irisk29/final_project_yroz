import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatefulWidget {
  final ProductDTO product;
  final String storeID;

  ProductItem(this.product, this.storeID);

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
          child: Positioned(
              child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: widget.product.imageUrl.isNotEmpty && widget.product.imageFromPhone != null
                  ? DecorationImage(image: FileImage(widget.product.imageFromPhone!), fit: BoxFit.cover)
                  : DecorationImage(
                      image: AssetImage('assets/images/default_product.png'),
                      fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15),
            ),
          ))
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
              icon: Provider.of<User>(context, listen: false).favoriteProducts.contains(widget.product.id) ? Icon(
                Icons.favorite,
              ) : Icon(
                Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                Provider.of<User>(context, listen: false).favoriteProducts.contains(widget.product.id) ? await Provider.of<User>(context, listen: false).removeFavoriteProduct(widget.product.id)
                : await Provider.of<User>(context, listen: false).addFavoriteProduct(widget.product.id);
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
                          Provider.of<User>(context, listen: false).addProductToShoppingBag(widget.product, quantity, widget.storeID);
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
                                  Provider.of<User>(context, listen: false).removeProductFromShoppingBag(widget.product, widget.storeID);
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
