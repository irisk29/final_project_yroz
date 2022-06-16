import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
