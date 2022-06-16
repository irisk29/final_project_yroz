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

  group('payment', () {
    final userId = "unittest-user";
    final storeId = "unittest-store";
    String? bankToken, creditToken, walletToken;

    setUpAll(() {
      return Future(() async {
        var result = await internalPaymentGateway.createUserAccount(userId);
        walletToken = result.getValue();
        await internalPaymentGateway.createStoreAccount(storeId);
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteUserAccount(userId);
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    Future<void> addCreditCard(String cardNumber, String expiryDate, String cvv,
        String cardHolder) async {
      Secret secret =
          await SecretLoader(secretPath: "assets/secrets.json").load();
      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));
      final encrypted = encrypter.encrypt(cardNumber, iv: iv);
      String encryptedCardNumber = encrypted.base16.toString();
      final result = await internalPaymentGateway.addUserCreditCard(
          userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
      creditToken = result.getValue()!;
    }

    Future<void> removeCreditCard() async {
      await internalPaymentGateway.removeUserCreditCard(userId, creditToken!);
      creditToken = null;
    }

    Future<void> addBankAccount() async {
      String bankAccount = "207884701";
      String branchNumber = "987";
      String bankName = "Yroz";
      final result = await internalPaymentGateway.addStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      bankToken = result.getValue()!;
    }

    Future<void> removeBankAccount() async {
      await internalPaymentGateway.removeStoreBankAccount(storeId, bankToken!);
      bankToken = null;
    }

    test('good scenario', () async {
      await addCreditCard("6886 1232 0788 4701", "10/22", "987", "Yroz");
      await addBankAccount();

      final cashbackAmount = "0";
      final creditAmount = "10";
      final result = await internalPaymentGateway.makePayment(userId, storeId,
          walletToken!, creditToken!, cashbackAmount, creditAmount);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true);

      await removeBankAccount();
      await removeCreditCard();
    });

    test('sad scenario - store has no bank account', () async {
      await addCreditCard("6886 1232 0788 4701", "10/22", "987", "Yroz");

      final cashbackAmount = "0";
      final creditAmount = "10";
      final result = await internalPaymentGateway.makePayment(userId, storeId,
          walletToken!, creditToken!, cashbackAmount, creditAmount);
      expect(result.getTag(), false);

      await removeCreditCard();
    });

    test('sad scenario - user has no credit card', () async {
      await addBankAccount();

      final cashbackAmount = "0";
      final creditAmount = "10";
      final result = await internalPaymentGateway.makePayment(
          userId, storeId, walletToken!, "", cashbackAmount, creditAmount);
      expect(result.getTag(), false);

      await removeBankAccount();
    });

    test('sad scenario - user wrong wallet token', () async {
      await addCreditCard("6886 1232 0788 4701", "10/22", "987", "Yroz");
      await addBankAccount();

      final cashbackAmount = "0";
      final creditAmount = "10";
      final result = await internalPaymentGateway.makePayment(
          userId, storeId, "", creditToken!, cashbackAmount, creditAmount);
      expect(result.getTag(), false);

      await removeBankAccount();
      await removeCreditCard();
    });

    test('sad scenario - not enough cash-back', () async {
      await addCreditCard("6886 1232 0788 4701", "10/22", "987", "Yroz");
      await addBankAccount();

      final cashbackAmount = "100";
      final creditAmount = "10";
      final result = await internalPaymentGateway.makePayment(userId, storeId,
          walletToken!, creditToken!, cashbackAmount, creditAmount);
      expect(result.getTag(), false);

      await removeBankAccount();
      await removeCreditCard();
    });

    test('sad scenario - not enough credit card money', () async {
      await addCreditCard("6886 9318 1234 9876", "10/22", "987", "Yroz");
      await addBankAccount();

      final cashbackAmount = "0";
      final creditAmount = "10";
      final result = await internalPaymentGateway.makePayment(userId, storeId,
          walletToken!, creditToken!, cashbackAmount, creditAmount);
      expect(result.getTag(), false);

      await removeBankAccount();
      await removeCreditCard();
    });
  });
}
