import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final loadedProduct =
        ModalRoute.of(context)!.settings.arguments as ProductDTO; // is the id!
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Positioned(
                  child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: loadedProduct.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(loadedProduct.imageUrl!),
                          fit: BoxFit.cover)
                      : DecorationImage(
                          image:
                              AssetImage('assets/images/default_product.png'),
                          fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(15),
                ),
              )),
            ),
            SizedBox(height: 10),
            Text(
              'Price: \€ ${loadedProduct.price}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.description != null
                    ? loadedProduct.description!
                    : "No Product Description",
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                "Category: " + loadedProduct.category,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
