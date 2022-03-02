import 'package:final_project_yroz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context)!.settings.arguments as String; // is the id!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return loadedProduct != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(loadedProduct.title),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      loadedProduct.imageUrl,
                      fit: BoxFit.cover,
                    ),
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
                      loadedProduct.description,
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
          )
        : SplashScreen();
  }

  Widget wrapWithMaterial() => MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Products("", "", []),
            ),
          ],
          child: Scaffold(
            body: this,
          ),
        ),
      );
}
