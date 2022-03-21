import 'dart:io';

import 'package:final_project_yroz/models/ModelProvider.dart';

class ProductDTO {
  String id;
  String name;
  String category;
  double price;
  String? imageUrl;
  String? description;
  String storeID;
  File? imageFromPhone;

  ProductDTO(
      {required this.id,
      required this.name,
      required this.price,
      required this.category,
      required this.imageUrl,
      required this.description,
      required this.storeID,
      required this.imageFromPhone});

  ProductDTO.productFromModel(StoreProductModel storeProductModel)
      : id = storeProductModel.id,
        name = storeProductModel.name,
        price = storeProductModel.price,
        category = storeProductModel.categories,
        imageUrl = storeProductModel.imageUrl,
        description = storeProductModel.description,
        storeID = storeProductModel.onlinestoremodelID,
        imageFromPhone = null {}

  @override
  bool operator ==(other) {
    if (other is ProductDTO) return this.id == other.id;
    return false;
  }
}
