import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_demo/DTOs/StroreDTO.dart';
import 'package:project_demo/LogicLayer/User.dart';
import 'package:project_demo/Result/ResultInterface.dart';
import 'package:project_demo/providers/online_store.dart';
import 'package:project_demo/providers/physical_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';
import './product.dart';

class Stores with ChangeNotifier {
  User user;
  List<OnlineStore> _onlineStores = [];
  List<PhysicalStore> _physicalStores = [];

  Stores(this.user, this._onlineStores, this._physicalStores);

  List<OnlineStore> get onlineStores {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._onlineStores];
  }

  List<PhysicalStore> get physicalStores {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._physicalStores];
  }

  // List<Product> get favoriteItems {
  //   return _items.where((prodItem) => prodItem.isFavorite).toList();
  // }

  OnlineStore findOnlineStoreById(String id) {
    return _onlineStores.firstWhere((prod) => prod.id == id,
        orElse: () => null);
  }

  PhysicalStore findPhysicalStoreById(String id) {
    return _physicalStores.firstWhere((prod) => prod.id == id,
        orElse: () => null);
  }

  Future<void> _showMyDialog(String error) async {
    return showDialog<void>(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(error),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addOnlineStore(OnlineStore store) async {
    try {
      StoreDTO dto = StoreDTO(store.name, store.phoneNumber, store.address,
          store.categories, store.operationHours, "");
      ResultInterface res = await user.openOnlineStore(dto);
      if (!res.getTag()) {
        _showMyDialog(res.getMessage());
      }
      _onlineStores.add(user.storeOwnerState.onlineStore);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addPhysicalStore(PhysicalStore store) async {
    try {
      StoreDTO dto = StoreDTO(store.name, store.phoneNumber, store.address,
          store.categories, store.operationHours, store.image);
      ResultInterface res = await user.openPhysicalStore(dto);
      if (!res.getTag()) {
        _showMyDialog(res.getMessage());
      }
      _physicalStores.add(user.storeOwnerState.physicalStore);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateOnlineStore(String id, OnlineStore newStore) async {
    final storeIndex = _onlineStores.indexWhere((prod) => prod.id == id);
    if (storeIndex >= 0) {
      _onlineStores[storeIndex] = null; //TODO: update store
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> updatePhysicalStore(String id, PhysicalStore newStore) async {
    final storeIndex = _physicalStores.indexWhere((prod) => prod.id == id);
    if (storeIndex >= 0) {
      _physicalStores[storeIndex] = null; //TODO: update store
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteStore(String id) async {}
}
