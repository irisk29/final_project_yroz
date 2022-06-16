import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
