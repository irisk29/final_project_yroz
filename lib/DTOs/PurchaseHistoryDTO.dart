import 'package:intl/intl.dart';

class PurchaseHistoryDTO {
  String transactionID;
  String userID;
  String storeID;
  bool succeeded;
  double creditAmount;
  double cashBackAmount;
  DateTime purchaseDate;

  PurchaseHistoryDTO(
      this.userID,
      this.storeID,
      this.succeeded,
      this.creditAmount,
      this.cashBackAmount,
      this.purchaseDate,
      this.transactionID);

  PurchaseHistoryDTO.fromJson(Map<String, dynamic> json)
      : transactionID = json['purchaseToken'],
        userID = json['userId'],
        storeID = json['storeId'],
        cashBackAmount = double.parse(json['cashBackAmount']),
        creditAmount = double.parse(json['creditAmount']),
        purchaseDate =
            DateFormat('dd/MM/yyyy HH:mm:ss').parse(json['purchaseDate']),
        succeeded = json['info']['succeeded'] == 'true';
}
