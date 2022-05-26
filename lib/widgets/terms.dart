import 'package:flutter/material.dart';

class Terms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(
          "Terms",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Policy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text("Opening store will allow you to advertise your business. That means that the application consumers will be able to purchase in your store. In any such purchase, the consumer, payment company and yroz will receive up to 10% of the purchase price, so that you will receive the rest 90%.\n" +
                "You can determine the product's prices as you wish and according to your business considerations.\n\nI have read and accept terms and conditions.")
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Agree"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          )
        ],
      ),
    );
  }
}
