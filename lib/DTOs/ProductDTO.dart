import 'package:final_project_yroz/LogicLayer/Category.dart';

class ProductDTO {
  String name;
  List<String> categories;
  double price;
  String imageUrl;
  String description;

  ProductDTO(
      this.name, this.price, this.categories, this.imageUrl, this.description);
}
