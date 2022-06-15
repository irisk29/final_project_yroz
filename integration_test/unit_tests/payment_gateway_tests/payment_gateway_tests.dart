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

  group('create user account', () {
    final userId = "unittest";

    tearDown(() {
      return Future(() async {
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.createUserAccount(userId);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back
    });

    test('sad scenario - user account already exists', () async {
      var result = await internalPaymentGateway.createUserAccount(userId);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back
      result = await internalPaymentGateway.createUserAccount(userId);
      expect(result.getTag(), false); // cannot create two accounts with same id
    });
  });

  group('delete user account', () {
    final userId = "unittest";

    setUp(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.deleteUserAccount(userId);
      expect(result.getTag(), true);
    });

    test('sad scenario - user account not exists', () async {
      var result = await internalPaymentGateway.deleteUserAccount(userId);
      expect(result.getTag(), true);
      result = await internalPaymentGateway.deleteUserAccount(userId);
      expect(result.getTag(), false); // cannot delete not existing account
    });
  });

  group('create store account', () {
    final storeId = "unittest";

    tearDown(() {
      return Future(() async {
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.createStoreAccount(storeId);
      expect(result.getTag(), true);
    });

    test('sad scenario - store account already exists', () async {
      var result = await internalPaymentGateway.createStoreAccount(storeId);
      expect(result.getTag(), true);
      result = await internalPaymentGateway.createStoreAccount(storeId);
      expect(result.getTag(), false); // cannot create two accounts with same id
    });
  });

  group('delete store account', () {
    final storeId = "unittest";

    setUp(() {
      return Future(() async {
        await internalPaymentGateway.createStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.deleteStoreAccount(storeId);
      expect(result.getTag(), true);
    });

    test('sad scenario - store account not exists', () async {
      var result = await internalPaymentGateway.deleteStoreAccount(storeId);
      expect(result.getTag(), true);
      result = await internalPaymentGateway.deleteStoreAccount(storeId);
      expect(result.getTag(), false); // cannot delete not existing account
    });
  });

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

  group('bank account validation', () {
    test('good scenario', () async {
      String bankAccount = "207884701"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.validateBankAccount(
          bankName, branchNumber, bankAccount);
      expect(result.getTag(), true);
    });

    test('sad scenario - invalid bank account number', () async {
      String bankAccount = "207884700"; // bank account not exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.validateBankAccount(
          bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);
    });

    test('sad scenario - invalid bank account details', () async {
      String bankAccount = "207884701";
      String branchNumber = "986"; // wrong branch number
      String bankName = "Yroz";

      final result = await internalPaymentGateway.validateBankAccount(
          bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);
    });
  });

  group('add credit card', () {
    final userId = "unittest";

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

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
      final result = await internalPaymentGateway.addUserCreditCard(
          userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back

      await internalPaymentGateway.removeUserCreditCard(
          userId, result.getValue()!);
    });

    test('sad scenario - invalid card', () async {
      String cardNumber =
          "6886 1232 0788 4700"; // card number not exists in the repo
      String expiryDate = "10/22";
      String cvv = "987";
      String cardHolder = "Yroz";

      String encryptedCardNumber = await encryptCreditNumber(cardNumber);
      final result = await internalPaymentGateway.addUserCreditCard(
          userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), false);
    });

    test('sad scenario - adding same card twice', () async {
      String cardNumber = "6886 1232 0788 4701";
      String expiryDate = "10/22";
      String cvv = "987";
      String cardHolder = "Yroz";

      String encryptedCardNumber = await encryptCreditNumber(cardNumber);
      var result = await internalPaymentGateway.addUserCreditCard(
          userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back

      final cardToken = result.getValue()!;

      result = await internalPaymentGateway.addUserCreditCard(
          userId, encryptedCardNumber, expiryDate, cvv, cardHolder);
      expect(result.getTag(), false); // cannot add the same card twice

      await internalPaymentGateway.removeUserCreditCard(userId, cardToken);
    });
  });

  group('remove credit card', () {
    final userId = "unittest";
    String? creditToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);
      });
    });

    setUp(() {
      return Future(() async {
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
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

    tearDown(() {
      return Future(() async {
        await internalPaymentGateway.removeUserCreditCard(userId, creditToken!);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.removeUserCreditCard(
          userId, creditToken!);
      expect(result.getTag(), true);
    });

    test('sad scenario - no such credit card', () async {
      final result =
          await internalPaymentGateway.removeUserCreditCard(userId, "");
      expect(result.getTag(), false);
    });
  });

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

  group('add user bank account', () {
    final userId = "unittest";

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

    test('good scenario', () async {
      String bankAccount = "207884701"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.addUserBankAccount(
          userId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back

      await internalPaymentGateway.removeUserBankAccount(
          userId, result.getValue()!);
    });

    test('sad scenario - invalid bank account', () async {
      String bankAccount = "207884700"; // bank account not exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.addUserBankAccount(
          userId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);
    });

    test('sad scenario - adding bank account twice', () async {
      String bankAccount = "207884701"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      var result = await internalPaymentGateway.addUserBankAccount(
          userId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back

      final bankToken = result.getValue()!;

      result = await internalPaymentGateway.addUserBankAccount(
          userId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);

      await internalPaymentGateway.removeUserBankAccount(userId, bankToken);
    });
  });

  group('remove user bank account', () {
    final userId = "unittest";
    String? bankToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);
      });
    });

    setUp(() {
      return Future(() async {
        String bankAccount = "207884701";
        String branchNumber = "987";
        String bankName = "Yroz";

        var result = await internalPaymentGateway.addUserBankAccount(
            userId, bankName, branchNumber, bankAccount);
        bankToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

    tearDown(() {
      return Future(() async {
        await internalPaymentGateway.removeUserBankAccount(userId, bankToken!);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.removeUserBankAccount(
          userId, bankToken!);
      expect(result.getTag(), true);
    });

    test('sad scenario - no such bank account', () async {
      final result =
          await internalPaymentGateway.removeUserBankAccount(userId, "");
      expect(result.getTag(), false);
    });
  });

  group('user bank account details', () {
    final userId = "unittest";
    String? bankToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createUserAccount(userId);

        String bankAccount = "207884701";
        String branchNumber = "987";
        String bankName = "Yroz";

        var result = await internalPaymentGateway.addUserBankAccount(
            userId, bankName, branchNumber, bankAccount);
        bankToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.removeUserCreditCard(userId, bankToken!);
        await internalPaymentGateway.deleteUserAccount(userId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.userBankAccountDetails(
          userId, bankToken!);
      expect(result.getTag(), true);
      expect(result.getValue()!.containsKey(bankToken), true);
      expect(result.getValue()![bankToken]!["bankAccount"], "207884701");
      expect(result.getValue()![bankToken]!["branchNumber"], "987");
      expect(result.getValue()![bankToken]!["bankName"], "Yroz");
    });

    test('sad scenario - wrong bank token', () async {
      final result =
          await internalPaymentGateway.userBankAccountDetails(userId, "");
      expect(result.getTag(), false);
    });
  });

  group('add store bank account', () {
    final storeId = "unittest";

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createStoreAccount(storeId);
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      String bankAccount = "207884701"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.addStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back

      await internalPaymentGateway.removeStoreBankAccount(
          storeId, result.getValue()!);
    });

    test('sad scenario - invalid bank account', () async {
      String bankAccount = "207884700"; // bank account not exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.addStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);
    });

    test('sad scenario - adding bank account twice', () async {
      String bankAccount = "207884701"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      var result = await internalPaymentGateway.addStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back

      final bankToken = result.getValue()!;

      result = await internalPaymentGateway.addStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);

      await internalPaymentGateway.removeStoreBankAccount(storeId, bankToken);
    });
  });

  group('remove store bank account', () {
    final storeId = "unittest";
    String? bankToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createStoreAccount(storeId);
      });
    });

    setUp(() {
      return Future(() async {
        String bankAccount = "207884701";
        String branchNumber = "987";
        String bankName = "Yroz";

        var result = await internalPaymentGateway.addStoreBankAccount(
            storeId, bankName, branchNumber, bankAccount);
        bankToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    tearDown(() {
      return Future(() async {
        await internalPaymentGateway.removeStoreBankAccount(
            storeId, bankToken!);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.removeStoreBankAccount(
          storeId, bankToken!);
      expect(result.getTag(), true);
    });

    test('sad scenario - no such bank account', () async {
      final result =
          await internalPaymentGateway.removeStoreBankAccount(storeId, "");
      expect(result.getTag(), false);
    });
  });

  group('edit store bank account', () {
    final storeId = "unittest";
    String? bankToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createStoreAccount(storeId);

        String bankAccount = "207884701";
        String branchNumber = "987";
        String bankName = "Yroz";

        final result = await internalPaymentGateway.addStoreBankAccount(
            storeId, bankName, branchNumber, bankAccount);
        bankToken = result.getValue();
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.removeStoreBankAccount(
            storeId, bankToken!);
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      String bankAccount = "544232653"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.editStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), true);
      expect(result.getValue() != null, true); // must get a token back
    });

    test('sad scenario - invalid bank account number', () async {
      String bankAccount = "544232652"; // bank account exists in the repo
      String branchNumber = "987";
      String bankName = "Yroz";

      final result = await internalPaymentGateway.editStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);
    });

    test('sad scenario - invalid bank account details', () async {
      String bankAccount = "544232653";
      String branchNumber = "986"; // wrong branch number
      String bankName = "Yroz";

      final result = await internalPaymentGateway.editStoreBankAccount(
          storeId, bankName, branchNumber, bankAccount);
      expect(result.getTag(), false);
    });
  });

  group('store bank account details', () {
    final storeId = "unittest";
    String? bankToken;

    setUpAll(() {
      return Future(() async {
        await internalPaymentGateway.createStoreAccount(storeId);

        String bankAccount = "207884701";
        String branchNumber = "987";
        String bankName = "Yroz";

        var result = await internalPaymentGateway.addStoreBankAccount(
            storeId, bankName, branchNumber, bankAccount);
        bankToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.removeStoreBankAccount(
            storeId, bankToken!);
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.storeBankAccountDetails(
          storeId, bankToken!);
      expect(result.getTag(), true);
      expect(result.getValue()!.containsKey(bankToken), true);
      expect(result.getValue()![bankToken]!["bankAccount"], "207884701");
      expect(result.getValue()![bankToken]!["branchNumber"], "987");
      expect(result.getValue()![bankToken]!["bankName"], "Yroz");
    });

    test('sad scenario - wrong bank token', () async {
      final result =
          await internalPaymentGateway.storeBankAccountDetails(storeId, "");
      expect(result.getTag(), false);
    });
  });

  group('get wallet balance', () {
    final userId = "unittest";
    String? walletToken;

    setUpAll(() {
      return Future(() async {
        final result = await internalPaymentGateway.createUserAccount(userId);
        walletToken = result.getValue()!;
      });
    });

    tearDownAll(() {
      return Future(() async {
        await internalPaymentGateway.deleteUserAccount(userId);
        walletToken = null;
      });
    });

    test('good scenario', () async {
      final result =
          await internalPaymentGateway.eWalletBalance(userId, walletToken!);
      expect(result.getTag(), true);
      expect(double.parse(result.getValue()!), 0.0);
    });

    test('sad scenario - wring wallet token', () async {
      final result = await internalPaymentGateway.eWalletBalance(userId, "");
      expect(result.getTag(), false);
    });
  });

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
      DateTime now = _getPSTTime();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      final result = await internalPaymentGateway.getPurchaseHistory(
          yesterday, now,
          userId: userId, storeId: storeId, succeeded: true);
      expect(result.getTag(), true);
      expect(result.getValue()!.length, 1);
      expect(result.getValue()!.first["purchaseToken"], paymentToken);
    });

    test('sad scenario - no such purchase history', () async {
      DateTime now = _getPSTTime();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      final result = await internalPaymentGateway.getPurchaseHistory(
          yesterday, now,
          userId: userId, storeId: storeId, succeeded: false);
      expect(result.getTag(), true);
      expect(result.getValue()!.isEmpty, true);
    });
  });
}
