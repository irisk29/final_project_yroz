import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_demo/DTOs/StroreDTO.dart';
import 'package:http/http.dart' as http;

class PhysicalStoreDTO extends StoreDTO {
  String qrCode;
  MemoryImage imageFile = null;

  PhysicalStoreDTO(
      String name,
      String address,
      String phoneNumber,
      List<String> categories,
      Map<int, DateTime> operationHours,
      String image,
      String qrCode)
      : super(name, phoneNumber, address, categories, operationHours, image) {
    this.qrCode = qrCode;
  }

  Future<void> initImageFile() async {
    var res = await http.get(Uri.parse(this.image));
    imageFile = MemoryImage(res.bodyBytes, scale: 0.5);
  }
}
