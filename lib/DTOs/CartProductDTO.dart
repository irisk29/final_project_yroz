import 'package:final_project_yroz/DTOs/ProductDTO.dart';

class CartProductDTO extends ProductDTO {
  double amount;

  CartProductDTO(String id, String name, double price, String category, String imageUrl, String description, double amount, String storeID)
      : this.amount = amount,
        super(id: id, name: name, price: price, category: category, imageUrl: imageUrl, description: description, storeID: storeID);

  double calculatePricePerQuantity() {
    return price * amount;
  }

  @override
  bool operator ==(other) {
    if (other is CartProductDTO) return this.id == other.id;
    return false;
  }
}
