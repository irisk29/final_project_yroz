import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'StoreDTO.dart';

class OnlineStoreDTO extends StoreDTO {
  List<ProductDTO> products;

  OnlineStoreDTO(
      String id,
      String name,
      String address,
      String phoneNumber,
      List<String> categories,
      Map<String, List<TimeOfDay>> operationHours,
      String? image,
      List<ProductDTO> products)
      : this.products = products,
        super(id, name, phoneNumber, address, categories, operationHours, image) {}

}