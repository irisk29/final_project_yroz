import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StorePreview extends StatefulWidget {
  final String title;
  final String address;
  final XFile? image;
  final String phoneNumber;
  final Map<String, List<TimeOfDay>> operationHours;

  StorePreview(this.title, this.address, this.image, this.phoneNumber,
      this.operationHours);

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

  String mapAsString(BuildContext context) {
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
    return FutureBuilder<Uint8List>(
        future: widget.image == null
            ? null
            : File(widget.image!.path).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.connectionState == ConnectionState.none) {
            final imgBytes = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
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
                                content: Text(mapAsString(context)),
                              ));
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
                      Icons.phone,
                      color: Colors.grey,
                    ),
                    title: Text(widget.phoneNumber),
                    onTap: () {
                      //open change language
                    },
                  ),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
