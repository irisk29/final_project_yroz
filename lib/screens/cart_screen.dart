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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<User>(context, listen: true);
    var deviceSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Cart',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              provider.saveShoppingBag(widget.storeID);
              Navigator.of(context).pop();
            },
          ),
          toolbarHeight: deviceSize.height * 0.1,
        ),
        body: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(deviceSize.height * 0.02),
              child: Padding(
                padding: EdgeInsets.all(deviceSize.height * 0.01),
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
                    () => setState(() {})),
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
