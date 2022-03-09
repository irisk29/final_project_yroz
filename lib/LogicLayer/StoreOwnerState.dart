import 'dart:convert';

import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/models/OnlineStoreModel.dart';
import 'package:final_project_yroz/models/PhysicalStoreModel.dart';
import 'package:final_project_yroz/providers/online_store.dart';
import 'package:final_project_yroz/providers/physical_store.dart';
import 'package:final_project_yroz/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoreOwnerState {
  String _storeOwnerID;
  OnlineStore? onlineStore;
  PhysicalStore? physicalStore;

  StoreOwnerState(this._storeOwnerID);
  StoreOwnerState.storeOwnerStateFromModel(StoreOwnerModel model)
      : _storeOwnerID = model.id {
    if (model.onlineStoreModel != null) {
      setOnlineStore(model.onlineStoreModel!);
    }
    if (model.physicalStoreModel != null) {
      setPhysicalStore(model.physicalStoreModel!);
    }
  }

  String get getStoreOwnerID => _storeOwnerID;
  void setStoreOwnerID(id) => _storeOwnerID = id;

  void setOnlineStore(OnlineStoreModel onlineStoreModel) {
    var categories = jsonDecode(onlineStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(onlineStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    onlineStore = new OnlineStore(
        id: onlineStoreModel.id,
        name: onlineStoreModel.name,
        phoneNumber: onlineStoreModel.phoneNumber,
        address: onlineStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: op,
        products: onlineStoreModel.storeProductModels == null
            ? []
            : onlineStoreModel.storeProductModels!
                .map((e) => Product(
                    id: e.id,
                    title: e.name,
                    description: e.description!,
                    category: e.categories,
                    price: e.price,
                    imageUrl: e.imageUrl!))
                .toList());
  }

  void setPhysicalStore(PhysicalStoreModel physicalStoreModel) {
    var categories = jsonDecode(physicalStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(physicalStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    physicalStore = new PhysicalStore(
      id: physicalStoreModel.id,
      name: physicalStoreModel.name,
      phoneNumber: physicalStoreModel.phoneNumber,
      address: physicalStoreModel.address,
      categories: List<String>.from(categories),
      operationHours: op,
      qrCode: physicalStoreModel.qrCode!,
    );
  }

  Map<String, List<TimeOfDay>> parseOperationHours(
      Map<String, dynamic> operationHours) {
    Map<String, List<TimeOfDay>> opH = {};
    operationHours.forEach((key, value) {
      List<dynamic> op = List.from(value);
      DateFormat inputFormat = DateFormat('hh:mm a');
      List<TimeOfDay> lst = op
          .map((e) => TimeOfDay.fromDateTime(inputFormat.parse(e as String)))
          .toList();
      opH[key] = lst;
    });
    return opH;
  }
}
