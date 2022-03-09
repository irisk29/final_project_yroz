import 'dart:convert';

import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/StoreStorageProxy.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoreOwnerState {
  String _storeOwnerID;
  OnlineStoreDTO? onlineStore;
  StoreDTO? physicalStore;

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

  void setOnlineStore(OnlineStoreModel onlineStoreModel) async {
    var categories = jsonDecode(onlineStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(onlineStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    String? imageUrl = await StoreStorageProxy().getDownloadUrl(onlineStoreModel.id);
    onlineStore = new OnlineStoreDTO(
        id: onlineStoreModel.id,
        name: onlineStoreModel.name,
        phoneNumber: onlineStoreModel.phoneNumber,
        address: onlineStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: op,
        image: imageUrl,
        products: onlineStoreModel.storeProductModels == null
            ? []
            : onlineStoreModel.storeProductModels!
                .map((e) => ProductDTO(
                    id: e.id,
                    name: e.name,
                    description: e.description!,
                    category: e.categories,
                    price: e.price,
                    imageUrl: e.imageUrl!))
                .toList(),
        qrCode: onlineStoreModel.qrCode);
  }

  void setPhysicalStore(PhysicalStoreModel physicalStoreModel) async{
    var categories = jsonDecode(physicalStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(physicalStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    String? imageUrl = await StoreStorageProxy().getDownloadUrl(physicalStoreModel.id);
    physicalStore = new StoreDTO(id: physicalStoreModel.id, name: physicalStoreModel.name, phoneNumber: physicalStoreModel.phoneNumber, 
    address: physicalStoreModel.address, categories: List<String>.from(categories), operationHours: op, image: imageUrl, qrCode: physicalStoreModel.qrCode!);
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
