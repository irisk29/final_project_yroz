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
    return Center(
      child: GestureDetector(
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
            width: 240,
            height: 150,
            child: Card(
              color: color,
              elevation: 3,
              child: Stack(children: <Widget>[
                Positioned(
                    top: 45,
                    left: 20,
                    child: Image.asset("assets/images/chip1.png")),
                Positioned(
                    top: 35,
                    left: 120,
                    child: Text(
                      '••••  ${fourDigits}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Color.fromRGBO(10, 113, 119, 1),
                          fontSize: 18,
                          height: 2),
                    )),
                Positioned(
                    top: 100,
                    left: 20,
                    child: Text(
                      '$name',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(20, 19, 42, 1), height: 1.5),
                    )),
                Positioned(
                    top: 5,
                    left: 170,
                    child: Text(
                      '$expiration',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Color.fromRGBO(10, 113, 119, 1),
                          fontSize: 14,
                          height: 1.5),
                    )),
                Positioned(
                    top: 42,
                    left: 70,
                    child: Image.asset("assets/images/nfc1.png")),
                Positioned(
                    top: 90,
                    left: 160,
                    child: Image.asset("assets/images/visa1.png")),
              ]),
            )),
      ),
    );
  }
}
