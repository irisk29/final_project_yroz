import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'StroreDTO.dart';

class PhysicalStoreDTO extends StoreDTO {
  String qrCode;
  MemoryImage? imageFile;

  PhysicalStoreDTO(
      String name,
      String address,
      String phoneNumber,
      List<String> categories,
      Map<String, List<TimeOfDay>> operationHours,
      String? image,
      String qrCode)
      : this.qrCode = qrCode,
        this.imageFile = null,
        super(name, phoneNumber, address, categories, operationHours, image) {}

  Future<void> initImageFile() async {
    if (this.image != null) {
      var res = await http.get(Uri.parse(this.image!));
      imageFile = MemoryImage(res.bodyBytes, scale: 0.5);
    }
  }
}
