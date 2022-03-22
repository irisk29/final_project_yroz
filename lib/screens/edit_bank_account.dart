import 'package:final_project_yroz/DTOs/BankAccountDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/widgets/bank_account_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditBankAccountScreen extends StatefulWidget {
  static const routeName = '/edit-bank-account';

  @override
  _EditBankAccountState createState() => _EditBankAccountState();
}

class _EditBankAccountState extends State<EditBankAccountScreen> {
  late Future<void> bankAccountFuture;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    bankAccountFuture = _fetchBankAccountDetails();
  }

  Future<BankAccountForm?> _fetchBankAccountDetails() async {
    final user = Provider.of<User>(context, listen: false);
    final bankAccount = await user.getStoreBankAccountDetails();
    return bankAccount != null
        ? BankAccountForm(bankAccount.bankAccount, bankAccount.bankName,
            bankAccount.branchNumber)
        : null;
  }

  Future<void> _saveForm(BankAccountForm bankAccountForm) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (bankAccountForm.saveForm()) {
        await Provider.of<User>(context, listen: false)
            .editStoreBankAccount(bankAccountForm.buildBankAccountDTO()!);
        Navigator.of(context).pop();
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(error.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceSize.height * 0.1,
        title: Text(
          "Edit Bank Account",
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: bankAccountFuture,
              builder: (BuildContext context, AsyncSnapshot snap) {
                return snap.connectionState != ConnectionState.done
                    ? Center(child: CircularProgressIndicator())
                    : snap.data == null
                        ? Center(
                            child: Text(
                                "Sorry, we could not find your bank account details at the moment...",
                                textAlign: TextAlign.center),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                snap.data,
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                  color: Colors.red))),
                                    ),
                                    onPressed: () =>
                                        _saveForm(snap.data as BankAccountForm),
                                    child: Text('Submit'),
                                  ),
                                ),
                              ],
                            ),
                          );
              },
            ),
    );
  }
}
