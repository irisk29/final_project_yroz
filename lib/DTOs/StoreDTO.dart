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
  String? qrCode;

  StoreDTO(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address,
      required this.categories,
      required this.operationHours,
      this.image,
      this.qrCode});

  Future<void> initImageFile() async {
    if (this.image != null) {
      var res = await http.get(Uri.parse(this.image!));
      imageFile = MemoryImage(res.bodyBytes, scale: 0.5);
    }
  }

  @override
  bool operator ==(other) {
    if (other is StoreDTO) return this.id == other.id;
    return false;
  }
}
