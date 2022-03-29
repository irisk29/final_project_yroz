import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/online_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  late String storeID;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.storeID = routeArgs['store'] as String;
  }

  void _update() {
    setState(() {
      //build(context);
      //widget.cart = widget.user.bagInStores.length > 0 ? widget.user.bagInStores.where((element) => element.onlineStoreID == widget.store.id).first : ShoppingBagDTO(widget.user.id!, widget.store.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<User>(context, listen: true);
    var deviceSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        provider.saveShoppingBag(widget.storeID);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Cart',
            style: const TextStyle(fontSize: 22),
          ),
          toolbarHeight: deviceSize.height * 0.1,
        ),
        body: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\€${provider.getShoppingBag(widget.storeID) != null ? provider.getShoppingBag(widget.storeID)!.calculateTotalPrice().toStringAsFixed(2) : 0.toStringAsFixed(2)}',
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    OrderButton(cart: provider.getShoppingBag(widget.storeID)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: provider.getShoppingBag(widget.storeID) != null
                    ? provider.getShoppingBag(widget.storeID)!.products.length
                    : 0,
                itemBuilder: (ctx, i) => CartItem(
                    provider
                        .getShoppingBag(widget.storeID)!
                        .products
                        .toList()[i],
                    widget.storeID,
                    _update),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final ShoppingBagDTO? cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cart == null)
          ? null
          : (widget.cart!.calculateTotalPrice() <= 0 || _isLoading)
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  Provider.of<User>(context, listen: false)
                      .saveShoppingBag(widget.cart!.onlineStoreID);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) =>
                              OnlinePaymentScreen(widget.cart!.onlineStoreID)));
                  setState(() {
                    _isLoading = false;
                  });
                },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
