import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
