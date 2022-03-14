import 'dart:io';

class ProductDTO {
  String id;
  String name;
  String category;
  double price;
  String imageUrl;
  String description;
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

  @override
  bool operator ==(other) {
    if (other is ProductDTO) return this.id == other.id;
    return false;
  }
}
