import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
