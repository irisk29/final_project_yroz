import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/online_store_products_screen.dart';
import 'package:final_project_yroz/widgets/badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';

class OnlineStoreScreen extends StatefulWidget {
  static const routeName = '/online-store';

  late OnlineStoreDTO store;
  //late User user;

  @override
  _OnlineStoreScreenState createState() => _OnlineStoreScreenState();
}

class _OnlineStoreScreenState extends State<OnlineStoreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as OnlineStoreDTO;
    //widget.user = routeArgs['user'] as User;
    super.didChangeDependencies();
  }

  String mapAsString() {
    String map = "";
    for (MapEntry<String, List<TimeOfDay>> e
        in widget.store.operationHours.entries) {
      map = map + e.key + ": ";
      for (int i = 0; i < e.value.length; i++) {
        map = map + e.value[i].format(context) + " ";
        if (i == 0) map = map + "- ";
      }
      map = map + '\n';
    }
    return map;
  }

  bool lessthanfifteen(TimeOfDay a, TimeOfDay b) {
    if (a.hour == b.hour && (a.minute - b.minute) < 15) return true;
    if (a.hour - b.hour == 1 && (60 + a.minute - b.minute) < 15) return true;
    return false;
  }

  bool opBigger(TimeOfDay me, TimeOfDay other) {
    return other.hour < me.hour ||
        other.hour == me.hour && other.minute < me.minute;
  }

  bool opSmaller(TimeOfDay me, TimeOfDay other) {
    return other.hour > me.hour ||
        other.hour == me.hour && other.minute > me.minute;
  }

  int isStoreOpen() {
    String day = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    //String hour = DateFormat('Hm').format(DateTime.now());
    for (MapEntry<String, List<TimeOfDay>> e
        in widget.store.operationHours.entries) {
      if (e.key == day) {
        TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now());
        if (opBigger(time, e.value[0]) && opSmaller(time, e.value[1])) {
          if (lessthanfifteen(e.value[1], time)) {
            return 1;
          }
          return 0;
        }
        return 2;
      }
    }
    return 2;
  }

  void routeToOnlineStoreProducts(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      OnlineStoreProductsScreen.routeName,
      arguments: {'store': widget.store},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.store.name,
        ),
        actions: [
          Badge(
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName,
                    arguments: {'store': widget.store.id});
              },
            ),
            value:
                Provider.of<User>(context, listen: false).bagInStores.length > 0
                    ? Provider.of<User>(context, listen: false)
                        .bagInStores
                        .where((element) =>
                            element.onlineStoreID == widget.store.id)
                        .first
                        .products
                        .length
                        .toString()
                    : 0.toString(),
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
                  image: widget.store.image != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.store.image!))
                      : DecorationImage(
                          image: AssetImage('assets/images/default-store.png'),
                          fit: BoxFit.cover),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "About the store",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: () async {
                Provider.of<User>(context, listen: false)
                            .favoriteStores
                            .firstWhereOrNull(
                                (e) => e.item1 == widget.store.id) ==
                        null
                    ? await Provider.of<User>(context, listen: false)
                        .addFavoriteStore(widget.store.id, true)
                    : await Provider.of<User>(context, listen: false)
                        .removeFavoriteStore(widget.store.id, true);
                setState(() {});
                //open change language
              },
              trailing: Provider.of<User>(context, listen: false)
                          .favoriteStores
                          .firstWhereOrNull(
                              (e) => e.item1 == widget.store.id) !=
                      null
                  ? Icon(
                      Icons.favorite,
                      color: Colors.black,
                    )
                  : Icon(
                      Icons.favorite_border,
                      color: Colors.black,
                    ),
            ),
            ListTile(
              leading: Icon(
                Icons.circle,
                color: isStoreOpen() == 0
                    ? Colors.green
                    : isStoreOpen() == 1
                        ? Colors.orange
                        : Colors.red,
              ),
              title: isStoreOpen() == 0
                  ? Text("Open Now")
                  : isStoreOpen() == 1
                      ? Text("Closing Soon")
                      : Text("Closed"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text('Opening hours'),
                          content: Text(mapAsString()),
                        ));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              title: Text(widget.store.address),
              onTap: () {
                //open change location
              },
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              title: Text(widget.store.phoneNumber),
              onTap: () {
                //open change language
              },
            ),
            ElevatedButton(
              onPressed: () => routeToOnlineStoreProducts(context),
              child: Text('Online Store Shop'),
            ),
          ],
        ),
      ),
    );
  }
}
