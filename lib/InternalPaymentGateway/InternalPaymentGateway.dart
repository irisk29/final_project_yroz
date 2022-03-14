import 'dart:convert';

import 'package:f_logs/model/flog/flog.dart';
import 'package:final_project_yroz/result/Failure.dart';
import 'package:final_project_yroz/result/OK.dart';
import 'package:final_project_yroz/result/ResultInterface.dart';
import 'package:http/http.dart' as http;

class InternalPaymentGateway {
  static final InternalPaymentGateway _internalPaymentGateway =
      InternalPaymentGateway._internal();
  static const externalPaymentUrl =
      'https://0cjie5t2fa.execute-api.us-east-1.amazonaws.com';

  factory InternalPaymentGateway() {
    return _internalPaymentGateway;
  }

  InternalPaymentGateway._internal();

  Future<ResultInterface> createUserAccount(String userId) async {
    try {
      var url = Uri.parse(externalPaymentUrl + '/dev/userAccount');
      var body = {"userId": userId};
      var response = await http.post(url, body: json.encode(body));
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(responseBody["msg"], responseBody["eWalletoken"]);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }

  Future<ResultInterface> createStoreAccount(String storeId) async {
    try {
      var url = Uri.parse(externalPaymentUrl + '/dev/storeAccount');
      var body = {"storeId": storeId};
      var response = await http.post(url, body: json.encode(body));
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(responseBody["msg"]);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }
}
