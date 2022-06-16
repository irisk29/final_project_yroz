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

  group('credit cards details', () {
    final userId = "unittest";
    String? creditToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);

        String cardNumber = "6886 1232 0788 4701";
        String expiryDate = "10/22";
        String cvv = "987";
        String cardHolder = "Yroz";

        Secret secret =
            await SecretLoader(secretPath: "assets/secrets.json").load();
        final key = encrypt.Key.fromUtf8(secret.KEY);
        final iv = encrypt.IV.fromUtf8(secret.IV);
        final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));
        final encrypted = encrypter.encrypt(cardNumber, iv: iv);
        final encryptedCardNumber = encrypted.base16.toString();

        final result = await internalPaymentGateway.addUserCreditCard(
            userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
        creditToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.removeUserCreditCard(userId, creditToken!);
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

    test('good scenario', () async {
      List<String> creditTokens = [];
      creditTokens.add(creditToken!);
      final result = await internalPaymentGateway.userCreditCardDetails(
          userId, creditTokens);
      expect(result.getTag(), true);
      expect(result.getValue()!.containsKey(creditToken), true);
      expect(result.getValue()![creditToken]!["expiryDate"], "10/22");
      expect(result.getValue()![creditToken]!["cardHolder"], "Yroz");
    });

    test('sad scenario - no such user', () async {
      List<String> creditTokens = [];
      creditTokens.add(creditToken!);
      final result =
          await internalPaymentGateway.userCreditCardDetails("", creditTokens);
      expect(result.getTag(), false);
    });

    test('sad scenario - wrong card token', () async {
      List<String> creditTokens = [];
      creditTokens.add("");
      final result = await internalPaymentGateway.userCreditCardDetails(
          userId, creditTokens);
      expect(result.getTag(), true);
      expect(result.getValue()!.isEmpty, true);
    });
  });
}
