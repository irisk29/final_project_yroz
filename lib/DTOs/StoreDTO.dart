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
  MemoryImage? imageFile;

  StoreDTO(this.id, this.name, this.phoneNumber, this.address, this.categories,
      this.operationHours, this.image);

  Future<void> initImageFile() async {
    if (this.image != null) {
      var res = await http.get(Uri.parse(this.image!));
      imageFile = MemoryImage(res.bodyBytes, scale: 0.5);
    }
  }
}
