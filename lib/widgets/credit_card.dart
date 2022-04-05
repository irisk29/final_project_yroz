import 'package:final_project_yroz/LogicLayer/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreditCardWidget extends StatelessWidget {
  final String name;
  final String fourDigits;
  final String expiration;
  final Color color;
  final String token;

  CreditCardWidget(
      this.name, this.fourDigits, this.expiration, this.color, this.token);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: GestureDetector(
          key: Key(fourDigits),
          onLongPress: () async {
            return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Are you sure?'),
                content: Text(
                  'You are about to remove your credit card, do you want to do so?',
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                  FlatButton(
                    key: const Key("yes"),
                    child: Text('Yes'),
                    onPressed: () async {
                      await Provider.of<User>(context, listen: false)
                          .removeCreditCardToken(this.token);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          },
          child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight * 0.75,
              child: Card(
                color: color,
                elevation: 3,
                child: Stack(children: <Widget>[
                  Positioned(
                      top: constraints.maxHeight * 0.225,
                      left: constraints.maxWidth * 0.075,
                      child: Image.asset("assets/images/chip1.png")),
                  Positioned(
                      top: constraints.maxHeight * 0.2,
                      left: constraints.maxWidth * 0.5,
                      child: Text(
                        '••••  ${fourDigits}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Color.fromRGBO(10, 113, 119, 1),
                            fontSize: 18,
                            height: 2),
                      )),
                  Positioned(
                      top: constraints.maxHeight * 0.5,
                      left: constraints.maxWidth * 0.1,
                      child: Text(
                        '$name',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(20, 19, 42, 1), height: 1.5),
                      )),
                  Positioned(
                      top: constraints.maxHeight * 0.075,
                      left: constraints.maxWidth * 0.725,
                      child: Text(
                        '$expiration',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Color.fromRGBO(10, 113, 119, 1),
                            fontSize: 14,
                            height: 1.5),
                      )),
                  Positioned(
                      top: constraints.maxHeight * 0.21,
                      left: constraints.maxWidth * 0.26,
                      child: Image.asset("assets/images/nfc1.png")),
                  Positioned(
                      top: constraints.maxHeight * 0.425,
                      left: constraints.maxWidth * 0.65,
                      child: Image.asset("assets/images/visa1.png")),
                ]),
              )),
        ),
      ),
    );
  }
}
