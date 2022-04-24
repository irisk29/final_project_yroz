import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/src/iterable_extensions.dart';

import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/favorite_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../LogicModels/OpeningTimes.dart';
import '../LogicModels/place.dart';
import '../models/UserModel.dart';

class PhysicalStoreScreen extends StatefulWidget {
  static const routeName = '/physical-store';

  late StoreDTO store;

  @override
  _PhysicalStoreScreenState createState() => _PhysicalStoreScreenState();

  //for test purposes
  Widget wrapWithMaterial(
      List<NavigatorObserver> nav, UserModel user, Map<String, Object> args) {
    args.toString();
    return MaterialApp(
      routes: {
        TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
        FavoriteScreen.routeName: (ctx) => FavoriteScreen()
      },
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: User.fromModel(user),
          ),
        ],
        child: this,
      ),
      // This mocked observer will now receive all navigation events
      // that happen in our app.
      //navigatorObservers: nav,
    );
  }
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
        if (e.closed) return 2;
        TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now());
        if (opBigger(time, e.operationHours.item1) &&
            opSmaller(time, e.operationHours.item2)) {
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
      if (e.closed)
        map = map + "Closed";
      else {
        map = map +
            e.operationHours.item1.format(context) +
            " - " +
            e.operationHours.item2.format(context);
      }
      map = map + '\n';
    }
    return map;
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
              child: widget.store.image != null
                  ? CachedNetworkImage(
                      imageUrl: widget.store.image!,
                      imageBuilder: (context, imageProvider) => Container(
                        height: deviceSize.height * 0.35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        height: deviceSize.height * 0.35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/placeholder-image.png'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: deviceSize.height * 0.35,
                        child: FittedBox(
                            fit: BoxFit.fill,
                            child: Center(
                                child: Icon(Icons.error_outline,
                                    color: Theme.of(context).errorColor))),
                      ),
                    )
                  : Container(
                      height: deviceSize.height * 0.35,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/images/default-store.png'),
                            fit: BoxFit.cover),
                      ),
                    ),
            ),
            ListTile(
              key: const Key("favorite"),
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
              onTap: () async {
                Secret secret = await SecretLoader(secretPath: "assets/secrets.json").load();
                var googleGeocoding = GoogleGeocoding(secret.API_KEY);
                GeocodingResponse? address = await googleGeocoding.geocoding.get(widget.store.address, []);
                if(address!=null) {
                  Place place = Place.fromStore(
                      widget.store.name, address, widget.store.address);
                  String dest_lat = place.geometry.location.lat.toString();
                  String dest_lng = place.geometry.location.lng.toString();
                  MapsLauncher.launchCoordinates(
                      double.parse(dest_lat), double.parse(dest_lng));
                }
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
          ],
        ),
      ),
    );
  }
}
