import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:final_project_yroz/widgets/store_products_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../DTOs/ProductDTO.dart';
import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../LogicModels/place.dart';

class StorePreview extends StatefulWidget {
  final bool isOnlineStore;
  final String title;
  final String address;
  final XFile? imageFromPhone;
  final String? imageUrl;
  final String phoneNumber;
  final Openings operationHours;
  final List<ProductDTO>? products;

  StorePreview(
      this.isOnlineStore,
      this.title,
      this.address,
      this.imageFromPhone,
      this.imageUrl,
      this.phoneNumber,
      this.operationHours,
      this.products);

  @override
  _StorePreviewState createState() => _StorePreviewState();
}

class _StorePreviewState extends State<StorePreview> {
  var _productsMode = false;

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
    for (OpeningTimes e in widget.operationHours.days) {
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
    for (OpeningTimes e in widget.operationHours.days) {
      map = map + e.day + ": ";
      if (e.closed)
        map = map + "closed";
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

    return _productsMode
        ? StoreProductsPreview(
            widget.products!, () => setState(() => _productsMode = false))
        : Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      height: deviceSize.height * 0.3,
                      child: widget.imageFromPhone != null
                          ? Container(
                              height: deviceSize.height * 0.3,
                              width: double.infinity,
                              child: Image.file(
                                  File(widget.imageFromPhone!.path),
                                  fit: BoxFit.cover),
                            )
                          : widget.imageFromPhone == null &&
                                  widget.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.imageUrl!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: deviceSize.height * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(
                                    height: deviceSize.height * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/placeholder-image.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: deviceSize.height * 0.35,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Center(
                                          child: Icon(Icons.error_outline,
                                              color: Theme.of(context)
                                                  .errorColor)),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: deviceSize.height * 0.3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/default-store.png'),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "About the store",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    onTap: null,
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
                    title: Text(widget.address),
                    onTap: () async {
                      Secret secret =
                          await SecretLoader(secretPath: "assets/secrets.json")
                              .load();
                      var googleGeocoding = GoogleGeocoding(secret.API_KEY);
                      GeocodingResponse? address = await googleGeocoding
                          .geocoding
                          .get(widget.address, []);
                      if (address != null) {
                        Place place = Place.fromStore(
                            widget.title, address, widget.address);
                        String dest_lat =
                            place.geometry.location.lat.toString();
                        String dest_lng =
                            place.geometry.location.lng.toString();
                        if (!Platform.isIOS) {
                          MapsLauncher.launchCoordinates(
                              double.parse(dest_lat), double.parse(dest_lng));
                        } else {
                          MapsLauncher.launchQuery(place.address);
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone,
                      color: Colors.grey,
                    ),
                    title: Text(widget.phoneNumber),
                    onTap: () {
                      launch("tel://${widget.phoneNumber}");
                      //open change language
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Promotions",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                  if (widget.isOnlineStore)
                    Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Shop now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
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
                              onTap: () => setState(() => _productsMode = true),
                              trailing: Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
  }
}
