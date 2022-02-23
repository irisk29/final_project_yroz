import 'package:flutter/foundation.dart';

class PhysicalStore with ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<int, DateTime> operationHours;
  String qrCode;
  String? image;

  PhysicalStore(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address,
      required this.categories,
      required this.operationHours,
      required this.qrCode,
      this.image});
}
