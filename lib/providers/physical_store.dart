import 'package:final_project_yroz/DTOs/PhysicalStoreDTO.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhysicalStore with ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<String, List<TimeOfDay>> operationHours;
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

  PhysicalStoreDTO createDTO() {
    return PhysicalStoreDTO(id: id, name: name, address: address, phoneNumber: phoneNumber, categories: categories, operationHours: operationHours, image: image, qrCode: qrCode);
  }
}