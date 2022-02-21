import 'package:project_demo/models/DigitalWalletModel.dart';

class DigitalWallet {
  double cashBaclAmount;

  DigitalWallet(this.cashBaclAmount);
  DigitalWallet.digitalWalletFromModel(DigitalWalletModel model) {
    this.cashBaclAmount = model.cashBackAmount;
  }

  void increaseAmount(double amount) {
    this.cashBaclAmount += amount;
  }

  bool decreaseAmount(double amount) {
    if (this.cashBaclAmount - amount < 0) return false;
    this.cashBaclAmount -= amount;
    return true;
  }
}
