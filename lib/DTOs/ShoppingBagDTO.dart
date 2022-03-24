import 'dart:convert';

import 'package:final_project_yroz/DTOs/CartProductDTO.dart';

import 'ProductDTO.dart';

class ShoppingBagDTO {
  List<CartProductDTO> products;
  String? id;
  String userId; //the user's bag
  String onlineStoreID; //the store's bag

  ShoppingBagDTO(this.id, this.userId, this.onlineStoreID) : products = [] {}

  double calculateTotalPrice() {
    double sum = 0;
    products.forEach((element) {
      sum += element.calculatePricePerQuantity();
    });
    return sum;
  }

  void addProduct(CartProductDTO productDTO) {
    final index = products.indexWhere((element) => element.id == productDTO.id);
    var quantity = 1.0;
    if (index >= 0) {
      final prevProduct = products[index];
      quantity += prevProduct.amount;
      products.remove(prevProduct);
    }
    final updatedProduct = CartProductDTO(
        productDTO.id,
        productDTO.name,
        productDTO.price,
        productDTO.category,
        productDTO.imageUrl,
        productDTO.description,
        quantity,
        productDTO.storeID,
        productDTO.cartID);
    products.add(updatedProduct);
  }

  void decreaseProductQuantity(String cartProductID) {
    final index = products.indexWhere((element) => element.cartID == cartProductID);
    if (index >= 0) {
      final prevProduct = products[index];
      if (prevProduct.amount - 1 == 0) {
        removeProduct(cartProductID);
      } else {
        final updatedProduct = CartProductDTO(
            prevProduct.id,
            prevProduct.name,
            prevProduct.price,
            prevProduct.category,
            prevProduct.imageUrl,
            prevProduct.description,
            prevProduct.amount - 1,
            prevProduct.storeID,
            prevProduct.cartID);
        products.remove(prevProduct);
        products.add(updatedProduct);
      }
    }
  }

  void removeProduct(String cartProductID) {
    products.removeWhere((element) => element.cartID == cartProductID);
  }

  double bagSize() {
    return products.fold(
        0, (previousValue, element) => previousValue + element.amount);
  }

  void clearBag() {
    products.clear();
  }

  @override
  bool operator ==(other) {
    if (other is ShoppingBagDTO)
      return this.userId == other.userId &&
          this.onlineStoreID == other.onlineStoreID;
    return false;
  }
}
