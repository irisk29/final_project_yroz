import 'dart:io';

import 'package:final_project_yroz/DTOs/ProductDTO.dart';

class CartProductDTO extends ProductDTO {
  double amount;
  String cartID;

  CartProductDTO(
      String id,
      String name,
      double price,
      String category,
      String? imageUrl,
      String? description,
      double amount,
      String storeID,
      String cartID)
      : this.amount = amount,
        this.cartID = cartID,
        super(
            id: id,
            name: name,
            price: price,
            category: category,
            imageUrl: imageUrl,
            description: description,
            storeID: storeID,
            imageFromPhone: imageUrl != null ? File(imageUrl) : null);

  double calculatePricePerQuantity() {
    return price * amount;
  }

  @override
  bool operator ==(other) {
    if (other is CartProductDTO) return this.id == other.id;
    return false;
  }

  CartProductDTO.fromJson(Map<String, dynamic> json)
      : amount = json['amount'].toDouble(),
        cartID = json['cartID'],
        super(
            id: json['id'],
            name: json['name'],
            price: json['price'],
            category: "",
            imageUrl: json.containsKey('imageUrl') ? json['imageUrl'] : "",
            description: json['description'],
            storeID: json['storeID'],
            imageFromPhone:
                json.containsKey('imageUrl') ? File(json['imageUrl']) : null);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'amount': amount,
        'storeID': storeID,
        'cartID': cartID
      };
}
