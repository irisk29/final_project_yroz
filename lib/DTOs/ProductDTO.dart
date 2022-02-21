import 'package:project_demo/LogicLayer/Categories.dart';

class ProductDTO {
  String name;
  List<Categories> categories;
  double price;
  String imageUrl;
  String description;

  ProductDTO(
      this.name, this.price, this.categories, this.imageUrl, this.description);
}
