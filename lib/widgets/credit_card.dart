import 'package:flutter/material.dart';


class CreditCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
            width: 240,
            height: 150,
            child: Card(
              color: Colors.green,
              elevation: 3,
              child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: 45,
                        left: 20,
                        child: Image.asset("assets/images/chip1.png")
                    ),Positioned(
                        top: 35,
                        left: 120,
                        child: Text('••••  6789', textAlign: TextAlign.right, style: TextStyle(
                            color: Color.fromRGBO(10, 113, 119, 1),
                            fontSize: 18,
                            height: 2
                        ),)
                    ),Positioned(
                        top: 100,
                        left: 20,
                        child: Text('Jane Walker', textAlign: TextAlign.left, style: TextStyle(
                            color: Color.fromRGBO(20, 19, 42, 1),
                            height: 1.5
                        ),)
                    ),Positioned(
                        top: 5,
                        left: 170,
                        child: Text('Debit', textAlign: TextAlign.right, style: TextStyle(
                            color: Color.fromRGBO(10, 113, 119, 1),
                            fontSize: 14,
                            height: 1.5
                        ),)
                    ),Positioned(
                        top: 42,
                        left: 70,
                        child: Image.asset("assets/images/nfc1.png")
                    ),Positioned(
                        top: 90,
                        left: 160,
                        child: Image.asset("assets/images/visa1.png")
                    ),
                  ]
              ),
            )
        ),
    );
  }
}
