import 'dart:async';

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
  var _formChanged;

  @override
  void initState() {
    bankAccountFuture = _fetchBankAccountDetails();
    _formChanged = false;
    super.initState();
  }

  Future<BankAccountForm?> _fetchBankAccountDetails() async {
    final user = Provider.of<User>(context, listen: false);
    final bankAccount = await user.getStoreBankAccountDetails();
    return bankAccount != null
        ? BankAccountForm(
            bankAccount.bankAccount, bankAccount.bankName, bankAccount.branchNumber, () => _formChanged = true)
        : null;
  }

  Future<void> _saveForm(BankAccountForm bankAccountForm, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    if (_formChanged) {
      final saveFormRes = await bankAccountForm.saveForm(context);
      if (saveFormRes) {
        final editRes = await Provider.of<User>(context, listen: false)
            .editStoreBankAccount(bankAccountForm.buildBankAccountDTO()!);
        if (editRes.getTag()) {
          setState(() {
            _isLoading = false;
          });
          SnackBar snackBar = SnackBar(
            duration: Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            content: const Text('Saved Bank Account Successfully!',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
            width: MediaQuery.of(context).size.width * 0.75,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.of(context).pop();
        } else {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Edit Bank Acoount Error'),
              content: Text(editRes.getMessage()),
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
      }
    } else {
      Navigator.of(context).pop();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _exitWithoutSavingDialog() {
    if (_formChanged) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Are your sure?'),
          content: Text("You are about to exit without saving your changes."),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: deviceSize.height * 0.1,
          automaticallyImplyLeading: false,
          leading: _isLoading
              ? Container()
              : IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _exitWithoutSavingDialog(),
                ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Edit Bank Account",
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : FutureBuilder(
                future: bankAccountFuture,
                builder: (BuildContext ctx, AsyncSnapshot snap) {
                  return snap.connectionState != ConnectionState.done
                      ? Center(child: CircularProgressIndicator())
                      : snap.data == null
                          ? Center(
                              child: Text("Sorry, we could not find your bank account details at the moment...",
                                  textAlign: TextAlign.center),
                            )
                          : Padding(
                              padding: EdgeInsets.all(deviceSize.width * 0.03),
                              child: Column(
                                children: [
                                  snap.data,
                                  SizedBox(
                                    width: deviceSize.width * 0.8,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            side: BorderSide(color: Colors.red))),
                                      ),
                                      onPressed: () => _saveForm(snap.data as BankAccountForm, context),
                                      child: Text('Submit'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                },
              ),
      ),
    );
  }
}
