import 'dart:io';

import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:flutter/material.dart';

import 'StoreDTO.dart';

class OnlineStoreDTO extends StoreDTO {
  List<ProductDTO> products;

  OnlineStoreDTO(
      {required String id,
      required String name,
      required String address,
      required String phoneNumber,
      required List<String> categories,
      required Map<String, List<TimeOfDay>> operationHours,
      String? image,
      required List<ProductDTO> products,
      String? qrCode,
      File? imageFromPhone})
      : this.products = products,
        super(
            id: id,
            name: name,
            phoneNumber: phoneNumber,
            address: address,
            categories: categories,
            operationHours: operationHours,
            image: image,
            qrCode: qrCode,
            imageFromPhone: imageFromPhone) {}

  void addProduct(ProductDTO product) {
    this.products.add(product);
  }

  void removeProduct(ProductDTO product) {
    this.products.removeWhere((element) => element.name==product.name && element.price==product.price && element.description==product.description);
    ;
  }

  @override
  bool operator ==(other) {
    if (other is OnlineStoreDTO) return this.id == other.id;
    return false;
  }
}
