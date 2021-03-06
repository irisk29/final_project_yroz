import 'package:final_project_yroz/DTOs/ShoppingBagDTO.dart';
import 'package:final_project_yroz/screens/tabs_screen.dart';
import 'package:final_project_yroz/widgets/invoice_content_cliper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceScreen extends StatelessWidget {
  static const routeName = '/invoice';

  late String userName;
  late DateTime purchaseDate;
  late ShoppingBagDTO? shoppingBag;
  late double cashbackAmount;
  late double creditAmount;

  InvoiceScreen(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    userName = routeArgs['userName'] as String;
    purchaseDate = routeArgs['purchaseDate'] as DateTime;
    shoppingBag = routeArgs['shoppingBag'] as ShoppingBagDTO?;
    cashbackAmount = routeArgs['cashbackAmount'] as double;
    creditAmount = routeArgs['creditAmount'] as double;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: EdgeInsets.only(
                bottom: constraints.maxHeight * 0.02,
                top: constraints.maxHeight * 0.02,
                left: constraints.maxWidth * 0.02,
                right: constraints.maxWidth * 0.02),
            child: ClipPath(
              clipper: InvoiceContentCliper(),
              child: Stack(
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
                  Padding(
                    padding: EdgeInsets.only(
                        left: constraints.maxWidth * 0.05,
                        right: constraints.maxWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: constraints.maxHeight * 0.05,
                            bottom: constraints.maxHeight * 0.04,
                          ),
                          child: Container(
                            child: ListTile(
                              leading: Image.asset('assets/icon/icon.png'),
                              title: Text(
                                "INVOICE",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: constraints.maxHeight * 0.02),
                                child: Text(
                                  userName,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Text(
                                "Purchase Date: " +
                                    DateFormat('dd/MM/yyyy')
                                        .format(purchaseDate),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: constraints.maxHeight * 0.05),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: constraints.maxWidth * 0.3,
                                          child: Text("Product"),
                                        ),
                                        Container(
                                          width: constraints.maxWidth * 0.13,
                                          child: Text("Price"),
                                        ),
                                        Container(
                                          width: constraints.maxWidth * 0.18,
                                          child: Text("Amount"),
                                        ),
                                        Text("Subtotal"),
                                      ],
                                    ),
                                    Divider(height: 0),
                                    shoppingBag != null
                                        ? ConstrainedBox(
                                            constraints: new BoxConstraints(
                                              minHeight:
                                                  constraints.maxHeight * 0.3,
                                              maxHeight:
                                                  constraints.maxHeight * 0.3,
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  shoppingBag!.products.length,
                                              itemBuilder: (context, index) {
                                                final product = shoppingBag!
                                                    .products[index];
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: constraints
                                                              .maxHeight *
                                                          0.02),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.3,
                                                          child: Text(
                                                              product.name)),
                                                      Container(
                                                        width: constraints
                                                                .maxWidth *
                                                            0.14,
                                                        child: Text("\???" +
                                                            product.price
                                                                .toStringAsFixed(
                                                                    2)),
                                                      ),
                                                      Container(
                                                        width: constraints
                                                                .maxWidth *
                                                            0.18,
                                                        child: Text(product
                                                            .amount
                                                            .toInt()
                                                            .toString()),
                                                      ),
                                                      (product.price *
                                                                      product
                                                                          .amount)
                                                                  .toStringAsFixed(
                                                                      2)
                                                                  .length >
                                                              9
                                                          ? Text("\???" +
                                                              (product.price *
                                                                      product
                                                                          .amount)
                                                                  .toStringAsExponential(
                                                                      2))
                                                          : Text("\???" +
                                                              (product.price *
                                                                      product
                                                                          .amount)
                                                                  .toStringAsFixed(
                                                                      2)),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : ConstrainedBox(
                                            constraints: new BoxConstraints(
                                              minHeight:
                                                  constraints.maxHeight * 0.3,
                                              maxHeight:
                                                  constraints.maxHeight * 0.3,
                                            ),
                                            child: Center(
                                              child:
                                                  Text("No Products Details"),
                                            ),
                                          ),
                                    Container(
                                      width: constraints.maxWidth * 0.5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: constraints.maxHeight *
                                                    0.01),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Cashback Amount",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "\???" +
                                                        cashbackAmount
                                                            .toStringAsFixed(2),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: constraints.maxHeight *
                                                    0.01),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Credit Amount",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                creditAmount
                                                            .toStringAsFixed(2)
                                                            .length >
                                                        9
                                                    ? Text(
                                                        "\???" +
                                                            creditAmount
                                                                .toStringAsExponential(
                                                                    2),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    : Text(
                                                        "\???" +
                                                            creditAmount
                                                                .toStringAsFixed(
                                                                    2),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: constraints.maxHeight *
                                                    0.01),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("TOTAL",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                (cashbackAmount + creditAmount)
                                                            .toStringAsFixed(2)
                                                            .length >
                                                        9
                                                    ? Text(
                                                        "\???" +
                                                            (cashbackAmount +
                                                                    creditAmount)
                                                                .toStringAsExponential(
                                                                    2),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    : Text(
                                                        "\???" +
                                                            (cashbackAmount +
                                                                    creditAmount)
                                                                .toStringAsFixed(
                                                                    2),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * 0.2,
                        color: Colors.white38,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: constraints.maxHeight * 0.025,
                              left: constraints.maxWidth * 0.075,
                              right: constraints.maxWidth * 0.075),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "RECIVED CASHBACK",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "TOTAL",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              Divider(thickness: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\???" +
                                        (creditAmount * 0.07)
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    "\???" +
                                        (cashbackAmount + creditAmount)
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              Divider(thickness: 1),
                              Text(
                                "Thank you!",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => false);
                          Navigator.of(context).pushNamed(
                            TabsScreen.routeName,
                            arguments: {'index': 4},
                          );
                        },
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(5),
                          primary: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
