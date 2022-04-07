import 'dart:async';
import 'dart:convert';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:f_logs/f_logs.dart';
import 'package:final_project_yroz/DTOs/OnlineStoreDTO.dart';
import 'package:final_project_yroz/DTOs/ProductDTO.dart';
import 'package:final_project_yroz/DTOs/PurchaseHistoryDTO.dart';
import 'package:final_project_yroz/DTOs/StoreDTO.dart';
import 'package:final_project_yroz/DataLayer/UsersStorageProxy.dart';
import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/ModelProvider.dart';
import 'package:final_project_yroz/Result/Failure.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../DTOs/BankAccountDTO.dart';

class StoreOwnerState {
  String _storeOwnerID;
  OnlineStoreDTO? onlineStore;
  StoreDTO? physicalStore;
  String? storeBankAccountToken;

  VoidCallback callback; // to notify changes in store owner state
  // Default Value, everything wil be bigger because this date already passed
  DateTime lastTimeViewedPurchases =
      DateFormat('dd/MM/yyyy, hh:mm:ss a').parse('1/1/2022, 10:00:00 AM');
  int newPurchasesNoViewed = 0;
  StreamSubscription<QuerySnapshot<PurchaseHistoryModel>>? purchasesMonitor;

  StoreOwnerState(this._storeOwnerID, this.callback, [String? bankToken])
      : storeBankAccountToken = bankToken;
  StoreOwnerState.storeOwnerStateFromModel(StoreOwnerModel model, this.callback)
      : _storeOwnerID = model.id {
    if (model.onlineStoreModel != null) {
      setOnlineStoreFromModel(model.onlineStoreModel!);
    }
    if (model.physicalStoreModel != null) {
      setPhysicalStore(model.physicalStoreModel!);
    }
    this.storeBankAccountToken = model.bankAccountToken;
    this.lastTimeViewedPurchases = model.lastPurchasesView!.getDateTimeInUtc();
    createPurchasesSubscription();
  }

  String get getStoreOwnerID => _storeOwnerID;
  void setStoreOwnerID(id) => _storeOwnerID = id;

  Future<void> setOnlineStoreFromModel(
      OnlineStoreModel onlineStoreModel) async {
    var categories = jsonDecode(onlineStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(onlineStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    List<ProductDTO> products = [];
    if (onlineStoreModel.storeProductModels != null) {
      products = onlineStoreModel.storeProductModels!
          .map((productModel) => ProductDTO.productFromModel(productModel))
          .toList();
    }

    onlineStore = new OnlineStoreDTO(
        id: onlineStoreModel.id,
        name: onlineStoreModel.name,
        phoneNumber: onlineStoreModel.phoneNumber,
        address: onlineStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: op,
        image: onlineStoreModel.imageUrl,
        products: products,
        qrCode: onlineStoreModel.qrCode);
  }

  void setOnlineStore(OnlineStoreDTO onlineStoreDTO) {
    this.onlineStore = onlineStoreDTO;
  }

  Future<void> setPhysicalStore(PhysicalStoreModel physicalStoreModel) async {
    var categories = jsonDecode(physicalStoreModel.categories);
    Map<String, dynamic> operationHours =
        jsonDecode(physicalStoreModel.operationHours);
    var op = parseOperationHours(operationHours);
    physicalStore = new StoreDTO(
        id: physicalStoreModel.id,
        name: physicalStoreModel.name,
        phoneNumber: physicalStoreModel.phoneNumber,
        address: physicalStoreModel.address,
        categories: List<String>.from(categories),
        operationHours: op,
        image: physicalStoreModel.imageUrl,
        qrCode: physicalStoreModel.qrCode!);
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

  Future<List<PurchaseHistoryDTO>>
      getSuccssefulPurchaseHistoryForStoreInDateRange(
          DateTime start, DateTime end) async {
    try {
      String storeID = this.onlineStore != null
          ? this.onlineStore!.id
          : this.physicalStore!.id;
      var res = await InternalPaymentGateway()
          .getPurchaseHistory(start, end, storeId: storeID, succeeded: true);
      if (!res.getTag()) {
        print(res.getMessage());
        return [];
      }
      FLog.info(text: "Got store purchases: ${res.getValue()}");
      List<PurchaseHistoryDTO> purchasesDTO = [];
      Iterable<Map<String, Object>>? purchases = res.getValue();
      if (purchases != null) {
        purchases.forEach((json) {
          Map<String, dynamic> info = json['info'] as Map<String, dynamic>;
          var purchase = PurchaseHistoryDTO(
              json['userId'] as String,
              json['storeId'] as String,
              info['succeeded'] == 'true',
              double.parse(json['cashBackAmount'] as String),
              double.parse(json['creditAmount'] as String),
              DateFormat('dd/MM/yyyy HH:mm:ss')
                  .parse(json['purchaseDate'] as String),
              json["purchaseToken"] as String);
          purchasesDTO.add(purchase);
        });
      }
      return purchasesDTO;
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return [];
    }
  }

  Future<void> cancelPurchasesSubscription() async {
    try {
      if (this.purchasesMonitor != null) {
        await this.purchasesMonitor!.cancel();
      }
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
    }
  }

  void createPurchasesSubscription() {
    String myStore = this.onlineStore != null
        ? this.onlineStore!.id
        : this.physicalStore!.id;
    print(TemporalDateTime.fromString(
        this.lastTimeViewedPurchases.toDateTimeIso8601String()));
    Stream<QuerySnapshot<PurchaseHistoryModel>> stream =
        Amplify.DataStore.observeQuery(PurchaseHistoryModel.classType,
            where: PurchaseHistoryModel.STOREID.eq(myStore) &
                PurchaseHistoryModel.DATE.gt(TemporalDateTime.fromString(
                    this.lastTimeViewedPurchases.toDateTimeIso8601String())));

    this.purchasesMonitor =
        stream.listen((QuerySnapshot<PurchaseHistoryModel> snapshot) {
      this.newPurchasesNoViewed = snapshot.items.length;
      FLog.info(
          text: "Got new purchases: " + this.newPurchasesNoViewed.toString());
      callback();
    });
  }

  Future<void> updateLastTimeViewedPurchses(DateTime date) async {
    this.lastTimeViewedPurchases = date;
    cancelPurchasesSubscription();
    createPurchasesSubscription();
    UsersStorageProxy().saveLastPurchaseView(date);
  }

  Future<BankAccountDTO?> getStoreBankAccountDetails() async {
    try {
      final storeId = onlineStore != null ? onlineStore!.id : physicalStore!.id;
      var res = await InternalPaymentGateway()
          .storeBankAccountDetails(storeId, storeBankAccountToken!);
      if (!res.getTag()) {
        print(res.getMessage());
        return null;
      }
      final bankAccount = res.getValue()!;
      final bankInfo = bankAccount[storeBankAccountToken!]!;
      return BankAccountDTO(bankInfo["bankName"]!, bankInfo["branchNumber"]!,
          bankInfo["bankAccount"]!, storeBankAccountToken!);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return null;
    }
  }

  Future<ResultInterface> addStoreBankAccount(String storeID, String bankName,
      String branchNumber, String bankAccount) async {
    //now that the user has store account registered, a token for their bank account is generated
    try {
      var storeAccountRes = await InternalPaymentGateway()
          .addStoreBankAccount(storeID, bankName, branchNumber, bankAccount);
      if (!storeAccountRes.getTag()) {
        print(storeAccountRes.getMessage());
        return storeAccountRes;
      }
      String token = storeAccountRes.getValue()!;
      await UsersStorageProxy().saveStoreBankAccount(token);
      storeBankAccountToken = token;
      return new Ok("Added bank token $token", token);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return Failure(e.toString());
    }
  }

  Future<ResultInterface> editStoreBankAccount(
      BankAccountDTO bankAccountDTO) async {
    try {
      final storeId = onlineStore != null ? onlineStore!.id : physicalStore!.id;
      var res = await InternalPaymentGateway().editStoreBankAccount(
          storeId,
          bankAccountDTO.bankName,
          bankAccountDTO.branchNumber,
          bankAccountDTO.bankAccount);
      if (!res.getTag()) {
        print(res.getMessage());
        return res;
      }
      String token = res.getValue()!;
      await UsersStorageProxy().saveStoreBankAccount(token);
      storeBankAccountToken = token;
      return new Ok("Added bank token $token", token);
    } on Exception catch (e) {
      FLog.error(text: e.toString(), stacktrace: StackTrace.current);
      return Failure(e.toString());
    }
  }
}
