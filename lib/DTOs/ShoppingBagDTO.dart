import 'package:final_project_yroz/DTOs/CartProductDTO.dart';

class ShoppingBagDTO {
  List<CartProductDTO> products;
  String userId; //the user's bag
  String onlineStoreID; //the store's bag

  ShoppingBagDTO(this.userId, this.onlineStoreID) : products = [] {}

  double calculateTotalPrice() {
    double sum = 0;
    products.forEach((element) {
      sum += element.calculatePricePerQuantity();
    });
    return sum;
  }

  void addProduct(CartProductDTO productDTO) {
    products.add(productDTO);
  }

  void removeProduct(String  productID) {
    products.removeWhere((element) => element.id == productID);
  }

  void clearBag() {
    products.clear();
  }

  @override
  bool operator ==(other) {
    if (other is ShoppingBagDTO) return this.userId == other.userId && this.onlineStoreID == other.onlineStoreID;
    return false;
  }
}
