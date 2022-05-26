import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../LogicLayer/Secret.dart';
import '../LogicLayer/SecretLoader.dart';
import '../models/UserModel.dart';

class CreditCardsScreen extends StatefulWidget {
  static const routeName = '/credit-cards';

  Widget wrapWithMaterial(List<NavigatorObserver> nav, UserModel user) {
    return MaterialApp(
      routes: {
        TabsScreen.routeName: (ctx) => TabsScreen().wrapWithMaterial(nav),
      },
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: User.fromModel(user),
          ),
        ],
        child: this,
      ),
      // This mocked observer will now receive all navigation events
      // that happen in our app.
      //navigatorObservers: nav,
    );
  }

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenScreenState();
}

class _CreditCardsScreenScreenState extends State<CreditCardsScreen> {
  List<CreditCardWidget> activeCards = [];
  List<CreditCardWidget> disabledCards = [];

  Future<void> _fetchCreditCards() async {
    activeCards = [];
    disabledCards = [];

    Map<String, Map<String, dynamic>> creditCards =
        await Provider.of<User>(context, listen: true)
            .getUserCreditCardDetails();
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
      if (DateTime.now().isBefore(expirationDate)) //not expired
      {
        if (activeCards.firstWhereOrNull((e) =>
                e.fourDigits == number.substring(15) &&
                e.expiration == creditCard['expiryDate']) ==
            null)
          activeCards.add(CreditCardWidget(
              creditCard['cardHolder'],
              number.substring(15),
              creditCard['expiryDate'],
              Colors.blue,
              token));
      } else {
        if (disabledCards.firstWhereOrNull((e) =>
                e.fourDigits == number.substring(15) &&
                e.expiration == creditCard['expiryDate']) ==
            null)
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
    return FutureBuilder(
        future: _fetchCreditCards(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          return LayoutBuilder(
            builder: (context, constraints) => WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: constraints.maxHeight * 0.1,
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Credit Cards",
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add_card),
                      onPressed: () async {
                        bool? res = await Navigator.of(context)
                            .pushNamed(AddCreditCardScreen.routeName) as bool?;
                        if (res != null && res) setState(() {});
                      },
                    ),
                  ],
                ),
                body: snap.connectionState != ConnectionState.done
                    ? Center(child: CircularProgressIndicator())
                    : activeCards.isEmpty && disabledCards.isEmpty
                        ? Container(
                            width: constraints.maxWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: constraints.maxWidth * 0.11,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.credit_card, size: 40),
                                    radius: constraints.maxWidth * 0.1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                      constraints.maxHeight * 0.01),
                                  child: Text("Credit Cards",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Text("You haven't saved any credit card yet"),
                                TextButton(
                                  onPressed: () async {
                                    bool? res = await Navigator.of(context)
                                            .pushNamed(
                                                AddCreditCardScreen.routeName)
                                        as bool?;
                                    if (res != null && res) setState(() {});
                                  },
                                  child: Text(
                                    "Click here to add one",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                activeCards.isEmpty
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.05,
                                                  top: constraints.maxHeight *
                                                      0.025),
                                              child: Text(
                                                "Active",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: constraints.maxHeight * 0.3,
                                            child: GridView.count(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.025,
                                                  right: constraints.maxWidth *
                                                      0.025),
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              crossAxisCount: 1,
                                              childAspectRatio: 0.825,
                                              crossAxisSpacing:
                                                  constraints.maxWidth * 0.025,
                                              children: activeCards,
                                            ),
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                disabledCards.isEmpty
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.05,
                                                  top: constraints.maxHeight *
                                                      0.025),
                                              child: Text(
                                                "Disabled",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: constraints.maxHeight * 0.3,
                                            child: GridView.count(
                                              padding: EdgeInsets.only(
                                                  left: constraints.maxWidth *
                                                      0.025,
                                                  right: constraints.maxWidth *
                                                      0.025),
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              crossAxisCount: 1,
                                              childAspectRatio: 0.825,
                                              crossAxisSpacing:
                                                  constraints.maxWidth * 0.025,
                                              children: disabledCards,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
              ),
            ),
          );
        });
  }
}
