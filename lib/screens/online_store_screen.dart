import 'package:flutter/material.dart';
import '../screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

class OnlineStoreScreen extends StatefulWidget {
  static const routeName = '/online-store';

  String title = "";
  String address = "";
  String image = "";

  @override
  _OnlineStoreScreenState createState() => _OnlineStoreScreenState();

  Widget wrapWithMaterial() => MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Products("","",[]),
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

class _OnlineStoreScreenState extends State<OnlineStoreScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    if(routeArgs!=null){
      widget.title = routeArgs['title'];
      widget.address = routeArgs['address'];
      widget.image = routeArgs['image'];
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("" + widget.title, ),
        actions: [
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
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
            Center(
              child: widget.image!="" ? Image.asset(widget.image) : null,
            ),
            ListTile(
              title: Text("About the store", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              onTap: () {
                //open change language
              },
              trailing: Icon(
                Icons.favorite_border,
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.circle,
                color: Colors.green,
              ),
              title: Text("Open Now"),
              onTap: () {
                //open change language
              },
            ),
            ListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              title: Text(widget.address),
              onTap: () {
                //open change location
              },
            ),
            ListTile(
              leading: Icon(
                Icons.language,
                color: Colors.grey,
              ),
              title: Text("www.mooo.com", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),),
              onTap: () {
                //open change language
              },
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              title: Text("+44 345 3366"),
              onTap: () {
                //open change language
              },
            ),
            ListTile(
              title: Text("Products", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              onTap: () {
                //open change language
              },
            ),
            ProductsGrid(false),
          ],
        ),
      ),
    );
  }
}
