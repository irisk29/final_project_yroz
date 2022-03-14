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

  // params: user id - email
  // returns: Result with eWalletoken
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

  // params: user id - email
  Future<ResultInterface> deleteUserAccount(String userId) async {
    try {
      var url = Uri.parse(externalPaymentUrl + '/dev/userAccount');
      var body = {"userId": userId};
      var response = await http.delete(url, body: json.encode(body));
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

  // params: store id
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

  // params: store id
  Future<ResultInterface> deleteStoreAccount(String storeId) async {
    try {
      var url = Uri.parse(externalPaymentUrl + '/dev/storeAccount');
      var body = {"storeId": storeId};
      var response = await http.delete(url, body: json.encode(body));
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

  // params: userId - email, cardNumber - 16 string length, expiryDate - m/y, cvv - 3 string length, cardHolder
  // returns: Result with credit crad token
  Future<ResultInterface> addUserCreditCard(String userId, String cardNumber,
      String expiryDate, String cvv, String cardHolder) async {
    try {
      var url = Uri.parse(externalPaymentUrl + '/dev/userCreditCard');
      var body = {
        "userId": userId,
        "cardNumber": cardNumber,
        "expiryDate": expiryDate,
        "cvv": cvv,
        "cardHolder": cardHolder
      };
      var response = await http.post(url, body: json.encode(body));
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(responseBody["msg"], responseBody["token"]);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }

  // params: userId - email, creditToken - saved credit token that recived from addUserCreditCard
  Future<ResultInterface> removeUserCreditCard(
      String userId, String creditToken) async {
    try {
      var url = Uri.parse(externalPaymentUrl + '/dev/userCreditCard');
      var body = {"userId": userId, "creditToken": creditToken};
      var response = await http.delete(url, body: json.encode(body));
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

  // params: userId - email, creditCardTokens - list of credit cards tokens
  // returns: list of all credit cards that were asked
  Future<ResultInterface> userCreditCardDetails(
      String userId, List<String> creditCardTokens) async {
    try {
      String splitedTokens = creditCardTokens.join(' ');
      var body = {
        "userId": "Sagiv",
        "creditCardTokens": splitedTokens,
      };
      var url = Uri.https(externalPaymentUrl, '/dev/userCreditCard', body);
      var response = await http.get(url);
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(responseBody["msg"], responseBody["creditCards"]);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }
}
