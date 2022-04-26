import 'dart:convert';

import 'package:final_project_yroz/Result/Failure.dart';
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

  Future<void> savePurchase(String transactionID, String userID, String storeID,
      [List<CartProductDTO>? products]) async {
    var date = TemporalDateTime.fromString(DateTime.now().toDateTimeIso8601String());
    var productsJson = JsonEncoder.withIndent('  ').convert(products);
    PurchaseHistoryModel purchaseHistoryModel = new PurchaseHistoryModel(
        date: date, transactionID: transactionID, userID: userID, storeID: storeID, products: productsJson);

    await Amplify.DataStore.save(purchaseHistoryModel);
    FLog.info(text: "Saved purchase history with transaction ID $transactionID");
  }

  Future<ResultInterface<List<CartProductDTO>>> getPurchaseProduct(String transactionID) async {
    List<PurchaseHistoryModel> purchases = await Amplify.DataStore.query(PurchaseHistoryModel.classType,
        where: PurchaseHistoryModel.TRANSACTIONID.eq(transactionID));

    if (purchases.isEmpty) {
      FLog.error(text: "No Purchases were found for transaction $transactionID");
      return new Failure("No Purchases were found for transaction $transactionID", []);
    }
    PurchaseHistoryModel purchase = purchases.first; //transaction ID is unique
    print(purchase.products);
    if (purchase.products == null) return new Ok("No products for purchase", []);
    if (purchase.products!.isEmpty) return new Ok("No products for purchase", []);
    var purchaseProducts = jsonDecode(purchase.products!) as List<dynamic>;
    var convertedPurchaseProducts =
        purchaseProducts.map((e) => CartProductDTO.fromJson(e as Map<String, dynamic>)).toList();
    return new Ok("Found products for purchase $transactionID", convertedPurchaseProducts);
  }
}
