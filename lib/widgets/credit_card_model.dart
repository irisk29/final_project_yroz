class CreditCardModel {
  CreditCardModel(this.cardNumber, this.expiryDate, this.cardHolderName,
      this.cvvCode, this.isCvvFocused);

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  void dispose() {
    cardNumber = '';
    expiryDate = '';
    cardHolderName = '';
    cvvCode = '';
    isCvvFocused = false;
  }
}