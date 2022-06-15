import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final internalPaymentGateway = InternalPaymentGateway();

  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized(); // to make the tests work

  group('create store account', () {
    final storeId = "unittest";

    tearDown(() {
      return Future(() async {
        await internalPaymentGateway.deleteStoreAccount(storeId);
      });
    });

    test('good scenario', () async {
      final result = await internalPaymentGateway.createStoreAccount(storeId);
      expect(result.getTag(), true);
    });

    test('sad scenario - store account already exists', () async {
      var result = await internalPaymentGateway.createStoreAccount(storeId);
      expect(result.getTag(), true);
      result = await internalPaymentGateway.createStoreAccount(storeId);
      expect(result.getTag(), false); // cannot create two accounts with same id
    });
  });
}
