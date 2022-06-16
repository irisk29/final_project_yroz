import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:final_project_yroz/LogicLayer/Secret.dart';
import 'package:final_project_yroz/LogicLayer/SecretLoader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  DateTime _getPSTTime() {
    tz.initializeTimeZones();

    final DateTime now = DateTime.now();
    final pacificTimeZone = tz.getLocation('Asia/Jerusalem');

    return tz.TZDateTime.from(now, pacificTimeZone);
  }

  group('purchase history', () {
    final userId = "unittest-user" + _getPSTTime().toString();
    final storeId = "unittest-store" + _getPSTTime().toString();
    String? bankToken, creditToken, walletToken, paymentToken;

    setUpAll(() {
      return Future(() async {
        var result = await internalPaymentGateway.createUserAccount(userId);
        walletToken = result.getValue();
        await internalPaymentGateway.createStoreAccount(storeId);

        String bankAccount = "207884701";
        String branchNumber = "987";
        String bankName = "Yroz";
        result = await internalPaymentGateway.addStoreBankAccount(
            storeId, bankName, branchNumber, bankAccount);
        bankToken = result.getValue()!;

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
        String encryptedCardNumber = encrypted.base16.toString();
        result = await internalPaymentGateway.addUserCreditCard(
            userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
        creditToken = result.getValue()!;

        final cashbackAmount = "0";
        final creditAmount = "10";
        result = await internalPaymentGateway.makePayment(userId, storeId,
            walletToken!, creditToken!, cashbackAmount, creditAmount);
        paymentToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.removeStoreBankAccount(
            storeId, bankToken!);
        bankToken = null;

        await internalPaymentGateway.removeUserCreditCard(userId, creditToken!);
        creditToken = null;

        await internalPaymentGateway.deleteUserAccount(userId);
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      DateTime now = _getPSTTime().add(const Duration(minutes: 1));
      DateTime yesterday = now.subtract(const Duration(days: 1));
      final result = await internalPaymentGateway.getPurchaseHistory(
          yesterday, now,
          userId: userId, storeId: storeId, succeeded: true);
      expect(result.getTag(), true);
      expect(result.getValue()!.length, 1);
      expect(result.getValue()!.first["purchaseToken"], paymentToken);
    });

    test('sad scenario - no such purchase history', () async {
      DateTime now = _getPSTTime().add(const Duration(minutes: 1));
      DateTime yesterday = now.subtract(const Duration(days: 1));
      final result = await internalPaymentGateway.getPurchaseHistory(
          yesterday, now,
          userId: userId, storeId: storeId, succeeded: false);
      expect(result.getTag(), true);
      expect(result.getValue()!.isEmpty, true);
    });
  });
}
