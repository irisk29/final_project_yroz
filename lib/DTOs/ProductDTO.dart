import 'package:final_project_yroz/LogicLayer/Category.dart';

class ProductDTO {
  String id;
  String name;
  String category;
  double price;
  String imageUrl;
  String description;

  ProductDTO(
  {required this.id, required this.name, required this.price, required this.category, required this.imageUrl, required this.description});
}
