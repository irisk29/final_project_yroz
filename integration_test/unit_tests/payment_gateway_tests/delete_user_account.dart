import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
