import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Product> _items = [];

  Products(this.authToken, this.userId, this._items);

  Products.withNull(): authToken = '', userId = '', _items = [];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product? findById(String id) {
    return _items.firstWhere((prod) => prod.id == id, orElse: null);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filter = filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.https('flutter4-390b1-default-rtdb.firebaseio.com',
        '/products.json?auth=$authToken$filter');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final faveUrl = Uri.https('flutter4-390b1-default-rtdb.firebaseio.com',
          '/userFavorites/$userId?auth=$authToken');
      final faveResponse = await http.get(faveUrl);
      final faveData = json.decode(faveResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          category: prodData['categories'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: faveData == null ? false : faveData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
          storeID: prodData['storeID']
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      // TODO: ADD CODE
      final newProduct = Product(
        title: product.title,
        description: product.description,
        category: product.category,
        price: product.price,
        imageUrl: product.imageUrl,
        id: product.id,
        storeID: product.storeID
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      // TODO: ADD CODE
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    // TODO: ADD CODE
  }
}
