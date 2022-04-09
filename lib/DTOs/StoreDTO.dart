import 'dart:io';

import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicModels/OpeningTimes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StoreDTO {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Openings operationHours;
  String? image; //url for the imageFromPhone in s3
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
