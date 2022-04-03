import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StorePreview extends StatefulWidget {
  final bool isOnlineStore;
  final String title;
  final String address;
  final XFile? image;
  final String phoneNumber;
  final Map<String, List<TimeOfDay>> operationHours;

  StorePreview(this.isOnlineStore, this.title, this.address, this.image,
      this.phoneNumber, this.operationHours);

  @override
  _StorePreviewState createState() => _StorePreviewState();
}

class _StorePreviewState extends State<StorePreview> {
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
    for (MapEntry<String, List<TimeOfDay>> e in widget.operationHours.entries) {
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

  String mapAsString() {
    String map = "";
    for (MapEntry<String, List<TimeOfDay>> e in widget.operationHours.entries) {
      map = map + e.key + ": ";
      for (int i = 0; i < e.value.length; i++) {
        map = map + e.value[i].format(context) + " ";
        if (i == 0) map = map + "- ";
      }
      map = map + '\n';
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return FutureBuilder<Uint8List>(
      future:
          widget.image == null ? null : File(widget.image!.path).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done ||
            snapshot.connectionState == ConnectionState.none) {
          final imgBytes = snapshot.data;
          return Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      height: deviceSize.height * 0.3,
                      decoration: BoxDecoration(
                        image: imgBytes != null
                            ? DecorationImage(
                                fit: BoxFit.cover, image: MemoryImage(imgBytes))
                            : DecorationImage(
                                image: AssetImage(
                                    'assets/images/default-store.png'),
                                fit: BoxFit.cover),
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
                    trailing: Icon(
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
                    title: Text(widget.address),
                    onTap: null,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone,
                      color: Colors.grey,
                    ),
                    title: Text(widget.phoneNumber),
                    onTap: null,
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
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
