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

  Future<ResultInterface> _postRequest(Uri url, Map<String, String> body,
      [String? responseBodyName]) async {
    try {
      var response = await http.post(url, body: json.encode(body));
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(
            responseBody["msg"],
            responseBodyName != null
                ? responseBody[responseBodyName]
                : responseBodyName);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }

  Future<ResultInterface> _patchRequest(Uri url, Map<String, String> body,
      [String? responseBodyName]) async {
    try {
      var response = await http.patch(url, body: json.encode(body));
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(
            responseBody["msg"],
            responseBodyName != null
                ? responseBody[responseBodyName]
                : responseBodyName);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }

  Future<ResultInterface> _deleteRequest(
      Uri url, Map<String, String> body) async {
    try {
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

  Future<ResultInterface> _getRequest(
      String authority, String unencodedPath, Map<String, String> body,
      [String? responseBodyName]) async {
    try {
      var url = Uri.https(authority, unencodedPath, body);
      var response = await http.get(url);
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return new Ok(
            responseBody["msg"],
            responseBodyName != null
                ? responseBody[responseBodyName]
                : responseBodyName);
      }
      return new Failure(responseBody["msg"]);
    } on Exception catch (e) {
      FLog.error(text: e.toString());
      return new Failure(e.toString());
    }
  }

  // params: user id - email
  // returns: Result with eWalletoken
  Future<ResultInterface> createUserAccount(String userId) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/userAccount');
    var body = {"userId": userId};
    return await _postRequest(url, body, "eWalletoken");
  }

  // params: user id - email
  Future<ResultInterface> deleteUserAccount(String userId) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/userAccount');
    var body = {"userId": userId};
    return await _deleteRequest(url, body);
  }

  // params: store id
  Future<ResultInterface> createStoreAccount(String storeId) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/storeAccount');
    var body = {"storeId": storeId};
    return await _postRequest(url, body);
  }

  // params: store id
  Future<ResultInterface> deleteStoreAccount(String storeId) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/storeAccount');
    var body = {"storeId": storeId};
    return await _deleteRequest(url, body);
  }

  // params: userId - email, cardNumber - 16 string length, expiryDate - m/y, cvv - 3 string length, cardHolder
  // returns: Result with credit crad token
  Future<ResultInterface> addUserCreditCard(String userId, String cardNumber,
      String expiryDate, String cvv, String cardHolder) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/userCreditCard');
    var body = {
      "userId": userId,
      "cardNumber": cardNumber,
      "expiryDate": expiryDate,
      "cvv": cvv,
      "cardHolder": cardHolder
    };
    return await _postRequest(url, body, "token");
  }

  // params: userId - email, creditToken - saved credit token that recived from addUserCreditCard
  Future<ResultInterface> removeUserCreditCard(
      String userId, String creditToken) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/userCreditCard');
    var body = {"userId": userId, "creditToken": creditToken};
    return await _deleteRequest(url, body);
  }

  // params: userId - email, creditCardTokens - list of credit cards tokens
  // returns: list of all credit cards that were asked
  Future<ResultInterface> userCreditCardDetails(
      String userId, List<String> creditCardTokens) async {
    String splitedTokens = creditCardTokens.join(' ');
    var body = {
      "userId": userId,
      "creditCardTokens": splitedTokens,
    };
    return await _getRequest(
        externalPaymentUrl, '/dev/userCreditCard', body, "creditCards");
  }

  // params: userId - email, bankName, branchNumber, bankAccount - 9 string length
  // returns: Result with bank account token
  Future<ResultInterface> addUserBankAccount(String userId, String bankName,
      String branchNumber, String bankAccount) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/userBankAccount');
    var body = {
      "userId": userId,
      "bankName": bankName,
      "branchNumber": branchNumber,
      "bankAccount": bankAccount,
    };
    return await _postRequest(url, body, "token");
  }

  // params: userId - email, bankAccountToken - saved bank account token that recived from addUserBankAccount
  Future<ResultInterface> removeUserBankAccount(
      String userId, String bankAccountToken) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/userBankAccount');
    var body = {"userId": userId, "bankAccountToken": bankAccountToken};
    return await _deleteRequest(url, body);
  }

  // params: userId - email, bankAccountToken - saved bank account token that recived from addUserBankAccount
  // returns: bank account details that was asked
  Future<ResultInterface> userBankAccountDetails(
      String userId, String bankAccountToken) async {
    var body = {
      "userId": userId,
      "bankAccountToken": bankAccountToken,
    };
    return await _getRequest(
        externalPaymentUrl, '/dev/userBankAccount', body, "bankAccountDetails");
  }

  // params: storeId, bankName, branchNumber, bankAccount - 9 string length
  // returns: Result with bank account token
  Future<ResultInterface> addStoreBankAccount(String storeId, String bankName,
      String branchNumber, String bankAccount) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/storeBankAccount');
    var body = {
      "storeId": storeId,
      "bankName": bankName,
      "branchNumber": branchNumber,
      "bankAccount": bankAccount,
    };
    return await _postRequest(url, body, "token");
  }

  // params: storeId, bankAccountToken - saved bank account token that recived from addUserBankAccount
  Future<ResultInterface> removeStoreBankAccount(
      String storeId, String bankAccountToken) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/storeBankAccount');
    var body = {"storeId": storeId, "bankAccountToken": bankAccountToken};
    return await _deleteRequest(url, body);
  }

  // params: storeId, bankAccountToken - saved bank account token that recived from addUserBankAccount
  // returns: bank account details that was asked
  Future<ResultInterface> storeBankAccountDetails(
      String storeId, String bankAccountToken) async {
    var body = {
      "storeId": storeId,
      "bankAccountToken": bankAccountToken,
    };
    return await _getRequest(externalPaymentUrl, '/dev/storeBankAccount', body,
        "bankAccountDetails");
  }

  // params: userId - email, eWalletToken - saved e wallet token that recived when calling createUserAccount
  // returns: user's e wallet balance
  Future<ResultInterface> eWalletBalance(
      String userId, String eWalletToken) async {
    var body = {
      "userId": userId,
      "eWalletToken": eWalletToken,
    };
    return await _getRequest(
        externalPaymentUrl, '/dev/eWallet', body, "balance");
  }

  // params: userId - email, eWalletToken - saved e wallet token that recived when calling createUserAccount,
  // bankAccountToken - saved bank account token that recived from addUserBankAccount, cashBackAmount - amount to transfer
  Future<ResultInterface> eWalletBankTransfer(
      String userId,
      String eWalletToken,
      String bankAccountToken,
      String cashBackAmount) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/eWallet');
    var body = {
      "userId": userId,
      "eWalletToken": eWalletToken,
      "bankAccountToken": bankAccountToken,
      "cashBackAmount": cashBackAmount
    };
    return await _patchRequest(url, body);
  }

  // params: userId - email, storeId, eWalletToken - saved e wallet token that recived when calling createUserAccount,
  // creditCardToken - saved bank account token that recived from addUserCreditCard,
  // cashBackAmount - cash back amount to use, creditAmount - credit amount to use
  // returns: generated token for this purchase
  Future<ResultInterface> makePayment(
      String userId,
      String storeId,
      String eWalletToken,
      String creditCardToken,
      String cashBackAmount,
      String creditAmount) async {
    var url = Uri.parse(externalPaymentUrl + '/dev/payments');
    var body = {
      "userId": userId,
      "storeId": storeId,
      "eWalletToken": eWalletToken,
      "creditCardToken": creditCardToken,
      "cashBackAmount": cashBackAmount,
      "creditAmount": creditAmount,
    };
    return await _patchRequest(url, body, "token");
  }
}
