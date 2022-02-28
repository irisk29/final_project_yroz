import 'dart:convert';

import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/PhysicalStoreModel.dart';
import 'package:final_project_yroz/providers/online_store.dart';
import 'package:final_project_yroz/providers/physical_store.dart';
import 'package:flutter/material.dart';

class StoreOwnerState {
  String _storeOwnerID;
  OnlineStore? onlineStore;
  PhysicalStore? physicalStore;

  StoreOwnerState(this._storeOwnerID);

  String get getStoreOwnerID => _storeOwnerID;
  void setStoreOwnerID(id) => _storeOwnerID = id;

  void setOnlineStore(OnlineStoreModel onlineStoreModel) {
    var categories = jsonDecode(onlineStoreModel.categories);
    var operationHours = jsonDecode(onlineStoreModel.operationHours);
    onlineStore = new OnlineStore(
        id: onlineStoreModel.id,
        name: onlineStoreModel.name,
        phoneNumber: onlineStoreModel.phoneNumber,
        address: onlineStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: Map<String, List<TimeOfDay>>.from(operationHours));
  }

  void setPhysicalStore(PhysicalStoreModel physicalStoreModel) {
    var categories = jsonDecode(physicalStoreModel.categories);
    var operationHours = jsonDecode(physicalStoreModel.operationHours);
    physicalStore = new PhysicalStore(
      id: physicalStoreModel.id,
      name: physicalStoreModel.name,
      phoneNumber: physicalStoreModel.phoneNumber,
      address: physicalStoreModel.address,
      categories: List<String>.from(categories),
      operationHours: Map<String, List<TimeOfDay>>.from(operationHours),
      qrCode: physicalStoreModel.qrCode,
    );
  }
}
