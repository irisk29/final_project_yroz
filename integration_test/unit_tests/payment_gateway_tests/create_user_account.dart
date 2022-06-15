import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

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
}
