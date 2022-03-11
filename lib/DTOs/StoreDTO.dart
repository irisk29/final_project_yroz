import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StoreDTO {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<String, List<TimeOfDay>> operationHours;
  String? image;
  String? qrCode;
  File? imageFromPhone;

  StoreDTO(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address,
      required this.categories,
      required this.operationHours,
      this.image,
      this.qrCode,
      this.imageFromPhone});


  @override
  bool operator ==(other) {
    if (other is StoreDTO) return this.id == other.id;
    return false;
  }
}
