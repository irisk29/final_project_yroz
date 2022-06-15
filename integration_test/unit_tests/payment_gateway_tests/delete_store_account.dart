import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('delete store account', () {
    final storeId = "unittest";

    setUp(() {
      return Future(() async {
        await internalPaymentGateway.createStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.deleteStoreAccount(storeId);
      expect(result.getTag(), true);
    });

    test('sad scenario - store account not exists', () async {
      var result = await internalPaymentGateway.deleteStoreAccount(storeId);
      expect(result.getTag(), true);
      result = await internalPaymentGateway.deleteStoreAccount(storeId);
      expect(result.getTag(), false); // cannot delete not existing account
    });
  });
}
