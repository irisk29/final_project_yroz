import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
