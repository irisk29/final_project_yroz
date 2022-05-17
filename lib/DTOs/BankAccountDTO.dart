class BankAccountDTO {
  String bankName;
  String branchNumber;
  String bankAccount;
  String? token;

  BankAccountDTO(this.bankName, this.branchNumber, this.bankAccount,
      [this.token]);
}
