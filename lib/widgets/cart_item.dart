import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem extends StatefulWidget {
  final CartProductDTO product;
  final String storeID;
  //final User user;
  final void Function() update;

  late double price;
  late String title;
  late double quantity;

  CartItem(
    this.product,
    this.storeID,
    //this.user,
    this.update
  ){
    price = product.price;
    quantity = product.amount;
    title = product.name;
  }

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.product.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Are you sure?'),
                content: Text(
                  'Do you want to remove the item from the cart?',
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) async {
        await Provider.of<User>(context, listen: false).removeProductFromShoppingBag(widget.product, widget.storeID);
        setState(() {
            () => widget.update();
        });
        Navigator.pushReplacementNamed(context, CartScreen.routeName, arguments: {'store': widget.storeID});
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
              leading: CircleAvatar(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text('\$${widget.price}'),
                  ),
                ),
              ),
              title: Text(widget.title),
              subtitle: Text('Total: \$${(widget.price * widget.quantity)}'),
              trailing: Text('${widget.quantity} x'),
              onLongPress: () async {
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
                            Provider.of<User>(context, listen: false).updateProductQuantityInBag(widget.product, widget.storeID, quantity);
                            setState(() {
                              widget.quantity = quantity;
                              () => widget.update();
                            });
                            Navigator.pushReplacementNamed(context, CartScreen.routeName, arguments: {'store': widget.storeID});
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
            ),
        ),
      ),
    );
  }
}
