import 'package:collection/src/iterable_extensions.dart';

import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/physical-store';

  late StoreDTO store;

  @override
  _PhysicalStoreScreenState createState() => _PhysicalStoreScreenState();
}

class _PhysicalStoreScreenState extends State<PhysicalStoreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as StoreDTO;
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
                        .addFavoriteStore(widget.store.id, false)
                    : await Provider.of<User>(context, listen: false)
                        .removeFavoriteStore(widget.store.id, false);
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
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.5,
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: const EdgeInsets.all(10),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 10,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                    text: 'No Expiration Date',
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
          ],
        ),
      ),
    );
  }
}
