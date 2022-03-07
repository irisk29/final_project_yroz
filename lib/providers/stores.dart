import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/providers/physical_store.dart';
import 'package:flutter/material.dart';

import 'online_store.dart';

class Stores with ChangeNotifier {
  User user;
  List<OnlineStore> _onlineStores = [];
  List<PhysicalStore> _physicalStores = [];

  Stores(this.user, this._onlineStores, this._physicalStores);

  Stores.withNull() : user = User.withNull() {}

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

  OnlineStore? findOnlineStoreById(String id) {
    return _onlineStores.firstWhere((prod) => prod.id == id, orElse: null);
  }

  PhysicalStore? findPhysicalStoreById(String id) {
    return _physicalStores.firstWhere((prod) => prod.id == id, orElse: null);
  }

  Future<void> addOnlineStore(OnlineStore store) async {
    try {
      OnlineStoreDTO dto = OnlineStoreDTO(
          store.id, store.name, store.address, store.phoneNumber, store.categories, store.operationHours, store.image,
          store.products.map((e) => e.createDTO()).toList());
      ResultInterface res = await user.openOnlineStore(dto);
      if (!res.getTag()) {
        print(res.getMessage());
      }
      _onlineStores.add(user.storeOwnerState!.onlineStore!);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addPhysicalStore(PhysicalStore store) async {
    try {
      StoreDTO dto = StoreDTO(
          store.id, store.name, store.phoneNumber, store.address, store.categories, store.operationHours, store.image);
      ResultInterface res = await user.openPhysicalStore(dto);
      if (!res.getTag()) {
        print(res.getMessage());
      }
      _physicalStores.add(user.storeOwnerState!.physicalStore!);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateOnlineStore(String id, OnlineStore newStore) async {
    final storeIndex = _onlineStores.indexWhere((prod) => prod.id == id);
    if (storeIndex >= 0) {
      user.updateOnlineStore(newStore.createDTO());
      _onlineStores.removeAt(storeIndex);
      _onlineStores.add(user.storeOwnerState!.onlineStore!);
      notifyListeners();
    } else {
      print('store with ${id} not found');
    }
  }

  Future<void> updatePhysicalStore(String id, PhysicalStore newStore) async {
    final storeIndex = _physicalStores.indexWhere((prod) => prod.id == id);
    if (storeIndex >= 0) {
      user.updatePhysicalStore(newStore.createDTO());
      _physicalStores.removeAt(storeIndex);
      _physicalStores.add(user.storeOwnerState!.physicalStore!);
      notifyListeners();
    } else {
      print('store with ${id} not found');
    }
  }

  Future<void> deleteStore(String id, bool isOnline) async {
    var storeIndex = isOnline
        ? _onlineStores.indexWhere((prod) => prod.id == id)
        : _physicalStores.indexWhere((prod) => prod.id == id);

    if (storeIndex >= 0) {
      ResultInterface res = await user.deleteStore(id, isOnline);
      if (!res.getTag()) {
        //TODO: print to log
        print(res.getMessage());
        return;
      }
      isOnline ? _onlineStores.removeAt(storeIndex) : _physicalStores.removeAt(storeIndex);
      notifyListeners();
    } else {
      print('store with ${id} not found');
    }
  }
}
