import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';

class CreditCardsScreen extends StatefulWidget {
  static const routeName = '/credit-cards';

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenScreenState();
}

class _CreditCardsScreenScreenState extends State<CreditCardsScreen> {
  List<CreditCardWidget> activeCards = [];
  List<CreditCardWidget> disabledCards = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchCreditCards() async {
    activeCards = [];
    disabledCards = [];

    Map<String, Map<String, dynamic>> creditCards =
    await Provider.of<User>(context, listen: false)
        .getUserCreditCardDetails();
    Secret secret = await SecretLoader(secretPath: "secrets.json").load();
    creditCards.forEach((token, creditCard) {

       final key = encrypt.Key.fromUtf8(secret.KEY);
       final iv = encrypt.IV.fromUtf8(secret.IV);
       final encrypter = encrypt.Encrypter(encrypt.AES(key));
       encrypt.Encrypted enc = encrypt.Encrypted.fromUtf8(creditCard['cardNumber']);
       String number = encrypter.decrypt(enc, iv: iv);
      DateTime expirationDate =
      new DateFormat('MM/yy').parse(creditCard['expiryDate']);
      if (DateTime.now().isBefore(expirationDate)) //not expired
          {
            if(activeCards.firstWhereOrNull((e) => e.fourDigits == number.substring(15) && e.expiration == creditCard['expiryDate']) == null)
          activeCards.add(CreditCardWidget(
              creditCard['cardHolder'],
              number.substring(15),
              creditCard['expiryDate'],
              Colors.blue,
              token));
      } else {
        if(disabledCards.firstWhereOrNull((e) => e.fourDigits == number.substring(15) && e.expiration == creditCard['expiryDate']) == null)
          disabledCards.add(CreditCardWidget(
              creditCard['cardHolder'],
              number.substring(15),
              creditCard['expiryDate'],
              Colors.red,
              token));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: _fetchCreditCards(),
        builder: (BuildContext context, AsyncSnapshot snap) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Credit Cards"),
            actions: [
              IconButton(
                icon: Icon(
                  IconData(0xf04b7, fontFamily: 'MaterialIcons'),
                ),
                onPressed: () async {
                  await Navigator.of(context)
                      .pushReplacementNamed(AddCreditCardScreen.routeName);
                },
              ),
            ],
      ),
      body: snap.connectionState != ConnectionState.done
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          height: height,
          child: Column(
            children: [
              Container(
                height: height * 0.01,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Active",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              activeCards.isEmpty
                  ? SizedBox(height: height * 0.23)
                  : SizedBox(
                      height: height * 0.23,
                      child: GridView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(height * 0.025),
                        children: [
                          activeCards
                              .map(
                                (creditCard) => creditCard,
                              )
                              .toList(),
                        ].expand((i) => i).toList(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          childAspectRatio: 1 / 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                      ),
                    ),
              Divider(),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Disabled",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              disabledCards.isEmpty
                  ? SizedBox(height: height * 0.23)
                  : SizedBox(
                      height: height * 0.23,
                      child: GridView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(height * 0.025),
                        children: [
                          disabledCards
                              .map(
                                (creditCard) => creditCard,
                              )
                              .toList(),
                        ].expand((i) => i).toList(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
    });
  }
}

