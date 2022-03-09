import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

class OnlineStoreProductsScreen extends StatefulWidget {
  static const routeName = '/online-store-products';

  String title = "";
  List<ProductDTO> products = [];

  @override
  _OnlineStoreProductsScreenState createState() =>
      _OnlineStoreProductsScreenState();

  Widget wrapWithMaterial() => MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Products("", "", []),
            ),
            ChangeNotifierProvider.value(
              value: Cart(),
            ),
          ],
          child: Scaffold(
            body: this,
          ),
        ),
      );
}

class _OnlineStoreProductsScreenState extends State<OnlineStoreProductsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    widget.title = routeArgs['title'] as String;
    Object? def = routeArgs['products'];
    if (def != null) widget.products = def as List<ProductDTO>;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "" + widget.title,
        ),
        actions: [
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              //color: Colors.black,
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(
                "Products:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: () {
                //open change language
              },
            ),
            SizedBox(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top) *
                  0.5,
              child: GridView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(5),
                children: [
                  widget.products
                      .map(
                        (storeData) =>
                            ProductItem(storeData),
                      )
                      .toList(),
                ].expand((i) => i).toList(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
