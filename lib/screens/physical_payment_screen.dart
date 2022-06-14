import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/screens/invoice_screen.dart';
import 'package:final_project_yroz/widgets/cashback_selection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';

class PhysicalPaymentScreen extends StatefulWidget {
  static const routeName = '/physical-payment';

  late String? storeID;

  PhysicalPaymentScreen(this.storeID);

  @override
  State<PhysicalPaymentScreen> createState() => _PhysicalPaymentScreenState();
}

class _PhysicalPaymentScreenState extends State<PhysicalPaymentScreen> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) => WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: constraints.maxHeight * 0.1,
              automaticallyImplyLeading: false,
              leading: isLoading
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text("Physical Payment"),
              ),
            ),
            body: Container(
              height: constraints.maxHeight * 0.85,
              width: constraints.maxWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PaymentCard(
                      widget.storeID, () => setState(() => isLoading = true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatefulWidget {
  final String? storeID;
  VoidCallback onLoading;

  PaymentCard(this.storeID, this.onLoading);

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  final cashbackController = TextEditingController();
  final amountController = TextEditingController();
  late bool _isLoading = false;
  late String userName;
  var _cashback;

  String dropdownvalue = '';

  List<Tuple2<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    final user = Provider.of<User>(context, listen: false);
    userName = user.name!;
  }

  Future<void> initCreditAndCashback() async {
    String cb =
        await Provider.of<User>(context, listen: false).getEWalletBalance();
    _cashback = cb == "" ? 0.0 : double.parse(cb);

    Map<String, Map<String, dynamic>> creditCards =
        await Provider.of<User>(context, listen: false)
            .getUserCreditCardDetails();
    items = [];
    Secret secret =
        await SecretLoader(secretPath: "assets/secrets.json").load();
    creditCards.forEach((token, creditCard) {
      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, padding: null));
      encrypt.Encrypted enc =
          encrypt.Encrypted.fromBase16(creditCard['cardNumber']);
      String number = encrypter.decrypt(enc, iv: iv);
      DateTime expirationDate =
          new DateFormat('MM/yy').parse(creditCard['expiryDate']);
      if (DateTime.now().isBefore(expirationDate) &&
          !items
              .where((element) => element.item1 == token)
              .isNotEmpty) //not expired
      {
        items.add(Tuple2<String, String>(number.substring(15), token));
      }
    });
    dropdownvalue = items.isNotEmpty ? items.first.item2 : "";
    if (items.length == 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Missing Credit Card"),
            content: Text(
                "You have no credit cards available, please enter a credit card to proceed"),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(AddCreditCardScreen.routeName)
                      .then((_) => setState(() {}));
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      );
    }
  }

  Future<void> _makePayment(
      double totalPrice, CashbackSelection cashbackSelection) async {
    cashbackSelection.setTotalPrice(totalPrice);
    if (cashbackSelection.form.currentState == null ||
        cashbackSelection.form.currentState!.validate()) {
      setState(() => _isLoading = true);
      widget.onLoading();

      var res = await Provider.of<User>(context, listen: false)
          .makePaymentPhysicalStore(
              dropdownvalue,
              cashbackSelection.cashbackAmount,
              totalPrice - cashbackSelection.cashbackAmount,
              widget.storeID!);
      if (res.getTag()) {
        Navigator.of(context).pushReplacementNamed(
          InvoiceScreen.routeName,
          arguments: {
            'userName': userName,
            'purchaseDate': DateTime.now(),
            'cashbackAmount': cashbackSelection.cashbackAmount,
            'creditAmount': totalPrice - cashbackSelection.cashbackAmount
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Payment Error"),
            content: Text(res.getMessage().toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var cashbackSelection;
    var totalPrice;

    return FutureBuilder(
      future: initCreditAndCashback(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else {
          cashbackSelection = CashbackSelection(_cashback);
          return LayoutBuilder(
            builder: (context, constraints) => _isLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 8.0,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          width: constraints.maxWidth * 0.8,
                          padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.4),
                                Theme.of(context).primaryColor.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0, 1],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "AMOUNT TO PAY",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Purchase amount'),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: amountController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a value.';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Amount has be a number';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'Amount has be a positive number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value != "")
                                    totalPrice = double.parse(value);
                                  else
                                    totalPrice = 0;
                                },
                              ),
                              Divider(),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: constraints.maxWidth * 0.025,
                                    bottom: constraints.maxWidth * 0.025),
                                child: cashbackSelection,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: constraints.maxWidth * 0.025,
                                    bottom: constraints.maxWidth * 0.025),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                  width: constraints.maxWidth * 0.8,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(
                                          'CREDIT CARD',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: DropdownButton(
                                          value: dropdownvalue,
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down),
                                          items: items.map(
                                              (Tuple2<String, String> item) {
                                            return DropdownMenuItem(
                                              value: item.item2,
                                              child: Text("XXXX-XXXX-XXXX-" +
                                                  item.item1),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            dropdownvalue = newValue!;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth * 0.75,
                        padding:
                            EdgeInsets.only(top: constraints.maxWidth * 0.025),
                        child: ElevatedButton(
                          child: Text(
                            'Pay',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () =>
                              _makePayment(totalPrice, cashbackSelection),
                        ),
                      ),
                    ],
                  ),
          );
        }
      },
    );
  }
}
