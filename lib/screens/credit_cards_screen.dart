import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:final_project_yroz/screens/add_credit_card_screen.dart';
import 'package:final_project_yroz/widgets/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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
      for (Tuple2<String, bool> store
          in Provider.of<User>(context, listen: true).favoriteStores) {}
      setState(() {
        // Update your UI with the desired changes.
      });
    }();

    () async {
      disabledCards = [];
      for (String product
          in Provider.of<User>(context, listen: true).favoriteProducts) {}
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
            onPressed: () {
              Navigator.of(context).pushNamed(AddCreditCardScreen.routeName);
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
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 1,
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
