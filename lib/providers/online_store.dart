import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OnlineStore with ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<String, List<TimeOfDay>> operationHours;
  File? image;

  OnlineStore(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address,
      required this.categories,
      required this.operationHours,
      this.image});
}
