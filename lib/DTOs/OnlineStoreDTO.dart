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
      required List<ProductDTO> products})
      : this.products = products,
        super(id, name, phoneNumber, address, categories, operationHours,
            image) {}

  void addProduct(ProductDTO product) {
    this.products.add(product);
  }
}
