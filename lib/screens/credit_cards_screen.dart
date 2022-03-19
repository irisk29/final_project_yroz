import 'package:collection/src/iterable_extensions.dart';
import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    () async {
      activeCards = [];
      disabledCards = [];

      Map<String, Map<String, dynamic>> creditCards =
          await Provider.of<User>(context, listen: true)
              .getUserCreditCardDetails();
      creditCards.forEach((token, creditCard) {
        DateTime expirationDate =
            new DateFormat('MM/yy').parse(creditCard['expiryDate']);
        if (DateTime.now().isBefore(expirationDate)) //not expired
        {
          if(activeCards.firstWhereOrNull((e) => e.fourDigits == creditCard['cardNumber'].toString().substring(15)) == null)
            activeCards.add(CreditCardWidget(
                creditCard['cardHolder'],
                creditCard['cardNumber'].toString().substring(15),
                creditCard['expiryDate'],
                Colors.blue,
                token));
        } else {
          if(disabledCards.firstWhereOrNull((e) => e.fourDigits == creditCard['cardNumber'].toString().substring(15)) == null)
            disabledCards.add(CreditCardWidget(
              creditCard['cardHolder'],
              creditCard['cardNumber'].toString().substring(15),
              creditCard['expiryDate'],
              Colors.red,
              token));
        }
      });
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
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
                  .pushNamed(AddCreditCardScreen.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
  }
}
