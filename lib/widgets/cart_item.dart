import 'package:final_project_yroz/DTOs/CartProductDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem extends StatefulWidget {
  final CartProductDTO? product;
  final String storeID;
  final void Function() update;

  late double price;
  late String title;
  late double quantity;

  CartItem(this.product, this.storeID, this.update) {
    price = product!.price;
    quantity = product!.amount;
    title = product!.name;
  }

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) => Dismissible(
        key: UniqueKey(),
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
            horizontal: deviceSize.width * 0.03,
            vertical: deviceSize.height * 0.025,
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
          await Provider.of<User>(context, listen: false)
              .removeProductFromShoppingBag(
                  widget.product!.cartID, widget.storeID);
          setState(() {
            () => widget.update();
          });
          Navigator.pushReplacementNamed(context, CartScreen.routeName,
              arguments: {'store': widget.storeID});
        },
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: deviceSize.width * 0.03,
            vertical: deviceSize.height * 0.01,
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: deviceSize.height * 0.01,
                bottom: deviceSize.height * 0.005),
            child: ListTile(
              leading: CircleAvatar(
                radius: deviceSize.width * 0.06,
                child: Padding(
                  padding: EdgeInsets.all(deviceSize.width * 0.01),
                  child: FittedBox(
                    child: Text('\€${widget.price * widget.quantity}'),
                  ),
                ),
              ),
              title: Text(widget.title),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Price: \€${(widget.price)}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          user.decreaseProductQuantityLocally(
                              widget.storeID, widget.product!.cartID);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        onPressed: () {
                          user.addProductToShoppingBagLocally(
                              widget.storeID, widget.product!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Text('X ${widget.quantity %1 == 0 ? widget.quantity.toInt() : widget.quantity.toStringAsFixed(2)}'),
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
                              onPressed: () async {
                                quantity = double.parse(myController.text);
                                Navigator.of(context).pop();
                                // await Provider.of<User>(context, listen: false).updateProductQuantityInBag(widget.product!, widget.storeID, quantity);
                                // setState(() {
                                //   widget.quantity = quantity;
                                //       () => widget.update();
                                // });
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
      ),
    );
  }
}
