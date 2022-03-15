import 'package:intl/intl.dart';

class PurchaseHistoryDTO {
  String? transactionID;
  String? userID;
  String? storeID;
  bool? succeeded;
  String? creditAmount;
  String? cashBackAmount;
  DateTime? purchaseDate;

  PurchaseHistoryDTO(
      {this.userID, this.storeID, this.succeeded, this.creditAmount, this.cashBackAmount, this.purchaseDate, this.transactionID});

  PurchaseHistoryDTO.fromJson(Map<String, dynamic> json)
      : userID = json.containsKey('userId') ? json['userId'] : null,
        storeID = json.containsKey('storeId') ? json['storeId'] : null,
        cashBackAmount = json.containsKey('cashBackAmount') ? json['cashBackAmount'] : null,
        creditAmount = json.containsKey('creditAmount') ? json['creditAmount'] : null,
        purchaseDate =
            json.containsKey('purchaseDate') ? new DateFormat('dd/MM/yyyy HH:mm:ss').parse(json['purchaseDate']) : null,
        succeeded = json.containsKey('info') ? json['info']['succeeded'] == 'true' : null;
}
