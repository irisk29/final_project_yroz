import 'dart:io';

import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/providers/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OnlineStore with ChangeNotifier {
  String id;
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<String, List<TimeOfDay>> operationHours;
  String? image;
  List<Product> products;

  OnlineStore(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.address,
      required this.categories,
      required this.operationHours,
      this.image,
      required this.products});

  StoreDTO createDTO() {
    return StoreDTO(id, name, phoneNumber, address, categories, operationHours, image);
  }

  void addProduct(Product product) {
    this.products.add(product);
  }
}
