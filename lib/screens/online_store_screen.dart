import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/online_store_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../LogicModels/OpeningTimes.dart';

class OnlineStoreScreen extends StatefulWidget {
  static const routeName = '/online-store';

  late OnlineStoreDTO store;

  @override
  _OnlineStoreScreenState createState() => _OnlineStoreScreenState();
}

class _OnlineStoreScreenState extends State<OnlineStoreScreen> {
  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as OnlineStoreDTO;
    super.didChangeDependencies();
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
    for (OpeningTimes e in widget.store.operationHours.days) {
      if (e.day.toLowerCase() == day) {
        if(e.closed)
          return 2;
        TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now());
        if (opBigger(time, e.operationHours.item1) && opSmaller(time, e.operationHours.item2)) {
          if (lessthanfifteen(e.operationHours.item2, time)) {
            return 1;
          }
          return 0;
        }
        return 2;
      }
    }
    return 2;
  }

  String mapAsString() {
    String map = "";
    for (OpeningTimes e in widget.store.operationHours.days) {
      map = map + e.day + ": ";
      if(e.closed)
        map = map + "closed";
      else {
        map = map + e.operationHours.item1.format(context) + " - " + e.operationHours.item2.format(context);
      }
      map = map + '\n';
    }
    return map;
  }

  void routeToOnlineStoreProducts(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      OnlineStoreProductsScreen.routeName,
      arguments: {'store': widget.store},
    );
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                height: deviceSize.height * 0.35,
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
                      color: Colors.red,
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
            ListTile(
              title: Text(
                "Promotions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: null,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: deviceSize.width * 0.02,
                  right: deviceSize.width * 0.02),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.5,
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: EdgeInsets.all(deviceSize.width * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cashback",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text.rich(
                            TextSpan(
                              children: <InlineSpan>[
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 10,
                                  ),
                                ),
                                TextSpan(
                                    text: ' No Expiration Date',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(
                        "7%",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Shop now",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: null,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: deviceSize.width * 0.02,
                  right: deviceSize.width * 0.02,
                  bottom: deviceSize.width * 0.02),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.5,
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  title: Text(
                    "Visit Our Online Shop",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () => routeToOnlineStoreProducts(context),
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
