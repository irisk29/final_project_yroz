import 'dart:io';
import 'dart:ui';

import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/physical-store';

  late StoreDTO store;
  //late User user;

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
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    widget.store = routeArgs['store'] as StoreDTO;
    //widget.user = routeArgs['user'] as User;
    super.didChangeDependencies();
  }

  String mapAsString() {
    String map = "";
    for (MapEntry<String, List<TimeOfDay>> e in widget.store.operationHours.entries) {
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
    for (MapEntry<String, List<TimeOfDay>> e in widget.store.operationHours.entries) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "" + widget.store.name,
        ),
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
                      ? DecorationImage(fit: BoxFit.cover, image: widget.store.imageFile!)
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
                Provider.of<User>(context, listen: false).favoriteStores.contains(widget.store.id) ? await Provider.of<User>(context, listen: false).removeFavoriteStore(widget.store.id, false)
                    : await Provider.of<User>(context, listen: false).addFavoriteStore(widget.store.id, false);
                setState(() {

                });
                //open change language
              },
              trailing: Provider.of<User>(context, listen: false).favoriteStores.contains(widget.store.id) ? Icon(
                Icons.favorite,
                color: Colors.black,
              ) : Icon(
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
             Image.file(
              File(widget.store.qrCode!),
              width: 150,
              height: 150,
              fit: BoxFit.fill,
            )
          ],
        ),
      ),
    );
  }
}
