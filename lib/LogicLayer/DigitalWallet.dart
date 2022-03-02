import 'package:final_project_yroz/models/DigitalWalletModel.dart';

class DigitalWallet {
  double cashBackAmount;

  DigitalWallet(this.cashBackAmount);
  DigitalWallet.digitalWalletFromModel(DigitalWalletModel model)
      : cashBackAmount = 0 {
    this.cashBackAmount = model.cashBackAmount;
  }

  void increaseAmount(double amount) {
    this.cashBackAmount += amount;
  }

  bool decreaseAmount(double amount) {
    if (this.cashBackAmount - amount < 0) return false;
    this.cashBackAmount -= amount;
    return true;
  }
}
