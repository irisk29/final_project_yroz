import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';
import '../widgets/product_item.dart';
import './cart_screen.dart';

class OnlineStoreProductsScreen extends StatefulWidget {
  static const routeName = '/online-store-products';

  late OnlineStoreDTO store;

  @override
  _OnlineStoreProductsScreenState createState() =>
      _OnlineStoreProductsScreenState();
}

class _OnlineStoreProductsScreenState extends State<OnlineStoreProductsScreen> {
  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as OnlineStoreDTO;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: true);
    final shoppingBag = user.getShoppingBag(widget.store.id);
    final productsAmount =
        shoppingBag != null ? shoppingBag.bagSize().toInt() : 0;
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceSize.height * 0.1,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.store.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.store.categories.join(", "),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          productsAmount > 0
              ? Badge(
                  child: IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName,
                          arguments: {'store': widget.store.id});
                    },
                  ),
                  value: productsAmount > 9 ? "9+" : productsAmount.toString(),
                )
              : IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName,
                        arguments: {'store': widget.store.id});
                  },
                ),
        ],
      ),
      body: widget.store.products.length > 0
          ? SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Products:",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top) *
                        0.8,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      crossAxisCount: 1,
                      childAspectRatio: 3.5,
                      mainAxisSpacing: deviceSize.height * 0.01,
                      crossAxisSpacing: deviceSize.width * 0.025,
                      children: widget.store.products
                          .map(
                            (storeData) =>
                                ProductItem(storeData, widget.store.id),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("This store does not offer any products for sale",
                      textAlign: TextAlign.center),
                ],
              ),
            ),
    );
  }
}
