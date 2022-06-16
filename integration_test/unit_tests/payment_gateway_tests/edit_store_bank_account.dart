import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
