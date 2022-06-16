import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
