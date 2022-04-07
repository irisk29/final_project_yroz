import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/InternalPaymentGateway/InternalPaymentGateway.dart';
import 'package:flutter/material.dart';

class BankAccountForm extends StatelessWidget {
  String? accountNumber;
  String? bankName;
  String? branchNumber;
  OutlineInputBorder? border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final _bankAccountForm = GlobalKey<FormState>();

  BankAccountForm([this.accountNumber, this.bankName, this.branchNumber]);

  BankAccountDTO? buildBankAccountDTO() {
    if (accountNumber != null && bankName != null && branchNumber != null) {
      return BankAccountDTO(bankName!, branchNumber!, accountNumber!);
    }
    return null;
  }

  Future<bool> saveForm(BuildContext context) async {
    if (_bankAccountForm.currentState!.validate()) {
      _bankAccountForm.currentState!.save();
      final res = await InternalPaymentGateway()
          .validateBankAccount(bankName!, branchNumber!, accountNumber!);
      if (res.getTag()) return true;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Invalid Bank Account"),
          content: Text(res.getMessage()),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[
        const Text(
          "Store's Bank Account Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.all(deviceSize.width * 0.05),
          child: SingleChildScrollView(
            child: Form(
              key: _bankAccountForm,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      key: const Key("bank_name"),
                      initialValue: bankName,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'BANK NAME',
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        focusedBorder: border,
                        enabledBorder: border,
                      ),
                      onSaved: (value) {
                        bankName = value;
                      }),
                  SizedBox(
                    height: deviceSize.height * 0.035,
                  ),
                  TextFormField(
                    key: const Key("branch_number"),
                    initialValue: branchNumber,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.black),
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: border,
                      enabledBorder: border,
                      labelText: 'BRANCH NUMBER',
                      hintText: 'XXX',
                    ),
                    validator: (value) {
                      if (value == null || value.length != 3) {
                        return "Invalid Branch Number";
                      }
                      return null;
                    },
                    onSaved: (value) => branchNumber = value,
                  ),
                  SizedBox(
                    height: deviceSize.height * 0.035,
                  ),
                  TextFormField(
                    key: const Key("account_number"),
                    initialValue: accountNumber,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.black),
                      labelStyle: const TextStyle(color: Colors.black),
                      focusedBorder: border,
                      enabledBorder: border,
                      labelText: 'ACCOUNT NUMBER',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.length < 9 ||
                          value.length > 12) {
                        return "Invalid Branch Number";
                      }
                      return null;
                    },
                    onSaved: (value) => accountNumber = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
