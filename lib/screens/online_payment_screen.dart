import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/widgets/cashback_selection.dart';
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        appBar: AppBar(
          toolbarHeight: constraints.maxHeight * 0.1,
          title: Text(
            'Payment',
            style: const TextStyle(fontSize: 22),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
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
            ),
            SingleChildScrollView(
              child: Container(
                height: constraints.maxHeight / 1.3,
                width: constraints.maxWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: constraints.maxWidth > 600 ? 2 : 1,
                      child: PaymentCard(widget.storeID),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  AnimationController? _controller;
  var _cashback;
  String dropdownvalue = '';
  List<Tuple2<String, String>> items = [];
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    widget.bag = Provider.of<User>(context, listen: false)
        .getShoppingBag(widget.storeID!);
  }

  Future<void> initCreditAndCashback() async {
    String cb =
        await Provider.of<User>(context, listen: false).getEWalletBalance();
    _cashback = double.parse(cb);

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
        barrierDismissible: false,
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
      );
    }
  }

  Future<void> _makePayment(
      double totalPrice, CashbackSelection cashbackSelection) async {
    setState(() => _isLoading = true);

    if (cashbackSelection.form.currentState == null ||
        cashbackSelection.form.currentState!.validate()) {
      var res = await Provider.of<User>(context, listen: false)
          .makePaymentOnlineStore(
              dropdownvalue,
              cashbackSelection.cashbackAmount,
              totalPrice - cashbackSelection.cashbackAmount,
              widget.bag!);
      if (!res.getTag()) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occured!"),
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

      Navigator.of(context).pop();
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.bag!.calculateTotalPrice();
    var cashbackSelection;

    return FutureBuilder(
      future: initCreditAndCashback(),
      builder: (BuildContext context, AsyncSnapshot snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        } else {
          cashbackSelection = CashbackSelection(_cashback);
          return LayoutBuilder(
            builder: (context, constraints) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 8.0,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          width: constraints.maxWidth * 0.8,
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "PURCHASE AMOUNT",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "\€${totalPrice.toString()}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: cashbackSelection,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
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
                                            fontWeight: FontWeight.w500,
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
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    child: Text(
                      'Pay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
