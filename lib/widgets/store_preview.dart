import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StorePreview extends StatelessWidget {
  final String title;
  final String address;
  MemoryImage? image;
  final String phoneNumber;
  final Map<String, List<TimeOfDay>> operationHours;

  StorePreview(
      this.title, this.address, img, this.phoneNumber, this.operationHours) {
    fetchImage(img);
  }

  Future<void> fetchImage(img) async {
    print('HIIIII');
    final bytes = await File(img.path).readAsBytes();
    this.image = MemoryImage(bytes);
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
    for (MapEntry<String, List<TimeOfDay>> e in operationHours.entries) {
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
    for (MapEntry<String, List<TimeOfDay>> e in operationHours.entries) {
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: image == null
                ? Text('No Image')
                : Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image:
                          new DecorationImage(fit: BoxFit.cover, image: image!),
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
            title: Text(address),
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
            title: Text(phoneNumber),
            onTap: () {
              //open change language
            },
          ),
        ],
      ),
    );
  }
}
