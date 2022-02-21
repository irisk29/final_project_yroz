import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:project_demo/LogicLayer/Categories.dart';

class OnlineStore with ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<int, DateTime> operationHours;
  File image;

  OnlineStore(
      @required this.name,
      @required this.phoneNumber,
      @required this.address,
      @required this.categories,
      @required this.operationHours);
}
