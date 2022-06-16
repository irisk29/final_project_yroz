import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
