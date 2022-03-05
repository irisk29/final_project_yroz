import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

class OnlineStoreScreen extends StatefulWidget {
  static const routeName = '/online-store';

  String title = "";
  String address = "";
  MemoryImage? image = null;
  String phoneNumber = "";
  Map<String, List<TimeOfDay>> operationHours = {};

  @override
  _OnlineStoreScreenState createState() => _OnlineStoreScreenState();

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

class _OnlineStoreScreenState extends State<OnlineStoreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final routeArgs =
    ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    widget.title = routeArgs['title'] as String;
    widget.address = routeArgs['address'] as String;
    widget.image = routeArgs['image'] as MemoryImage;
    widget.phoneNumber = routeArgs['phoneNumber'] as String;
    Object? abc = routeArgs['operationHours'];
    if(abc!=null)
      widget.operationHours = abc as Map<String,List<TimeOfDay>>;
    super.didChangeDependencies();
  }

  String mapAsString(){
    String map = "";
    for(MapEntry<String,List<TimeOfDay>> e in widget.operationHours.entries){
      map = map + e.key + ": ";
      for(int i = 0; i<e.value.length; i++){
        map = map + e.value[i].format(context) + " ";
        if (i==0)
          map = map + "- ";
      }
      map = map + '\n';
    }
    return map;
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
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: new DecorationImage(
                      fit: BoxFit.cover, image: widget.image!),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "About the store",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
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
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Opening hours'),
                      content: Text(mapAsString()),
                    )
                );
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
              title: Text(
                "www.mooo.com",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              onTap: () {
                //open change language
              },
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              title: Text(widget.phoneNumber),
              onTap: () {
                //open change language
              },
            ),
            ListTile(
              title: Text(
                "Products:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
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
