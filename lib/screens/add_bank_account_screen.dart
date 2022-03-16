import 'package:flutter/material.dart';

class AddBankAccountScreen extends StatefulWidget {
  static const routeName = '/add-bank-account';

  @override
  State<StatefulWidget> createState() {
    return AddBankAccountScreenState();
  }
}

class AddBankAccountScreenState extends State<AddBankAccountScreen> {
  String accountNumber = '';
  String bankNumber = '';
  String ownerName = '';
  String branchNumber = '';
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: "",
                        decoration:
                          InputDecoration(
                            labelText: 'BANK NUMBER',
                            hintStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                      ),
                      TextFormField(
                        initialValue: "",
                        decoration:
                        InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'BRANCH NUMBER',
                          hintText: 'XXX',
                        ),
                      ),
                      TextFormField(
                        initialValue: "",
                        decoration:
                        InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'ACCOUNT NUMBER',
                        ),
                      ),
                      TextFormField(
                        initialValue: "",
                        decoration:
                        InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'ACCOUNT OWNER',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          primary: const Color(0xff348396),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          child: const Text(
                            'Validate',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            print('valid!');
                          } else {
                            print('invalid!');
                          }
                          // TODO: CALL STUB
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}