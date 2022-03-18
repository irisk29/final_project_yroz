import 'dart:convert';
import 'dart:io';

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
  String? storeBankAccountToken;

  VoidCallback callback;
  DateTime? lastTimeViewedPurchases;
  int newPurchasesNoViewed = 0;

  // TODO: add here the observeQuery and stream.listen for notifications
  // inside stream.listen call this.callback instead of setState

  StoreOwnerState(this._storeOwnerID, this.callback);
  StoreOwnerState.storeOwnerStateFromModel(StoreOwnerModel model, this.callback)
      : _storeOwnerID = model.id {
    if (model.onlineStoreModel != null) {
      setOnlineStoreFromModel(model.onlineStoreModel!);
    }
    if (model.physicalStoreModel != null) {
      setPhysicalStore(model.physicalStoreModel!);
    }
    this.storeBankAccountToken = model.bankAccountToken;
  }

  String get getStoreOwnerID => _storeOwnerID;
  void setStoreOwnerID(id) => _storeOwnerID = id;

  void setOnlineStoreFromModel(OnlineStoreModel onlineStoreModel) async {
    var categories = jsonDecode(onlineStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(onlineStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    String? imageUrl =
        await StoreStorageProxy().getDownloadUrl(onlineStoreModel.id);
    File? imageFile = imageUrl != null
        ? await StoreStorageProxy().createFileFromImageUrl(imageUrl)
        : null;
    List<ProductDTO> products = [];
    if (onlineStoreModel.storeProductModels == null ||
        onlineStoreModel.storeProductModels!.isEmpty) {
      onlineStoreModel.storeProductModels!.forEach((e) async {
        String? prodImageUrl = await StoreStorageProxy().getDownloadUrl(e.id);
        File? prodImageFile = prodImageUrl != null
            ? await StoreStorageProxy().createFileFromImageUrl(prodImageUrl)
            : null;
        products.add(new ProductDTO(
            id: e.id,
            name: e.name,
            description: e.description!,
            category: e.categories,
            price: e.price,
            imageUrl: e.imageUrl!,
            storeID: e.onlinestoremodelID,
            imageFromPhone: prodImageFile));
      });
    }

    onlineStore = new OnlineStoreDTO(
        id: onlineStoreModel.id,
        name: onlineStoreModel.name,
        phoneNumber: onlineStoreModel.phoneNumber,
        address: onlineStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: op,
        image: imageUrl,
        products: products,
        qrCode: onlineStoreModel.qrCode,
        imageFromPhone: imageFile);
  }

  void setOnlineStore(OnlineStoreDTO onlineStoreDTO) {
    this.onlineStore = onlineStoreDTO;
  }

  void setPhysicalStore(PhysicalStoreModel physicalStoreModel) async {
    var categories = jsonDecode(physicalStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(physicalStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    String? imageUrl =
        await StoreStorageProxy().getDownloadUrl(physicalStoreModel.id);
    File? imageFile = imageUrl != null
        ? await StoreStorageProxy().createFileFromImageUrl(imageUrl)
        : null;
    physicalStore = new StoreDTO(
        id: physicalStoreModel.id,
        name: physicalStoreModel.name,
        phoneNumber: physicalStoreModel.phoneNumber,
        address: physicalStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: op,
        image: imageUrl,
        qrCode: physicalStoreModel.qrCode!,
        imageFromPhone: imageFile);
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
