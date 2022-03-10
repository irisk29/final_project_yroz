import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

class OnlineStoreProductsScreen extends StatefulWidget {
  static const routeName = '/online-store-products';

  late OnlineStoreDTO store;
  late User user;

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
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as OnlineStoreDTO;
    widget.user = routeArgs['user'] as User;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "" + widget.store.name,
        ),
        actions: [
          Badge(
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
            value: widget.user.bagInStores.where((element) => element.onlineStoreID == widget.store.id).first.products.length.toString(),
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
                  widget.store.products
                      .map(
                        (storeData) =>
                            ProductItem(storeData, widget.user, widget.store.id),
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
