import 'dart:convert';

import 'package:final_project_yroz/Result/OK.dart';
import 'package:final_project_yroz/Result/ResultInterface.dart';
import 'package:final_project_yroz/models/PurchaseHistoryModel.dart';
import 'package:f_logs/f_logs.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project_yroz/DTOs/CartProductDTO.dart';

class PurchaseStorageProxy {
  static final PurchaseStorageProxy _singleton = PurchaseStorageProxy._internal();

  factory PurchaseStorageProxy() {
    return _singleton;
  }

  PurchaseStorageProxy._internal();

  Future<void> savePurchase(String transactionID, [List<CartProductDTO>? products]) async {
    var date = TemporalDateTime.fromString(DateTime.now().toDateTimeIso8601String());
    var productsJson = products == null ? "" : JsonEncoder.withIndent('  ').convert(products);
    PurchaseHistoryModel purchaseHistoryModel =
        new PurchaseHistoryModel(date: date, transactionID: transactionID, products: productsJson);

    await Amplify.DataStore.save(purchaseHistoryModel);
    FLog.info(text: "Saved purchase history with transaction ID $transactionID");
  }

  Future<ResultInterface> getPurchaseProduct(String transactionID) async {
    List<PurchaseHistoryModel> purchases = await Amplify.DataStore.query(PurchaseHistoryModel.classType,
        where: PurchaseHistoryModel.TRANSACTIONID.eq(transactionID));

    if (purchases.isEmpty) {
      FLog.error(text: "No Purchases were found for transaction $transactionID");
    }
    PurchaseHistoryModel purchase = purchases.first; //transaction ID is unique
    List<CartProductDTO> products = jsonDecode(purchase.products);
    return new Ok("Found products for purchase $transactionID", products);
  }
}
