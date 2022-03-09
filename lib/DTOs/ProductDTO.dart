class ProductDTO {
  String id;
  String name;
  String category;
  double price;
  String imageUrl;
  String description;

  ProductDTO(
  {required this.id, required this.name, required this.price, required this.category, required this.imageUrl, required this.description});

  @override
  bool operator ==(other) {
    if (other is ProductDTO) return this.id == other.id;
    return false;
  }
}
