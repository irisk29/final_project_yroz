import 'dart:convert';

import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/credit_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';

class OnlinePaymentScreen extends StatefulWidget {
  static const routeName = '/online-payment';

  late String? storeID;

  OnlinePaymentScreen(this.storeID);

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  @override
  void didChangeDependencies() {}

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Store Payment"),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(243, 90, 106, 1.0).withOpacity(0.5),
                  Color.fromRGBO(243, 90, 106, 1.0).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height / 1.3,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: PaymentCard(widget.storeID),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCard extends StatefulWidget {
  String? storeID;
  late ShoppingBagDTO? bag;

  PaymentCard(this.storeID);

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  AnimationController? _controller;
  final myController = TextEditingController();
  final _initValues = {
    'cashback': 0.0,
  };

  String dropdownvalue = '';

  List<Tuple2<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    initCashBack();
    widget.bag = Provider.of<User>(context, listen: false)
        .getShoppingBag(widget.storeID!);
  }

  @override
  void didChangeDependencies() {
    () async {
      setState(() {
        widget.bag = Provider.of<User>(context, listen: false)
            .getShoppingBag(widget.storeID!);
        // Update your UI with the desired changes.
      });
    }();
    super.didChangeDependencies();
  }

  Future<void> activeCreditCards() async {
    Map<String, Map<String, dynamic>> creditCards =
        await Provider.of<User>(context, listen: false)
            .getUserCreditCardDetails();
    items = [];
    Secret secret =
        await SecretLoader(secretPath: "assets/secrets.json").load();
    creditCards.forEach((token, creditCard) {
      final key = encrypt.Key.fromUtf8(secret.KEY);
      final iv = encrypt.IV.fromUtf8(secret.IV);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
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
          builder: (ctx) => AlertDialog(
                title: Text("Missing Credit Card"),
                content: Text(
                    "You have no credit cards available, please enter a credit card to proceed"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushReplacementNamed(CreditCardsScreen.routeName);
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
              ));
    }
  }

  void initCashBack() async {
    String cb =
        await Provider.of<User>(context, listen: false).getEWalletBalance();
    _initValues['cashback'] = double.parse(cb);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double cashback = 0.0;
    widget.bag = Provider.of<User>(context, listen: false)
        .getShoppingBag(widget.storeID!);

    return FutureBuilder(
        future: activeCreditCards(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          return snap.connectionState != ConnectionState.done
              ? Center(child: CircularProgressIndicator())
              : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 8.0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    height: 320,
                    constraints: BoxConstraints(minHeight: 320),
                    width: deviceSize.width * 0.75,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                            "Purchase amount: ${widget.bag!.calculateTotalPrice().toString()}",
                            style:
                                TextStyle(color: Colors.black, fontSize: 20.0)),
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(Icons.payments_outlined),
                              ),
                              TextSpan(
                                  text: "Cashback available: " +
                                      _initValues['cashback'].toString(),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16.0)),
                            ],
                          ),
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Cashback to use'),
                          keyboardType: TextInputType.number,
                          controller: myController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a number.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              if (value != "")
                                cashback = double.parse(value);
                              else
                                cashback = 0;
                            });
                          },
                        ),
                        Text("\nChoose Credit Card to pay with:"),
                        DropdownButton(
                          value: dropdownvalue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: items.map((Tuple2<String, String> item) {
                            return DropdownMenuItem(
                              value: item.item2,
                              child: Text(item.item1),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue!;
                            });
                          },
                        ),
                        Text('Amount left to pay: ' +
                            (widget.bag!.calculateTotalPrice() -
                                    (myController.text.length > 0
                                        ? double.parse(myController.text)
                                        : 0))
                                .toString()),
                        FlatButton(
                          child: Text('Confirm Amount'),
                          onPressed: () async {
                            var res =
                                await Provider.of<User>(context, listen: false)
                                    .makePaymentOnlineStore(
                                        dropdownvalue,
                                        cashback.toString(),
                                        (widget.bag!.calculateTotalPrice() -
                                                (myController.text.length > 0
                                                    ? double.parse(
                                                        myController.text)
                                                    : 0.0))
                                            .toString(),
                                        widget.bag!);
                            AlertDialog(
                              title: Text(res.getTag()
                                  ? "Congratulations!"
                                  : "An error occured!"),
                              content: Text(res.getMessage().toString()),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Okay'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                );
        });
  }
}
