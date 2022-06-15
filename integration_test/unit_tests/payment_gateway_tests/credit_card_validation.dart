import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('credit card validation', () {
    Future<String> encryptCreditNumber(String cardNumber) async {
      Secret secret =
          await SecretLoader(secretPath: "assets/secrets.json").load();

      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));

      final encrypted = encrypter.encrypt(cardNumber, iv: iv);
      return encrypted.base16.toString();
    }

    test('good scenario', () async {
      String cardNumber =
          "6886 1232 0788 4701"; // card number exists in the repo
      String expiryDate = "10/22";
      String cvv = "987";
      String cardHolder = "Yroz";

      String encryptedCardNumber = await encryptCreditNumber(cardNumber);
      final result = await internalPaymentGateway.validateCreditCard(
          encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), true);
    });

    test('sad scenario - invalid card number', () async {
      String cardNumber =
          "6886 1232 0788 4700"; // card number not exists in the repo
      String expiryDate = "10/22";
      String cvv = "987";
      String cardHolder = "Yroz";

      String encryptedCardNumber = await encryptCreditNumber(cardNumber);
      final result = await internalPaymentGateway.validateCreditCard(
          encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), false);
    });

    test('sad scenario - invalid card details', () async {
      String cardNumber = "6886 1232 0788 4701";
      String expiryDate = "10/23"; // wrong expiry date
      String cvv = "987";
      String cardHolder = "Yroz";

      String encryptedCardNumber = await encryptCreditNumber(cardNumber);
      final result = await internalPaymentGateway.validateCreditCard(
          encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), false);
    });
  });
}
